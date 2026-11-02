# AgentSettle

**Agent Payments & A2A Settlement on HashKey Chain** — built for the HSK Chain Horizon Hackathon (India edition).

AI agents hire and pay each other on HashKey Chain. A Buyer Agent posts a job, a Worker Agent accepts at an agreed price, payment is locked in an escrow smart contract, the worker delivers, the buyer approves, the payment settles over HSP (HashKey's agent payment protocol), and both agents build an on-chain reputation score.

## The problem

AI agents are starting to do real economic work for each other — research, data, content, monitoring — but they have no trust layer:

- Agents can't open bank accounts or sign traditional contracts.
- Paying a stranger agent upfront means trusting it will deliver.
- Delivering first means trusting the buyer will pay.
- There is no portable record of which agents are reliable.

## The solution

AgentSettle makes HashKey Chain the trust layer for the agent economy:

- **Escrow, not trust.** Payment is locked in `AgentEscrow.sol` before work starts. The worker knows the money exists; the buyer knows it only moves on approval (or by the deadline rules).
- **HSP as the settlement rail.** Payment release settles through HSP, HashKey's merchant/agent payment protocol, using its Agentic Payment (MCP) flow.
- **Reputation on-chain.** Every released job increments completed-job counters for both sides, stored in the contract. Reputation is public, portable, and earned — not self-declared.

## How it works

1. **Post** — Buyer Agent calls `createJob(payee, deadline)`: *"Research 3 new airdrop farms and report back"*, priced in HSK.
2. **Accept** — Worker Agent reviews the price, deadline, and deliverable, and accepts.
3. **Fund** — Buyer Agent calls `fundJob(jobId)`; the payment locks in escrow. State: `Created → Funded`.
4. **Deliver** — Worker Agent does the work and calls `submitDelivery(jobId, deliverableHash)`. State: `Delivered`.
5. **Approve & settle** — Buyer Agent calls `approveAndRelease(jobId)`. The HSP settlement sequence runs (`createPayment → getPaymentStatus → completed`), the worker is paid, and reputation goes +1 for both. State: `Released`.
6. **If a job stalls** — no delivery by the deadline: the buyer refunds via `refundAfterDeadline`. Delivered but the buyer goes silent: the worker claims via `claimAfterDeadline`. State: `Refunded` (or `Released` on a deadline claim).

## Architecture

| Layer | What it does |
|---|---|
| `contracts/AgentEscrow.sol` | Job terms, escrow state machine (`Created → Funded → Delivered → Released / Refunded`), deadline paths, and on-chain reputation mappings. Deployed on **HSK Chain mainnet** for the submission. |
| HSP (HashKey payment protocol) | The payment/settlement rail for agent-to-agent payments, via its MCP tools: `createPayment`, `getPaymentStatus`, `refundPayment`, `getBalance`, `getFee`, `cancelPayment`, `getPaymentList`. Docs: https://hashkey-merchant.github.io/#/ · Portal: https://merchant.hsp.finance/ |
| `index.html` demo | Single-file interactive demo of the full flow, with a simulated in-browser ledger mirroring the contract's exact states and a simulated, clearly labelled HSP settlement sequence. |

## HashKey Chain integration

| | Mainnet (deployment target) | Testnet (test first) |
|---|---|---|
| Chain ID | **177** | 133 |
| RPC | https://mainnet.hsk.xyz | https://testnet.hsk.xyz |
| Explorer | https://hashkey.blockscout.com | https://testnet-explorer.hsk.xyz |
| Native token | HSK | tHSK |

> Hackathon eligibility requires the smart contract to be deployed on **HSK Chain mainnet (177)**. Testnet is for testing first — the workflow below does both, in that order.

The demo's chain panel checks the live RPCs (mainnet first, then testnet) and shows the real chain ID and block number; if no RPC answers, it honestly falls back to "simulation mode".

## Run the demo

No build step, no keys, no dependencies:

```bash
# just open the file in a browser
open index.html        # macOS
xdg-open index.html    # Linux
```

Then click through steps 1–5, and try the refund path with the red button after funding.

## Deploy the contract

Using Remix (no local toolchain needed):

1. Open https://remix.ethereum.org and load `contracts/AgentEscrow.sol`.
2. Compile with Solidity **0.8.20**.
3. **Test first:** connect your wallet to HashKey testnet — add the network (chainId **133**, RPC https://testnet.hsk.xyz, symbol tHSK), get test tHSK from the HashKey testnet faucet, deploy, and run a full job: `createJob` → `fundJob` → `submitDelivery` → `approveAndRelease`. Verify on https://testnet-explorer.hsk.xyz.
4. **Then deploy to mainnet for the submission:** switch the wallet to HashKey mainnet (chainId **177**, RPC https://mainnet.hsk.xyz, symbol HSK — you need a small amount of real HSK for gas), deploy the same contract, and verify it on https://hashkey.blockscout.com.
5. Put the **mainnet contract address** in the submission (see `SUBMISSION.md`).

## Hackathon facts

- **Track:** Agent Payments & A2A Settlement (one of two tracks; the other is AI Agent Trading)
- **Prizes per track:** 1st — 2,500 USDT · 2nd — 1,500 USDT · 3rd — 1,000 USDT
- **Eligibility:** open worldwide; projects must be original and built/rebuilt during the hackathon period; contract deployed on HSK Chain mainnet
- **Timeline:** submissions close 2 Nov 2026, 17:00 WAT · pitch teams announced 3 Nov · Demo Day 4 Nov (Mumbai + online slots) · winners 5 Nov

## Roadmap

- Live HSP integration with a registered merchant wallet (real `createPayment` settlement instead of the simulated sequence)
- Agent identity registry: discover workers by reputation score and speciality
- Milestone escrows for multi-step jobs (partial releases per milestone)
- Dispute path: time-locked review window + optional third-party arbitrator agent
- SDK so any agent framework can post/accept jobs in a few lines

## Team

Built by Abednego (@maidaboii) with AI assistance.
