import gleam/list
import gleam/option.{type Option, None, Some}
import interpolation.{
  type InterpolationMethod, type InterpolationResult, type Point,
  InterpolationResult, Linear, Newton, Point, generate_x_values,
  interpolate_linear, interpolate_newton,
}

pub type StreamState {
  StreamState(
    // Накопленные точки (окно)
    points: List(Point),
    // Последнее значение x, для которого была выполнена интерполяция
    last_x: Option(Float),
    // Шаг дискретизации
    step: Float,
    methods: List(InterpolationMethod),
  )
}

pub fn new_state(step: Float, methods: List(InterpolationMethod)) -> StreamState {
  StreamState(points: [], last_x: None, step: step, methods: methods)
}

pub fn process_point(
  state: StreamState,
  point: Point,
) -> #(StreamState, List(InterpolationResult)) {
  let new_points = insert_sorted(state.points, point)

  let #(results, new_last_x) =
    process_all_methods(state.methods, new_points, state.last_x, state.step, [])

  let new_state =
    StreamState(..state, points: new_points, last_x: Some(new_last_x))

  #(new_state, results)
}

fn process_all_methods(
  methods: List(InterpolationMethod),
  points: List(Point),
  last_x: Option(Float),
  step: Float,
  acc: List(InterpolationResult),
) -> #(List(InterpolationResult), Float) {
  let x_start = case last_x {
    None ->
      case list.first(points) {
        Ok(p) -> p.x
        Error(_) -> 0.0
      }
    Some(x) -> x +. step
  }

  let x_end = case list.last(points) {
    Ok(p) -> p.x
    Error(_) -> x_start
  }

  case x_start >. x_end {
    True -> #(acc, option.unwrap(last_x, 0.0))
    False -> {
      let results =
        list.flat_map(methods, fn(method) {
          process_method(method, points, step, x_start, x_end)
        })
      let final_x = find_max_interpolated_x(results, option.unwrap(last_x, 0.0))
      #(list.append(acc, results), final_x)
    }
  }
}

fn process_method(
  method: InterpolationMethod,
  points: List(Point),
  step: Float,
  x_start: Float,
  x_end: Float,
) -> List(InterpolationResult) {
  case method {
    Linear -> process_linear(points, step, x_start, x_end)
    Newton(n) -> process_newton(points, n, step, x_start, x_end)
  }
}

fn process_linear(
  points: List(Point),
  step: Float,
  x_start: Float,
  x_end: Float,
) -> List(InterpolationResult) {
  case list.length(points) < 2 {
    True -> []
    False -> {
      // Для линейной интерполяции нужны только 2 соседние точки
      // Ищем диапазон, где можем интерполировать
      let first_x = case list.first(points) {
        Ok(p) -> p.x
        Error(_) -> x_start
      }
      let last_x = case list.last(points) {
        Ok(p) -> p.x
        Error(_) -> x_end
      }

      let actual_start = max_float(x_start, first_x)
      let actual_end = min_float(x_end, last_x)

      generate_x_values(actual_start, actual_end, step)
      |> list.filter_map(fn(x) {
        case interpolate_linear(points, x) {
          Ok(y) -> Ok(InterpolationResult("linear", Point(x, y)))
          Error(_) -> Error(Nil)
        }
      })
    }
  }
}

fn process_newton(
  points: List(Point),
  n: Int,
  step: Float,
  x_start: Float,
  x_end: Float,
) -> List(InterpolationResult) {
  let point_count = list.length(points)

  case point_count < n {
    True -> []
    False -> {
      // Для Ньютона используем окно из n точек
      let window = take_last(points, n)

      // Диапазон интерполяции для этого окна
      let window_start = case list.first(window) {
        Ok(p) -> p.x
        Error(_) -> x_start
      }
      let window_end = case list.last(window) {
        Ok(p) -> p.x
        Error(_) -> x_end
      }

      let actual_start = max_float(x_start, window_start)
      let actual_end = min_float(x_end, window_end)

      generate_x_values(actual_start, actual_end, step)
      |> list.filter_map(fn(x) {
        case interpolate_newton(window, x) {
          Ok(y) -> Ok(InterpolationResult("newton", Point(x, y)))
          Error(_) -> Error(Nil)
        }
      })
    }
  }
}

// Вычислить оставшиеся точки
pub fn finalize(state: StreamState) -> List(InterpolationResult) {
  case list.last(state.points) {
    Error(_) -> []
    Ok(last_point) -> {
      let x_start = case state.last_x {
        None ->
          case list.first(state.points) {
            Ok(p) -> p.x
            Error(_) -> 0.0
          }
        Some(x) -> x +. state.step
      }
      let x_end = last_point.x

      case x_start >. x_end {
        True -> []
        False -> {
          list.flat_map(state.methods, fn(method) {
            process_method(method, state.points, state.step, x_start, x_end)
          })
        }
      }
    }
  }
}

fn insert_sorted(points: List(Point), point: Point) -> List(Point) {
  case points {
    [] -> [point]
    [first, ..rest] -> {
      case point.x <=. first.x {
        True -> [point, first, ..rest]
        False -> [first, ..insert_sorted(rest, point)]
      }
    }
  }
}

fn take_last(lst: List(a), n: Int) -> List(a) {
  let len = list.length(lst)
  list.drop(lst, max_int(0, len - n))
}

fn find_max_interpolated_x(
  results: List(InterpolationResult),
  default: Float,
) -> Float {
  list.fold(results, default, fn(max, result) {
    let InterpolationResult(_, Point(x, _)) = result
    max_float(max, x)
  })
}

fn max_float(a: Float, b: Float) -> Float {
  case a >. b {
    True -> a
    False -> b
  }
}

fn min_float(a: Float, b: Float) -> Float {
  case a <. b {
    True -> a
    False -> b
  }
}

fn max_int(a: Int, b: Int) -> Int {
  case a > b {
    True -> a
    False -> b
  }
}
