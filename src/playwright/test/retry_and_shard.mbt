///|
pub fn default_test_config() -> @test_utils.TestConfig {
  @test_utils.default_test_config()
}

///|
pub fn current_test_config() -> @test_utils.TestConfig {
  @test_utils.current_test_config()
}

///|
pub fn set_test_config(config : @test_utils.TestConfig) -> Unit {
  @test_utils.set_test_config(config)
}

///|
pub fn reset_test_config() -> Unit {
  @test_utils.reset_test_config()
}

///|
pub fn configure_test(
  retry_times? : Int,
  timeout_ms? : Int,
  expect_timeout_ms? : Int,
  expect_interval_ms? : Int,
  slow_timeout_ms? : Int,
  shard_index? : Int,
  shard_total? : Int,
) -> Unit {
  @test_utils.configure_test(
    retry_times?,
    timeout_ms?,
    expect_timeout_ms?,
    expect_interval_ms?,
    slow_timeout_ms?,
    shard_index?,
    shard_total?,
  )
}

///|
pub fn[T] with_test_config(
  config : @test_utils.TestConfig,
  run : () -> T raise,
) -> T raise {
  @test_utils.with_test_config(config, run)
}

///|
pub async fn[T] with_test_config_async(
  config : @test_utils.TestConfig,
  run : async () -> T,
) -> T {
  @test_utils.with_test_config_async(config, run)
}

///|
pub async fn[T] retry(times? : Int, run : async () -> T) -> T {
  @test_utils.retry(times?, run)
}

///|
pub async fn[T] timeout(ms? : Int, run : async () -> T) -> T {
  @test_utils.timeout(ms?, run)
}

///|
pub async fn to_pass(
  run : async () -> Unit,
  timeout? : Int,
  interval? : Int,
) -> Unit {
  @test_utils.to_pass(run, timeout?, interval?)
}

///|
pub async fn[T] slow(run : async () -> T, timeout_ms? : Int) -> T {
  @test_utils.slow(run, timeout_ms?)
}

///|
pub fn[T] step(name : String, run : () -> T) -> T {
  @test_utils.step(name, run)
}

///|
pub async fn[T] step_async(name : String, run : async () -> T) -> T {
  @test_utils.step_async(name, run)
}

///|
pub fn skip(run : () -> Unit) -> Unit {
  @test_utils.skip(run)
}

///|
pub fn skip_if(condition~ : Bool, run : () -> Unit) -> Unit {
  @test_utils.skip_if(condition~, run)
}

///|
pub fn skip_async(run : async () -> Unit) -> Unit {
  @test_utils.skip_async(run)
}

///|
pub async fn skip_if_async(condition~ : Bool, run : async () -> Unit) -> Unit {
  @test_utils.skip_if_async(condition~, run)
}

///|
#callsite(autofill(loc))
pub fn fail(
  run : () -> Unit raise,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit raise {
  @test_utils.fail(run, msg?, loc~)
}

///|
#callsite(autofill(loc))
pub fn fixme(
  run : () -> Unit raise,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit raise {
  @test_utils.fixme(run, msg?, loc~)
}

///|
#callsite(autofill(loc))
pub async fn fail_async(
  run : async () -> Unit,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit {
  @test_utils.fail_async(run, msg?, loc~)
}

///|
#callsite(autofill(loc))
pub async fn fixme_async(
  run : async () -> Unit,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit {
  @test_utils.fixme_async(run, msg?, loc~)
}

///|
pub fn in_shard(
  item_index~ : Int,
  item_total~ : Int,
  shard_index? : Int,
  shard_total? : Int,
) -> Bool {
  @test_utils.in_shard(item_index~, item_total~, shard_index?, shard_total?)
}

///|
pub fn shard(
  item_index~ : Int,
  item_total~ : Int,
  shard_index? : Int,
  shard_total? : Int,
  run : () -> Unit,
) -> Unit {
  @test_utils.shard(item_index~, item_total~, shard_index?, shard_total?, run)
}

///|
pub async fn shard_async(
  item_index~ : Int,
  item_total~ : Int,
  shard_index? : Int,
  shard_total? : Int,
  run : async () -> Unit,
) -> Unit {
  @test_utils.shard_async(
    item_index~,
    item_total~,
    shard_index?,
    shard_total?,
    run,
  )
}
