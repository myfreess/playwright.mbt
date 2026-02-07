# mizchi/playwright.mbt

Playwright 互換 API を WebDriver BiDi 上に実装した MoonBit ライブラリです。
関数名は MoonBit 流儀の `snake_case` で提供します。

## インストール

```bash
moon add mizchi/playwright
```

## パッケージ

- `mizchi/playwright`: ブラウザ操作 API（`chromium`, `firefox`, `webkit` など）
- `mizchi/playwright/test`: `expect` とテスト DSL（`retry`, `timeout`, `to_pass`, `expect_poll`, `step`, `skip`, `fail`, `fixme`, `shard` など）

## 使い方

```mbt
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

  // shard は設定値を省略可能
  @pwt.shard(item_index=0, item_total=2, fn() {})

  // retry / timeout は設定値をデフォルトとして使える
  let _ = @pwt.retry(async fn() -> Int { 1 })

  let _ = @pwt.timeout(async fn() -> Int { 1 })

  // 一定時間リトライしながら assertion
  @pwt.to_pass(async fn() {
    @pwt.expect("ok").to_equal("ok")
  })

  // expect.poll 相当
  @pwt.expect_poll(async fn() -> String { "done-1" }).to_match("done-\\d+")
}
```
