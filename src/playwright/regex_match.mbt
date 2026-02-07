///|
/// Regex matching backed by moonbitlang/regexp

///|
fn regex_match(text : String, pattern : String) -> Bool {
  try {
    let compiled = @regexp.compile(pattern[:])
    compiled.match_(text[:]) is Some(_)
  } catch {
    _ => false
  }
}
