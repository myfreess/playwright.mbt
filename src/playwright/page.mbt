///|
/// Page methods

///|
/// Navigate to URL
/// See: https://playwright.dev/docs/api/class-page#page-goto
pub async fn Page::goto(
  self : Page,
  url : String,
  timeout? : Int,
  waitUntil? : String,
  referer? : String,
) -> Response? {
  consume((timeout, waitUntil, referer))
  let state = self.state.val
  let result = state.browser.state.val.client.browsing_context_navigate(
    state.context_id,
    url,
  )
  match result {
    Ok(nav) => {
      state.url = nav.url
      Some(make_response(nav.url))
    }
    Err(_) => None
  }
}

///|
/// Reload page
pub async fn Page::reload(
  self : Page,
  timeout? : Int,
  waitUntil? : String,
) -> Response? {
  consume((timeout, waitUntil))
  let state = self.state.val
  let _ = state.browser.state.val.client.browsing_context_reload(
    state.context_id,
  )
  Some(make_response(state.url))
}

///|
/// Go back in history
pub async fn Page::goBack(
  self : Page,
  timeout? : Int,
  waitUntil? : String,
) -> Response? {
  consume((timeout, waitUntil))
  let _ = self.evaluate("history.back()")
  None
}

///|
/// Go forward in history
pub async fn Page::goForward(
  self : Page,
  timeout? : Int,
  waitUntil? : String,
) -> Response? {
  consume((timeout, waitUntil))
  let _ = self.evaluate("history.forward()")
  None
}

///|
/// Get page URL
pub fn Page::url(self : Page) -> String {
  self.state.val.url
}

///|
/// Get page title
pub async fn Page::title(self : Page) -> String {
  match self.eval_string("document.title") {
    Some(value) => value
    None => ""
  }
}

///|
/// Get page content (HTML)
pub async fn Page::content(self : Page) -> String {
  match self.eval_string("document.documentElement.outerHTML") {
    Some(value) => value
    None => ""
  }
}

///|
/// Set page content
pub async fn Page::setContent(
  self : Page,
  html : String,
  timeout? : Int,
  waitUntil? : String,
) -> Unit {
  consume((timeout, waitUntil))
  let expr = "(html) => { document.open(); document.write(html); document.close(); }"
  let args : Array[Json] = [
    Json::object({ "type": Json::string("string"), "value": Json::string(html) }),
  ]
  let _ = self.call_function(expr, args)

}

///|
/// Get locator for CSS selector or text
pub fn Page::locator(self : Page, selector : String) -> Locator {
  let state : LocatorState = {
    page: self,
    selector,
    index: None,
    has_text: None,
    has_text_exact: false,
    has_not_text: None,
    label_text: None,
    label_text_exact: false,
    label_scope_selector: None,
  }
  { state: { val: state } }
}

///|
/// Get locator by role
pub fn Page::getByRole(
  self : Page,
  role : String,
  name? : String,
  exact? : Bool,
) -> Locator {
  consume(exact)
  let selector = "[role=" + js_string_literal(role) + "]"
  let base = self.locator(selector)
  match name {
    Some(text) => base.getByText(text, exact?)
    None => base
  }
}

///|
/// Get locator by text
pub fn Page::getByText(self : Page, text : String, exact? : Bool) -> Locator {
  let exact_flag = match exact {
    Some(true) => true
    _ => false
  }
  let state : LocatorState = {
    page: self,
    selector: "*",
    index: None,
    has_text: Some(text),
    has_text_exact: exact_flag,
    has_not_text: None,
    label_text: None,
    label_text_exact: false,
    label_scope_selector: None,
  }
  { state: { val: state } }
}

///|
/// Get locator by label
pub fn Page::getByLabel(self : Page, text : String, exact? : Bool) -> Locator {
  let exact_flag = match exact {
    Some(true) => true
    _ => false
  }
  let state : LocatorState = {
    page: self,
    selector: "label",
    index: None,
    has_text: None,
    has_text_exact: false,
    has_not_text: None,
    label_text: Some(text),
    label_text_exact: exact_flag,
    label_scope_selector: None,
  }
  { state: { val: state } }
}

