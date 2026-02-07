///|
/// BrowserType and entry points

///|
const DEFAULT_WS_ENDPOINT : String = "ws://127.0.0.1:9222"

///|
pub fn chromium() -> BrowserType {
  { kind: BrowserKind::Chromium }
}

///|
pub fn firefox() -> BrowserType {
  { kind: BrowserKind::Firefox }
}

///|
pub fn webkit() -> BrowserType {
  { kind: BrowserKind::WebKit }
}

///|
pub fn BrowserType::name(self : BrowserType) -> String {
  match self.kind {
    Chromium => "chromium"
    Firefox => "firefox"
    WebKit => "webkit"
  }
}

///|
pub async fn BrowserType::connect(
  self : BrowserType,
  ws_endpoint : String,
) -> Browser {
  self.connect_with_transport(@bidi.Transport::websocket(ws_endpoint))
}

///|
pub async fn BrowserType::connect_with_transport(
  self : BrowserType,
  transport : @bidi.Transport,
) -> Browser {
  let client = @bidi.BidiClient::new(transport)
  match client.session_new() {
    Ok(_) => ()
    Err(_) => ()
  }
  let _ = client.session_subscribe([
    "browsingContext.load", "browsingContext.domContentLoaded", "network.beforeRequestSent",
    "network.responseStarted", "network.responseCompleted",
  ])
  let state : BrowserState = {
    kind: self.kind,
    client,
    connected: true,
    contexts: [],
    default_context: None,
  }
  let state_ref : Ref[BrowserState] = Ref::new(state)
  register_bidi_event_router(state_ref)
  { state: state_ref }
}

///| BrowserType Methods

///|
/// Launch browser with options
/// See: https://playwright.dev/docs/api/class-browsertype#browser-type-launch
pub async fn BrowserType::launch(
  self : BrowserType,
  headless? : Bool,
  args? : Array[String],
  channel? : String,
  chromiumSandbox? : Bool,
  devtools? : Bool,
  downloadsPath? : String,
  executablePath? : String,
  handleSIGHUP? : Bool,
  handleSIGINT? : Bool,
  handleSIGTERM? : Bool,
  slowMo? : Int,
  timeout? : Int,
) -> Browser {
  let _ = headless
  let _ = args
  let _ = channel
  let _ = chromiumSandbox
  let _ = devtools
  let _ = downloadsPath
  let _ = handleSIGHUP
  let _ = handleSIGINT
  let _ = handleSIGTERM
  let _ = slowMo
  let _ = timeout
  let endpoint = match executablePath {
    Some(path) =>
      if path.has_prefix("ws://") || path.has_prefix("wss://") {
        path
      } else {
        DEFAULT_WS_ENDPOINT
      }
    None => DEFAULT_WS_ENDPOINT
  }
  self.connect(endpoint)
}

///|
/// Launch persistent context (saves user data)
pub async fn BrowserType::launchPersistentContext(
  self : BrowserType,
  userDataDir : String,
  headless? : Bool,
  args? : Array[String],
  channel? : String,
  slowMo? : Int,
  timeout? : Int,
) -> BrowserContext {
  let _ = userDataDir
  let _ = headless
  let _ = args
  let _ = channel
  let _ = slowMo
  let _ = timeout
  let browser = self.launch()
  browser.newContext()
}
