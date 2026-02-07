///|
/// Regex matching backed by moonbitlang/core/string/regex

///|
using @string {type Regex, type Pattern}

///|
fn range_set_empty() -> Array[(Int, Int)] {
  []
}

///|
fn range_set_add_range(
  set : Array[(Int, Int)],
  start : Int,
  end : Int,
) -> Array[(Int, Int)] {
  let (lo, hi) = if start <= end { (start, end) } else { (end, start) }
  let result : Array[(Int, Int)] = []
  let mut inserted = false
  let mut cur_start = lo
  let mut cur_end = hi
  for range in set {
    let (range_start, range_end) = range
    if range_end + 1 < cur_start {
      result.push((range_start, range_end))
    } else if cur_end + 1 < range_start {
      if not(inserted) {
        result.push((cur_start, cur_end))
        inserted = true
      }
      result.push((range_start, range_end))
    } else {
      if range_start < cur_start {
        cur_start = range_start
      }
      if range_end > cur_end {
        cur_end = range_end
      }
    }
  }
  if not(inserted) {
    result.push((cur_start, cur_end))
  }
  result
}

///|
fn range_set_add_char(set : Array[(Int, Int)], ch : Char) -> Array[(Int, Int)] {
  range_set_add_range(set, ch.to_int(), ch.to_int())
}

///|
fn range_set_add_char_range(
  set : Array[(Int, Int)],
  start : Char,
  end : Char,
) -> Array[(Int, Int)] {
  range_set_add_range(set, start.to_int(), end.to_int())
}

///|
fn range_set_union(
  left : Array[(Int, Int)],
  right : Array[(Int, Int)],
) -> Array[(Int, Int)] {
  let mut result = left
  for range in right {
    let (start, end) = range
    result = range_set_add_range(result, start, end)
  }
  result
}

///|
fn range_set_diff(
  left : Array[(Int, Int)],
  right : Array[(Int, Int)],
) -> Array[(Int, Int)] {
  if left.length() == 0 {
    return []
  }
  if right.length() == 0 {
    return left
  }
  let result : Array[(Int, Int)] = []
  let mut right_index = 0
  for range in left {
    let (left_start, left_end) = range
    let mut cur_start = left_start
    let cur_end = left_end
    while right_index < right.length() {
      let (_, right_end) = right[right_index]
      if right_end < cur_start {
        right_index = right_index + 1
      } else {
        break
      }
    }
    let mut scan_index = right_index
    while scan_index < right.length() {
      let (right_start, right_end) = right[scan_index]
      if right_start > cur_end {
        break
      }
      if right_start > cur_start {
        result.push((cur_start, right_start - 1))
      }
      if right_end >= cur_end {
        cur_start = cur_end + 1
        break
      }
      cur_start = right_end + 1
      scan_index = scan_index + 1
    }
    if cur_start <= cur_end {
      result.push((cur_start, cur_end))
    }
  }
  result
}

///|
fn pattern_from_char(ch : Char) -> Pattern {
  Pattern::char_range(ch.to_int(), ch.to_int())
}

///|
fn pattern_from_set(set : Array[(Int, Int)]) -> Pattern {
  Pattern::char_set(ReadOnlyArray::from_array(set[:]))
}

///|
let regex_valid_set : Array[(Int, Int)] = [(0, 0x10FFFF)]

///|
let regex_word_set : Array[(Int, Int)] = {
  let mut set = range_set_empty()
  set = range_set_add_char_range(set, 'a', 'z')
  set = range_set_add_char_range(set, 'A', 'Z')
  set = range_set_add_char_range(set, '0', '9')
  set = range_set_add_char(set, '_')
  set
}

///|
let regex_digit_set : Array[(Int, Int)] = {
  let mut set = range_set_empty()
  set = range_set_add_char_range(set, '0', '9')
  set
}