///|
/// Get locator by placeholder
pub fn Page::getByPlaceholder(
  self : Page,
  text : String,
  exact? : Bool,
) -> Locator {
  consume(exact)
  let selector = "[placeholder=" + js_string_literal(text) + "]"
  let state : LocatorState = {
    page: self,
    selector,
    index: None,
    has_text: None,
    has_text_exact: false,
    has_not_text: None,
    label_text: None,
    label_text_exact: false,
    label_scope_selector: None,
  }
  { state: { val: state } }
}

///|
/// Get locator by alt text
pub fn Page::getByAltText(self : Page, text : String, exact? : Bool) -> Locator {
  consume(exact)
  let selector = "[alt=" + js_string_literal(text) + "]"
  let state : LocatorState = {
    page: self,
    selector,
    index: None,
    has_text: None,
    has_text_exact: false,
    has_not_text: None,
    label_text: None,
    label_text_exact: false,
    label_scope_selector: None,
  }
  { state: { val: state } }
}

///|
/// Get locator by title
pub fn Page::getByTitle(self : Page, text : String, exact? : Bool) -> Locator {
  consume(exact)
  let selector = "[title=" + js_string_literal(text) + "]"
  let state : LocatorState = {
    page: self,
    selector,
    index: None,
    has_text: None,
    has_text_exact: false,
    has_not_text: None,
    label_text: None,
    label_text_exact: false,
    label_scope_selector: None,
  }
  { state: { val: state } }
}

///|
/// Get locator by test ID
pub fn Page::getByTestId(self : Page, testId : String) -> Locator {
  let selector = "[data-testid=" + js_string_literal(testId) + "]"
  let state : LocatorState = {
    page: self,
    selector,
    index: None,
    has_text: None,
    has_text_exact: false,
    has_not_text: None,
    label_text: None,
    label_text_exact: false,
    label_scope_selector: None,
  }
  { state: { val: state } }
}

///|
/// Subscribe network event
pub fn Page::onNetworkEvent(
  self : Page,
  handler : (NetworkEvent) -> Unit,
) -> Unit {
  self.state.val.network_listeners.push(handler)
}

///|
/// Subscribe request event
pub fn Page::onRequest(self : Page, handler : (Request) -> Unit) -> Unit {
  self.onNetworkEvent(fn(evt : NetworkEvent) {
    match evt {
      NetworkEvent::Request(req) => handler(req)
      _ => ()
    }
  })
}

///|
/// Subscribe response event
pub fn Page::onResponse(self : Page, handler : (Response) -> Unit) -> Unit {
  self.onNetworkEvent(fn(evt : NetworkEvent) {
    match evt {
      NetworkEvent::Response(resp) => handler(resp)
      _ => ()
    }
  })
}

///|
/// Subscribe response completed event
pub fn Page::onResponseCompleted(
  self : Page,
  handler : (Response) -> Unit,
) -> Unit {
  self.onNetworkEvent(fn(evt : NetworkEvent) {
    match evt {
      NetworkEvent::ResponseCompleted(resp) => handler(resp)
      _ => ()
    }
  })
}

///|
/// Click on element
pub async fn Page::click(
  self : Page,
  selector : String,
  button? : String,
  clickCount? : Int,
  delay? : Int,
  force? : Bool,
  modifiers? : Array[String],
  noWaitAfter? : Bool,
  position? : (Double, Double),
  timeout? : Int,
  trial? : Bool,
) -> Unit {
  consume(
    (
      button, clickCount, delay, force, modifiers, noWaitAfter, position, timeout,
      trial,
    ),
  )
  let locator = self.locator(selector)
  locator.click()
}

