///|
fn assert_failure(f : () -> Unit raise) -> Unit raise {
  let failed = try {
    f()
    false
  } catch {
    _ => true
  }
  assert_eq(failed, true)
}

///|
test "expect to_be and to_equal" {
  expect(1).to_be(1)
  expect("a").to_equal("a")
}

///|
test "expect to_match" {
  expect("hello").to_match("h.llo")
}

///|
test "expect to_match supports non-capturing group" {
  expect("ab").to_match("(?:a)b")
}

///|
test "expect failure" {
  assert_failure(fn() { expect(1).to_be(2) })
  assert_failure(fn() { expect("hello").to_match("z+") })
}

///|
test "expect to_contain and to_have_length" {
  expect("hello world").to_contain("world")
  expect("hello").to_have_length(5)
}

///|
test "expect array helpers" {
  expect([1, 2, 3]).to_contain_item(2)
  expect([1, 2, 3]).to_have_length_items(3)
}

///|
test "expect numeric comparisons" {
  expect(3).to_be_greater_than(2)
  expect(2).to_be_less_than(3)
  expect(3.1415).to_be_close_to(3.14, precision=2)
}

///|
test "expect truthy and falsy" {
  expect(true).to_be_truthy()
  expect(false).to_be_falsy()
}
