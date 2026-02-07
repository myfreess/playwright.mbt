# TODO (Playwright client layer)

Scope: Playwright-like API on top of `mizchi/webdriver`.

## Client API
- [x] BrowserType.connect / connect_over_websocket to BiDi endpoint.
- [x] Browser / BrowserContext / Page lifecycle and disposal.
- [x] `page.goto`, `page.set_content`, `page.reload`, `page.url`, `page.title`.
- [x] `page.wait_for_load_state` / `page.wait_for_timeout` (networkidle support).
- [x] `page.evaluate` / `page.evaluate_handle`.

## Locator & selectors
- [x] Locator core (`locator`, `get_by_text`, `get_by_role`, `get_by_test_id`, etc).
- [x] Locator actions: click, fill, focus, press, hover.
- [x] Locator queries: text_content, inner_text, inner_html, input_value, get_attribute.
- [x] `locator.count`, `locator.nth`, `locator.filter`.

## Expect API
- [x] `toBe`, `toEqual`, `toMatch`.
- [x] `toHaveText`, `toContainText`, `toHaveClass`, `toHaveCSS`.
- [x] `toBeVisible`, `toBeHidden`, `toBeEnabled`, `toBeDisabled`.

## Test runner integration
- [x] `test` / `expect` helpers for MoonBit tests.
- [x] Adapters to run basic Playwright-style tests via `moon test`.

## Tests
- [x] Add MoonBit tests that mirror `tests/playwright-adapter.test.ts` behavior.