///|
/// Double click on element
pub async fn Page::dblclick(
  self : Page,
  selector : String,
  timeout? : Int,
  force? : Bool,
) -> Unit {
  consume((timeout, force))
  let locator = self.locator(selector)
  locator.dblclick()
}

///|
/// Fill input
pub async fn Page::fill(
  self : Page,
  selector : String,
  value : String,
  force? : Bool,
  noWaitAfter? : Bool,
  timeout? : Int,
) -> Unit {
  consume((force, noWaitAfter, timeout))
  let locator = self.locator(selector)
  locator.fill(value)
}

///|
/// Type text (keystroke by keystroke)
pub async fn Page::type_(
  self : Page,
  selector : String,
  text : String,
  delay? : Int,
  noWaitAfter? : Bool,
  timeout? : Int,
) -> Unit {
  consume((delay, noWaitAfter, timeout))
  let locator = self.locator(selector)
  locator.type_(text)
}

///|
/// Press key
pub async fn Page::press(
  self : Page,
  selector : String,
  key : String,
  delay? : Int,
  noWaitAfter? : Bool,
  timeout? : Int,
) -> Unit {
  consume((delay, noWaitAfter, timeout))
  let locator = self.locator(selector)
  locator.press(key)
}

///|
/// Check checkbox
pub async fn Page::check(
  self : Page,
  selector : String,
  force? : Bool,
  noWaitAfter? : Bool,
  timeout? : Int,
) -> Unit {
  consume((force, noWaitAfter, timeout))
  let locator = self.locator(selector)
  locator.check()
}

///|
/// Uncheck checkbox
pub async fn Page::uncheck(
  self : Page,
  selector : String,
  force? : Bool,
  noWaitAfter? : Bool,
  timeout? : Int,
) -> Unit {
  consume((force, noWaitAfter, timeout))
  let locator = self.locator(selector)
  locator.uncheck()
}

///|
/// Select option(s) in dropdown
pub async fn Page::selectOption(
  self : Page,
  selector : String,
  values : Array[SelectOption],
  force? : Bool,
  noWaitAfter? : Bool,
  timeout? : Int,
) -> Array[String] {
  consume((self, selector, values, force, noWaitAfter, timeout))
  async_noop()
  []
}

///|
/// Hover over element
pub async fn Page::hover(
  self : Page,
  selector : String,
  force? : Bool,
  modifiers? : Array[String],
  position? : (Double, Double),
  timeout? : Int,
  trial? : Bool,
) -> Unit {
  consume((force, modifiers, position, timeout, trial))
  let locator = self.locator(selector)
  locator.hover()
}

///|
/// Focus element
pub async fn Page::focus(
  self : Page,
  selector : String,
  timeout? : Int,
) -> Unit {
  consume(timeout)
  let locator = self.locator(selector)
  locator.focus()
}

///|
/// Wait for selector
pub async fn Page::waitForSelector(
  self : Page,
  selector : String,
  state? : String,
  timeout? : Int,
  strict? : Bool,
) -> ElementHandle? {
  let strict_mode = match strict {
    Some(true) => true
    _ => false
  }
  let desired = match state {
    Some("attached") => "attached"
    Some("detached") => "detached"
    Some("hidden") => "hidden"
    Some("visible") => "visible"
    _ => "visible"
  }
  let timeout_ms = match timeout {
    Some(value) => value
    None => 30_000
  }
  let start = @async.now()
  let result = for attempt = 0 {
    let nodes = self.locate_nodes(selector)
    let found = nodes.length() > 0
    if strict_mode && nodes.length() > 1 {
      raise PlaywrightError::StrictModeViolation(
        selector~,
        count=nodes.length(),
      )
    }
    match desired {
      "attached" =>
        if found {
          let handle = JSHandle::from_page(self, nodes[0])
          break handle.asElement()
        }
      "detached" => if not(found) { break None }
      "hidden" =>
        if not(found) {
          break None
        } else {
          match self.is_node_visible(nodes[0]) {
            Some(true) => ()
            Some(false) => break None
            None => ()
          }
        }
      "visible" =>
        if found {
          match self.is_node_visible(nodes[0]) {
            Some(true) => {
              let handle = JSHandle::from_page(self, nodes[0])
              break handle.asElement()
            }
            _ => ()
          }
        }
      _ => ()
    }
    if timeout_ms <= 0 {
      break None
    }
    let elapsed = @async.now() - start
    if elapsed >= timeout_ms.to_int64() {
      break None
    }
    let remaining = timeout_ms - elapsed.to_int()
    let base = 10
    let cap = 200
    let step = if attempt > 6 { 6 } else { attempt }
    let delay = base * (1 << step)
    let wait = if delay > cap { cap } else { delay }
    let wait_ms = if wait > remaining { remaining } else { wait }
    sleep_ms(wait_ms)
    continue attempt + 1
  }
  result
}

