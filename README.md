# mizchi/playwright.mbt

Playwright 互換の API を WebDriver BiDi 上に実装した MoonBit ライブラリ。

## 状態

初期実装（順次拡張中）。

## 使い方

```mbt
import "mizchi/playwright" as @pw
import "mizchi/playwright/test" as @pwt

let chromium = @pw.chromium()
let _ = @pwt.expect(chromium.name()).to_equal("chromium")

async test "retry + shard helper" {
  let _ = @pwt.step("open", fn() -> Int { 1 })
  @pwt.shard(item_index=0, item_total=2, shard_index=1, shard_total=2, fn() {})
  let _ = @pwt.retry(times=3, async fn() -> Int { 1 })
  let _ = @pwt.timeout(ms=1_000, async fn() -> Int { 1 })
  @pwt.to_pass(timeout=1_000, interval=10, async fn() {
    @pwt.expect("ok").to_equal("ok")
  })
  @pwt.expect_poll(async fn() -> String { "done-1" }).to_match("done-\\d+")
}
```
