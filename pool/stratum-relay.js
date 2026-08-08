"use strict";

const http = require("node:http");
const net = require("node:net");
const tls = require("node:tls");

const poolPort = Number(process.env.POOL_PORT || 3333);
const metricsPort = Number(process.env.METRICS_PORT || 8080);
const upstreamHost = String(process.env.UPSTREAM_HOST || "").trim();
const upstreamPort = Number(process.env.UPSTREAM_PORT || 3333);
const upstreamTls = process.env.UPSTREAM_TLS === "true";

if (!upstreamHost) {
  throw new Error("Set UPSTREAM_HOST to your own Stratum daemon or pool endpoint.");
}

const workers = new Map();
let accepted = 0;
let rejected = 0;
let connections = 0;

const identify = (line) => {
  try {
    const message = JSON.parse(line);
    if (message.method === "mining.authorize") return String(message.params?.[0] || "unknown").slice(0, 160);
  } catch {
    // Non-JSON or partial frames are still safely relayed.
  }
  return null;
};

const submitResult = (line) => {
  try {
    const message = JSON.parse(line);
    if (Object.prototype.hasOwnProperty.call(message, "result") && typeof message.result === "boolean") {
      if (message.result) accepted += 1;
      else rejected += 1;
    }
  } catch {
    // Ignore upstream messages that are not JSON-RPC result frames.
  }
};

const server = net.createServer((miner) => {
  connections += 1;
  let worker = "unknown";
  const upstream = upstreamTls
    ? tls.connect({ host: upstreamHost, port: upstreamPort, servername: upstreamHost })
    : net.createConnection({ host: upstreamHost, port: upstreamPort });

  miner.setKeepAlive(true, 30_000);
  upstream.setKeepAlive(true, 30_000);

  miner.on("data", (chunk) => {
    for (const line of chunk.toString("utf8").split("\n")) {
      const identity = identify(line);
      if (identity) {
        worker = identity;
        workers.set(worker, { connectedAt: workers.get(worker)?.connectedAt || Date.now(), lastSeenAt: Date.now() });
      }
    }
    upstream.write(chunk);
  });
  upstream.on("data", (chunk) => {
    for (const line of chunk.toString("utf8").split("\n")) submitResult(line);
    miner.write(chunk);
  });

  const close = () => {
    connections = Math.max(0, connections - 1);
    if (worker !== "unknown") workers.delete(worker);
    miner.destroy();
    upstream.destroy();
  };
  miner.on("error", close);
  upstream.on("error", close);
  miner.on("close", close);
  upstream.on("close", close);
});

server.listen(poolPort, "0.0.0.0", () => {
  console.log(`Stratum relay listening on 0.0.0.0:${poolPort}; upstream=${upstreamHost}:${upstreamPort}`);
});

http.createServer((_req, res) => {
  res.setHeader("content-type", "application/json");
  res.end(JSON.stringify({
    ok: true,
    connections,
    accepted,
    rejected,
    workers: Array.from(workers.entries()).map(([name, data]) => ({ name, ...data })),
  }));
}).listen(metricsPort, "127.0.0.1", () => {
  console.log(`Metrics listening on 127.0.0.1:${metricsPort}`);
});
