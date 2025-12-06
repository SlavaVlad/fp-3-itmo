import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}

// Цвета узлов красно-черного дерева
// Red - красный узел, Black - чёрный узел
pub type Color {
  Red
  Black
}

// Ленивое значение для отложенных вычислений
// Позволяет откладывать создание поддеревьев до момента их использования
// Не знаю правильно это или нет на самом деле, в gleam вроде lazy нету встроенного
pub type Lazy(a) {
  Thunk(fn() -> a)
  // Отложенное вычисление через функцию
  Value(a)
  // Уже вычисленное значение
}

// Красно-черное дерево с ленивыми вычислениями
// Полиморфная структура данных с ключами типа k и значениями типа v
// Поддерживает инварианты красно-чёрного дерева для гарантии балансировки
pub type RBTree(k, v) {
  Empty
  // Пустое дерево
  Node(
    // Узел дерева
    color: Color,
    // Цвет узла (красный или чёрный)
    key: k,
    // Ключ для поиска и сортировки
    value: v,
    // Значение, связанное с ключом
    left: Lazy(RBTree(k, v)),
    // Левое поддерево (ленивое)
    right: Lazy(RBTree(k, v)),
    // Правое поддерево (ленивое)
  )
}

// Форсирует вычисление ленивого значения
// Если значение уже вычислено, возвращает его, иначе выполняет функцию
fn force(lazy: Lazy(a)) -> a {
  case lazy {
    Value(val) -> val
    Thunk(f) -> f()
  }
}

// Создаёт ленивое значение из функции
// Отложенное вычисление будет выполнено при первом обращении
fn delay(f: fn() -> a) -> Lazy(a) {
  Thunk(f)
}

// Создаёт пустое дерево - нейтральный элемент моноида
// Время выполнения: O(1)
pub fn empty() -> RBTree(k, v) {
  Empty
}

// Проверяет, является ли дерево пустым
// Время выполнения: O(1)
pub fn is_empty(tree: RBTree(k, v)) -> Bool {
  case tree {
    Empty -> True
    _ -> False
  }
}

// Создаёт узел с чёрным цветом
fn make_black(tree: RBTree(k, v)) -> RBTree(k, v) {
  case tree {
    Node(_, key, value, left, right) -> Node(Black, key, value, left, right)
    Empty -> Empty
  }
}

// Балансировка RB tree
fn balance(
  color: Color,
  key: k,
  value: v,
  left: Lazy(RBTree(k, v)),
  right: Lazy(RBTree(k, v)),
) -> RBTree(k, v) {
  let left_tree = force(left)
  let right_tree = force(right)

  case color, left_tree, right_tree {
    // Случай 1: красный левый parent с красными child
    Black, Node(Red, lk, lv, ll, lr), r ->
      case force(ll) {
        Node(Red, llk, llv, lll, llr) ->
          Node(
            Red,
            lk,
            lv,
            delay(fn() { Node(Black, llk, llv, lll, llr) }),
            delay(fn() { Node(Black, key, value, lr, Value(r)) }),
          )
        _ ->
          case force(lr) {
            Node(Red, lrk, lrv, lrl, lrr) ->
              Node(
                Red,
                lrk,
                lrv,
                delay(fn() { Node(Black, lk, lv, ll, lrl) }),
                delay(fn() { Node(Black, key, value, lrr, Value(r)) }),
              )
            _ -> Node(color, key, value, left, right)
          }
      }

    // Случай 3: красный правый parent с красным левым child
    Black, l, Node(Red, rk, rv, rl, rr) ->
      case force(rl) {
        Node(Red, rlk, rlv, rll, rlr) ->
          Node(
            Red,
            rlk,
            rlv,
            delay(fn() { Node(Black, key, value, Value(l), rll) }),
            delay(fn() { Node(Black, rk, rv, rlr, rr) }),
          )
        _ ->
          case force(rr) {
            Node(Red, rrk, rrv, rrl, rrr) ->
              Node(
                Red,
                rk,
                rv,
                delay(fn() { Node(Black, key, value, Value(l), rl) }),
                delay(fn() { Node(Black, rrk, rrv, rrl, rrr) }),
              )
            _ -> Node(color, key, value, left, right)
          }
      }

    // Базовый случай - балансировка не нужна
    _, _, _ -> Node(color, key, value, left, right)
  }
}

// Вставляет элемент в дерево с сохранением инвариантов красно-чёрного дерева
// Время выполнения: O(log n)
// compare - функция сравнения ключей, должна возвращать order.Lt, order.Eq или order.Gt
pub fn insert(
  tree: RBTree(k, v),
  key: k,
  value: v,
  compare: fn(k, k) -> Order,
) -> RBTree(k, v) {
  let result = insert_helper(tree, key, value, compare)
  make_black(result)
  // гарантия что корень чёрный
}

