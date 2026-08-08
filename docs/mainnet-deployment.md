# Mainnet Deployment Guide

This guide deploys the included fixed-supply community-token factory to an EVM-compatible mainnet. Each person deploying it controls their own owner address, fee recipient, RPC endpoint, and deployment account.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- An RPC URL for the network you choose
- A funded deployment account for that network's native gas token

Install dependencies once:

```bash
forge install OpenZeppelin/openzeppelin-contracts foundry-rs/forge-std
```

## Configure public values

Create a local `.env` file. Do not commit it.

```bash
RPC_URL=https://your-evm-rpc.example
FACTORY_OWNER_ADDRESS=0xYourOwnerAddress
FACTORY_FEE_RECIPIENT=0xYourFeeRecipient
FACTORY_CREATION_FEE_WEI=0
```

Import the deployer into Foundry's encrypted keystore:

```bash
cast wallet import community-token-deployer --interactive
```

## Deploy

```bash
source .env
forge script script/DeployCommunityTokenFactory.s.sol:DeployCommunityTokenFactory \
  --rpc-url "$RPC_URL" \
  --account community-token-deployer \
  --broadcast \
  --verify
```

`--verify` requires a supported block explorer/API configuration; remove it if your network does not support automatic verification.

## Create a token

Call `createToken(name, symbol, supply)` on the deployed `WheatTokenFactory` and send exactly its configured `creationFee`. The full fixed supply is minted to the wallet that calls `createToken`.

Example with `cast` where `FACTORY_ADDRESS` is your deployed factory:

```bash
cast send "$FACTORY_ADDRESS" \
  "createToken(string,string,uint256)" \
  "Example Coin" EXAMPLE 1000000 \
  --value "$FACTORY_CREATION_FEE_WEI" \
  --account community-token-deployer \
  --rpc-url "$RPC_URL"
```

This code is provided as a starting point. Obtain an independent security review, define a legal/compliance plan, secure privileged keys with a multisig, and test on a testnet before deploying real value.