///|
let regex_space_set : Array[(Int, Int)] = {
  let mut set = range_set_empty()
  set = range_set_add_char(set, ' ')
  set = range_set_add_char(set, '\t')
  set = range_set_add_char(set, '\n')
  set = range_set_add_char(set, '\r')
  set = range_set_add_char(set, '\u{000B}')
  set = range_set_add_char(set, '\f')
  set
}

///|
let regex_line_terminator_set : Array[(Int, Int)] = {
  let mut set = range_set_empty()
  set = range_set_add_char(set, '\n')
  set
}

///|
let regex_non_word_set : Array[(Int, Int)] = range_set_diff(
  regex_valid_set, regex_word_set,
)

///|
let regex_non_digit_set : Array[(Int, Int)] = range_set_diff(
  regex_valid_set, regex_digit_set,
)

///|
let regex_non_space_set : Array[(Int, Int)] = range_set_diff(
  regex_valid_set, regex_space_set,
)

///|
let regex_any_set : Array[(Int, Int)] = range_set_diff(
  regex_valid_set, regex_line_terminator_set,
)

///|
fn regex_match(text : String, pattern : String) -> Bool {
  match parse_regex_pattern(pattern) {
    Some(ast) => {
      let re = Regex::internal_compile_pattern(ast)
      re.execute(text[:]) is Some(_)
    }
    None => false
  }
}

///|
fn parse_regex_pattern(pattern : String) -> Pattern? {
  let chars = pattern.to_array()
  let index : Ref[Int] = { val: 0 }
  match parse_alternation(chars, index) {
    Some(expr) => if index.val == chars.length() { Some(expr) } else { None }
    None => None
  }
}

///|
fn parse_alternation(chars : Array[Char], index : Ref[Int]) -> Pattern? {
  let first = match parse_concatenation(chars, index) {
    Some(value) => value
    None => return None
  }
  let parts : Array[Pattern] = [first]
  while peek_char(chars, index) == Some('|') {
    index.val = index.val + 1
    let next = match parse_concatenation(chars, index) {
      Some(value) => value
      None => return None
    }
    parts.push(next)
  }
  if parts.length() == 1 {
    Some(parts[0])
  } else {
    Some(Pattern::alt(ReadOnlyArray::from_array(parts[:])))
  }
}

///|
fn parse_concatenation(chars : Array[Char], index : Ref[Int]) -> Pattern? {
  let parts : Array[Pattern] = []
  let mut allow_anchor = true
  while true {
    match peek_char(chars, index) {
      None => break
      Some('|') => break
      Some(')') => break
      _ => ()
    }
    match parse_repeat(chars, index, allow_anchor) {
      Some(expr) => {
        parts.push(expr)
        allow_anchor = false
      }
      None => break
    }
  }
  if parts.length() == 0 {
    Some(Pattern::epsilon())
  } else if parts.length() == 1 {
    Some(parts[0])
  } else {
    Some(Pattern::seq(ReadOnlyArray::from_array(parts[:])))
  }
}

///|
priv struct Quantifier {
  min : Int
  max : Int?
  greedy : Bool
}

///|
fn parse_repeat(
  chars : Array[Char],
  index : Ref[Int],
  allow_anchor : Bool,
) -> Pattern? {
  let atom = match parse_atom(chars, index, allow_anchor) {
    Some(value) => value
    None => return None
  }
  match parse_quantifier(chars, index) {
    Some(q) =>
      Some(Pattern::quantifier(atom, min=q.min, max=q.max, greedy=q.greedy))
    None => Some(atom)
  }
}

