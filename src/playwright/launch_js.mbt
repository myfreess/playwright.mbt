///| Browser process launcher (JS target)
///| Uses chromium-bidi's WebSocketServer for full BiDi protocol support.
///| Requires: chromium-bidi, ws, @puppeteer/browsers npm packages + Chrome binary.

///|
/// Launch chromium-bidi WebSocket server and create a BiDi session.
/// Returns the BiDi WebSocket URL (ws://localhost:PORT/session/ID).
extern "js" fn ffi_launch_browser_process(headless : Bool) -> @js_async.Promise[String] =
  #| async (headless) => {
  #|   const { existsSync } = await import('node:fs');
  #|   const { WebSocketServer } = await import('chromium-bidi/bidiServer/WebSocketServer.js');
  #|
  #|   // Find Chrome binary
  #|   const candidates = [
  #|     process.env.CHROME_PATH,
  #|     process.env.BROWSER_BIN,
  #|     '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  #|     '/Applications/Chromium.app/Contents/MacOS/Chromium',
  #|     '/usr/bin/google-chrome',
  #|     '/usr/bin/google-chrome-stable',
  #|     '/usr/bin/chromium',
  #|     '/usr/bin/chromium-browser',
  #|     '/snap/bin/chromium',
  #|   ].filter(Boolean);
  #|
  #|   let chromeBinary = null;
  #|   for (const p of candidates) {
  #|     if (existsSync(p)) { chromeBinary = p; break; }
  #|   }
  #|   if (!chromeBinary) {
  #|     throw new Error('Chrome/Chromium not found. Set CHROME_PATH env var.');
  #|   }
  #|
  #|   // Start BiDi WS server on random port
  #|   const port = 9990 + Math.floor(Math.random() * 1000);
  #|   const server = new WebSocketServer(port, false);
  #|
  #|   // Store for cleanup
  #|   if (!globalThis.__pw_bidi_servers) globalThis.__pw_bidi_servers = [];
  #|   globalThis.__pw_bidi_servers.push(server);
  #|
  #|   // Wait for server to be ready
  #|   await new Promise(r => setTimeout(r, 500));
  #|
  #|   // Create session via HTTP POST /session
  #|   const sessionResp = await fetch(`http://127.0.0.1:${port}/session`, {
  #|     method: 'POST',
  #|     headers: { 'Content-Type': 'application/json' },
  #|     body: JSON.stringify({
  #|       capabilities: {
  #|         alwaysMatch: {
  #|           'goog:chromeOptions': {
  #|             binary: chromeBinary,
  #|             args: headless ? ['--headless=new'] : [],
  #|           },
  #|         },
  #|       },
  #|     }),
  #|   });
  #|
  #|   const sessionData = await sessionResp.json();
  #|   const wsUrl = sessionData.value?.capabilities?.webSocketUrl;
  #|   if (!wsUrl) {
  #|     throw new Error('Failed to create BiDi session: ' + JSON.stringify(sessionData));
  #|   }
  #|
  #|   return wsUrl;
  #| }

///|
/// Close all BiDi servers launched by this session
extern "js" fn ffi_kill_browser_processes() -> Unit =
  #| () => {
  #|   // Note: chromium-bidi WebSocketServer doesn't expose a clean close() method.
  #|   // Browser instances are cleaned up when WS connections close.
  #|   globalThis.__pw_bidi_servers = [];
  #| }

///|
/// Launch browser process and return BiDi WS endpoint URL
async fn launch_browser_process(headless : Bool) -> String {
  ffi_launch_browser_process(headless).wait()
}
