# AgentSettle — demo video script (~2 minutes)

Setup: open `index.html` in a browser, full screen. Start on the header so the chain-status panel is visible. Total target: 1:50–2:10.

---

**0:00–0:15 — The hook**
- Show: the page header and tagline.
- Say: "AI agents are starting to hire each other — but agents can't open bank accounts, and they can't trust strangers. AgentSettle fixes that: escrow on HashKey Chain is their trust layer, and HSP is how they settle. This is AgentSettle, for the Agent Payments and A2A Settlement track."

**0:15–0:30 — It's really on HashKey Chain**
- Show: point at the chain-status panel (live network, chain ID, block number).
- Say: "The demo checks the real HashKey RPCs live — mainnet, chainId 177, is the deployment target, testnet 133 is for testing. Everything below the line is a simulation of the contract logic, and it's labelled that way — honestly, no fake connections."

**0:30–0:50 — Post and accept the job**
- Click: **1 · Post job** (title already reads "Research 3 new airdrop farms and report back", price 2.5 tHSK), then **2 · Worker accepts**.
- Say: "A Buyer Agent posts a real job — research three new airdrop farms — priced at 2.5 tHSK. The Worker Agent reviews the terms and accepts. On-chain, that's `createJob` in AgentEscrow.sol."

**0:50–1:05 — Fund the escrow**
- Click: **3 · Fund escrow**. Point at the buyer balance dropping and the escrow card showing Funded.
- Say: "The buyer locks the payment in escrow before any work starts. The worker can see the money exists; the buyer knows it can't move without approval. That's the whole trust problem, solved by the contract."

**1:05–1:25 — Delivery**
- Click: **4 · Worker delivers report**. Show the sample report and its hash.
- Say: "The worker delivers the research report and stores its hash on-chain with `submitDelivery`. The work is provable, timestamped, and tied to this job."

**1:25–1:50 — Approve, HSP settles, reputation grows**
- Click: **5 · Approve & release**. Slow down on the log as the HSP lines appear.
- Say: "The buyer approves — and settlement runs over HSP, HashKey's agent payment protocol: `createPayment`, `getPaymentStatus`, completed. Watch the balances: the worker is paid, and both agents gain reputation — plus one completed job each, stored on-chain. Next time anyone hires them, that record is public. In this demo the HSP calls are simulated; live settlement with a registered merchant wallet is the next step."

**1:50–2:00 — The safety net + close**
- Show: point at the refund button / contract panel; mention the mainnet deploy panel if there's time.
- Say: "And if a job stalls, the contract has deadline paths — refunds for undelivered jobs, claims for ghosted workers. The contract deploys to HashKey mainnet, chainId 177 — the runbook is in the README. AgentSettle: agents can't use banks, so we gave them an escrow, a payment rail, and a credit score. Thank you."

---

Fallbacks while recording:
- If the chain panel says "Simulation mode", that's fine — say the line from 0:15 anyway and note the demo degrades honestly when RPCs are unreachable.
- If you run long, cut the safety-net section to one sentence; never cut the HSP settlement moment at 1:25.
