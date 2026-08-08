#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/standalone/.env"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required: https://docs.docker.com/engine/install/"
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$ROOT/standalone/.env.example" "$ENV_FILE"
  echo "Created $ENV_FILE. Edit the COIN_* values, then run this command again."
  exit 0
fi

set -a
. "$ENV_FILE"
set +a

docker compose --env-file "$ENV_FILE" -f "$ROOT/standalone/docker-compose.yml" up -d

# The default Anvil key is public and valid only for a private local test network.
DEPLOYER_KEY="${DEPLOYER_PRIVATE_KEY:-ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80}"

docker run --rm --network host \
  -v "$ROOT:/app" -w /app \
  --env RPC_URL="http://127.0.0.1:${RPC_PORT:-8545}" \
  --env PRIVATE_KEY="$DEPLOYER_KEY" \
  --env COIN_NAME --env COIN_SYMBOL --env COIN_INITIAL_SUPPLY --env COIN_MAX_SUPPLY \
  --env COIN_ADMIN_ADDRESS --env COIN_TREASURY_ADDRESS \
  ghcr.io/foundry-rs/foundry:stable \
  sh -lc 'test -d lib/forge-std || forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts; forge script script/DeployOwnCoin.s.sol:DeployOwnCoin --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --broadcast'

echo "Private network RPC: http://127.0.0.1:${RPC_PORT:-8545}"
