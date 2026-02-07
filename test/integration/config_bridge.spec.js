const { spawnSync } = require("node:child_process")
const fs = require("node:fs")
const path = require("node:path")
const { test, expect } = require("@playwright/test")

const repoRoot = path.resolve(__dirname, "..", "..")
const runtimeStatePath = path.join(__dirname, ".runtime", "state.json")

function asPositiveInt(value, fallback) {
  if (typeof value !== "number" || Number.isNaN(value)) {
    return fallback
  }
  const intValue = Math.trunc(value)
  return intValue <= 0 ? fallback : intValue
}

test("playwright config can be injected into moonbit setup", async ({}, testInfo) => {
  const config = testInfo.config
  const runtimeState = JSON.parse(fs.readFileSync(runtimeStatePath, "utf-8"))
  const wsEndpoint = runtimeState.ws_endpoint
  const retries = asPositiveInt(config.retries, 0)
  const timeoutMs = asPositiveInt(config.timeout, 5_000)
  const expectTimeoutMs = asPositiveInt(config.expect?.timeout, 5_000)
  const expectIntervalMs = asPositiveInt(
    config.metadata?.moonbit?.expect_interval_ms,
    1,
  )
  const shardIndex = asPositiveInt(config.shard?.current, 1)
  const shardTotal = asPositiveInt(config.shard?.total, 1)
  const retryTimes = retries + 1
  expect(typeof wsEndpoint).toBe("string")
  expect(wsEndpoint.length).toBeGreaterThan(0)

  const result = spawnSync(
    "moon",
    [
      "run",
      "src/playwright/test_utils/integration_bridge",
      "--target",
      "js",
      String(retryTimes),
      String(timeoutMs),
      String(expectTimeoutMs),
      String(expectIntervalMs),
      String(shardIndex),
      String(shardTotal),
      wsEndpoint,
    ],
    {
      cwd: repoRoot,
      encoding: "utf-8",
    },
  )

  expect(result.status, result.stdout + "\n" + result.stderr).toBe(0)
})
