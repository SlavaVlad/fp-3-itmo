import gleam/io
import gleam/string
import task1/task1
import task2/task2

pub fn main() {
  io.println(string.repeat("=", 70))
  io.println("TASK 1: Sum of multiples of 3 or 5 below 1000")
  io.println(string.repeat("=", 70))
  task1.main()

  io.println("")
  io.println(string.repeat("=", 70))
  io.println("TASK 2: Sum of numbers equal to sum of 5th powers of digits")
  io.println(string.repeat("=", 70))
  task2.main()
}
