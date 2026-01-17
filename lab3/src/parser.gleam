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
  // Проверяем, является ли число целым
  let rounded = float.round(f)
  case float.loosely_equals(f, int.to_float(rounded), 0.0001) {
    True -> int.to_string(rounded)
    False -> float.to_string(f)
  }
}
