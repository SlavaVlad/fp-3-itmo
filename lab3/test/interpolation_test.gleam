import gleam/float
import gleam/list
import gleeunit
import gleeunit/should
import interpolation.{
  Point, divided_differences, find_linear_segment, generate_x_values,
  interpolate_linear, interpolate_newton, linear_interpolate, newton_polynomial,
}

pub fn main() {
  gleeunit.main()
}

pub fn linear_interpolate_midpoint_test() {
  // Интерполяция в середине отрезка
  let p0 = Point(0.0, 0.0)
  let p1 = Point(2.0, 2.0)

  let result = linear_interpolate(p0, p1, 1.0)
  should.be_true(float.loosely_equals(result, 1.0, 0.001))
}

pub fn linear_interpolate_at_start_test() {
  // Интерполяция в начальной точке
  let p0 = Point(0.0, 5.0)
  let p1 = Point(10.0, 15.0)

  let result = linear_interpolate(p0, p1, 0.0)
  should.be_true(float.loosely_equals(result, 5.0, 0.001))
}

pub fn linear_interpolate_at_end_test() {
  // Интерполяция в конечной точке
  let p0 = Point(0.0, 5.0)
  let p1 = Point(10.0, 15.0)

  let result = linear_interpolate(p0, p1, 10.0)
  should.be_true(float.loosely_equals(result, 15.0, 0.001))
}

pub fn linear_interpolate_quarter_test() {
  // Интерполяция на четверти отрезка
  let p0 = Point(0.0, 0.0)
  let p1 = Point(4.0, 8.0)

  let result = linear_interpolate(p0, p1, 1.0)
  should.be_true(float.loosely_equals(result, 2.0, 0.001))
}

pub fn find_linear_segment_test() {
  let points = [Point(0.0, 0.0), Point(1.0, 1.0), Point(2.0, 2.0)]

  // Точка в первом сегменте
  let result1 = find_linear_segment(points, 0.5)
  should.be_ok(result1)

  // Точка во втором сегменте
  let result2 = find_linear_segment(points, 1.5)
  should.be_ok(result2)
}

pub fn interpolate_linear_test() {
  let points = [
    Point(0.0, 0.0),
    Point(1.0, 2.0),
    Point(2.0, 4.0),
    Point(3.0, 6.0),
  ]

  // Линейная функция y = 2x
  let result = interpolate_linear(points, 1.5)
  case result {
    Ok(y) -> should.be_true(float.loosely_equals(y, 3.0, 0.001))
    Error(_) -> should.fail()
  }
}

pub fn divided_differences_linear_test() {
  // Для линейной функции разделённые разности постоянны
  let points = [Point(0.0, 0.0), Point(1.0, 2.0), Point(2.0, 4.0)]

  let coeffs = divided_differences(points)

  // Первый коэффициент - значение в первой точке
  case list.first(coeffs) {
    Ok(c0) -> should.be_true(float.loosely_equals(c0, 0.0, 0.001))
    Error(_) -> should.fail()
  }
}

pub fn newton_polynomial_linear_test() {
  // Тест на линейной функции y = x
  let points = [Point(0.0, 0.0), Point(1.0, 1.0)]
  let coeffs = divided_differences(points)

  let y = newton_polynomial(points, coeffs, 0.5)
  should.be_true(float.loosely_equals(y, 0.5, 0.001))
}

pub fn newton_polynomial_quadratic_test() {
  // Тест на квадратичной функции y = x^2
  let points = [Point(0.0, 0.0), Point(1.0, 1.0), Point(2.0, 4.0)]
  let coeffs = divided_differences(points)

  // Проверяем в точке x = 1.5, ожидаем y = 2.25
  let y = newton_polynomial(points, coeffs, 1.5)
  should.be_true(float.loosely_equals(y, 2.25, 0.001))
}

pub fn interpolate_newton_test() {
  let points = [Point(0.0, 0.0), Point(1.0, 1.0), Point(2.0, 4.0)]

  let result = interpolate_newton(points, 1.5)
  case result {
    Ok(y) -> should.be_true(float.loosely_equals(y, 2.25, 0.001))
    Error(_) -> should.fail()
  }
}

pub fn interpolate_newton_at_known_point_test() {
  // Интерполяция должна давать точное значение в известной точке
  let points = [
    Point(0.0, 0.0),
    Point(1.0, 1.0),
    Point(2.0, 8.0),
    Point(3.0, 27.0),
  ]

  let result = interpolate_newton(points, 2.0)
  case result {
    Ok(y) -> should.be_true(float.loosely_equals(y, 8.0, 0.001))
    Error(_) -> should.fail()
  }
}

pub fn generate_x_values_test() {
  let values = generate_x_values(0.0, 2.0, 0.5)

  should.equal(list.length(values), 5)

  case list.first(values) {
    Ok(x) -> should.be_true(float.loosely_equals(x, 0.0, 0.001))
    Error(_) -> should.fail()
  }

  case list.last(values) {
    Ok(x) -> should.be_true(float.loosely_equals(x, 2.0, 0.001))
    Error(_) -> should.fail()
  }
}

pub fn generate_x_values_single_test() {
  let values = generate_x_values(1.0, 1.0, 0.5)

  should.equal(list.length(values), 1)
}

// Edge cases

pub fn interpolate_linear_empty_test() {
  let result = interpolate_linear([], 0.5)
  should.be_error(result)
}

pub fn interpolate_linear_single_point_test() {
  let result = interpolate_linear([Point(0.0, 0.0)], 0.5)
  should.be_error(result)
}

pub fn interpolate_newton_empty_test() {
  let result = interpolate_newton([], 0.5)
  should.be_error(result)
}

pub fn interpolate_newton_single_point_test() {
  let result = interpolate_newton([Point(0.0, 0.0)], 0.5)
  should.be_error(result)
}
