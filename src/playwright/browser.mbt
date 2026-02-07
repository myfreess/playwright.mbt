///|
/// Browser methods

///|
pub async fn Browser::close(self : Browser) -> Unit {
  let state = self.state.val
  state.connected = false
  match state.client.session_end() {
    Ok(_) => ()
    Err(_) => ()
  }
  state.client.close() |> ignore
}

///|
/// Close browser with error callback (for use with defer)
/// Note: This initiates close but doesn't wait for completion
pub fn Browser::close_with_error_callback(
  self : Browser,
  on_error : (Error) -> Unit,
) -> Unit {
  let _ = on_error
  self.state.val.connected = false
}

///|
/// Create new browser context
pub async fn Browser::newContext(
  self : Browser,
  viewport? : (Int, Int),
  userAgent? : String,
  locale? : String,
  timezoneId? : String,
  geolocation? : (Double, Double),
  permissions? : Array[String],
  colorScheme? : String,
  reducedMotion? : String,
  forcedColors? : String,
  acceptDownloads? : Bool,
  ignoreHTTPSErrors? : Bool,
  javaScriptEnabled? : Bool,
  bypassCSP? : Bool,
  offline? : Bool,
  deviceScaleFactor? : Double,
  isMobile? : Bool,
  hasTouch? : Bool,
) -> BrowserContext {
  let _ = viewport
  let _ = userAgent
  let _ = locale
  let _ = timezoneId
  let _ = geolocation
  let _ = permissions
  let _ = colorScheme
  let _ = reducedMotion
  let _ = forcedColors
  let _ = acceptDownloads
  let _ = ignoreHTTPSErrors
  let _ = javaScriptEnabled
  let _ = bypassCSP
  let _ = offline
  let _ = deviceScaleFactor
  let _ = isMobile
  let _ = hasTouch
  let state = self.state.val
  let user_context = match state.client.browser_create_user_context() {
    Ok(id) => id
    Err(_) => "default"
  }
  let ctx_state : BrowserContextState = {
    browser: self,
    user_context,
    pages: [],
  }
  let ctx : BrowserContext = { state: Ref::new(ctx_state) }
  state.contexts.push(ctx.state)
  ctx
}

///|
/// Create new page (with default context)
pub async fn Browser::newPage(
  self : Browser,
  viewport? : (Int, Int),
  userAgent? : String,
  locale? : String,
  timezoneId? : String,
  ignoreHTTPSErrors? : Bool,
  javaScriptEnabled? : Bool,
  bypassCSP? : Bool,
  offline? : Bool,
  colorScheme? : String,
  deviceScaleFactor? : Double,
  isMobile? : Bool,
  hasTouch? : Bool,
) -> Page {
  let _ = viewport
  let _ = userAgent
  let _ = locale
  let _ = timezoneId
  let _ = ignoreHTTPSErrors
  let _ = javaScriptEnabled
  let _ = bypassCSP
  let _ = offline
  let _ = colorScheme
  let _ = deviceScaleFactor
  let _ = isMobile
  let _ = hasTouch
  let ctx = self.ensure_default_context()
  ctx.newPage()
}

///|
/// Get all contexts
pub fn Browser::contexts(self : Browser) -> Array[BrowserContext] {
  let list : Array[BrowserContext] = []
  for ctx_state in self.state.val.contexts {
    let ctx : BrowserContext = { state: ctx_state }
    list.push(ctx)
  }
  list
}

///|
/// Check if browser is connected
pub fn Browser::isConnected(self : Browser) -> Bool {
  self.state.val.connected
}

///|
/// Get browser version
pub fn Browser::version(self : Browser) -> String {
  match self.state.val.kind {
    Chromium => "bidi-chromium"
    Firefox => "bidi-firefox"
    WebKit => "bidi-webkit"
  }
}

///|
fn Browser::ensure_default_context(self : Browser) -> BrowserContext {
  let state = self.state.val
  match state.default_context {
    Some(ctx) => ctx.val
    None => {
      let ctx_state : BrowserContextState = {
        browser: self,
        user_context: "default",
        pages: [],
      }
      let ctx : BrowserContext = { state: Ref::new(ctx_state) }
      state.default_context = Some(Ref::new(ctx))
      ctx
    }
  }
}
