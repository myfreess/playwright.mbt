const fs = require("node:fs/promises")
const path = require("node:path")
const { chromium } = require("@playwright/test")

const runtimeDir = path.join(__dirname, ".runtime")
const stateFile = path.join(runtimeDir, "state.json")

module.exports = async function globalSetup() {
  await fs.mkdir(runtimeDir, { recursive: true })
  const server = await chromium.launchServer({
    headless: true,
  })
  const wsEndpoint = server.wsEndpoint()
  const state = {
    ws_endpoint: wsEndpoint,
    server_pid: server.process()?.pid ?? null,
    started_at_unix_ms: Date.now(),
  }
  await fs.writeFile(stateFile, JSON.stringify(state, null, 2), "utf-8")
  return async () => {
    await server.close()
    await fs.rm(stateFile, { force: true })
  }
}
