# Anchor ⚓ — Verified Work. Verifiable Pay.

An independently developed Block Tides project for Arc Studio microgrants. Anchor connects funded work, reviewer approval, onchain USDC settlement, and contribution receipts.

## Current state

**Starter implementation, not deployed or audited.** This repo includes a React/Vite frontend, Solidity escrow contract and a starter Hardhat test suite. The interface operates in clearly marked demo mode until a deployed Arc contract address is configured. No real transactions have been completed through this code yet.

## Local development

```bash
npm install
npm run dev
```

Copy `.env.example` to `.env` and set `VITE_ANCHOR_CONTRACT` only after deploying and validating the contract. The UI switches to live contract mode when a deployed contract is supplied. Add an EVM wallet that supports Arc.

## Contracts and tests

```bash
npx hardhat compile
npm test
```

Arc mainnet: chain ID 5042; RPC `https://rpc.mainnet.arc.io`; explorer `https://explorer.arc.io`. Arc gas is native USDC (18 decimals), whereas the USDC ERC-20 token interface at `0x3600000000000000000000000000000000000000` uses **6 decimals**. Never confuse these amounts.

**Before deploying to mainnet**: import contracts into **Arc Studio** and actually use Arc Studio to write/test/build the deployment version, as required by the competition. Run thorough automated and manual testing on Arc testnet; review the escrow's stalled-dispute limitations; secure credentials and conduct an independent code review. Limit demonstration funds.

## Known limitations

- Each bounty supports one claimant and one payment.
- Claimed tasks cannot be refunded or reassigned through this contract, and disputes have no onchain resolution. This is a material blocker for production usage.
- Work descriptions and receipt URLs are only represented as hashes. Store the original content separately and make it retrievable for independently verifiable receipts.
- Frontend currently displays onchain bounty IDs and hashes; it does not resolve offchain task titles or full evidence content from a production index.
- Frontend uses an injected browser wallet and assumes its availability for chain reads.
- `VITE_*` vars are public; never put any keys or secrets in them.
- Do not treat a demo state or sample receipt as evidence of a mainnet payout.

## DoraHacks submission evidence still needed

- Arc Studio project link and evidence of its actual use
- Public GitHub repository
- Publicly deployed functioning app
- Deployed Arc Mainnet contract address
- Real USDC payout transaction hash and explorer link
- Demonstration video showing the successful payout

© Block Tides. Project prototype. No independent security audit.
