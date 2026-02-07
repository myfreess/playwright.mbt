# mizchi/playwright.mbt

Playwright 互換の API を WebDriver BiDi 上に実装した MoonBit ライブラリ。

## 状態

初期実装（順次拡張中）。

## 使い方

```mbt check
import "mizchi/playwright" as @pw
import "mizchi/playwright/test" as @pwt

let chromium = @pw.chromium()
let _ = @pwt.expect(chromium.name()).to_equal("chromium")
```
