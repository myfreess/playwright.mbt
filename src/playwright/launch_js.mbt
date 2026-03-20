///| Browser process launcher (JS target)
///| Uses Playwright's Node.js API to launch a browser with BiDi support.

///|
/// Launch a browser using Playwright's chromium.launchServer().
/// Returns the WebSocket endpoint URL with BiDi support.
/// Requires @playwright/test to be installed (npx playwright install chromium).
extern "js" fn ffi_launch_browser_process(headless : Bool) -> @js_async.Promise[String] =
  #| async (headless) => {
  #|   // Use Playwright's Node.js API to get a proper BiDi-capable server
  #|   const { chromium } = await import('playwright-core');
  #|   const server = await chromium.launchServer({
  #|     headless: headless,
  #|   });
  #|   const wsEndpoint = server.wsEndpoint();
  #|
  #|   // Store server ref for cleanup
  #|   if (!globalThis.__pw_browser_servers) {
  #|     globalThis.__pw_browser_servers = [];
  #|   }
  #|   globalThis.__pw_browser_servers.push(server);
  #|
  #|   return wsEndpoint;
  #| }

///|
/// Close all browser servers launched by this session
extern "js" fn ffi_kill_browser_processes() -> Unit =
  #| () => {
  #|   if (globalThis.__pw_browser_servers) {
  #|     for (const server of globalThis.__pw_browser_servers) {
  #|       try { server.close(); } catch {}
  #|     }
  #|     globalThis.__pw_browser_servers = [];
  #|   }
  #| }

///|
/// Launch browser process and return WS endpoint URL
async fn launch_browser_process(headless : Bool) -> String {
  ffi_launch_browser_process(headless).wait()
}
