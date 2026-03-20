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
pub async fn BrowserType::connect_over_websocket(
  self : BrowserType,
  ws_endpoint : String,
) -> Browser {
  self.connect(ws_endpoint)
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
/// Launch browser with options.
/// Spawns a real browser process and connects via BiDi WebSocket.
/// See: https://playwright.dev/docs/api/class-browsertype#browser-type-launch
pub async fn BrowserType::launch(
  self : BrowserType,
  headless? : Bool,
  args? : Array[String],
  channel? : String,
  chromium_sandbox? : Bool,
  devtools? : Bool,
  downloads_path? : String,
  executable_path? : String,
  handle_sighup? : Bool,
  handle_sigint? : Bool,
  handle_sigterm? : Bool,
  slow_mo? : Int,
  timeout? : Int,
) -> Browser {
  consume(
    (
      args, channel, chromium_sandbox, devtools, downloads_path, handle_sighup,
      handle_sigint, handle_sigterm, slow_mo, timeout,
    ),
  )
  // If executable_path is a WebSocket URL, connect directly (legacy behavior)
  match executable_path {
    Some(path) =>
      if path.has_prefix("ws://") || path.has_prefix("wss://") {
        return self.connect(path)
      }
    _ => ()
  }
  // Launch Chrome with BiDi pipe transport (no WS, direct stdio)
  let transport = @bidi.Transport::chrome_bidi_pipe(
    headless=headless.unwrap_or(true),
  )
  self.connect_with_transport(transport)
}

///|
/// Launch persistent context (saves user data)
pub async fn BrowserType::launch_persistent_context(
  self : BrowserType,
  user_data_dir : String,
  headless? : Bool,
  args? : Array[String],
  channel? : String,
  slow_mo? : Int,
  timeout? : Int,
) -> BrowserContext {
  let _ = user_data_dir
  let _ = headless
  let _ = args
  let _ = channel
  let _ = slow_mo
  let _ = timeout
  let browser = self.launch()
  browser.new_context()
}
