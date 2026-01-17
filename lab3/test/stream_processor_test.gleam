import gleam/float
import gleam/list
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import interpolation.{InterpolationResult, Linear, Newton, Point}
import stream_processor.{StreamState}

pub fn main() {
  gleeunit.main()
}

pub fn new_state_test() {
  let state = stream_processor.new_state(0.5, [Linear])

  should.equal(state.step, 0.5)
  should.equal(state.points, [])
  should.equal(state.last_x, None)
}

pub fn process_first_point_test() {
  let state = stream_processor.new_state(0.5, [Linear])

  let #(new_state, results) =
    stream_processor.process_point(state, Point(0.0, 0.0))

  // После первой точки нет результатов (нужно минимум 2)
  should.equal(results, [])
  should.equal(list.length(new_state.points), 1)
}

pub fn process_two_points_linear_test() {
  let state = stream_processor.new_state(0.5, [Linear])

  let #(state1, _) = stream_processor.process_point(state, Point(0.0, 0.0))
  let #(state2, results) =
    stream_processor.process_point(state1, Point(1.0, 1.0))

  // После двух точек должны быть результаты линейной интерполяции
  should.be_true(results != [])
  should.equal(list.length(state2.points), 2)
}

pub fn process_points_sorted_test() {
  let state = stream_processor.new_state(0.5, [Linear])

  // Добавляем точки в неправильном порядке
  let #(state1, _) = stream_processor.process_point(state, Point(2.0, 2.0))
  let #(state2, _) = stream_processor.process_point(state1, Point(0.0, 0.0))
  let #(state3, _) = stream_processor.process_point(state2, Point(1.0, 1.0))

  // Точки должны быть отсортированы
  let xs = list.map(state3.points, fn(p) { p.x })
  should.equal(xs, [0.0, 1.0, 2.0])
}

pub fn process_newton_needs_n_points_test() {
  let state = stream_processor.new_state(0.5, [Newton(3)])

  let #(state1, results1) =
    stream_processor.process_point(state, Point(0.0, 0.0))
  let #(state2, results2) =
    stream_processor.process_point(state1, Point(1.0, 1.0))
  let #(_, results3) = stream_processor.process_point(state2, Point(2.0, 4.0))

  // Первые две точки не дают результатов для Newton(3)
  should.equal(results1, [])
  should.equal(results2, [])
  // Третья точка должна дать результаты
  should.be_true(results3 != [])
}

pub fn finalize_empty_test() {
  let state = stream_processor.new_state(0.5, [Linear])

  let results = stream_processor.finalize(state)
  should.equal(results, [])
}

pub fn finalize_with_points_test() {
  let state =
    StreamState(
      points: [Point(0.0, 0.0), Point(1.0, 1.0), Point(2.0, 2.0)],
      last_x: Some(0.5),
      step: 0.5,
      methods: [Linear],
    )

  let results = stream_processor.finalize(state)
  should.be_true(results != [])
}

pub fn process_multiple_methods_test() {
  let state = stream_processor.new_state(0.5, [Linear, Newton(2)])

  let #(state1, _) = stream_processor.process_point(state, Point(0.0, 0.0))
  let #(_, results) = stream_processor.process_point(state1, Point(1.0, 1.0))

  // Должны быть результаты от обоих методов
  let linear_results =
    list.filter(results, fn(r) {
      let InterpolationResult(method, _) = r
      method == "linear"
    })
  let newton_results =
    list.filter(results, fn(r) {
      let InterpolationResult(method, _) = r
      method == "newton"
    })

  should.be_true(linear_results != [])
  should.be_true(newton_results != [])
}

pub fn stream_linear_interpolation_values_test() {
  let state = stream_processor.new_state(0.5, [Linear])

  let #(state1, _) = stream_processor.process_point(state, Point(0.0, 0.0))
  let #(_, results) = stream_processor.process_point(state1, Point(1.0, 2.0))

  // Проверяем, что значения интерполяции корректны (y = 2x)
  list.each(results, fn(r) {
    let InterpolationResult(_, Point(x, y)) = r
    let expected_y = x *. 2.0
    should.be_true(float.loosely_equals(y, expected_y, 0.001))
  })
}
