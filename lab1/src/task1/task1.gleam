import gleam/int
import gleam/io
import gleam/list

// 1. Хвостовая рекурсия
pub fn sum_multiples_tail_recursive(limit: Int) -> Int {
  // Это всё можно оформить в одно выражение
  // матчить лимит в 0 и в других случаях
  case limit {
    n if n <= 0 -> 0
    _ -> sum_multiples_tail_recursive_helper(limit - 1, 0)
  }
}

fn sum_multiples_tail_recursive_helper(current: Int, acc: Int) -> Int {
  case current {
    0 -> acc
    n if n % 3 == 0 || n % 5 == 0 ->
      sum_multiples_tail_recursive_helper(n - 1, acc + n)
    n -> sum_multiples_tail_recursive_helper(n - 1, acc)
  }
}

// 2. Настоящая рекурсия
pub fn sum_multiples_recursive(limit: Int) -> Int {
  case limit - 1 {
    n if n <= 0 -> 0
    n if n % 3 == 0 || n % 5 == 0 -> n + sum_multiples_recursive(n)
    n -> sum_multiples_recursive(n)
  }
}

// 3. Модульная (filter и fold)
pub fn sum_multiples_modular(limit: Int) -> Int {
  list.range(1, limit - 1)
  |> list.filter(fn(n) { n % 3 == 0 || n % 5 == 0 })
  |> list.fold(0, fn(acc, n) { acc + n })
}

// 4. Map
pub fn sum_multiples_map(limit: Int) -> Int {
  list.range(1, limit - 1)
  |> list.map(fn(n) {
    case n % 3 == 0 || n % 5 == 0 {
      True -> n
      False -> 0
    }
  })
  |> list.fold(0, fn(acc, n) { acc + n })
}

pub fn main() {
  let limit = 1000

  io.println("1. Tail recursion:")
  let result1 = sum_multiples_tail_recursive(limit)
  io.println("   Result: " <> int.to_string(result1))

  io.println("2. Regular recursion:")
  let result2 = sum_multiples_recursive(limit)
  io.println("   Result: " <> int.to_string(result2))

  io.println("3. Modular (filter + fold):")
  let result3 = sum_multiples_modular(limit)
  io.println("   Result: " <> int.to_string(result3))

  io.println("4. Map-based:")
  let result4 = sum_multiples_map(limit)
  io.println("   Result: " <> int.to_string(result4))
}
