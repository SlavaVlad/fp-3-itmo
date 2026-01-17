import gleam/float
import gleam/list
import gleam/result

pub type Point {
  Point(x: Float, y: Float)
}

pub type InterpolationMethod {
  Linear
  Newton(n: Int)
}

pub type InterpolationResult {
  InterpolationResult(method: String, point: Point)
}

// Алгоритмы интерполяции и прочая математика
// y = y0 + (y1 - y0) * (x - x0) / (x1 - x0)
pub fn linear_interpolate(p0: Point, p1: Point, x: Float) -> Float {
  let dx = p1.x -. p0.x
  case dx == 0.0 {
    True -> p0.y
    False -> p0.y +. { p1.y -. p0.y } *. { x -. p0.x } /. dx
  }
}

// Найти 2 соседние точки для интерполяции по x
pub fn find_linear_segment(
  points: List(Point),
  x: Float,
) -> Result(#(Point, Point), Nil) {
  case points {
    [] -> Error(Nil)
    [_] -> Error(Nil)
    [p0, p1, ..rest] -> {
      case x >=. p0.x && x <=. p1.x {
        True -> Ok(#(p0, p1))
        False -> find_linear_segment([p1, ..rest], x)
      }
    }
  }
}

pub fn interpolate_linear(points: List(Point), x: Float) -> Result(Float, Nil) {
  find_linear_segment(points, x)
  |> result.map(fn(segment) {
    let #(p0, p1) = segment
    linear_interpolate(p0, p1, x)
  })
}

pub fn generate_linear_points(
  points: List(Point),
  step: Float,
  x_start: Float,
  x_end: Float,
) -> List(InterpolationResult) {
  generate_x_values(x_start, x_end, step)
  |> list.filter_map(fn(x) {
    interpolate_linear(points, x)
    |> result.map(fn(y) { InterpolationResult("linear", Point(x, y)) })
  })
}

// Ньютон
pub fn divided_differences(points: List(Point)) -> List(Float) {
  case points {
    [] -> []
    [p] -> [p.y]
    _ -> {
      let initial_column = list.map(points, fn(p) { p.y })
      let xs = list.map(points, fn(p) { p.x })
      build_dd_table(xs, xs, initial_column, [])
    }
  }
}

fn build_dd_table(
  all_xs: List(Float),
  current_xs: List(Float),
  column: List(Float),
  acc: List(Float),
) -> List(Float) {
  case column {
    [] -> list.reverse(acc)
    [first, ..] -> {
      let new_acc = [first, ..acc]

      case list.length(column) <= 1 {
        True -> list.reverse(new_acc)
        False -> {
          let offset = list.length(acc) + 1
          let next_column = compute_dd_column(all_xs, column, offset)
          let next_xs = case current_xs {
            [] -> []
            [_, ..rest] -> rest
          }
          build_dd_table(all_xs, next_xs, next_column, new_acc)
        }
      }
    }
  }
}

fn compute_dd_column(
  all_xs: List(Float),
  column: List(Float),
  offset: Int,
) -> List(Float) {
  compute_dd_column_impl(all_xs, column, offset, 0)
}

fn compute_dd_column_impl(
  all_xs: List(Float),
  column: List(Float),
  offset: Int,
  idx: Int,
) -> List(Float) {
  case column {
    [] -> []
    [_] -> []
    [f_i, f_i1, ..rest] -> {
      let x_i = get_at(all_xs, idx)
      let x_j = get_at(all_xs, idx + offset)

      let diff = case x_i, x_j {
        Ok(xi), Ok(xj) -> {
          let dx = xj -. xi
          case dx == 0.0 {
            True -> 0.0
            False -> { f_i1 -. f_i } /. dx
          }
        }
        _, _ -> 0.0
      }
      [diff, ..compute_dd_column_impl(all_xs, [f_i1, ..rest], offset, idx + 1)]
    }
  }
}

fn get_at(lst: List(a), idx: Int) -> Result(a, Nil) {
  case idx < 0 {
    True -> Error(Nil)
    False -> {
      case lst {
        [] -> Error(Nil)
        [first, ..rest] -> {
          case idx == 0 {
            True -> Ok(first)
            False -> get_at(rest, idx - 1)
          }
        }
      }
    }
  }
}

// P(x) = c0 + c1*(x-x0) + c2*(x-x0)*(x-x1) + ...
pub fn newton_polynomial(
  points: List(Point),
  coefficients: List(Float),
  x: Float,
) -> Float {
  let xs = list.map(points, fn(p) { p.x })
  evaluate_newton_poly(coefficients, xs, x, 1.0, 0.0)
}

fn evaluate_newton_poly(
  coeffs: List(Float),
  xs: List(Float),
  x: Float,
  product: Float,
  acc: Float,
) -> Float {
  case coeffs {
    [] -> acc
    [c, ..rest_coeffs] -> {
      let new_acc = acc +. c *. product
      case xs {
        [] -> new_acc
        [xi, ..rest_xs] -> {
          let new_product = product *. { x -. xi }
          evaluate_newton_poly(rest_coeffs, rest_xs, x, new_product, new_acc)
        }
      }
    }
  }
}

// Выполнить интерполяцию Ньютона для значения x
pub fn interpolate_newton(points: List(Point), x: Float) -> Result(Float, Nil) {
  case list.length(points) < 2 {
    True -> Error(Nil)
    False -> {
      let coeffs = divided_differences(points)
      Ok(newton_polynomial(points, coeffs, x))
    }
  }
}

pub fn generate_newton_points(
  points: List(Point),
  step: Float,
  x_start: Float,
  x_end: Float,
) -> List(InterpolationResult) {
  case list.length(points) < 2 {
    True -> []
    False -> {
      let coeffs = divided_differences(points)
      generate_x_values(x_start, x_end, step)
      |> list.map(fn(x) {
        let y = newton_polynomial(points, coeffs, x)
        InterpolationResult("newton", Point(x, y))
      })
    }
  }
}

pub fn generate_x_values(
  x_start: Float,
  x_end: Float,
  step: Float,
) -> List(Float) {
  generate_x_values_acc(x_start, x_end, step, [])
  |> list.reverse
}

fn generate_x_values_acc(
  current: Float,
  x_end: Float,
  step: Float,
  acc: List(Float),
) -> List(Float) {
  case current >. x_end {
    True -> acc
    False ->
      generate_x_values_acc(current +. step, x_end, step, [current, ..acc])
  }
}

pub fn get_x_range(points: List(Point)) -> Result(#(Float, Float), Nil) {
  case points {
    [] -> Error(Nil)
    [first, ..rest] -> {
      let min_x = list.fold(rest, first.x, fn(min, p) { float.min(min, p.x) })
      let max_x = list.fold(rest, first.x, fn(max, p) { float.max(max, p.x) })
      Ok(#(min_x, max_x))
    }
  }
}

pub fn round_to(value: Float, decimals: Int) -> Float {
  let multiplier = pow10(decimals)
  float.round(value *. multiplier) |> int_to_float |> fn(x) { x /. multiplier }
}

fn pow10(n: Int) -> Float {
  case n <= 0 {
    True -> 1.0
    False -> 10.0 *. pow10(n - 1)
  }
}

fn int_to_float(n: Int) -> Float {
  case n >= 0 {
    True -> int_to_float_positive(n, 0.0)
    False -> 0.0 -. int_to_float_positive(0 - n, 0.0)
  }
}

fn int_to_float_positive(n: Int, acc: Float) -> Float {
  case n == 0 {
    True -> acc
    False -> int_to_float_positive(n - 1, acc +. 1.0)
  }
}
