const { defineConfig } = require("@playwright/test")

module.exports = defineConfig({
  globalSetup: require.resolve("./global.setup.js"),
  testDir: ".",
  testMatch: /.*\.spec\.js/,
  retries: 2,
  timeout: 15_000,
  expect: {
    timeout: 80,
  },
  shard: {
    current: 2,
    total: 2,
  },
  metadata: {
    moonbit: {
      expect_interval_ms: 1,
    },
  },
  fullyParallel: false,
  workers: 1,
  reporter: [["line"]],
})
