# TODO (Playwright client layer)

Scope: Playwright-like API on top of `mizchi/webdriver`.

## Client API
- [x] BrowserType.connect / connect_over_websocket to BiDi endpoint.
- [x] BrowserType.launch via chromium-bidi WebSocketServer.
- [x] Browser / BrowserContext / Page lifecycle and disposal.
- [x] `page.goto` with real response status from network events.
- [x] `page.set_content`, `page.reload`, `page.url`, `page.title`.
- [x] `page.wait_for_load_state` / `page.wait_for_timeout` (networkidle support).
- [x] `page.evaluate` / `page.evaluate_handle` (expression + callFunction dispatch).
- [x] `page.content()` returns full HTML.
- [x] `page.console_messages()` / `page.console_errors()` via log.entryAdded.
- [x] Chrome process cleanup on exit (SIGINT/SIGTERM/exit handlers).

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
- [x] remote_value_to_json: object/array/map/set/date deserialization (16 tests).

---

## Planned: interaction reliability

These are needed to fully replace TypeScript Playwright for e2e testing.

### P1: Click/Fill via BiDi (not evaluate)
- [ ] `page.click(selector)` — verify works via BiDi `input.performActions`, not just `evaluate`
- [ ] `page.fill(selector, value)` — verify works for input elements in hydrated islands
- [ ] Verify click triggers MoonBit island event handlers (not just DOM click)
- [ ] Test: click counter increment button → verify count changes

### P2: Shadow DOM support
- [ ] `locator` should pierce Shadow DOM for Web Components
- [ ] `evaluate` workaround documented for shadow root access
- [ ] Test: WC counter island click via locator (not evaluate)

### P3: Response body access
- [ ] `Response::text()` — return body from network event or page content
- [ ] `Response::json()` — parse response body as JSON
- [ ] Currently returns empty — need BiDi `network.continueResponse` or post-navigate fetch

### P4: BrowserContext options
- [ ] `javaScriptEnabled: false` — pass to BiDi context creation for progressive enhancement tests
- [ ] `viewport` — set viewport size on context creation
- [ ] `locale`, `timezone_id` — pass through to BiDi

### P5: API testing (request context)
- [ ] `request.get()` / `request.post()` without browser page
- [ ] Or document `evaluate(fetch)` pattern as recommended alternative
- [ ] Test: POST to Server Action endpoint with JSON body

### P6: Debugging & CI stability
- [ ] Screenshot on failure (`page.screenshot()` — currently stub)
- [ ] Trace/HAR recording for CI debugging
- [ ] Retry mechanism for flaky tests
- [ ] Better error messages when BiDi connection drops

### P7: Process management
- [ ] Daemon mode: keep browser alive across test runs
- [ ] Connection reuse: `BrowserType.connect(ws_url)` to existing BiDi server
- [ ] `chromium-bidi` server lifecycle management (start once, reuse)