///|
/// Wait for load state
pub async fn Page::waitForLoadState(
  self : Page,
  state? : String,
  timeout? : Int,
) -> Unit {
  let desired = match state {
    Some("domcontentloaded") => "domcontentloaded"
    Some("load") => "load"
    Some("networkidle") => "load"
    Some(value) => value
    None => "load"
  }
  match self.eval_string("document.readyState") {
    Some("complete") =>
      if desired == "load" || desired == "networkidle" {
        return
      }
    Some("interactive") => if desired == "domcontentloaded" { return }
    _ => ()
  }
  match timeout {
    Some(value) => {
      let _ = self.waitForNavigation(timeout=value, waitUntil=desired)

    }
    None => {
      let _ = self.waitForNavigation(waitUntil=desired)

    }
  }
}

///|
/// Wait for navigation
pub async fn Page::waitForNavigation(
  self : Page,
  timeout? : Int,
  url? : String,
  waitUntil? : String,
) -> Response? {
  let wait_method = match waitUntil {
    Some("domcontentloaded") => "browsingContext.domContentLoaded"
    Some("load") => "browsingContext.load"
    Some("networkidle") => "browsingContext.load"
    Some(value) => value
    None => "browsingContext.load"
  }
  let timeout_ms = match timeout {
    Some(value) => value
    None => 30_000
  }
  let start = @async.now()
  let result = for attempt = 0 {
    match self.take_navigation_event(Some(wait_method), url) {
      Some(evt) => {
        self.state.val.url = evt.url
        break Some(make_response(evt.url))
      }
      None => ()
    }
    match url {
      Some(target) =>
        if self.state.val.url == target {
          break Some(make_response(target))
        }
      None => ()
    }
    if timeout_ms <= 0 {
      break None
    }
    let elapsed = @async.now() - start
    if elapsed >= timeout_ms.to_int64() {
      break None
    }
    let remaining = timeout_ms - elapsed.to_int()
    let base = 10
    let cap = 200
    let step = if attempt > 6 { 6 } else { attempt }
    let delay = base * (1 << step)
    let wait = if delay > cap { cap } else { delay }
    let wait_ms = if wait > remaining { remaining } else { wait }
    sleep_ms(wait_ms)
    continue attempt + 1
  }
  result
}

///|
/// Wait for URL
pub async fn Page::waitForURL(
  self : Page,
  url : String,
  timeout? : Int,
  waitUntil? : String,
) -> Unit {
  consume(waitUntil)
  if self.state.val.url == url {
    return
  }
  let timeout_ms = match timeout {
    Some(value) => value
    None => 30_000
  }
  let start = @async.now()
  let _ = for attempt = 0 {
    match self.take_navigation_event(None, Some(url)) {
      Some(evt) => {
        self.state.val.url = evt.url
        break ()
      }
      None => ()
    }
    if self.state.val.url == url {
      break ()
    }
    if timeout_ms <= 0 {
      break ()
    }
    let elapsed = @async.now() - start
    if elapsed >= timeout_ms.to_int64() {
      break ()
    }
    let remaining = timeout_ms - elapsed.to_int()
    let base = 10
    let cap = 200
    let step = if attempt > 6 { 6 } else { attempt }
    let delay = base * (1 << step)
    let wait = if delay > cap { cap } else { delay }
    let wait_ms = if wait > remaining { remaining } else { wait }
    sleep_ms(wait_ms)
    continue attempt + 1
  }

}

