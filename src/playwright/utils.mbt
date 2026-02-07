///|
/// JSON and JS helpers

///|
fn json_get_object(json : Json, key : String) -> Json? {
  match json {
    Object(map) =>
      match map.get(key) {
        Some(Object(obj)) => Some(Json::object(obj))
        _ => None
      }
    _ => None
  }
}

///|
fn json_get_array(json : Json, key : String) -> Array[Json]? {
  match json {
    Object(map) =>
      match map.get(key) {
        Some(Array(items)) => Some(items)
        _ => None
      }
    _ => None
  }
}

///|
fn js_string_literal(value : String) -> String {
  let sb = StringBuilder::new()
  sb.write_char('"')
  for ch in value {
    match ch {
      '"' => sb.write_view("\\\"")
      '\\' => sb.write_view("\\\\")
      '\n' => sb.write_view("\\n")
      '\r' => sb.write_view("\\r")
      '\t' => sb.write_view("\\t")
      _ => sb.write_char(ch)
    }
  }
  sb.write_char('"')
  sb.to_string()
}

///|
fn remote_value_to_json(value : Json) -> Json {
  match value {
    Object(map) =>
      match map.get("type") {
        Some(String("string")) =>
          match map.get("value") {
            Some(String(s)) => Json::string(s)
            _ => Json::string("")
          }
        Some(String("number")) =>
          match map.get("value") {
            Some(Number(n, ..)) => Json::number(n)
            _ => Json::number(0.0)
          }
        Some(String("boolean")) =>
          match map.get("value") {
            Some(True) => Json::boolean(true)
            Some(False) => Json::boolean(false)
            _ => Json::boolean(false)
          }
        Some(String("null")) => Json::null()
        Some(String("undefined")) => Json::null()
        _ => value
      }
    _ => value
  }
}

///|
fn remote_value_to_string(value : Json) -> String? {
  match value {
    Object(map) =>
      match map.get("type") {
        Some(String("string")) =>
          match map.get("value") {
            Some(String(s)) => Some(s)
            _ => None
          }
        Some(String("number")) =>
          match map.get("value") {
            Some(Number(n, ..)) => Some(n.to_string())
            _ => None
          }
        Some(String("boolean")) =>
          match map.get("value") {
            Some(True) => Some("true")
            Some(False) => Some("false")
            _ => None
          }
        Some(String("null")) => Some("null")
        Some(String("undefined")) => Some("undefined")
        _ => None
      }
    _ => None
  }
}

///|
fn[T] consume(value : T) -> Unit {
  let _ = value

}

///|
let noop_client : @bidi.BidiClient = @bidi.BidiClient::new(
  @bidi.Transport::unsupported("noop"),
)

///|
async fn async_noop() -> Unit {
  let _ = noop_client.connect()

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
fn json_to_remote_value(value : Json) -> Json {
  match value {
    String(s) =>
      Json::object({ "type": Json::string("string"), "value": Json::string(s) })
    Number(n, ..) =>
      Json::object({ "type": Json::string("number"), "value": Json::number(n) })
    True =>
      Json::object({
        "type": Json::string("boolean"),
        "value": Json::boolean(true),
      })
    False =>
      Json::object({
        "type": Json::string("boolean"),
        "value": Json::boolean(false),
      })
    Null => Json::object({ "type": Json::string("null") })
    _ => value
  }
}