///|
fn parse_atom(
  chars : Array[Char],
  index : Ref[Int],
  allow_anchor : Bool,
) -> Pattern? {
  match peek_char(chars, index) {
    None => None
    Some('(') => {
      index.val = index.val + 1
      let inner = match parse_alternation(chars, index) {
        Some(value) => value
        None => return None
      }
      if peek_char(chars, index) != Some(')') {
        return None
      }
      index.val = index.val + 1
      Some(inner)
    }
    Some('[') => parse_char_class(chars, index)
    Some('.') => {
      index.val = index.val + 1
      Some(pattern_from_set(regex_any_set))
    }
    Some('^') =>
      if allow_anchor {
        index.val = index.val + 1
        Some(Pattern::start_of_input())
      } else {
        index.val = index.val + 1
        Some(pattern_from_char('^'))
      }
    Some('$') =>
      if is_end_anchor(chars, index) {
        index.val = index.val + 1
        Some(Pattern::end_of_input())
      } else {
        index.val = index.val + 1
        Some(pattern_from_char('$'))
      }
    Some('\\') => {
      index.val = index.val + 1
      let esc = match next_char(chars, index) {
        Some(value) => value
        None => return None
      }
      let atom = escape_atom(esc)
      Some(atom)
    }
    Some('|') => None
    Some(')') => None
    Some(ch) => {
      index.val = index.val + 1
      Some(pattern_from_char(ch))
    }
  }
}

///|
fn parse_char_class(chars : Array[Char], index : Ref[Int]) -> Pattern? {
  if peek_char(chars, index) != Some('[') {
    return None
  }
  index.val = index.val + 1
  let mut negate = false
  if peek_char(chars, index) == Some('^') {
    negate = true
    index.val = index.val + 1
  }
  let mut set = range_set_empty()
  let mut first = true
  while true {
    match peek_char(chars, index) {
      None => return None
      Some(']') if not(first) => {
        index.val = index.val + 1
        break
      }
      _ => ()
    }
    let atom = match parse_class_atom(chars, index) {
      Some(value) => value
      None => return None
    }
    first = false
    if peek_char(chars, index) == Some('-') &&
      peek_char_offset(chars, index, 1) != Some(']') {
      index.val = index.val + 1
      match parse_class_atom(chars, index) {
        Some(ClassAtom::Single(end)) =>
          match atom {
            ClassAtom::Single(start) =>
              set = range_set_add_range(set, start.to_int(), end.to_int())
            ClassAtom::Set(_) => {
              set = add_class_atom(set, atom)
              set = range_set_add_char(set, '-')
              set = range_set_add_char(set, end)
            }
          }
        Some(next_atom) => {
          set = add_class_atom(set, atom)
          set = range_set_add_char(set, '-')
          set = add_class_atom(set, next_atom)
        }
        None => {
          set = add_class_atom(set, atom)
          set = range_set_add_char(set, '-')
          break
        }
      }
    } else {
      set = add_class_atom(set, atom)
    }
  }
  if negate {
    set = range_set_diff(regex_valid_set, set)
  }
  Some(pattern_from_set(set))
}

///|
fn parse_quantifier(chars : Array[Char], index : Ref[Int]) -> Quantifier? {
  match peek_char(chars, index) {
    Some('*') => {
      index.val = index.val + 1
      let greedy = consume_non_greedy(chars, index)
      Some({ min: 0, max: None, greedy })
    }
    Some('+') => {
      index.val = index.val + 1
      let greedy = consume_non_greedy(chars, index)
      Some({ min: 1, max: None, greedy })
    }
    Some('?') => {
      index.val = index.val + 1
      let greedy = consume_non_greedy(chars, index)
      Some({ min: 0, max: Some(1), greedy })
    }
    Some('{') => parse_braced_quantifier(chars, index)
    _ => None
  }
}

///|
fn parse_braced_quantifier(
  chars : Array[Char],
  index : Ref[Int],
) -> Quantifier? {
  let start = index.val
  index.val = index.val + 1
  let min = parse_number(chars, index)
  match min {
    Some(min_value) =>
      match peek_char(chars, index) {
        Some('}') => {
          index.val = index.val + 1
          let greedy = consume_non_greedy(chars, index)
          Some({ min: min_value, max: Some(min_value), greedy })
        }
        Some(',') => {
          index.val = index.val + 1
          let max = parse_number(chars, index)
          match peek_char(chars, index) {
            Some('}') => {
              index.val = index.val + 1
              let greedy = consume_non_greedy(chars, index)
              Some({ min: min_value, max, greedy })
            }
            _ => {
              index.val = start
              None
            }
          }
        }
        _ => {
          index.val = start
          None
        }
      }
    None => {
      index.val = start
      None
    }
  }
}