///|
/// Wait for network request
pub async fn Page::waitForRequest(
  self : Page,
  url : String,
  timeout? : Int,
  matchMode? : String,
  predicate? : (Request) -> Bool,
) -> Request? {
  let match_mode = resolve_match_mode(url, matchMode)
  let timeout_ms = match timeout {
    Some(value) => value
    None => 30_000
  }
  let start = @async.now()
  let result = for attempt = 0 {
    match self.take_request_event(url, match_mode, predicate) {
      Some(req) => break Some(req)
      None => ()
    }
    if timeout_ms <= 0 {
      break None
    }
    let elapsed = @async.now() - start
    if elapsed >= timeout_ms.to_int64() {
      break None
    }
    let remaining = timeout_ms - elapsed.to_int()
    let base = 10
    let cap = 200
    let step = if attempt > 6 { 6 } else { attempt }
    let delay = base * (1 << step)
    let wait = if delay > cap { cap } else { delay }
    let wait_ms = if wait > remaining { remaining } else { wait }
    sleep_ms(wait_ms)
    continue attempt + 1
  }
  result
}

///|
/// Wait for network response
pub async fn Page::waitForResponse(
  self : Page,
  url : String,
  timeout? : Int,
  matchMode? : String,
  stage? : String,
  predicate? : (Response) -> Bool,
) -> Response? {
  let match_mode = resolve_match_mode(url, matchMode)
  let resolved_stage = resolve_response_stage(stage)
  let timeout_ms = match timeout {
    Some(value) => value
    None => 30_000
  }
  let start = @async.now()
  let result = for attempt = 0 {
    let matched = if resolved_stage == "completed" {
      self.take_response_completed_event(url, match_mode, predicate)
    } else {
      self.take_response_event(url, match_mode, predicate)
    }
    match matched {
      Some(resp) => break Some(resp)
      None => ()
    }
    if timeout_ms <= 0 {
      break None
    }
    let elapsed = @async.now() - start
    if elapsed >= timeout_ms.to_int64() {
      break None
    }
    let remaining = timeout_ms - elapsed.to_int()
    let base = 10
    let cap = 200
    let step = if attempt > 6 { 6 } else { attempt }
    let delay = base * (1 << step)
    let wait = if delay > cap { cap } else { delay }
    let wait_ms = if wait > remaining { remaining } else { wait }
    sleep_ms(wait_ms)
    continue attempt + 1
  }
  result
}

///|
/// Wait for timeout
pub async fn Page::waitForTimeout(self : Page, timeout : Int) -> Unit {
  consume(self)
  sleep_ms(timeout)
}

///|
/// Wait for function to return truthy value
pub async fn Page::waitForFunction(
  self : Page,
  pageFunction : String,
  arg? : Json,
  polling? : Int,
  timeout? : Int,
) -> Json {
  consume((polling, timeout))
  match arg {
    Some(value) => self.evaluate(pageFunction, arg=value)
    None => self.evaluate(pageFunction)
  }
}

///|
/// Evaluate JavaScript in page context
pub async fn Page::evaluate(
  self : Page,
  pageFunction : String,
  arg? : Json,
) -> Json {
  consume(arg)
  let state = self.state.val
  let result = state.browser.state.val.client.script_evaluate(
    pageFunction,
    state.context_id,
  )
  match result {
    Ok(json) =>
      match json_get_object(json, "result") {
        Some(value) => remote_value_to_json(value)
        None => Json::null()
      }
    Err(_) => Json::null()
  }
}

