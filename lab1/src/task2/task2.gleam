import gleam/int
import gleam/io
import gleam/list
import gleam/string

// 1. Хвостовая рекурсия
pub fn sum_power_equals_tail_recursive(power: Int, max_limit: Int) -> Int {
  tail_recursive_helper(2, max_limit, 0, power)
}

fn tail_recursive_helper(current: Int, max: Int, acc: Int, power: Int) -> Int {
  case current > max {
    True -> acc
    False -> {
      let digit_sum = digits_power_sum_tail(current, power)
      case digit_sum == current {
        True -> tail_recursive_helper(current + 1, max, acc + current, power)
        False -> tail_recursive_helper(current + 1, max, acc, power)
      }
    }
  }
}

fn digits_power_sum_tail(n: Int, power: Int) -> Int {
  digits_power_sum_acc(n, power, 0)
}

fn digits_power_sum_acc(n: Int, power: Int, acc: Int) -> Int {
  case n {
    0 -> acc
    _ -> {
      let digit = n % 10
      let pow_val = int_pow(digit, power)
      digits_power_sum_acc(n / 10, power, acc + pow_val)
    }
  }
}

fn int_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * int_pow(base, exp - 1)
  }
}

// 2. Настоящая рекурсия
pub fn sum_power_equals_recursive(power: Int, max_limit: Int) -> Int {
  case max_limit < 2 {
    True -> 0
    False -> {
      let sum_of_powers =
        string.inspect(max_limit)
        |> string.to_graphemes()
        |> list.map(fn(c) {
          let assert Ok(d) = int.parse(c)
          recursive_pow(d, power)
        })
        |> list.fold(0, fn(acc, n) { acc + n })

      case sum_of_powers == max_limit {
        True -> max_limit + sum_power_equals_recursive(power, max_limit - 1)
        False -> sum_power_equals_recursive(power, max_limit - 1)
      }
    }
  }
}

fn recursive_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * recursive_pow(base, exp - 1)
  }
}

// 3. Модульная (filter fold)
pub fn sum_power_equals_modular(power: Int, max_limit: Int) -> Int {
  list.range(2, max_limit)
  |> list.filter(fn(n) {
    let sum_of_powers =
      string.inspect(n)
      |> string.to_graphemes()
      |> list.map(fn(c) {
        let assert Ok(d) = int.parse(c)
        modular_pow(d, power)
      })
      |> list.fold(0, fn(acc, x) { acc + x })
    sum_of_powers == n
  })
  |> list.fold(0, fn(acc, n) { acc + n })
}

fn modular_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * modular_pow(base, exp - 1)
  }
}

// 4. Map
pub fn sum_power_equals_map(power: Int, max_limit: Int) -> Int {
  list.range(2, max_limit)
  |> list.map(fn(n) {
    let sum_of_powers =
      string.inspect(n)
      |> string.to_graphemes()
      |> list.map(fn(c) {
        let assert Ok(d) = int.parse(c)
        map_pow(d, power)
      })
      |> list.fold(0, fn(acc, x) { acc + x })

    case sum_of_powers == n {
      True -> n
      False -> 0
    }
  })
  |> list.fold(0, fn(acc, n) { acc + n })
}

fn map_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * map_pow(base, exp - 1)
  }
}

pub fn main() {
  let power = 5
  let max_limit = 354_294

  io.println("1. Tail recursion:")
  let result1 = sum_power_equals_tail_recursive(power, max_limit)
  io.println("   Result: " <> int.to_string(result1))

  io.println("2. Regular recursion:")
  let result2 = sum_power_equals_recursive(power, max_limit)
  io.println("   Result: " <> int.to_string(result2))

  io.println("3. Modular (filter + fold):")
  let result3 = sum_power_equals_modular(power, max_limit)
  io.println("   Result: " <> int.to_string(result3))

  io.println("4. Map-based:")
  let result4 = sum_power_equals_map(power, max_limit)
  io.println("   Result: " <> int.to_string(result4))
}
