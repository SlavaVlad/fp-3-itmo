import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/order
import gleam/string
import gleeunit
import gleeunit/should
import lab2
import prng/random
import prng/seed

pub fn main() {
  gleeunit.main()
}

// Вспомогательные функции для тестов
fn int_compare(a: Int, b: Int) -> order.Order {
  int.compare(a, b)
}

fn int_equal(a: Int, b: Int) -> Bool {
  a == b
}

fn string_equal(a: String, b: String) -> Bool {
  a == b
}

// Генерация случайных данных
fn gk() -> Int {
  int.random(10_000) - 5000
}

fn gv() -> String {
  let length = int.random(64)
  let generator: random.Generator(Int) = random.int(97, 122)
  // random string of given length
  let string =
    string.join(
      list.repeat("", length)
        |> list.map(fn(_) {
          let code = random.sample(generator, seed.random())
          let assert Ok(cp) = string.utf_codepoint(code)
          string.from_utf_codepoints([cp])
        }),
      "",
    )
  io.println("Generating rnd s:" <> string)
  string
}

/// Тест создания пустого дерева
pub fn empty_tree_test() {
  let tree = lab2.empty()
  lab2.is_empty(tree) |> should.be_true
  lab2.size(tree) |> should.equal(0)
}

/// Тест вставки одного элемента
pub fn single_insert_test() {
  let key = gk()
  let value = gv()
  let tree =
    lab2.empty()
    |> lab2.insert(key, value, int_compare)

  lab2.is_empty(tree) |> should.be_false
  lab2.size(tree) |> should.equal(1)
  lab2.lookup(tree, key, int_compare) |> should.equal(option.Some(value))
  lab2.lookup(tree, gk(), int_compare) |> should.equal(option.None)
}

/// Тест множественных вставок
pub fn multiple_insert_test() {
  let k1 = gk()
  let v1 = gv()
  let k2 = gk()
  let v2 = gv()
  let k3 = gk()
  let v3 = gv()
  let k4 = gk()
  let v4 = gv()
  let k5 = gk()
  let v5 = gv()
  let tree =
    lab2.empty()
    |> lab2.insert(k1, v1, int_compare)
    |> lab2.insert(k2, v2, int_compare)
    |> lab2.insert(k3, v3, int_compare)
    |> lab2.insert(k4, v4, int_compare)
    |> lab2.insert(k5, v5, int_compare)

  lab2.size(tree) |> should.equal(5)
  lab2.lookup(tree, k1, int_compare) |> should.equal(option.Some(v1))
  lab2.lookup(tree, k2, int_compare) |> should.equal(option.Some(v2))
  lab2.lookup(tree, k3, int_compare) |> should.equal(option.Some(v3))
  lab2.lookup(tree, k4, int_compare) |> should.equal(option.Some(v4))
  lab2.lookup(tree, k5, int_compare) |> should.equal(option.Some(v5))
}

/// Тест удаления элементов
pub fn delete_test() {
  let k1 = gk()
  let v1 = gv()
  let k2 = gk()
  let v2 = gv()
  let k3 = gk()
  let v3 = gv()
  let tree =
    lab2.empty()
    |> lab2.insert(k1, v1, int_compare)
    |> lab2.insert(k2, v2, int_compare)
    |> lab2.insert(k3, v3, int_compare)
    |> lab2.delete(k2, int_compare)

  lab2.size(tree) |> should.equal(2)
  lab2.lookup(tree, k2, int_compare) |> should.equal(option.None)
  lab2.lookup(tree, k1, int_compare) |> should.equal(option.Some(v1))
  lab2.lookup(tree, k3, int_compare) |> should.equal(option.Some(v3))
}

/// Тест фильтрации
pub fn filter_test() {
  let k1 = gk() * 2 + 1
  let v1 = gv()
  let k2 = gk() * 2
  let v2 = gv()
  let k3 = gk() * 2 + 1
  let v3 = gv()
  let k4 = gk() * 2
  let v4 = gv()
  let k5 = gk() * 2 + 1
  let v5 = gv()
  let tree =
    lab2.empty()
    |> lab2.insert(k1, v1, int_compare)
    |> lab2.insert(k2, v2, int_compare)
    |> lab2.insert(k3, v3, int_compare)
    |> lab2.insert(k4, v4, int_compare)
    |> lab2.insert(k5, v5, int_compare)

  let filtered = lab2.filter(tree, fn(key, _) { key % 2 == 0 }, int_compare)

  lab2.size(filtered) |> should.equal(2)
  lab2.contains(filtered, k2, int_compare) |> should.be_true
  lab2.contains(filtered, k4, int_compare) |> should.be_true
  lab2.contains(filtered, k1, int_compare) |> should.be_false
}

