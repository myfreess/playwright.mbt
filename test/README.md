# test/

統合テストや外部連携テスト用の置き場。

- `integration/`: Playwright 本体（`@playwright/test`）との設定連携テスト
  - `globalSetup` で Playwright サーバーを 1 回起動し、`wsEndpoint` を全テストで共有
  - 実行: `cd test/integration && pnpm test`
