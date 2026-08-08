# WheatCoin Contracts (Archived)

This repository contains the public, non-bot Solidity source for the former WheatCoin project:

- `WheatCoin.sol`: a capped ERC-20 implementation with role-based minting, pausing, burning, and EIP-2612 permits.
- `WheatTokenFactory.sol`: an optional fixed-supply community-token factory.
- `test/`: Foundry tests covering the core behaviour.
- `script/DeployCommunityTokenFactory.s.sol`: a generic deployment script for your own EVM network.

## Project status

WheatCoin is shut down and is transitioning to **WheatHost**, a hosting-service project. This repository is published for transparency and educational review only. It does not include MizoBot, its database, dashboard, keys, wallet data, operational services, or deployment credentials.

Do not treat this repository as an active token launch, a production deployment, or financial advice.

## Test locally

Requirements: [Foundry](https://book.getfoundry.sh/getting-started/installation).

```bash
forge install OpenZeppelin/openzeppelin-contracts foundry-rs/forge-std
forge test -vv
```

The contracts target Solidity `0.8.24`. See [mainnet deployment](docs/mainnet-deployment.md) to deploy a token factory, or use the [standalone private network starter](standalone/README.md) to run your own local EVM network and deploy a custom coin. Copy `.env.example` to `.env` only if you are experimenting with your own deployment environment. Never commit private keys, RPC credentials, or real wallet secrets.

## License

MIT. See [LICENSE](LICENSE).
