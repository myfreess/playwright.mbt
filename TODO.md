# TODO (Playwright client layer)

Scope: Playwright-like API on top of `mizchi/webdriver`.

## Client API
- [ ] BrowserType.connect / connectOverWebSocket to BiDi endpoint.
- [ ] Browser / BrowserContext / Page lifecycle and disposal.
- [ ] `page.goto`, `page.setContent`, `page.reload`, `page.url`, `page.title`.
- [ ] `page.waitForLoadState` / `page.waitForTimeout` (networkidle support).
- [ ] `page.evaluate` / `page.evaluateHandle`.

## Locator & selectors
- [ ] Locator core (`locator`, `getByText`, `getByRole`, `getByTestId`, etc).
- [ ] Locator actions: click, fill, focus, press, hover.
- [ ] Locator queries: textContent, innerText, innerHTML, inputValue, getAttribute.
- [ ] `locator.count`, `locator.nth`, `locator.filter`.

## Expect API
- [ ] `toBe`, `toEqual`, `toMatch`.
- [ ] `toHaveText`, `toContainText`, `toHaveClass`, `toHaveCSS`.
- [ ] `toBeVisible`, `toBeHidden`, `toBeEnabled`, `toBeDisabled`.

## Test runner integration
- [ ] `test` / `expect` helpers for MoonBit tests.
- [ ] Adapters to run basic Playwright-style tests via `moon test`.

## Tests
- [ ] Add MoonBit tests that mirror `tests/playwright-adapter.test.ts` behavior.
