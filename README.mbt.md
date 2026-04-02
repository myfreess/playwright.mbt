# mizchi/playwright.mbt

MoonBit library that implements a Playwright-compatible API on top of WebDriver BiDi.
Function names follow the MoonBit `snake_case` convention.

## Installation

```bash
moon add mizchi/playwright
```

## Packages

- `mizchi/playwright`: Browser automation API (`chromium`, `firefox`, `webkit`, etc.)
- `mizchi/playwright/test`: `expect` and the test DSL (`retry`, `timeout`, `to_pass`, `expect_poll`, `step`, `skip`, `fail`, `fixme`, `shard`, etc.)

## Usage

```mbt check
import "mizchi/playwright" as @pw
import "mizchi/playwright/test" as @pwt

let chromium = @pw.chromium()
let _ = @pwt.expect(chromium.name()).to_equal("chromium")

async test "dsl helpers" {
  @pwt.configure_test(
    retry_times=3,
    timeout_ms=3_000,
    expect_timeout_ms=800,
    expect_interval_ms=10,
    shard_index=1,
    shard_total=2,
  )

  let _ = @pwt.step("open", fn() -> Int { 1 })

  // shard can omit configuration values
  @pwt.shard(item_index=0, item_total=2, fn() {})

  // retry / timeout can use configured defaults
  let _ = @pwt.retry(async fn() -> Int { 1 })

  let _ = @pwt.timeout(async fn() -> Int { 1 })

  // Retry assertions for a bounded amount of time
  @pwt.to_pass(async fn() {
    @pwt.expect("ok").to_equal("ok")
  })

  // Equivalent to expect.poll
  @pwt.expect_poll(async fn() -> String { "done-1" }).to_match("done-\\d+")
}
```

## Playwright Integration (Shared Single Process)

Using `globalSetup` on the `@playwright/test` side lets you start the browser server only once and share the `wsEndpoint` across multiple tests.

```js
// test/integration/global.setup.js
const { chromium } = require("@playwright/test")
const fs = require("node:fs/promises")
const path = require("node:path")

module.exports = async () => {
  const server = await chromium.launchServer({ headless: true })
  const runtimeDir = path.join(__dirname, ".runtime")
  await fs.mkdir(runtimeDir, { recursive: true })
  await fs.writeFile(
    path.join(runtimeDir, "state.json"),
    JSON.stringify({ ws_endpoint: server.wsEndpoint() }),
    "utf-8",
  )
  return async () => {
    await server.close()
  }
}
```

```js
// test/integration/config_bridge.spec.js (excerpt)
const state = JSON.parse(fs.readFileSync(".runtime/state.json", "utf-8"))
const wsEndpoint = state.ws_endpoint

spawnSync("moon", [
  "run",
  "src/playwright/test_utils/integration_bridge",
  "--target",
  "js",
  /* retry/timeout/shard, etc. */,
  wsEndpoint,
])
```

This repository already implements this approach in `test/integration/`.