///|
fn parse_number(chars : Array[Char], index : Ref[Int]) -> Int? {
  let mut value = 0
  let mut consumed = false
  while true {
    match peek_char(chars, index) {
      Some(ch) =>
        if ch >= '0' && ch <= '9' {
          value = value * 10 + (ch.to_int() - '0'.to_int())
          index.val = index.val + 1
          consumed = true
        } else {
          break
        }
      None => break
    }
  }
  if consumed {
    Some(value)
  } else {
    None
  }
}

///|
fn consume_non_greedy(chars : Array[Char], index : Ref[Int]) -> Bool {
  if peek_char(chars, index) == Some('?') {
    index.val = index.val + 1
    false
  } else {
    true
  }
}

///|
fn is_end_anchor(chars : Array[Char], index : Ref[Int]) -> Bool {
  if peek_char(chars, index) != Some('$') {
    return false
  }
  match peek_char_offset(chars, index, 1) {
    None => true
    Some(')') => true
    Some('|') => true
    _ => false
  }
}

///|
priv enum ClassAtom {
  Single(Char)
  Set(Array[(Int, Int)])
}

///|
fn parse_class_atom(chars : Array[Char], index : Ref[Int]) -> ClassAtom? {
  let ch = match next_char(chars, index) {
    Some(value) => value
    None => return None
  }
  if ch == '\\' {
    let esc = match next_char(chars, index) {
      Some(value) => value
      None => return None
    }
    match escape_class_atom(esc) {
      Some(atom) => Some(atom)
      None => Some(ClassAtom::Single(esc))
    }
  } else {
    Some(ClassAtom::Single(ch))
  }
}

///|
fn escape_atom(esc : Char) -> Pattern {
  match escape_class_atom(esc) {
    Some(ClassAtom::Set(set)) => pattern_from_set(set)
    Some(ClassAtom::Single(ch)) => pattern_from_char(ch)
    None => pattern_from_char(esc)
  }
}

///|
fn escape_class_atom(esc : Char) -> ClassAtom? {
  match esc {
    'd' => Some(ClassAtom::Set(regex_digit_set))
    'D' => Some(ClassAtom::Set(regex_non_digit_set))
    'w' => Some(ClassAtom::Set(regex_word_set))
    'W' => Some(ClassAtom::Set(regex_non_word_set))
    's' => Some(ClassAtom::Set(regex_space_set))
    'S' => Some(ClassAtom::Set(regex_non_space_set))
    'n' => Some(ClassAtom::Single('\n'))
    'r' => Some(ClassAtom::Single('\r'))
    't' => Some(ClassAtom::Single('\t'))
    _ => None
  }
}

///|
fn add_class_atom(
  set : Array[(Int, Int)],
  atom : ClassAtom,
) -> Array[(Int, Int)] {
  match atom {
    ClassAtom::Single(ch) => range_set_add_char(set, ch)
    ClassAtom::Set(cs) => range_set_union(set, cs)
  }
}

///|
fn peek_char(chars : Array[Char], index : Ref[Int]) -> Char? {
  if index.val >= chars.length() {
    None
  } else {
    Some(chars[index.val])
  }
}

///|
fn peek_char_offset(
  chars : Array[Char],
  index : Ref[Int],
  offset : Int,
) -> Char? {
  let pos = index.val + offset
  if pos < 0 || pos >= chars.length() {
    None
  } else {
    Some(chars[pos])
  }
}

///|
fn next_char(chars : Array[Char], index : Ref[Int]) -> Char? {
  match peek_char(chars, index) {
    Some(ch) => {
      index.val = index.val + 1
      Some(ch)
    }
    None => None
  }
}
