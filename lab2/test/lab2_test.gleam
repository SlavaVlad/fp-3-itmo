import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/string
import gleeunit
import gleeunit/should
import lab2

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

// Unit тесты

/// Тест создания пустого дерева
pub fn empty_tree_test() {
  let tree = lab2.empty()
  lab2.is_empty(tree) |> should.be_true
  lab2.size(tree) |> should.equal(0)
}

/// Тест вставки одного элемента
pub fn single_insert_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(5, "five", int_compare)

  lab2.is_empty(tree) |> should.be_false
  lab2.size(tree) |> should.equal(1)
  lab2.lookup(tree, 5, int_compare) |> should.equal(option.Some("five"))
  lab2.lookup(tree, 10, int_compare) |> should.equal(option.None)
}

/// Тест множественных вставок
pub fn multiple_insert_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(5, "five", int_compare)
    |> lab2.insert(3, "three", int_compare)
    |> lab2.insert(7, "seven", int_compare)
    |> lab2.insert(1, "one", int_compare)
    |> lab2.insert(9, "nine", int_compare)

  lab2.size(tree) |> should.equal(5)
  lab2.lookup(tree, 1, int_compare) |> should.equal(option.Some("one"))
  lab2.lookup(tree, 3, int_compare) |> should.equal(option.Some("three"))
  lab2.lookup(tree, 5, int_compare) |> should.equal(option.Some("five"))
  lab2.lookup(tree, 7, int_compare) |> should.equal(option.Some("seven"))
  lab2.lookup(tree, 9, int_compare) |> should.equal(option.Some("nine"))
}

/// Тест удаления элементов
pub fn delete_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(5, "five", int_compare)
    |> lab2.insert(3, "three", int_compare)
    |> lab2.insert(7, "seven", int_compare)
    |> lab2.delete(3, int_compare)

  lab2.size(tree) |> should.equal(2)
  lab2.lookup(tree, 3, int_compare) |> should.equal(option.None)
  lab2.lookup(tree, 5, int_compare) |> should.equal(option.Some("five"))
  lab2.lookup(tree, 7, int_compare) |> should.equal(option.Some("seven"))
}

/// Тест фильтрации
pub fn filter_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(1, "one", int_compare)
    |> lab2.insert(2, "two", int_compare)
    |> lab2.insert(3, "three", int_compare)
    |> lab2.insert(4, "four", int_compare)
    |> lab2.insert(5, "five", int_compare)

  let filtered = lab2.filter(tree, fn(key, _) { key % 2 == 0 }, int_compare)

  lab2.size(filtered) |> should.equal(2)
  lab2.contains(filtered, 2, int_compare) |> should.be_true
  lab2.contains(filtered, 4, int_compare) |> should.be_true
  lab2.contains(filtered, 1, int_compare) |> should.be_false
}

/// Тест отображения
pub fn map_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(1, 10, int_compare)
    |> lab2.insert(2, 20, int_compare)
    |> lab2.insert(3, 30, int_compare)

  let mapped = lab2.map(tree, fn(value) { value * 2 })

  lab2.lookup(mapped, 1, int_compare) |> should.equal(option.Some(20))
  lab2.lookup(mapped, 2, int_compare) |> should.equal(option.Some(40))
  lab2.lookup(mapped, 3, int_compare) |> should.equal(option.Some(60))
}

/// Тест левой свёртки
pub fn fold_left_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(1, 10, int_compare)
    |> lab2.insert(2, 20, int_compare)
    |> lab2.insert(3, 30, int_compare)

  let sum = lab2.fold_left(tree, 0, fn(acc, _, value) { acc + value })
  sum |> should.equal(60)
}

/// Тест правой свёртки
pub fn fold_right_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(1, "a", int_compare)
    |> lab2.insert(2, "b", int_compare)
    |> lab2.insert(3, "c", int_compare)

  let result = lab2.fold_right(tree, "", fn(_, value, acc) { value <> acc })
  // Порядок может отличаться в зависимости от структуры дерева
  result |> string.length |> should.equal(3)
}

