import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import interpolation.{type InterpolationMethod, Linear, Newton}

pub type Config {
  Config(methods: List(InterpolationMethod), step: Float, help: Bool)
}

pub type ParseError {
  InvalidStep(String)
  InvalidN(String)
  MissingValue(String)
  UnknownOption(String)
  NoMethodsSpecified
}

pub fn default_config() -> Config {
  Config(methods: [Linear], step: 1.0, help: False)
}

pub fn parse_args(args: List(String)) -> Result(Config, ParseError) {
  parse_args_loop(args, Config(methods: [], step: 1.0, help: False))
  |> result.try(validate_config)
}

fn parse_args_loop(
  args: List(String),
  config: Config,
) -> Result(Config, ParseError) {
  case args {
    [] -> Ok(config)

    ["--help", ..rest] | ["-h", ..rest] ->
      parse_args_loop(rest, Config(..config, help: True))

    ["--linear", ..rest] | ["-l", ..rest] -> {
      let methods = add_method(config.methods, Linear)
      parse_args_loop(rest, Config(..config, methods: methods))
    }

    ["--newton", ..rest] | ["-n", ..rest] -> {
      case rest {
        [n_str, ..rest2] -> {
          case int.parse(n_str) {
            Ok(n) -> {
              let methods = add_method(config.methods, Newton(n))
              parse_args_loop(rest2, Config(..config, methods: methods))
            }
            Error(_) -> {
              // Если не число, значение по умолчанию
              let methods = add_method(config.methods, Newton(4))
              parse_args_loop(rest, Config(..config, methods: methods))
            }
          }
        }
        [] -> {
          let methods = add_method(config.methods, Newton(4))
          Ok(Config(..config, methods: methods))
        }
      }
    }

    ["--step", ..rest] | ["-s", ..rest] -> {
      case rest {
        [step_str, ..rest2] -> {
          case float.parse(step_str) {
            Ok(step) -> parse_args_loop(rest2, Config(..config, step: step))
            Error(_) -> {
              case int.parse(step_str) {
                Ok(step_int) ->
                  parse_args_loop(
                    rest2,
                    Config(..config, step: int.to_float(step_int)),
                  )
                Error(_) -> Error(InvalidStep(step_str))
              }
            }
          }
        }
        [] -> Error(MissingValue("--step"))
      }
    }

    [opt, ..rest] -> {
      case string.starts_with(opt, "-") {
        True -> Error(UnknownOption(opt))
        False -> parse_args_loop(rest, config)
      }
    }
  }
}

fn add_method(
  methods: List(InterpolationMethod),
  method: InterpolationMethod,
) -> List(InterpolationMethod) {
  case list.any(methods, fn(m) { methods_equal(m, method) }) {
    True -> methods
    False -> list.append(methods, [method])
  }
}

fn methods_equal(a: InterpolationMethod, b: InterpolationMethod) -> Bool {
  case a, b {
    Linear, Linear -> True
    Newton(n1), Newton(n2) -> n1 == n2
    _, _ -> False
  }
}

// Валидация конфигурации
fn validate_config(config: Config) -> Result(Config, ParseError) {
  case config.help {
    True -> Ok(config)
    False -> {
      case list.is_empty(config.methods) {
        True -> Error(NoMethodsSpecified)
        False -> Ok(config)
      }
    }
  }
}

// Получить текст справки
pub fn help_text() -> String {
  "Лаб3 - потоковая интерполяция данных
    -h, --help          Показать эту справку
    -l, --linear        Использовать линейную интерполяцию
    -n, --newton [N]    Использовать интерполяцию Ньютона с N точками (по умолчанию: 4)
    -s, --step STEP     Шаг дискретизации (по умолчанию: 1.0)

    Данные подаются на стандартный ввод в формате CSV:
    x1 y1
    x2 y2
    ...

    Разделитель: пробел

    echo '0 0\\n1 1\\n2 2' | lab3 --linear --step 0.5
    cat data.csv | lab3 --newton 4 --linear --step 0.25

    Программа работает в потоковом режиме - выводит результаты
    по мере поступления достаточного количества данных.
"
}

// Форматировать ошибку парсинга
pub fn format_error(error: ParseError) -> String {
  case error {
    InvalidStep(s) -> "Неверный шаг: " <> s
    InvalidN(s) -> "Неверное N: " <> s
    MissingValue(opt) -> "Отсутствует значение для: " <> opt
    UnknownOption(opt) -> "Неизвестная опция: " <> opt
    NoMethodsSpecified ->
      "Не указан метод интерполяции. Используйте --linear или --newton"
  }
}
