import cli.{type Config}
import gleam/io
import gleam/list
import interpolation.{type InterpolationResult, InterpolationResult, Point}
import parser
import stream_processor.{type StreamState}

// Контроллер

// Этого почему-то нет в gleam/io. bread
@external(erlang, "lab3_ffi", "get_args")
fn get_args() -> List(String)

@external(erlang, "lab3_ffi", "read_line")
fn read_line_ffi() -> Result(String, Nil)

pub fn main() -> Nil {
  let args = get_args()
  case cli.parse_args(args) {
    Error(err) -> {
      io.println("Ошибка: " <> cli.format_error(err))
      io.println("")
      io.println(cli.help_text())
    }
    Ok(config) -> {
      case config.help {
        True -> io.println(cli.help_text())
        False -> run_interpolation(config)
      }
    }
  }
}

fn run_interpolation(config: Config) -> Nil {
  let initial_state = stream_processor.new_state(config.step, config.methods)
  process_input_loop(initial_state)
}

fn process_input_loop(state: StreamState) -> Nil {
  case read_line_ffi() {
    Error(_) -> {
      let final_results = stream_processor.finalize(state)
      print_results(final_results)
    }

    Ok("") -> process_input_loop(state)

    Ok(line) -> {
      case parser.parse_line(line) {
        Error(_) -> {
          process_input_loop(state)
        }
        Ok(point) -> {
          let #(new_state, results) =
            stream_processor.process_point(state, point)
          print_results(results)
          process_input_loop(new_state)
        }
      }
    }
  }
}

fn print_results(results: List(InterpolationResult)) -> Nil {
  list.each(results, fn(result) {
    let InterpolationResult(method, Point(x, y)) = result
    io.println(parser.format_result(method, x, y))
  })
}