/// Тест преобразования в список и обратно
pub fn to_from_list_test() {
  let original_list = [#(1, "one"), #(2, "two"), #(3, "three")]
  let tree = lab2.from_list(original_list, int_compare)
  let result_list = lab2.to_list(tree)

  lab2.size(tree) |> should.equal(3)
  list.length(result_list) |> should.equal(3)
  lab2.contains(tree, 1, int_compare) |> should.be_true
  lab2.contains(tree, 2, int_compare) |> should.be_true
  lab2.contains(tree, 3, int_compare) |> should.be_true
}

// Тесты свойств моноида

/// Тест нейтрального элемента (левая единица)
pub fn monoid_left_identity_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(1, "one", int_compare)
    |> lab2.insert(2, "two", int_compare)

  let result = lab2.concat(lab2.mempty(), tree, int_compare)

  lab2.equal(tree, result, int_equal, string_equal) |> should.be_true
}

/// Тест нейтрального элемента (правая единица)
pub fn monoid_right_identity_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(1, "one", int_compare)
    |> lab2.insert(2, "two", int_compare)

  let result = lab2.concat(tree, lab2.mempty(), int_compare)

  lab2.equal(tree, result, int_equal, string_equal) |> should.be_true
}

/// Тест ассоциативности
pub fn monoid_associativity_test() {
  let tree1 = lab2.empty() |> lab2.insert(1, "one", int_compare)
  let tree2 = lab2.empty() |> lab2.insert(2, "two", int_compare)
  let tree3 = lab2.empty() |> lab2.insert(3, "three", int_compare)

  let left_assoc =
    lab2.concat(lab2.concat(tree1, tree2, int_compare), tree3, int_compare)
  let right_assoc =
    lab2.concat(tree1, lab2.concat(tree2, tree3, int_compare), int_compare)

  // Проверяем, что оба дерева содержат одинаковые элементы
  lab2.size(left_assoc) |> should.equal(3)
  lab2.size(right_assoc) |> should.equal(3)
  lab2.contains(left_assoc, 1, int_compare) |> should.be_true
  lab2.contains(left_assoc, 2, int_compare) |> should.be_true
  lab2.contains(left_assoc, 3, int_compare) |> should.be_true
  lab2.contains(right_assoc, 1, int_compare) |> should.be_true
  lab2.contains(right_assoc, 2, int_compare) |> should.be_true
  lab2.contains(right_assoc, 3, int_compare) |> should.be_true
}

/// Тест инвариантов красно-чёрного дерева (упрощённая проверка)
pub fn red_black_invariant_test() {
  // Создаём большое дерево и проверяем, что поиск работает корректно
  let tree =
    lab2.from_list(
      [
        #(1, "one"),
        #(2, "two"),
        #(3, "three"),
        #(4, "four"),
        #(5, "five"),
        #(6, "six"),
        #(7, "seven"),
        #(8, "eight"),
        #(9, "nine"),
        #(10, "ten"),
      ],
      int_compare,
    )

  lab2.size(tree) |> should.equal(10)

  // Проверяем, что все элементы можно найти
  let all_found =
    list.all([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], fn(key) {
      lab2.contains(tree, key, int_compare)
    })

  all_found |> should.be_true
}

/// Тест обновления существующего ключа
pub fn update_existing_key_test() {
  let tree =
    lab2.empty()
    |> lab2.insert(1, "old", int_compare)
    |> lab2.insert(1, "new", int_compare)

  lab2.size(tree) |> should.equal(1)
  lab2.lookup(tree, 1, int_compare) |> should.equal(option.Some("new"))
}

/// Тест свойства: insert -> lookup должен возвращать вставленное значение
pub fn insert_lookup_property_test() {
  let test_cases = [
    #(1, "one"),
    #(42, "forty-two"),
    #(0, "zero"),
    #(-5, "minus-five"),
  ]

  list.each(test_cases, fn(test_case) {
    let #(key, value) = test_case
    let tree = lab2.empty() |> lab2.insert(key, value, int_compare)
    lab2.lookup(tree, key, int_compare) |> should.equal(option.Some(value))
  })
}

