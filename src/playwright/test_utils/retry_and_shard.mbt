///|
fn normalize_retry_times(times : Int) -> Int {
  if times <= 1 {
    1
  } else {
    times
  }
}

///|
fn normalize_timeout_ms(timeout : Int?, fallback : Int) -> Int {
  match timeout {
    Some(value) => if value <= 0 { 1 } else { value }
    None => fallback
  }
}

///|
fn[T] consume(value : T) -> Unit {
  let _ = value

}

///|
async fn sleep_ms(ms : Int) -> Unit {
  if ms <= 0 {
    return
  }
  let queue : @async.Queue[Unit] = @async.Queue::new(
    kind=@aqueue.Kind::Unbounded,
  )
  let _ = @async.with_timeout_opt(ms, async fn() -> Unit { queue.get() })

}

///|
pub async fn[T] retry(times~ : Int, run : async () -> T) -> T {
  let max_attempts = normalize_retry_times(times)
  for attempt = 1 {
    let result : Result[T, Error] = try? run()
    match result {
      Ok(value) => break value
      Err(_) => {
        if attempt >= max_attempts {
          break result.unwrap_or_error()
        }
        continue attempt + 1
      }
    }
  }
}

///|
pub async fn[T] timeout(ms~ : Int, run : async () -> T) -> T {
  let timeout_ms = if ms <= 0 { 1 } else { ms }
  @async.with_timeout(timeout_ms, run)
}

///|
pub async fn to_pass(
  run : async () -> Unit,
  timeout? : Int,
  interval? : Int,
) -> Unit {
  let timeout_ms = normalize_timeout_ms(timeout, 5_000)
  let interval_ms = normalize_timeout_ms(interval, 50)
  let start = @async.now()
  for attempt = 0 {
    let result : Result[Unit, Error] = try? run()
    match result {
      Ok(_) => return ()
      Err(_) => {
        let elapsed = (@async.now() - start).to_int()
        if elapsed >= timeout_ms {
          result.unwrap_or_error()
        }
        let remaining = timeout_ms - elapsed
        let wait_ms = if interval_ms < remaining {
          interval_ms
        } else {
          remaining
        }
        sleep_ms(wait_ms)
        continue attempt + 1
      }
    }
  }
}

///|
pub async fn[T] slow(run : async () -> T, timeout_ms? : Int) -> T {
  let limit_ms = normalize_timeout_ms(timeout_ms, 30_000)
  timeout(ms=limit_ms, run)
}

///|
pub fn[T] step(name : String, run : () -> T) -> T {
  consume(name)
  run()
}

///|
pub async fn[T] step_async(name : String, run : async () -> T) -> T {
  consume(name)
  run()
}

///|
pub fn skip(run : () -> Unit) -> Unit {
  consume(run)
}

///|
pub fn skip_if(condition~ : Bool, run : () -> Unit) -> Unit {
  if not(condition) {
    run()
  }
}

///|
pub fn skip_async(run : async () -> Unit) -> Unit {
  consume(run)
}

///|
pub async fn skip_if_async(condition~ : Bool, run : async () -> Unit) -> Unit {
  if not(condition) {
    run()
  }
}

///|
#callsite(autofill(loc))
pub fn fail(
  run : () -> Unit raise,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit raise {
  let result : Result[Unit, Error] = try? run()
  match result {
    Ok(_) => {
      let message = match msg {
        Some(value) => value
        None => "expected block to fail"
      }
      assert_eq(true, false, msg=message, loc~)
    }
    Err(_) => ()
  }
}

///|
#callsite(autofill(loc))
pub fn fixme(
  run : () -> Unit raise,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit raise {
  fail(run, msg?, loc~)
}

///|
#callsite(autofill(loc))
pub async fn fail_async(
  run : async () -> Unit,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit {
  let result : Result[Unit, Error] = try? run()
  match result {
    Ok(_) => {
      let message = match msg {
        Some(value) => value
        None => "expected block to fail"
      }
      assert_eq(true, false, msg=message, loc~)
    }
    Err(_) => ()
  }
}

///|
#callsite(autofill(loc))
pub async fn fixme_async(
  run : async () -> Unit,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit {
  fail_async(run, msg?, loc~)
}

///|
fn normalize_shard_total(shard_total : Int) -> Int {
  if shard_total <= 1 {
    1
  } else {
    shard_total
  }
}

///|
fn normalize_shard_index(shard_index : Int, shard_total : Int) -> Int {
  if shard_index <= 1 {
    1
  } else if shard_index > shard_total {
    shard_total
  } else {
    shard_index
  }
}

///|
pub fn in_shard(
  item_index~ : Int,
  item_total~ : Int,
  shard_index~ : Int,
  shard_total~ : Int,
) -> Bool {
  if item_total <= 0 {
    return false
  }
  if item_index < 0 || item_index >= item_total {
    return false
  }
  let total = normalize_shard_total(shard_total)
  let index = normalize_shard_index(shard_index, total)
  let start = (index - 1) * item_total / total
  let end = index * item_total / total
  item_index >= start && item_index < end
}

///|
pub fn shard(
  item_index~ : Int,
  item_total~ : Int,
  shard_index~ : Int,
  shard_total~ : Int,
  run : () -> Unit,
) -> Unit {
  if in_shard(item_index~, item_total~, shard_index~, shard_total~) {
    run()
  }
}

///|
pub async fn shard_async(
  item_index~ : Int,
  item_total~ : Int,
  shard_index~ : Int,
  shard_total~ : Int,
  run : async () -> Unit,
) -> Unit {
  if in_shard(item_index~, item_total~, shard_index~, shard_total~) {
    run()
  }
}
