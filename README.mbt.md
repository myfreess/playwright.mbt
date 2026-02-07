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

```mbt check
import "mizchi/playwright" as @pw
import "mizchi/playwright/test" as @pwt

let chromium = @pw.chromium()
let _ = @pwt.expect(chromium.name()).to_equal("chromium")

async test "dsl helpers" {
  let _ = @pwt.step("open", fn() -> Int { 1 })

  // shard(2/2) だけ実行
  @pwt.shard(item_index=0, item_total=2, shard_index=1, shard_total=2, fn() {})

  // 失敗時に最大 3 回再実行
  let _ = @pwt.retry(times=3, async fn() -> Int { 1 })

  // 1 秒以内に終わることを要求
  let _ = @pwt.timeout(ms=1_000, async fn() -> Int { 1 })

  // 一定時間リトライしながら assertion
  @pwt.to_pass(timeout=1_000, interval=10, async fn() {
    @pwt.expect("ok").to_equal("ok")
  })

  // expect.poll 相当
  @pwt.expect_poll(async fn() -> String { "done-1" }).to_match("done-\\d+")
}
```