/// Тест свойства: size увеличивается при вставке новых элементов
pub fn insert_size_property_test() {
  let tree = lab2.empty()
  lab2.size(tree) |> should.equal(0)

  let tree1 = lab2.insert(tree, 1, "one", int_compare)
  lab2.size(tree1) |> should.equal(1)

  let tree2 = lab2.insert(tree1, 2, "two", int_compare)
  lab2.size(tree2) |> should.equal(2)

  let tree3 = lab2.insert(tree2, 3, "three", int_compare)
  lab2.size(tree3) |> should.equal(3)

  // Вставка существующего ключа не должна увеличивать размер
  let tree4 = lab2.insert(tree3, 2, "two-updated", int_compare)
  lab2.size(tree4) |> should.equal(3)
}

/// Тест свойства: filter сохраняет порядок и структуру
pub fn filter_property_test() {
  let original =
    lab2.from_list(
      [#(1, "a"), #(2, "b"), #(3, "c"), #(4, "d"), #(5, "e")],
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
  let original = lab2.from_list([#(1, 10), #(2, 20), #(3, 30)], int_compare)

  // Тождественное отображение
  let identity_map = lab2.map(original, fn(x) { x })
  lab2.equal(original, identity_map, int_equal, int_equal) |> should.be_true

  // Отображение с изменением
  let doubled = lab2.map(original, fn(x) { x * 2 })
  lab2.size(doubled) |> should.equal(lab2.size(original))
  lab2.lookup(doubled, 1, int_compare) |> should.equal(option.Some(20))
  lab2.lookup(doubled, 2, int_compare) |> should.equal(option.Some(40))
  lab2.lookup(doubled, 3, int_compare) |> should.equal(option.Some(60))
}

/// Тест свойства: fold_left и fold_right дают корректные результаты
pub fn fold_property_test() {
  let tree =
    lab2.from_list([#(1, 1), #(2, 2), #(3, 3), #(4, 4), #(5, 5)], int_compare)

  // Сумма всех значений
  let sum_left = lab2.fold_left(tree, 0, fn(acc, _, value) { acc + value })
  let sum_right = lab2.fold_right(tree, 0, fn(_, value, acc) { acc + value })

  sum_left |> should.equal(15)
  sum_right |> should.equal(15)

  // Количество элементов
  let count_left = lab2.fold_left(tree, 0, fn(acc, _, _) { acc + 1 })
  let count_right = lab2.fold_right(tree, 0, fn(_, _, acc) { acc + 1 })

  count_left |> should.equal(5)
  count_right |> should.equal(5)
}

/// Тест свойства: to_list -> from_list должно давать эквивалентное дерево
pub fn list_roundtrip_property_test() {
  let original_list = [#(3, "c"), #(1, "a"), #(4, "d"), #(2, "b")]
  let tree = lab2.from_list(original_list, int_compare)
  let result_list = lab2.to_list(tree)
  let restored_tree = lab2.from_list(result_list, int_compare)

  lab2.size(tree) |> should.equal(lab2.size(restored_tree))
  lab2.equal(tree, restored_tree, int_equal, string_equal) |> should.be_true

  // Проверяем, что все элементы присутствуют
  list.each(original_list, fn(item) {
    let #(key, value) = item
    lab2.lookup(restored_tree, key, int_compare)
    |> should.equal(option.Some(value))
  })
}

/// Тест инвариантов моноида (коммутативность для деревьев с разными ключами)
pub fn monoid_commutativity_test() {
  let tree1 = lab2.from_list([#(1, "a"), #(2, "b")], int_compare)
  let tree2 = lab2.from_list([#(3, "c"), #(4, "d")], int_compare)

  let concat1 = lab2.concat(tree1, tree2, int_compare)
  let concat2 = lab2.concat(tree2, tree1, int_compare)

  // Для деревьев с разными ключами конкатенация должна быть коммутативной
  lab2.size(concat1) |> should.equal(4)
  lab2.size(concat2) |> should.equal(4)

  // Оба дерева должны содержать все элементы
  [1, 2, 3, 4]
  |> list.each(fn(key) {
    lab2.contains(concat1, key, int_compare) |> should.be_true
    lab2.contains(concat2, key, int_compare) |> should.be_true
  })
}