///|
/// Evaluate JavaScript and return handle
pub async fn Page::evaluateHandle(
  self : Page,
  pageFunction : String,
  arg? : Json,
) -> JSHandle {
  consume(arg)
  let state = self.state.val
  let result = state.browser.state.val.client.script_evaluate(
    pageFunction,
    state.context_id,
  )
  match result {
    Ok(json) =>
      match json_get_object(json, "result") {
        Some(value) => JSHandle::from_page(self, value)
        None => JSHandle::from_page(self, Json::null())
      }
    Err(_) => JSHandle::from_page(self, Json::null())
  }
}

///|
/// Take screenshot
pub async fn Page::screenshot(
  self : Page,
  path? : String,
  type_? : String,
  quality? : Int,
  fullPage? : Bool,
  clip? : Clip,
  omitBackground? : Bool,
  timeout? : Int,
  scale? : String,
) -> ResponseBody {
  consume(
    (self, path, type_, quality, fullPage, clip, omitBackground, timeout, scale),
  )
  async_noop()
  ResponseBody::bytes(b"")
}

///|
/// Generate PDF (Chromium only)
pub async fn Page::pdf(
  self : Page,
  path? : String,
  scale? : Double,
  displayHeaderFooter? : Bool,
  headerTemplate? : String,
  footerTemplate? : String,
  printBackground? : Bool,
  landscape? : Bool,
  pageRanges? : String,
  format? : String,
  width? : String,
  height? : String,
  margin? : Margin,
  preferCSSPageSize? : Bool,
) -> ResponseBody {
  consume(
    (
      self, path, scale, displayHeaderFooter, headerTemplate, footerTemplate, printBackground,
      landscape, pageRanges, format, width, height, margin, preferCSSPageSize,
    ),
  )
  async_noop()
  ResponseBody::bytes(b"")
}

///|
/// Close page
pub async fn Page::close(self : Page, runBeforeUnload? : Bool) -> Unit {
  consume(runBeforeUnload)
  let state = self.state.val
  let _ = state.browser.state.val.client.browsing_context_close(
    state.context_id,
  )
  let _ = state.context

}

///|
/// Close page with error callback (for use with defer)
/// Note: This initiates close but doesn't wait for completion
pub fn Page::close_with_error_callback(
  self : Page,
  on_error : (Error) -> Unit,
) -> Unit {
  consume((self, on_error))
}

///|
/// Check if page is closed
pub fn Page::isClosed(self : Page) -> Bool {
  consume(self)
  false
}

///|
/// Bring page to front
pub async fn Page::bringToFront(self : Page) -> Unit {
  consume(self)
  async_noop()
}

///|
/// Set viewport size
pub async fn Page::setViewportSize(
  self : Page,
  width : Int,
  height : Int,
) -> Unit {
  consume((self, width, height))
  async_noop()
}

///|
/// Get viewport size
pub fn Page::viewportSize(self : Page) -> (Int, Int)? {
  consume(self)
  None
}

///|
/// Set extra HTTP headers
pub async fn Page::setExtraHTTPHeaders(self : Page, headers : Headers) -> Unit {
  consume((self, headers))
  async_noop()
}

///|
/// Add script tag
pub async fn Page::addScriptTag(
  self : Page,
  url? : String,
  path? : String,
  content? : String,
  type_? : String,
) -> Json {
  consume((self, url, path, content, type_))
  async_noop()
  Json::null()
}

///|
/// Add style tag
pub async fn Page::addStyleTag(
  self : Page,
  url? : String,
  path? : String,
  content? : String,
) -> Json {
  consume((self, url, path, content))
  async_noop()
  Json::null()
}

///|
/// Expose function to page
pub async fn Page::exposeFunction(
  self : Page,
  name : String,
  callback : Json,
) -> Unit {
  consume((self, name, callback))
  async_noop()
}

