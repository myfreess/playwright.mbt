///|
pub struct PollExpect[T] {
  probe : async () -> T
  timeout_ms : Int
  interval_ms : Int
}

///|
fn normalize_poll_timeout(timeout : Int?) -> Int {
  match timeout {
    Some(value) => if value <= 0 { 1 } else { value }
    None => 5_000
  }
}

///|
fn normalize_poll_interval(interval : Int?) -> Int {
  match interval {
    Some(value) => if value <= 0 { 1 } else { value }
    None => 50
  }
}

///|
pub fn[T] poll(
  probe : async () -> T,
  timeout? : Int,
  interval? : Int,
) -> PollExpect[T] {
  {
    probe,
    timeout_ms: normalize_poll_timeout(timeout),
    interval_ms: normalize_poll_interval(interval),
  }
}

///|
pub fn[T] expect_poll(
  probe : async () -> T,
  timeout? : Int,
  interval? : Int,
) -> PollExpect[T] {
  poll(probe, timeout?, interval?)
}

///|
#callsite(autofill(loc))
pub async fn[T : Eq + Show] PollExpect::to_be(
  self : PollExpect[T],
  expected : T,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit {
  to_pass(timeout=self.timeout_ms, interval=self.interval_ms, async fn() {
    let value = (self.probe)()
    @playwright.expect(value).to_be(expected, msg?, loc~)
  })
}

///|
#callsite(autofill(loc))
pub async fn[T : Eq + Show] PollExpect::to_equal(
  self : PollExpect[T],
  expected : T,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit {
  self.to_be(expected, msg?, loc~)
}

///|
#callsite(autofill(loc))
pub async fn PollExpect::to_match(
  self : PollExpect[String],
  pattern : String,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit {
  to_pass(timeout=self.timeout_ms, interval=self.interval_ms, async fn() {
    let value = (self.probe)()
    @playwright.expect(value).to_match(pattern, msg?, loc~)
  })
}

///|
#callsite(autofill(loc))
pub async fn PollExpect::to_contain(
  self : PollExpect[String],
  expected : String,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit {
  to_pass(timeout=self.timeout_ms, interval=self.interval_ms, async fn() {
    let value = (self.probe)()
    @playwright.expect(value).to_contain(expected, msg?, loc~)
  })
}