fn insert_helper(
  tree: RBTree(k, v),
  key: k,
  value: v,
  compare: fn(k, k) -> Order,
) -> RBTree(k, v) {
  case tree {
    Empty -> Node(Red, key, value, Value(Empty), Value(Empty))
    Node(color, k, v, left, right) ->
      case compare(key, k) {
        order.Lt ->
          balance(
            color,
            k,
            v,
            delay(fn() { insert_helper(force(left), key, value, compare) }),
            right,
          )
        order.Gt ->
          balance(
            color,
            k,
            v,
            left,
            delay(fn() { insert_helper(force(right), key, value, compare) }),
          )
        order.Eq -> Node(color, key, value, left, right)
      }
  }
}

// Поиск элемента в дереве
pub fn lookup(
  tree: RBTree(k, v),
  key: k,
  compare: fn(k, k) -> Order,
) -> Option(v) {
  case tree {
    Empty -> None
    Node(_, k, v, left, right) ->
      case compare(key, k) {
        order.Lt -> lookup(force(left), key, compare)
        order.Gt -> lookup(force(right), key, compare)
        order.Eq -> Some(v)
      }
  }
}

// Находит минимальный элемент в дереве
fn find_min(tree: RBTree(k, v)) -> Option(#(k, v)) {
  case tree {
    Empty -> None
    Node(_, key, value, left, _) ->
      case force(left) {
        Empty -> Some(#(key, value))
        _ -> find_min(force(left))
      }
  }
}

// Удаляет минимальный элемент из дерева
fn delete_min(tree: RBTree(k, v)) -> RBTree(k, v) {
  case tree {
    Empty -> Empty
    Node(color, key, value, left, right) ->
      case force(left) {
        Empty -> force(right)
        _ ->
          Node(
            color,
            key,
            value,
            delay(fn() { delete_min(force(left)) }),
            right,
          )
      }
  }
}

pub fn delete(
  tree: RBTree(k, v),
  key: k,
  compare: fn(k, k) -> Order,
) -> RBTree(k, v) {
  case tree {
    Empty -> Empty
    Node(_, k, v, left, right) ->
      case compare(key, k) {
        order.Lt ->
          Node(
            Black,
            k,
            v,
            delay(fn() { delete(force(left), key, compare) }),
            right,
          )
        order.Gt ->
          Node(
            Black,
            k,
            v,
            left,
            delay(fn() { delete(force(right), key, compare) }),
          )
        order.Eq ->
          case force(left), force(right) {
            Empty, Empty -> Empty
            _, Empty -> force(left)
            Empty, _ -> force(right)
            _, _ ->
              case find_min(force(right)) {
                None -> force(left)
                Some(#(min_key, min_value)) ->
                  Node(
                    Black,
                    min_key,
                    min_value,
                    left,
                    delay(fn() { delete_min(force(right)) }),
                  )
              }
          }
      }
  }
}

// Фильтрация элементов дерева
pub fn filter(
  tree: RBTree(k, v),
  predicate: fn(k, v) -> Bool,
  compare: fn(k, k) -> Order,
) -> RBTree(k, v) {
  fold_left(tree, empty(), fn(acc, key, value) {
    case predicate(key, value) {
      True -> insert(acc, key, value, compare)
      False -> acc
    }
  })
}

// Отображение значений в дереве
pub fn map(tree: RBTree(k, v), f: fn(v) -> w) -> RBTree(k, w) {
  case tree {
    Empty -> Empty
    Node(color, key, value, left, right) ->
      Node(
        color,
        key,
        f(value),
        delay(fn() { map(force(left), f) }),
        delay(fn() { map(force(right), f) }),
      )
  }
}

// Левая свёртка дерева
pub fn fold_left(tree: RBTree(k, v), acc: a, f: fn(a, k, v) -> a) -> a {
  case tree {
    Empty -> acc
    Node(_, key, value, left, right) -> {
      let left_acc = fold_left(force(left), acc, f)
      let current_acc = f(left_acc, key, value)
      fold_left(force(right), current_acc, f)
    }
  }
}

// Правая свёртка дерева
pub fn fold_right(tree: RBTree(k, v), acc: a, f: fn(k, v, a) -> a) -> a {
  case tree {
    Empty -> acc
    Node(_, key, value, left, right) -> {
      let right_acc = fold_right(force(right), acc, f)
      let current_acc = f(key, value, right_acc)
      fold_right(force(left), current_acc, f)
    }
  }
}

// Объединение двух деревьев (операция моноида)
pub fn concat(
  tree1: RBTree(k, v),
  tree2: RBTree(k, v),
  compare: fn(k, k) -> Order,
) -> RBTree(k, v) {
  fold_left(tree2, tree1, fn(acc, key, value) {
    insert(acc, key, value, compare)
  })
}

// Нейтральный элемент моноида (пустое дерево)
pub fn mempty() -> RBTree(k, v) {
  empty()
}

// Размер дерева
pub fn size(tree: RBTree(k, v)) -> Int {
  fold_left(tree, 0, fn(acc, _, _) { acc + 1 })
}

// Преобразование дерева в список пар
pub fn to_list(tree: RBTree(k, v)) -> List(#(k, v)) {
  fold_right(tree, [], fn(key, value, acc) { [#(key, value), ..acc] })
}

// Создание дерева из списка пар
pub fn from_list(
  list: List(#(k, v)),
  compare: fn(k, k) -> Order,
) -> RBTree(k, v) {
  list
  |> list_fold_left(empty(), fn(acc, pair) {
    let #(key, value) = pair
    insert(acc, key, value, compare)
  })
}

// Вспомогательная функция для свёртки списка
fn list_fold_left(list: List(a), acc: b, f: fn(b, a) -> b) -> b {
  case list {
    [] -> acc
    [head, ..tail] -> list_fold_left(tail, f(acc, head), f)
  }
}

// Эффективная проверка равенства двух деревьев
// Сравнивает деревья структурно без преобразования в списки
// Время выполнения: O(min(n, m)) где n, m - размеры деревьев
pub fn equal(
  tree1: RBTree(k, v),
  tree2: RBTree(k, v),
  key_compare: fn(k, k) -> Bool,
  value_compare: fn(v, v) -> Bool,
) -> Bool {
  equal_helper(tree1, tree2, key_compare, value_compare)
}

// Вспомогательная функция для структурного сравнения деревьев
// Использует замыкание при первом несовпадении
fn equal_helper(
  tree1: RBTree(k, v),
  tree2: RBTree(k, v),
  key_compare: fn(k, k) -> Bool,
  value_compare: fn(v, v) -> Bool,
) -> Bool {
  case tree1, tree2 {
    // Оба дерева пустые - равны
    Empty, Empty -> True

    Empty, _ -> False
    _, Empty -> False

    Node(color1, key1, value1, left1, right1),
      Node(color2, key2, value2, left2, right2)
    -> {
      color1 == color2
      // Ключи должны быть равны
      && key_compare(key1, key2)
      // Значения должны быть равны
      && value_compare(value1, value2)
      // Рекурсивно проверяем левые поддеревья (ленивые)
      && equal_helper(force(left1), force(left2), key_compare, value_compare)
      // Рекурсивно проверяем правые поддеревья (ленивые)
      && equal_helper(force(right1), force(right2), key_compare, value_compare)
    }
  }
}

// Проверка, содержится ли ключ в дереве
pub fn contains(tree: RBTree(k, v), key: k, compare: fn(k, k) -> Order) -> Bool {
  case lookup(tree, key, compare) {
    Some(_) -> True
    None -> False
  }
}

// Получение всех ключей дерева
pub fn keys(tree: RBTree(k, v)) -> List(k) {
  fold_right(tree, [], fn(key, _, acc) { [key, ..acc] })
}

// Получение всех значений дерева
pub fn values(tree: RBTree(k, v)) -> List(v) {
  fold_right(tree, [], fn(_, value, acc) { [value, ..acc] })
}

// Семантическое равенство деревьев - сравнивает содержимое независимо от структуры
// Два дерева семантически равны, если содержат одинаковые пары ключ-значение
// Время выполнения: O(n log n) из-за необходимости итерации
pub fn semantic_equal(
  tree1: RBTree(k, v),
  tree2: RBTree(k, v),
  key_order: fn(k, k) -> Order,
  value_equal: fn(v, v) -> Bool,
) -> Bool {
  // Быстрая проверка размеров
  case size(tree1) == size(tree2) {
    False -> False
    True -> {
      // Проверяем, что все элементы из tree1 есть в tree2 с теми же значениями
      fold_left(tree1, True, fn(acc, key, value) {
        acc
        && case lookup(tree2, key, key_order) {
          Some(other_value) -> value_equal(value, other_value)
          None -> False
        }
      })
    }
  }
}

// Сравнение с игнорированием цветов узлов (только структура и данные)
// Полезно когда важна только логическая структура дерева поиска
pub fn structure_equal(
  tree1: RBTree(k, v),
  tree2: RBTree(k, v),
  key_compare: fn(k, k) -> Bool,
  value_compare: fn(v, v) -> Bool,
) -> Bool {
  case tree1, tree2 {
    Empty, Empty -> True
    Empty, _ -> False
    _, Empty -> False
    Node(_, key1, value1, left1, right1), Node(_, key2, value2, left2, right2) -> {
      // Игнорируем цвет, сравниваем только ключи, значения и структуру
      key_compare(key1, key2)
      && value_compare(value1, value2)
      && structure_equal(force(left1), force(left2), key_compare, value_compare)
      && structure_equal(
        force(right1),
        force(right2),
        key_compare,
        value_compare,
      )
    }
  }
}
