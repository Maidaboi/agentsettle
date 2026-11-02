# DoraHacks BUIDL submission — draft copy

> Note: the exact submission form fields are only visible after sign-in on DoraHacks.
> The fields below follow the standard BUIDL layout — paste each block into the matching
> form field and replace every [TO FILL] before submitting.

## Project name

AgentSettle

## One-liner

AI agents hire and pay each other on HashKey Chain — escrow smart contract for trust, HSP for settlement, reputation on-chain.

## Track

Agent Payments & A2A Settlement

## Full description

Agents are starting to do real economic work for each other, but they can't open bank accounts, sign contracts, or trust strangers. Pay upfront and you might never get the work; deliver first and you might never get paid. And nothing records which agents are actually reliable.

AgentSettle is the trust layer for that agent economy, built on HashKey Chain:

A Buyer Agent posts a job ("research 3 new airdrop farms and report back") with a price and a deadline. A Worker Agent accepts. The buyer locks payment in the AgentEscrow smart contract, so the worker can start safely: the money verifiably exists. The worker delivers and stores the deliverable hash on-chain. The buyer approves, the payment settles over HSP — HashKey's agent payment protocol — and the escrow releases. Both agents earn +1 on their on-chain reputation counters, which anyone can read before hiring them next time.

Deadline rules keep both sides honest: no delivery by the deadline refunds the buyer automatically on request; a worker who delivered but is ghosted by the buyer can claim payment after the deadline.

Story in one line: agents can't use banks — so HashKey Chain is their bank, their escrow agent, and their credit score, all at once.

## Architecture / tech stack

- **AgentEscrow.sol** (Solidity 0.8.20, no external dependencies) — job terms, escrow state machine (Created → Funded → Delivered → Released / Refunded), deadline refund/claim paths, reentrancy-safe ordering (state before transfers), and reputation mappings (`completedJobsAsPayee`, `completedJobsAsPayer`, `reputation`). Deployed on **HSK Chain mainnet (chainId 177)**: `0x1750a7459E179B52278440212a6b3f038015B7F7` (deployment tx `0x3f4de866861c21d03facf1b6678bdc41f2e3e2e12814578c4886abf39dc86025`, verified on-chain).
- **HSP (HashKey payment protocol)** — the settlement rail for agent-to-agent payments, via its Agentic Payment MCP tools: `createPayment`, `getPaymentStatus`, `refundPayment`, `getBalance`, `getFee`, `cancelPayment`, `getPaymentList`.
- **Demo front end** — a single dependency-free HTML/JS file: live chain-status check against the real HashKey RPCs, a playable end-to-end job flow, agent balance cards, reputation scores, and a timestamped escrow/HSP activity log.

## What was built during the hackathon

- The AgentEscrow contract (written from scratch for this hackathon)
- The interactive demo (flow, simulated ledger mirroring the contract's states, simulated HSP settlement sequence, live RPC chain panel)
- This submission pack: README with deploy runbook, demo script, and pitch flow

## Current status (honest)

The AgentEscrow contract is **deployed and verified live on HSK Chain mainnet (chainId 177)** at `0x1750a7459E179B52278440212a6b3f038015B7F7`. The demo's escrow ledger and HSP calls are **simulated in-browser** and labelled as such — the demo is a playable model of the contract's state machine, not a live wallet integration. Live HSP settlement needs a registered merchant wallet; integrating it is the immediate next step after the hackathon.

## Links

- GitHub repo: [TO FILL]
- Live demo: [TO FILL]
- Demo video: [TO FILL]
- **Mainnet contract address (HSK Chain, chainId 177): 0x1750a7459E179B52278440212a6b3f038015B7F7**
- Testnet contract address (chainId 133, if deployed): Not deployed — mainnet deployment was done directly
- Explorer link for mainnet contract: https://hashkey.blockscout.com/address/0x1750a7459E179B52278440212a6b3f038015B7F7

## Challenges

- HashKey's RPC endpoints can be slow/unreachable from some networks (testnet timed out during development), so the demo was built to degrade honestly: live mainnet → live testnet → clearly labelled simulation mode, never faking a connection.
- Modelling fairness in the contract: the interesting design work was the deadline paths — a buyer who ghosts shouldn't keep a delivered worker unpaid, and a worker who never delivers shouldn't keep the buyer locked. Both paths are in the contract.
- Fitting a two-sided protocol (escrow contract + HSP settlement) into a demo a judge can actually play in two minutes.

## Future work

- Live HSP merchant-wallet integration (real settlement via `createPayment`)
- Agent registry/discovery ranked by on-chain reputation
- Milestone-based escrows with partial releases
- Dispute/review window with an arbitrator-agent option
- A small SDK for agent frameworks to post and accept jobs programmatically

## Team

Built by Abednego (@maidaboii) with AI assistance.
