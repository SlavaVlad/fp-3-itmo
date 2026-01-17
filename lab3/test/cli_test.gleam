import cli.{InvalidStep, MissingValue, NoMethodsSpecified, UnknownOption}
import gleam/list
import gleeunit
import gleeunit/should
import interpolation.{Linear}

pub fn main() {
  gleeunit.main()
}

pub fn parse_linear_flag_test() {
  let result = cli.parse_args(["--linear"])

  case result {
    Ok(config) -> {
      should.be_true(
        list.any(config.methods, fn(m) {
          case m {
            Linear -> True
            _ -> False
          }
        }),
      )
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_linear_short_flag_test() {
  let result = cli.parse_args(["-l"])

  case result {
    Ok(config) -> {
      should.be_true(
        list.any(config.methods, fn(m) {
          case m {
            Linear -> True
            _ -> False
          }
        }),
      )
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_step_test() {
  let result = cli.parse_args(["--linear", "--step", "0.5"])

  case result {
    Ok(config) -> {
      should.equal(config.step, 0.5)
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_step_integer_test() {
  let result = cli.parse_args(["--linear", "--step", "2"])

  case result {
    Ok(config) -> {
      should.equal(config.step, 2.0)
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_multiple_methods_test() {
  let result = cli.parse_args(["--linear", "--newton", "3"])

  case result {
    Ok(config) -> {
      should.equal(list.length(config.methods), 2)
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_help_flag_test() {
  let result = cli.parse_args(["--help"])

  case result {
    Ok(config) -> {
      should.be_true(config.help)
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_short_help_flag_test() {
  let result = cli.parse_args(["-h"])

  case result {
    Ok(config) -> {
      should.be_true(config.help)
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_no_methods_error_test() {
  let result = cli.parse_args([])

  case result {
    Error(NoMethodsSpecified) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn parse_invalid_step_error_test() {
  let result = cli.parse_args(["--linear", "--step", "abc"])

  case result {
    Error(InvalidStep(_)) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn parse_missing_step_value_error_test() {
  let result = cli.parse_args(["--linear", "--step"])

  case result {
    Error(MissingValue(_)) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn parse_unknown_option_error_test() {
  let result = cli.parse_args(["--linear", "--unknown"])

  case result {
    Error(UnknownOption(_)) -> should.be_true(True)
    _ -> should.fail()
  }
}