/// Тест отображения
pub fn map_test() {
  let k1 = gk()
  let v1 = gk()
  let k2 = gk()
  let v2 = gk()
  let k3 = gk()
  let v3 = gk()
  let tree =
    lab2.empty()
    |> lab2.insert(k1, v1, int_compare)
    |> lab2.insert(k2, v2, int_compare)
    |> lab2.insert(k3, v3, int_compare)

  let mapped = lab2.map(tree, fn(value) { value * 2 })

  lab2.lookup(mapped, k1, int_compare) |> should.equal(option.Some(v1 * 2))
  lab2.lookup(mapped, k2, int_compare) |> should.equal(option.Some(v2 * 2))
  lab2.lookup(mapped, k3, int_compare) |> should.equal(option.Some(v3 * 2))
}

/// Тест левой свёртки
pub fn fold_left_test() {
  let k1 = gk()
  let v1 = gk()
  let k2 = gk()
  let v2 = gk()
  let k3 = gk()
  let v3 = gk()
  let tree =
    lab2.empty()
    |> lab2.insert(k1, v1, int_compare)
    |> lab2.insert(k2, v2, int_compare)
    |> lab2.insert(k3, v3, int_compare)

  let sum = lab2.fold_left(tree, 0, fn(acc, _, value) { acc + value })
  sum |> should.equal(v1 + v2 + v3)
}

/// Тест правой свёртки
pub fn fold_right_test() {
  let k1 = gk()
  let v1 = gv()
  let k2 = gk()
  let v2 = gv()
  let k3 = gk()
  let v3 = gv()
  let tree =
    lab2.empty()
    |> lab2.insert(k1, v1, int_compare)
    |> lab2.insert(k2, v2, int_compare)
    |> lab2.insert(k3, v3, int_compare)

  let result = lab2.fold_right(tree, "", fn(_, value, acc) { value <> acc })
  // Порядок может отличаться в зависимости от структуры дерева
  result
  |> string.length
  |> should.equal(string.length(v1) + string.length(v2) + string.length(v3))
}

