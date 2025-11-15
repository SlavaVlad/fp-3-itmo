import gleeunit
import gleeunit/should
import task1/task1
import task2/task2

pub fn main() {
  gleeunit.main()
}

// Task 1 tests
pub fn task1_tail_recursive_test() {
  task1.sum_multiples_tail_recursive(10)
  |> should.equal(23)

  task1.sum_multiples_tail_recursive(1000)
  |> should.equal(233_168)

  task1.sum_multiples_tail_recursive(0)
  |> should.equal(0)

  task1.sum_multiples_tail_recursive(1)
  |> should.equal(0)
}

pub fn task1_recursive_test() {
  task1.sum_multiples_recursive(10)
  |> should.equal(23)

  task1.sum_multiples_recursive(1000)
  |> should.equal(233_168)

  task1.sum_multiples_recursive(0)
  |> should.equal(0)

  task1.sum_multiples_recursive(1)
  |> should.equal(0)
}

pub fn task1_modular_test() {
  task1.sum_multiples_modular(10)
  |> should.equal(23)

  task1.sum_multiples_modular(1000)
  |> should.equal(233_168)

  task1.sum_multiples_modular(0)
  |> should.equal(0)

  task1.sum_multiples_modular(1)
  |> should.equal(0)
}

pub fn task1_map_test() {
  task1.sum_multiples_map(10)
  |> should.equal(23)

  task1.sum_multiples_map(1000)
  |> should.equal(233_168)

  task1.sum_multiples_map(0)
  |> should.equal(0)

  task1.sum_multiples_map(1)
  |> should.equal(0)
}

pub fn task1_all_implementations_equal_test() {
  let limit = 1000
  let result1 = task1.sum_multiples_tail_recursive(limit)
  let result2 = task1.sum_multiples_recursive(limit)
  let result3 = task1.sum_multiples_modular(limit)
  let result4 = task1.sum_multiples_map(limit)

  result1 |> should.equal(result2)
  result1 |> should.equal(result3)
  result1 |> should.equal(result4)
}

// Task 2 tests
pub fn task2_tail_recursive_test() {
  task2.sum_power_equals_tail_recursive(4, 10_000)
  |> should.equal(19_316)

  task2.sum_power_equals_tail_recursive(5, 354_294)
  |> should.equal(443_839)
}

pub fn task2_recursive_test() {
  task2.sum_power_equals_recursive(4, 10_000)
  |> should.equal(19_316)

  task2.sum_power_equals_recursive(5, 354_294)
  |> should.equal(443_839)
}

pub fn task2_modular_test() {
  task2.sum_power_equals_modular(4, 10_000)
  |> should.equal(19_316)

  task2.sum_power_equals_modular(5, 354_294)
  |> should.equal(443_839)
}

pub fn task2_map_test() {
  task2.sum_power_equals_map(4, 10_000)
  |> should.equal(19_316)

  task2.sum_power_equals_map(5, 354_294)
  |> should.equal(443_839)
}

pub fn task2_all_implementations_equal_test() {
  let power = 5
  let max_limit = 354_294
  let result1 = task2.sum_power_equals_tail_recursive(power, max_limit)
  let result2 = task2.sum_power_equals_recursive(power, max_limit)
  let result3 = task2.sum_power_equals_modular(power, max_limit)
  let result4 = task2.sum_power_equals_map(power, max_limit)

  result1 |> should.equal(result2)
  result1 |> should.equal(result3)
  result1 |> should.equal(result4)
}
