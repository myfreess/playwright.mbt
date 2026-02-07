///|
/// Core types and internal state

///|
pub enum BrowserKind {
  Chromium
  Firefox
  WebKit
} derive(Show, Eq)

///|
pub struct BrowserType {
  kind : BrowserKind
} derive(Show)

///|
pub struct Browser {
  priv state : Ref[BrowserState]
}

///|
pub struct BrowserContext {
  priv state : Ref[BrowserContextState]
}

///|
pub struct Page {
  priv state : Ref[PageState]
}

///|
pub struct Locator {
  priv state : Ref[LocatorState]
}

///|
pub struct Response {
  url_ : String
  status_ : Int
  status_text_ : String
  headers_ : Headers
  from_cache_ : Bool
  from_service_worker_ : Bool
} derive(Show)

///|
pub struct Request {
  url_ : String
  method_ : String
  headers_ : Headers
} derive(Show)

///|
pub struct Frame {
  url_ : String
  name_ : String
} derive(Show)

///|
pub enum NetworkEvent {
  Request(Request)
  Response(Response)
  ResponseCompleted(Response)
} derive(Show)

///|
pub suberror PlaywrightError {
  StrictModeViolation(selector~ : String, count~ : Int)
} derive(Show, Eq)

///|
/// Structured data types

///|
pub struct Headers {
  entries : Array[(String, String)]
} derive(Show, Eq)

///|
pub struct Cookie {
  name : String
  value : String
  url : String?
  domain : String?
  path : String?
  expires : Double?
  http_only : Bool?
  secure : Bool?
  same_site : String?
} derive(Show, Eq)

///|
pub struct SelectOption {
  value : String?
  label : String?
  index : Int?
} derive(Show, Eq)

///|
pub enum Length {
  Points(Double)
  Css(String)
} derive(Show, Eq)

///|
pub struct Margin {
  top : Length?
  right : Length?
  bottom : Length?
  left : Length?
} derive(Show, Eq)

///|
pub struct Clip {
  x : Double
  y : Double
  width : Double
  height : Double
} derive(Show, Eq)

///|
pub struct BoundingBox {
  x : Double
  y : Double
  width : Double
  height : Double
} derive(Show, Eq)

///|
pub fn Headers::empty() -> Headers {
  { entries: [] }
}

///|
pub fn Headers::from_pairs(entries : Array[(String, String)]) -> Headers {
  { entries, }
}

///|
pub fn Headers::from_json(json : Json) -> Headers {
  match json {
    Object(map) => {
      let entries : Array[(String, String)] = []
      for entry in map.to_array() {
        let key = entry.0
        let value = match entry.1 {
          String(s) => Some(s)
          Number(n, ..) => Some(n.to_string())
          True => Some("true")
          False => Some("false")
          _ => None
        }
        match value {
          Some(v) => entries.push((key, v))
          None => ()
        }
      }
      { entries, }
    }
    _ => Headers::empty()
  }
}

///|
pub fn Headers::to_json(self : Headers) -> Json {
  let map : Map[String, Json] = Map::new()
  for entry in self.entries {
    map.set(entry.0, Json::string(entry.1))
  }
  Json::object(map)
}

///|
pub fn Headers::get(self : Headers, key : String) -> String? {
  for entry in self.entries {
    if entry.0 == key {
      return Some(entry.1)
    }
  }
  None
}

///|
pub fn Cookie::from_json(json : Json) -> Cookie? {
  match (json_get_string(json, "name"), json_get_string(json, "value")) {
    (Some(name), Some(value)) =>
      Some({
        name,
        value,
        url: json_get_string(json, "url"),
        domain: json_get_string(json, "domain"),
        path: json_get_string(json, "path"),
        expires: json_get_number(json, "expires"),
        http_only: json_get_bool(json, "http_only"),
        secure: json_get_bool(json, "secure"),
        same_site: json_get_string(json, "same_site"),
      })
    _ => None
  }
}

///|
pub fn Cookie::new(
  name : String,
  value : String,
  url? : String,
  domain? : String,
  path? : String,
  expires? : Double,
  http_only? : Bool,
  secure? : Bool,
  same_site? : String,
) -> Cookie {
  { name, value, url, domain, path, expires, http_only, secure, same_site }
}

///|
pub fn Cookie::to_json(self : Cookie) -> Json {
  let map : Map[String, Json] = Map::new()
  map.set("name", Json::string(self.name))
  map.set("value", Json::string(self.value))
  match self.url {
    Some(value) => map.set("url", Json::string(value))
    None => ()
  }
  match self.domain {
    Some(value) => map.set("domain", Json::string(value))
    None => ()
  }
  match self.path {
    Some(value) => map.set("path", Json::string(value))
    None => ()
  }
  match self.expires {
    Some(value) => map.set("expires", Json::number(value))
    None => ()
  }
  match self.http_only {
    Some(value) => map.set("http_only", Json::boolean(value))
    None => ()
  }
  match self.secure {
    Some(value) => map.set("secure", Json::boolean(value))
    None => ()
  }
  match self.same_site {
    Some(value) => map.set("same_site", Json::string(value))
    None => ()
  }
  Json::object(map)
}

