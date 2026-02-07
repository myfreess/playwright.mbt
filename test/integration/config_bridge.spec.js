const { spawnSync } = require("node:child_process")
const path = require("node:path")
const { test, expect } = require("@playwright/test")

const repoRoot = path.resolve(__dirname, "..", "..")

function asPositiveInt(value, fallback) {
  if (typeof value !== "number" || Number.isNaN(value)) {
    return fallback
  }
  const intValue = Math.trunc(value)
  return intValue <= 0 ? fallback : intValue
}

test("playwright config can be injected into moonbit setup", async ({}, testInfo) => {
  const config = testInfo.config
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
    ],
    {
      cwd: repoRoot,
      encoding: "utf-8",
    },
  )

  expect(result.status, result.stdout + "\n" + result.stderr).toBe(0)
})
