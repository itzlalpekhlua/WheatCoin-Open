# Standalone Stratum Relay

This is a small, standalone TCP relay for miners using the Stratum protocol. It forwards miner traffic to **your own** compatible Stratum daemon or pool endpoint and exposes local worker/accepted/rejected telemetry at `http://127.0.0.1:8080`.

It contains no MizoBot code, no embedded wallet address, no payout key, and no hidden upstream.

## Start

```bash
cd pool
cp .env.example .env
nano .env
docker compose up -d
```

Point compatible miners at your server's port `3333`, then inspect local telemetry:

```bash
curl http://127.0.0.1:8080
```

## What this is - and is not

This relay is useful for pooling a public endpoint, collecting basic worker activity, and keeping the upstream under your control. It deliberately **does not** change miner usernames, custody rewards, validate shares, calculate PPLNS/PPS rewards, or issue payouts.

A production mining pool must run a node for the mined proof-of-work chain plus a share validator, job manager, accounting database, payout engine, authentication, monitoring, backups, and abuse controls. An ERC-20 coin on an EVM network is not mineable by itself; that network normally uses validators, not Stratum GPU/CPU miners.

Use this only for miners and chains you are authorized to operate. Do not expose the metrics listener publicly.
