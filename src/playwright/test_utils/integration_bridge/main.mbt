///|
fn parse_int_arg(args : Array[String], index : Int, name : String) -> Int {
  match args.get(index) {
    Some(value) =>
      try @strconv.parse_int(value.to_string_view(), base=10) catch {
        _ => @abort.abort("invalid int arg: " + name + "=" + value)
      } noraise {
        parsed => parsed
      }
    None => @abort.abort("missing required arg: " + name)
  }
}

///|
fn ensure(condition : Bool, message : String) -> Unit {
  if not(condition) {
    @abort.abort(message)
  }
}

///|
async fn main {
  let _ = @async.now()
  let args = @env.args()
  let argc = args.length()
  ensure(argc >= 6, "expected at least 6 args")
  let offset = argc - 6
  let retry_times = parse_int_arg(args, offset + 0, "retry_times")
  let timeout_ms = parse_int_arg(args, offset + 1, "timeout_ms")
  let expect_timeout_ms = parse_int_arg(args, offset + 2, "expect_timeout_ms")
  let expect_interval_ms = parse_int_arg(args, offset + 3, "expect_interval_ms")
  let shard_index = parse_int_arg(args, offset + 4, "shard_index")
  let shard_total = parse_int_arg(args, offset + 5, "shard_total")
  @test_utils.reset_test_config()
  @test_utils.configure_test(
    retry_times~,
    timeout_ms~,
    expect_timeout_ms~,
    expect_interval_ms~,
    shard_index~,
    shard_total~,
  )
  let attempts : Ref[Int] = { val: 0 }
  let value = try
    @test_utils.retry(async fn() -> Int {
      attempts.val = attempts.val + 1
      if attempts.val < retry_times {
        assert_eq(true, false, msg="retry configured by playwright")
      }
      attempts.val
    })
  catch {
    _ => @abort.abort("retry should eventually succeed")
  } noraise {
    v => v
  }
  ensure(value == retry_times, "retry does not use configured retry_times")
  let timeout_value = try @test_utils.timeout(async fn() -> Int { 7 }) catch {
    _ => @abort.abort("timeout should not fail for immediate callback")
  } noraise {
    v => v
  }
  ensure(timeout_value == 7, "timeout should execute successful callback")
  let hit : Ref[Int] = { val: 0 }
  @test_utils.shard(item_index=0, item_total=2, fn() { hit.val = hit.val + 1 })
  @test_utils.shard(item_index=1, item_total=2, fn() { hit.val = hit.val + 1 })
  let expected_hit = (if @test_utils.in_shard(item_index=0, item_total=2) {
      1
    } else {
      0
    }) +
    (if @test_utils.in_shard(item_index=1, item_total=2) { 1 } else { 0 })
  ensure(hit.val == expected_hit, "shard should respect configured shard")
  let should_fail = try? @test_utils.to_pass(async fn() {
    assert_eq(true, false, msg="configured expect timeout")
  })
  match should_fail {
    Ok(_) => @abort.abort("to_pass should fail under configured timeout")
    Err(_) => ()
  }
  let config = @test_utils.current_test_config()
  ensure(config.retry_times == retry_times, "retry_times mismatch")
  ensure(config.timeout_ms == timeout_ms, "timeout_ms mismatch")
  ensure(
    config.expect_timeout_ms == expect_timeout_ms,
    "expect_timeout_ms mismatch",
  )
  ensure(
    config.expect_interval_ms == expect_interval_ms,
    "expect_interval_ms mismatch",
  )
  ensure(config.shard_index == shard_index, "shard_index mismatch")
  ensure(config.shard_total == shard_total, "shard_total mismatch")
}
