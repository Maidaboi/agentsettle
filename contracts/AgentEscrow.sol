// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AgentEscrow
/// @notice Escrow for agent-to-agent (A2A) jobs on HashKey Chain.
///         A payer (buyer agent) posts a job for a payee (worker agent) and
///         locks payment in this contract. The payee submits a deliverable
///         hash, the payer approves, and the escrow releases payment.
///         On release, both sides gain on-chain reputation (completed-job
///         counters). If the job stalls, deadline paths refund the payer or
///         let a payee who already delivered claim payment.
contract AgentEscrow {
    enum JobStatus {
        Created,    // job posted, not yet funded
        Funded,     // payment locked in escrow
        Delivered,  // payee submitted a deliverable hash
        Released,   // payment released to payee (terminal)
        Refunded    // payment returned to payer (terminal)
    }

    struct Job {
        address payer;
        address payee;
        uint256 amount;
        uint256 deadline; // unix timestamp
        JobStatus status;
        string deliverableHash;
    }

    uint256 public nextJobId = 1;

    mapping(uint256 => Job) public jobs;

    /// @notice Reputation: jobs completed (paid out) per address, by role.
    mapping(address => uint256) public completedJobsAsPayee;
    mapping(address => uint256) public completedJobsAsPayer;

    /// @notice Simple combined reputation score: +1 per completed job on
    ///         either side of a released escrow.
    mapping(address => uint256) public reputation;

    event JobCreated(uint256 indexed jobId, address indexed payer, address indexed payee, uint256 deadline);
    event JobFunded(uint256 indexed jobId, uint256 amount);
    event DeliverySubmitted(uint256 indexed jobId, string deliverableHash);
    event PaymentReleased(uint256 indexed jobId, address indexed payee, uint256 amount);
    event JobRefunded(uint256 indexed jobId, address indexed payer, uint256 amount);
    event DeadlineClaimed(uint256 indexed jobId, address indexed payee, uint256 amount);

    modifier onlyPayer(uint256 jobId) {
        require(msg.sender == jobs[jobId].payer, "not payer");
        _;
    }

    modifier onlyPayee(uint256 jobId) {
        require(msg.sender == jobs[jobId].payee, "not payee");
        _;
    }

    /// @notice Post a job. Send tHSK/HSK with the call to fund it immediately,
    ///         or send 0 and fund later with fundJob().
    /// @param payee    The worker agent that will do the job.
    /// @param deadline Unix timestamp by which the job should be delivered.
    /// @return jobId   The new job's id.
    function createJob(address payee, uint256 deadline) external payable returns (uint256 jobId) {
        require(payee != address(0), "payee is zero address");
        require(payee != msg.sender, "payee cannot be payer");
        require(deadline > block.timestamp, "deadline in the past");

        jobId = nextJobId++;
        Job storage job = jobs[jobId];
        job.payer = msg.sender;
        job.payee = payee;
        job.amount = msg.value;
        job.deadline = deadline;
        job.status = msg.value > 0 ? JobStatus.Funded : JobStatus.Created;

        emit JobCreated(jobId, msg.sender, payee, deadline);
        if (msg.value > 0) {
            emit JobFunded(jobId, msg.value);
        }
    }

    /// @notice Fund a job that was created without payment.
    function fundJob(uint256 jobId) external payable onlyPayer(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == JobStatus.Created, "job not awaiting funding");
        require(msg.value > 0, "no value sent");

        job.amount = msg.value;
        job.status = JobStatus.Funded;

        emit JobFunded(jobId, msg.value);
    }

    /// @notice Payee submits the deliverable (an IPFS/content hash or URL hash).
    function submitDelivery(uint256 jobId, string calldata deliverableHash) external onlyPayee(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == JobStatus.Funded, "job not funded");
        require(bytes(deliverableHash).length > 0, "empty deliverable hash");

        job.deliverableHash = deliverableHash;
        job.status = JobStatus.Delivered;

        emit DeliverySubmitted(jobId, deliverableHash);
    }

    /// @notice Payer approves the delivery; escrow releases payment to the
    ///         payee and both sides gain reputation.
    function approveAndRelease(uint256 jobId) external onlyPayer(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == JobStatus.Delivered, "job not delivered");

        _release(jobId, job);
        emit PaymentReleased(jobId, job.payee, job.amount);
    }

    /// @notice If the payee delivered but the payer never approved, the payee
    ///         can claim payment after the deadline passes.
    function claimAfterDeadline(uint256 jobId) external onlyPayee(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == JobStatus.Delivered, "job not delivered");
        require(block.timestamp > job.deadline, "deadline not passed");

        _release(jobId, job);
        emit DeadlineClaimed(jobId, job.payee, job.amount);
    }

    /// @notice If nothing was delivered by the deadline, the payer can take
    ///         the escrowed payment back.
    function refundAfterDeadline(uint256 jobId) external onlyPayer(jobId) {
        Job storage job = jobs[jobId];
        require(
            job.status == JobStatus.Created || job.status == JobStatus.Funded,
            "job already delivered or closed"
        );
        require(block.timestamp > job.deadline, "deadline not passed");

        _refund(jobId, job);
    }

    /// @dev Shared release path. All state changes (status + reputation)
    ///      happen BEFORE the external transfer (checks-effects-interactions).
    function _release(uint256 jobId, Job storage job) internal {
        uint256 amount = job.amount;
        address payee = job.payee;
        address payer = job.payer;

        job.amount = 0;
        job.status = JobStatus.Released;

        completedJobsAsPayee[payee] += 1;
        completedJobsAsPayer[payer] += 1;
        reputation[payee] += 1;
        reputation[payer] += 1;

        if (amount > 0) {
            (bool ok, ) = payable(payee).call{value: amount}("");
            require(ok, "transfer to payee failed");
        }
        // jobId is referenced by callers' events; silence unused warning path.
        jobId;
    }

    /// @dev Shared refund path. State is closed before any transfer.
    function _refund(uint256 jobId, Job storage job) internal {
        uint256 amount = job.amount;
        address payer = job.payer;

        job.amount = 0;
        job.status = JobStatus.Refunded;

        emit JobRefunded(jobId, payer, amount);

        if (amount > 0) {
            (bool ok, ) = payable(payer).call{value: amount}("");
            require(ok, "refund transfer failed");
        }
    }

    /// @notice Convenience getter for a job's full record.
    function getJob(uint256 jobId)
        external
        view
        returns (
            address payer,
            address payee,
            uint256 amount,
            uint256 deadline,
            JobStatus status,
            string memory deliverableHash
        )
    {
        Job storage job = jobs[jobId];
        return (job.payer, job.payee, job.amount, job.deadline, job.status, job.deliverableHash);
    }
}