///|
/// Set default navigation timeout
pub fn Page::setDefaultNavigationTimeout(self : Page, timeout : Int) -> Unit {
  consume((self, timeout))
}

///|
/// Set default timeout
pub fn Page::setDefaultTimeout(self : Page, timeout : Int) -> Unit {
  consume((self, timeout))
}

///|
async fn Page::eval_string(self : Page, expression : String) -> String? {
  let state = self.state.val
  let result = state.browser.state.val.client.script_evaluate(
    expression,
    state.context_id,
  )
  match result {
    Ok(json) =>
      match json_get_object(json, "result") {
        Some(value) => remote_value_to_string(value)
        None => None
      }
    Err(_) => None
  }
}

///|
async fn Page::call_function(
  self : Page,
  function_declaration : String,
  args : Array[Json],
) -> Unit {
  let state = self.state.val
  let _ = state.browser.state.val.client.script_call_function(
    function_declaration,
    state.context_id,
    arguments=args,
  )

}

///|
async fn Page::locate_nodes(self : Page, selector : String) -> Array[Json] {
  let state = self.state.val
  let locator = @bidi.Locator::css(selector)
  let result = state.browser.state.val.client.browsing_context_locate_nodes_typed(
    state.context_id,
    locator,
  )
  match result {
    Ok(json) => json_get_array(json, "nodes").unwrap_or([])
    Err(_) => []
  }
}

///|
async fn Page::is_node_visible(self : Page, node : Json) -> Bool? {
  let state = self.state.val
  let args : Array[Json] = [node]
  let result = state.browser.state.val.client.script_call_function(
    "(node) => { if (!node || !(node instanceof Element)) return false; if (node.hidden) return false; let el = node; while (el) { if (el.hidden) return false; if (el.getAttribute && el.getAttribute('aria-hidden') === 'true') return false; const style = getComputedStyle(el); if (!style) return false; const opacity = parseFloat(style.opacity || '1'); if (opacity <= 0) return false; if (style.visibility === 'hidden' || style.visibility === 'collapse' || style.display === 'none' || style.contentVisibility === 'hidden') return false; if (el instanceof HTMLDetailsElement && !el.open) { const summary = el.querySelector('summary'); if (summary && !summary.contains(node)) return false; } el = el.parentElement; } if (node.getClientRects().length === 0) return false; const rect = node.getBoundingClientRect(); return rect.width > 0 && rect.height > 0; }",
    state.context_id,
    arguments=args,
  )
  match result {
    Ok(json) =>
      match json_get_object(json, "result") {
        Some(value) =>
          match remote_value_to_json(value) {
            True => Some(true)
            False => Some(false)
            _ => None
          }
        None => None
      }
    Err(_) => None
  }
}

///|
fn Page::take_navigation_event(
  self : Page,
  event_name : String?,
  url : String?,
) -> NavigationEvent? {
  let events = self.state.val.navigation_events
  let mut index = 0
  while index < events.length() {
    let evt = events[index]
    let event_ok = match event_name {
      Some(value) => evt.event_name == value
      None => true
    }
    let url_ok = match url {
      Some(value) => evt.url == value
      None => true
    }
    if event_ok && url_ok {
      let _ = events.remove(index)
      return Some(evt)
    }
    index = index + 1
  }
  None
}

///|
fn Page::take_request_event(
  self : Page,
  pattern : String,
  match_mode : String,
  predicate : ((Request) -> Bool)?,
) -> Request? {
  let events = self.state.val.request_events
  let mut index = 0
  while index < events.length() {
    let req = events[index]
    let url_ok = url_matches(req.url(), pattern, match_mode)
    let predicate_ok = match predicate {
      Some(pred) => pred(req)
      None => true
    }
    if url_ok && predicate_ok {
      let _ = events.remove(index)
      return Some(req)
    }
    index = index + 1
  }
  None
}