///|
pub fn SelectOption::from_value(value : String) -> SelectOption {
  { value: Some(value), label: None, index: None }
}

///|
pub fn SelectOption::new(
  value? : String,
  label? : String,
  index? : Int,
) -> SelectOption {
  { value, label, index }
}

///|
pub fn SelectOption::to_json(self : SelectOption) -> Json {
  let map : Map[String, Json] = Map::new()
  match self.value {
    Some(value) => map.set("value", Json::string(value))
    None => ()
  }
  match self.label {
    Some(value) => map.set("label", Json::string(value))
    None => ()
  }
  match self.index {
    Some(value) => map.set("index", Json::number(value.to_double()))
    None => ()
  }
  Json::object(map)
}

///|
pub fn Length::to_json(self : Length) -> Json {
  match self {
    Points(value) => Json::number(value)
    Css(value) => Json::string(value)
  }
}

///|
pub fn Length::points(value : Double) -> Length {
  Points(value)
}

///|
pub fn Length::css(value : String) -> Length {
  Css(value)
}

///|
pub fn Margin::to_json(self : Margin) -> Json {
  let map : Map[String, Json] = Map::new()
  match self.top {
    Some(value) => map.set("top", value.to_json())
    None => ()
  }
  match self.right {
    Some(value) => map.set("right", value.to_json())
    None => ()
  }
  match self.bottom {
    Some(value) => map.set("bottom", value.to_json())
    None => ()
  }
  match self.left {
    Some(value) => map.set("left", value.to_json())
    None => ()
  }
  Json::object(map)
}

///|
pub fn Margin::new(
  top? : Length,
  right? : Length,
  bottom? : Length,
  left? : Length,
) -> Margin {
  { top, right, bottom, left }
}

///|
pub fn Clip::to_json(self : Clip) -> Json {
  Json::object({
    "x": Json::number(self.x),
    "y": Json::number(self.y),
    "width": Json::number(self.width),
    "height": Json::number(self.height),
  })
}

///|
pub fn Clip::new(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Clip {
  { x, y, width, height }
}

///|
pub fn BoundingBox::from_json(json : Json) -> BoundingBox? {
  match
    (
      json_get_number(json, "x"),
      json_get_number(json, "y"),
      json_get_number(json, "width"),
      json_get_number(json, "height"),
    ) {
    (Some(x), Some(y), Some(width), Some(height)) =>
      Some({ x, y, width, height })
    _ => None
  }
}

///|
pub fn BoundingBox::new(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> BoundingBox {
  { x, y, width, height }
}

///|
pub fn BoundingBox::to_json(self : BoundingBox) -> Json {
  Json::object({
    "x": Json::number(self.x),
    "y": Json::number(self.y),
    "width": Json::number(self.width),
    "height": Json::number(self.height),
  })
}

///|
fn json_get_string(json : Json, key : String) -> String? {
  match json {
    Object(map) =>
      match map.get(key) {
        Some(String(value)) => Some(value)
        _ => None
      }
    _ => None
  }
}

///|
fn json_get_number(json : Json, key : String) -> Double? {
  match json {
    Object(map) =>
      match map.get(key) {
        Some(Number(value, ..)) => Some(value)
        _ => None
      }
    _ => None
  }
}

///|
fn json_get_bool(json : Json, key : String) -> Bool? {
  match json {
    Object(map) =>
      match map.get(key) {
        Some(True) => Some(true)
        Some(False) => Some(false)
        _ => None
      }
    _ => None
  }
}

///|
priv struct BrowserState {
  kind : BrowserKind
  client : @bidi.BidiClient
  mut connected : Bool
  contexts : Array[Ref[BrowserContextState]]
  mut default_context : Ref[BrowserContext]?
}

///|
priv struct BrowserContextState {
  browser : Browser
  user_context : String
  pages : Array[Ref[PageState]]
}

///|
priv struct NavigationEvent {
  event_name : String
  url : String
}

///|
priv struct PageState {
  browser : Browser
  context : BrowserContext
  context_id : String
  mut url : String
  navigation_events : Array[NavigationEvent]
  network_listeners : Array[(NetworkEvent) -> Unit]
  request_events : Array[Request]
  response_events : Array[Response]
  response_completed_events : Array[Response]
}

///|
priv struct LocatorState {
  page : Page
  selector : String
  index : Int?
  has_text : String?
  has_text_exact : Bool
  has_not_text : String?
  label_text : String?
  label_text_exact : Bool
  label_scope_selector : String?
}
