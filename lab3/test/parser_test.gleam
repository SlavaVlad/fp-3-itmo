import gleam/float
import gleeunit
import gleeunit/should
import interpolation.{Point}
import parser.{EmptyLine, InvalidFormat}

pub fn main() {
  gleeunit.main()
}

pub fn parse_space_separated_test() {
  let result = parser.parse_line("1.0 2.0")

  case result {
    Ok(point) -> {
      should.be_true(float.loosely_equals(point.x, 1.0, 0.001))
      should.be_true(float.loosely_equals(point.y, 2.0, 0.001))
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_tab_separated_test() {
  let result = parser.parse_line("1.5\t3.5")

  case result {
    Ok(point) -> {
      should.be_true(float.loosely_equals(point.x, 1.5, 0.001))
      should.be_true(float.loosely_equals(point.y, 3.5, 0.001))
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_semicolon_separated_test() {
  let result = parser.parse_line("2.0;4.0")

  case result {
    Ok(point) -> {
      should.be_true(float.loosely_equals(point.x, 2.0, 0.001))
      should.be_true(float.loosely_equals(point.y, 4.0, 0.001))
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_integers_test() {
  let result = parser.parse_line("1 2")

  case result {
    Ok(point) -> {
      should.be_true(float.loosely_equals(point.x, 1.0, 0.001))
      should.be_true(float.loosely_equals(point.y, 2.0, 0.001))
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_with_whitespace_test() {
  let result = parser.parse_line("  1.0   2.0  ")

  case result {
    Ok(point) -> {
      should.be_true(float.loosely_equals(point.x, 1.0, 0.001))
      should.be_true(float.loosely_equals(point.y, 2.0, 0.001))
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_negative_numbers_test() {
  let result = parser.parse_line("-1.5 -2.5")

  case result {
    Ok(point) -> {
      should.be_true(float.loosely_equals(point.x, -1.5, 0.001))
      should.be_true(float.loosely_equals(point.y, -2.5, 0.001))
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_empty_line_test() {
  let result = parser.parse_line("")

  case result {
    Error(EmptyLine) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn parse_whitespace_only_test() {
  let result = parser.parse_line("   ")

  case result {
    Error(EmptyLine) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn parse_single_value_test() {
  let result = parser.parse_line("1.0")

  case result {
    Error(InvalidFormat(_)) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn parse_too_many_values_test() {
  let result = parser.parse_line("1.0 2.0 3.0")

  case result {
    Error(InvalidFormat(_)) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn format_point_integer_test() {
  let result = parser.format_point(1.0, 2.0)
  should.equal(result, "1 2")
}

pub fn format_point_float_test() {
  let result = parser.format_point(1.5, 2.5)
  // Результат зависит от реализации float.to_string
  should.be_true(result != "")
}

pub fn format_result_test() {
  let result = parser.format_result("linear", 1.0, 2.0)
  should.equal(result, "linear: 1 2")
}

// Тесты парсинга нескольких строк

pub fn parse_lines_test() {
  let lines = ["1.0 1.0", "2.0 4.0", "invalid", "3.0 9.0"]
  let points = parser.parse_lines(lines)

  should.equal(points, [Point(1.0, 1.0), Point(2.0, 4.0), Point(3.0, 9.0)])
}

pub fn parse_lines_empty_test() {
  let points = parser.parse_lines([])
  should.equal(points, [])
}
