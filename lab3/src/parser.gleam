import gleam/float
import gleam/int
import gleam/list
import gleam/string
import interpolation.{type Point, Point}

pub type ParseLineError {
  EmptyLine
  InvalidFormat(String)
  InvalidNumber(String)
}

pub fn parse_line(line: String) -> Result(Point, ParseLineError) {
  let trimmed = string.trim(line)

  case string.is_empty(trimmed) {
    True -> Error(EmptyLine)
    False -> {
      let parts = split_by_delimiters(trimmed)

      case parts {
        [x_str, y_str] -> {
          case parse_number(x_str), parse_number(y_str) {
            Ok(x), Ok(y) -> Ok(Point(x, y))
            Error(_), _ -> Error(InvalidNumber(x_str))
            _, Error(_) -> Error(InvalidNumber(y_str))
          }
        }
        _ -> Error(InvalidFormat(trimmed))
      }
    }
  }
}

fn split_by_delimiters(s: String) -> List(String) {
  case string.contains(s, ";") {
    True ->
      string.split(s, ";")
      |> list.map(string.trim)
      |> list.filter(fn(x) { !string.is_empty(x) })
    False -> {
      case string.contains(s, "\t") {
        True ->
          string.split(s, "\t")
          |> list.map(string.trim)
          |> list.filter(fn(x) { !string.is_empty(x) })
        False -> {
          string.split(s, " ")
          |> list.map(string.trim)
          |> list.filter(fn(x) { !string.is_empty(x) })
        }
      }
    }
  }
}

fn parse_number(s: String) -> Result(Float, Nil) {
  let trimmed = string.trim(s)
  case float.parse(trimmed) {
    Ok(f) -> Ok(f)
    Error(_) -> {
      case int.parse(trimmed) {
        Ok(i) -> Ok(int.to_float(i))
        Error(_) -> Error(Nil)
      }
    }
  }
}

pub fn parse_lines(lines: List(String)) -> List(Point) {
  list.filter_map(lines, fn(line) {
    case parse_line(line) {
      Ok(point) -> Ok(point)
      Error(_) -> Error(Nil)
    }
  })
}

pub fn format_point(x: Float, y: Float) -> String {
  format_float(x) <> " " <> format_float(y)
}

pub fn format_result(method: String, x: Float, y: Float) -> String {
  method <> ": " <> format_float(x) <> " " <> format_float(y)
}

fn format_float(f: Float) -> String {
  // Округляем до 4
  let scaled = f *. 10_000.0
  let rounded_scaled = float.round(scaled)
  let rounded_val = int.to_float(rounded_scaled) /. 10_000.0
  let rounded_int = float.round(rounded_val)

  case float.loosely_equals(rounded_val, int.to_float(rounded_int), 0.0001) {
    True -> int.to_string(rounded_int)
    False -> {
      // Форматируем с точностью 4 знака
      let s = float.to_string(rounded_val)
      trim_trailing_zeros(s)
    }
  }
}

fn trim_trailing_zeros(s: String) -> String {
  case string.contains(s, ".") {
    False -> s
    True -> {
      let chars = string.to_graphemes(s)
      let trimmed = trim_zeros_from_end(list.reverse(chars))
      string.concat(list.reverse(trimmed))
    }
  }
}

fn trim_zeros_from_end(chars: List(String)) -> List(String) {
  case chars {
    [] -> []
    ["0", ..rest] -> trim_zeros_from_end(rest)
    [".", ..rest] -> rest
    _ -> chars
  }
}