/// Тест преобразования в список и обратно
pub fn to_from_list_test() {
  let k1 = gk()
  let v1 = gv()
  let k2 = gk()
  let v2 = gv()
  let k3 = gk()
  let v3 = gv()
  let original_list = [#(k1, v1), #(k2, v2), #(k3, v3)]
  let tree = lab2.from_list(original_list, int_compare)
  let result_list = lab2.to_list(tree)

  lab2.size(tree) |> should.equal(3)
  list.length(result_list) |> should.equal(3)
  lab2.contains(tree, k1, int_compare) |> should.be_true
  lab2.contains(tree, k2, int_compare) |> should.be_true
  lab2.contains(tree, k3, int_compare) |> should.be_true
}

// Тесты свойств моноида

/// Тест нейтрального элемента (левая единица)
pub fn monoid_left_identity_test() {
  let k1 = gk()
  let v1 = gv()
  let k2 = gk()
  let v2 = gv()
  let tree =
    lab2.empty()
    |> lab2.insert(k1, v1, int_compare)
    |> lab2.insert(k2, v2, int_compare)

  let result = lab2.concat(lab2.empty(), tree, int_compare)

  lab2.semantic_equal(tree, result, int_compare, string_equal) |> should.be_true
}

/// Тест нейтрального элемента (правая единица)
pub fn monoid_right_identity_test() {
  let k1 = gk()
  let v1 = gv()
  let k2 = gk()
  let v2 = gv()
  let tree =
    lab2.empty()
    |> lab2.insert(k1, v1, int_compare)
    |> lab2.insert(k2, v2, int_compare)

  let result = lab2.concat(tree, lab2.empty(), int_compare)

  lab2.semantic_equal(tree, result, int_compare, string_equal) |> should.be_true
}

/// Тест ассоциативности
pub fn monoid_associativity_test() {
  let k1 = gk()
  let v1 = gv()
  let k2 = gk()
  let v2 = gv()
  let k3 = gk()
  let v3 = gv()
  let tree1 = lab2.empty() |> lab2.insert(k1, v1, int_compare)
  let tree2 = lab2.empty() |> lab2.insert(k2, v2, int_compare)
  let tree3 = lab2.empty() |> lab2.insert(k3, v3, int_compare)

  let left_assoc =
    lab2.concat(lab2.concat(tree1, tree2, int_compare), tree3, int_compare)
  let right_assoc =
    lab2.concat(tree1, lab2.concat(tree2, tree3, int_compare), int_compare)

  // Проверяем, что оба дерева содержат одинаковые элементы
  lab2.size(left_assoc) |> should.equal(3)
  lab2.size(right_assoc) |> should.equal(3)
  lab2.contains(left_assoc, k1, int_compare) |> should.be_true
  lab2.contains(left_assoc, k2, int_compare) |> should.be_true
  lab2.contains(left_assoc, k3, int_compare) |> should.be_true
  lab2.contains(right_assoc, k1, int_compare) |> should.be_true
  lab2.contains(right_assoc, k2, int_compare) |> should.be_true
  lab2.contains(right_assoc, k3, int_compare) |> should.be_true
}

/// Тест инвариантов красно-чёрного дерева (упрощённая проверка)
pub fn red_black_invariant_test() {
  // Создаём большое дерево и проверяем, что поиск работает корректно
  let tree =
    lab2.from_list(
      list.map(list.range(1, 10), fn(i) { #(i, gv()) }),
      int_compare,
    )

  lab2.size(tree) |> should.equal(10)

  // Проверяем, что все элементы можно найти
  let all_found =
    list.all(list.range(1, 10), fn(key) {
      lab2.contains(tree, key, int_compare)
    })

  all_found |> should.be_true
}

/// Тест обновления существующего ключа
pub fn update_existing_key_test() {
  let key = gk()
  let old_value = gv()
  let new_value = gv()
  let tree =
    lab2.empty()
    |> lab2.insert(key, old_value, int_compare)
    |> lab2.insert(key, new_value, int_compare)

  lab2.size(tree) |> should.equal(1)
  lab2.lookup(tree, key, int_compare) |> should.equal(option.Some(new_value))
}

/// Тест свойства: insert -> lookup должен возвращать вставленное значение
pub fn insert_lookup_property_test() {
  let test_cases = [
    #(gk(), gv()),
    #(gk(), gv()),
    #(gk(), gv()),
    #(gk(), gv()),
  ]

  list.each(test_cases, fn(test_case) {
    let #(key, value) = test_case
    let tree = lab2.empty() |> lab2.insert(key, value, int_compare)
    lab2.lookup(tree, key, int_compare) |> should.equal(option.Some(value))
  })
}

/// Тест свойства: size увеличивается при вставке новых элементов
pub fn insert_size_property_test() {
  let key1 = gk()
  let key2 = gk()
  let key3 = gk()
  let tree = lab2.empty()
  lab2.size(tree) |> should.equal(0)

  let tree1 = lab2.insert(tree, key1, gv(), int_compare)
  lab2.size(tree1) |> should.equal(1)

  let tree2 = lab2.insert(tree1, key2, gv(), int_compare)
  lab2.size(tree2) |> should.equal(2)

  let tree3 = lab2.insert(tree2, key3, gv(), int_compare)
  lab2.size(tree3) |> should.equal(3)

  // Вставка существующего ключа не должна увеличивать размер
  let tree4 = lab2.insert(tree3, key2, gv(), int_compare)
  lab2.size(tree4) |> should.equal(3)
}

/// Тест свойства: filter сохраняет порядок и структуру
pub fn filter_property_test() {
  let original =
    lab2.from_list(
      list.map(list.range(1, 5), fn(i) { #(i, gv()) }),
      int_compare,
    )

  // Фильтр, который пропускает все элементы
  let all_filter = lab2.filter(original, fn(_, _) { True }, int_compare)
  lab2.equal(original, all_filter, int_equal, string_equal) |> should.be_true

  // Фильтр, который не пропускает ничего
  let none_filter = lab2.filter(original, fn(_, _) { False }, int_compare)
  lab2.is_empty(none_filter) |> should.be_true

  // Частичный фильтр
  let partial_filter =
    lab2.filter(original, fn(key, _) { key > 3 }, int_compare)
  lab2.size(partial_filter) |> should.equal(2)
  lab2.contains(partial_filter, 4, int_compare) |> should.be_true
  lab2.contains(partial_filter, 5, int_compare) |> should.be_true
}

/// Тест свойства: map сохраняет структуру дерева
pub fn map_property_test() {
  let k1 = gk()
  let v1 = gk()
  let k2 = gk()
  let v2 = gk()
  let k3 = gk()
  let v3 = gk()
  let original = lab2.from_list([#(k1, v1), #(k2, v2), #(k3, v3)], int_compare)

  // Тождественное отображение
  let identity_map = lab2.map(original, fn(x) { x })
  lab2.equal(original, identity_map, int_equal, int_equal) |> should.be_true

  // Отображение с изменением
  let doubled = lab2.map(original, fn(x) { x * 2 })
  lab2.size(doubled) |> should.equal(lab2.size(original))
  lab2.lookup(doubled, k1, int_compare) |> should.equal(option.Some(v1 * 2))
  lab2.lookup(doubled, k2, int_compare) |> should.equal(option.Some(v2 * 2))
  lab2.lookup(doubled, k3, int_compare) |> should.equal(option.Some(v3 * 2))
}

/// Тест свойства: fold_left и fold_right дают корректные результаты
pub fn fold_property_test() {
  let values = list.map(list.range(1, 5), fn(_) { gk() })
  let tree = lab2.from_list(list.zip(list.range(1, 5), values), int_compare)

  let expected_sum = list.fold(values, 0, fn(acc, v) { acc + v })

  // Сумма всех значений
  let sum_left = lab2.fold_left(tree, 0, fn(acc, _, value) { acc + value })
  let sum_right = lab2.fold_right(tree, 0, fn(_, value, acc) { acc + value })

  sum_left |> should.equal(expected_sum)
  sum_right |> should.equal(expected_sum)

  // Количество элементов
  let count_left = lab2.fold_left(tree, 0, fn(acc, _, _) { acc + 1 })
  let count_right = lab2.fold_right(tree, 0, fn(_, _, acc) { acc + 1 })

  count_left |> should.equal(5)
  count_right |> should.equal(5)
}

/// Тест свойства: to_list -> from_list должно давать эквивалентное дерево
pub fn list_roundtrip_property_test() {
  let k1 = gk()
  let v1 = gv()
  let k2 = gk()
  let v2 = gv()
  let k3 = gk()
  let v3 = gv()
  let k4 = gk()
  let v4 = gv()
  let original_list = [#(k1, v1), #(k2, v2), #(k3, v3), #(k4, v4)]
  let tree = lab2.from_list(original_list, int_compare)
  let result_list = lab2.to_list(tree)
  let restored_tree = lab2.from_list(result_list, int_compare)

  lab2.size(tree) |> should.equal(lab2.size(restored_tree))
  lab2.semantic_equal(tree, restored_tree, int_compare, string_equal)
  |> should.be_true

  // Проверяем, что все элементы присутствуют
  list.each(original_list, fn(item) {
    let #(key, value) = item
    lab2.lookup(restored_tree, key, int_compare)
    |> should.equal(option.Some(value))
  })
}

/// Тест инвариантов моноида (коммутативность для деревьев с разными ключами)
pub fn monoid_commutativity_test() {
  let k1 = gk()
  let v1 = gv()
  let k2 = gk()
  let v2 = gv()
  let k3 = gk()
  let v3 = gv()
  let k4 = gk()
  let v4 = gv()
  let tree1 = lab2.from_list([#(k1, v1), #(k2, v2)], int_compare)
  let tree2 = lab2.from_list([#(k3, v3), #(k4, v4)], int_compare)

  let concat1 = lab2.concat(tree1, tree2, int_compare)
  let concat2 = lab2.concat(tree2, tree1, int_compare)

  // Для деревьев с разными ключами конкатенация должна быть коммутативной
  lab2.size(concat1) |> should.equal(4)
  lab2.size(concat2) |> should.equal(4)

  // Оба дерева должны содержать все элементы
  [k1, k2, k3, k4]
  |> list.each(fn(key) {
    lab2.contains(concat1, key, int_compare) |> should.be_true
    lab2.contains(concat2, key, int_compare) |> should.be_true
  })
}
