# Standalone Coin Network Starter

This folder is a self-contained starter for running a private EVM-compatible network on your own server and deploying your own ERC-20 coin. It has no dependency on MizoBot or any hosted service.

## Quick start

```bash
git clone https://github.com/itzlalpekhlua/WheatCoin-Open.git
cd WheatCoin-Open
cp standalone/.env.example standalone/.env
nano standalone/.env
./standalone/make-network.sh
```

The first run creates the editable configuration. The next run starts a local Anvil node with Docker and deploys `OwnCoin` using your chosen name, symbol, supply, admin, and treasury address.

Your RPC is bound to `127.0.0.1:8545` by default, so it is not publicly exposed. Use an SSH tunnel or an authenticated reverse proxy if remote applications need access.

## Important limits

Anvil is suitable for local development, private demos, and integration testing. It is **not** a production public blockchain. A real public network needs multiple independently operated validators, persistent key management, a reviewed genesis configuration, monitoring, backups, DDoS protection, and an audited token contract.

Never use the documented default Anvil private key outside a disposable private test environment. Set `DEPLOYER_PRIVATE_KEY` to your own funded test/private-network key if you need a separate deployer.