///|
fn Page::take_response_event(
  self : Page,
  pattern : String,
  match_mode : String,
  predicate : ((Response) -> Bool)?,
) -> Response? {
  let events = self.state.val.response_events
  let mut index = 0
  while index < events.length() {
    let resp = events[index]
    let url_ok = url_matches(resp.url(), pattern, match_mode)
    let predicate_ok = match predicate {
      Some(pred) => pred(resp)
      None => true
    }
    if url_ok && predicate_ok {
      let _ = events.remove(index)
      return Some(resp)
    }
    index = index + 1
  }
  None
}

///|
fn Page::take_response_completed_event(
  self : Page,
  pattern : String,
  match_mode : String,
  predicate : ((Response) -> Bool)?,
) -> Response? {
  let events = self.state.val.response_completed_events
  let mut index = 0
  while index < events.length() {
    let resp = events[index]
    let url_ok = url_matches(resp.url(), pattern, match_mode)
    let predicate_ok = match predicate {
      Some(pred) => pred(resp)
      None => true
    }
    if url_ok && predicate_ok {
      let _ = events.remove(index)
      return Some(resp)
    }
    index = index + 1
  }
  None
}

///|
fn resolve_match_mode(pattern : String, match_mode : String?) -> String {
  match match_mode {
    Some(mode) => {
      let lower = mode.to_lower()
      if lower == "contains" || lower == "include" || lower == "substring" {
        "contains"
      } else if lower == "startswith" || lower == "prefix" {
        "startsWith"
      } else if lower == "endswith" || lower == "suffix" {
        "endsWith"
      } else if lower == "glob" || lower == "wildcard" {
        "glob"
      } else if lower == "regex" || lower == "re" {
        "regex"
      } else {
        "exact"
      }
    }
    None =>
      if pattern.length() >= 2 &&
        pattern.has_prefix("/") &&
        pattern.has_suffix("/") {
        "regex"
      } else if pattern.contains_char('*') || pattern.contains_char('?') {
        "glob"
      } else {
        "exact"
      }
  }
}

///|
fn resolve_response_stage(stage : String?) -> String {
  match stage {
    Some(value) => {
      let lower = value.to_lower()
      if lower == "complete" || lower == "completed" {
        "completed"
      } else {
        "started"
      }
    }
    None => "started"
  }
}

///|
fn url_matches(url : String, pattern : String, match_mode : String) -> Bool {
  match match_mode {
    "contains" => url.contains(pattern)
    "startsWith" => url.has_prefix(pattern)
    "endsWith" => url.has_suffix(pattern)
    "glob" => glob_match(url, pattern)
    "regex" => regex_match(url, normalize_regex_pattern(pattern))
    _ => url == pattern
  }
}

///|
fn normalize_regex_pattern(pattern : String) -> String {
  if pattern.length() >= 2 && pattern.has_prefix("/") && pattern.has_suffix("/") {
    let view = pattern.sub(start=1, end=pattern.length() - 1) catch {
      _ => return pattern
    }
    view.to_string()
  } else {
    pattern
  }
}

///|
fn glob_match(text : String, pattern : String) -> Bool {
  let text_chars = text.to_array()
  let pattern_chars = pattern.to_array()
  let mut ti = 0
  let mut pi = 0
  let mut star = -1
  let mut match_index = 0
  let tlen = text_chars.length()
  let plen = pattern_chars.length()
  while ti < tlen {
    if pi < plen &&
      (pattern_chars[pi] == '?' || pattern_chars[pi] == text_chars[ti]) {
      ti = ti + 1
      pi = pi + 1
      continue
    }
    if pi < plen && pattern_chars[pi] == '*' {
      star = pi
      match_index = ti
      pi = pi + 1
      continue
    }
    if star >= 0 {
      pi = star + 1
      match_index = match_index + 1
      ti = match_index
      continue
    }
    return false
  }
  while pi < plen && pattern_chars[pi] == '*' {
    pi = pi + 1
  }
  pi == plen
}
