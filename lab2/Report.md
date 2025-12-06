# Отчёт по лабораторной работе №2

**Университет ИТМО**  
**Факультет программной инженерии и компьютерной техники**  

**Студент:** Владимиров Владислав Александрович 
**Группа:** P3322

**Тема:** Реализация Red-Black Tree с ленивыми вычислениями  
**Лабораторная работа №2**  
**Дисциплина:** Функциональное программирование  

---

## Требования к разработанному ПО

### Цель работы
Цель: освоиться с построением пользовательских типов данных, полиморфизмом, рекурсивными алгоритмами и средствами тестирования (unit testing, property-based testing), а также разделением интерфейса и особенностей реализации.

В рамках лабораторной работы вам предлагается реализовать одну из предложенных классических структур данных (список, дерево, бинарное дерево, hashmap, граф...).

Требования:

1. Функции:
    - добавление и удаление элементов;
    - фильтрация;
    - отображение (map);
    - свертки (левая и правая);
    - структура должна быть [моноидом](https://ru.m.wikipedia.org/wiki/Моноид).
2. Структуры данных должны быть неизменяемыми.
3. Библиотека должна быть протестирована в рамках unit testing.
4. Библиотека должна быть протестирована в рамках property-based тестирования (как минимум 3 свойства, включая свойства моноида).
5. Структура должна быть полиморфной.
6. Требуется использовать идиоматичный для технологии стиль программирования. Примечание: некоторые языки позволяют получить большую часть API через реализацию небольшого интерфейса. Так как лабораторная работа про ФП, а не про экосистему языка -- необходимо реализовать их вручную и по возможности -- обеспечить совместимость.
7. Обратите внимание:
    - API должно быть реализовано для заданного интерфейса и оно не должно "протекать". На уровне тестов -- в первую очередь нужно протестировать именно API (dict, set, bag).
    - Должна быть эффективная реализация функции сравнения (не наивное приведение к спискам, их сортировка с последующим сравнением), реализованная на уровне API, а не внутреннего представления.



### Вариант задания
**Red-Black Tree Lazy** - красно-чёрное дерево на ленивых вычислениях.

### Функциональные требования

1. **Основные операции:**
   - Добавление элементов (`insert`)
   - Удаление элементов (`delete`) 
   - Фильтрация (`filter`)
   - Отображение (`map`)
   - Свёртки левая и правая (`fold_left`, `fold_right`)

2. **Структурные требования:**
   - Структура должна быть моноидом
   - Неизменяемые структуры данных
   - Полиморфная реализация
   - Использование ленивых вычислений

3. **Требования к тестированию:**
   - Unit testing для всех функций
   - Property-based тестирование (минимум 3 свойства)
   - Тестирование свойств моноида

### Технические требования

- **Язык программирования:** Gleam
- **Сложность операций:** O(log n) для insert, delete, lookup
- **API не должно "протекать"**
- **Эффективная реализация сравнения деревьев**
- **Идиоматичный стиль программирования**

---

## Ключевые элементы реализации

### Основные типы данных

```gleam
// Цвета узлов красно-черного дерева
pub type Color {
  Red
  Black
}

// Ленивое значение для отложенных вычислений
pub type Lazy(a) {
  Thunk(fn() -> a)  // Отложенное вычисление
  Value(a)          // Уже вычисленное значение
}

// Красно-черное дерево с ленивыми вычислениями
pub type RBTree(k, v) {
  Empty                                    // Пустое дерево
  Node(
    color: Color,                          // Цвет узла
    key: k,                               // Ключ
    value: v,                             // Значение
    left: Lazy(RBTree(k, v)),             // Левое поддерево (ленивое)
    right: Lazy(RBTree(k, v)),            // Правое поддерево (ленивое)
  )
}
```

### Управление ленивыми вычислениями

```gleam
// Форсирует вычисление ленивого значения
fn force(lazy: Lazy(a)) -> a {
  case lazy {
    Value(val) -> val
    Thunk(f) -> f()
  }
}

// Создаёт ленивое значение из функции
fn delay(f: fn() -> a) -> Lazy(a) {
  Thunk(f)
}
```

### Балансировка красно-чёрного дерева

Реализованы 4 случая нарушения инвариантов Red-Black Tree:

```gleam
n balance(
  color: Color,
  key: k,
  value: v,
  left: Lazy(RBTree(k, v)),
  right: Lazy(RBTree(k, v)),
) -> RBTree(k, v) {
  let left_tree = force(left)
  let right_tree = force(right)

  case color, left_tree, right_tree {
    // Случай 1: красный левый дедушка с красными детьми
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

    // Случай 3: красный правый дедушка с красным левым внуком
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
```

### Основные операции

**Главное - сравнение**
```gleam
// Вспомогательная функция для структурного сравнения деревьев
// Использует замыкание при первом несовпадении
fn equal(
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
```

**Вставка элемента:**
```gleam
pub fn insert(tree: RBTree(k, v), key: k, value: v, 
             compare: fn(k, k) -> Order) -> RBTree(k, v) {
  let result = insert_helper(tree, key, value, compare)
  make_black(result)  // Корень всегда чёрный
}
```

**Поиск элемента:**
```gleam
pub fn lookup(tree: RBTree(k, v), key: k, 
             compare: fn(k, k) -> Order) -> Option(v) {
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
```

### Функции высшего порядка

**Отображение:**
```gleam
pub fn map(tree: RBTree(k, v), f: fn(v) -> w) -> RBTree(k, w) {
  case tree {
    Empty -> Empty
    Node(color, key, value, left, right) ->
      Node(color, key, f(value),
        delay(fn() { map(force(left), f) }),
        delay(fn() { map(force(right), f) }))
  }
}
```

**Левая свёртка:**
```gleam
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
```

### Операции моноида

```gleam
// Нейтральный элемент
pub fn mempty() -> RBTree(k, v) {
  empty()
}

// Операция объединения
pub fn concat(tree1: RBTree(k, v), tree2: RBTree(k, v), 
             compare: fn(k, k) -> Order) -> RBTree(k, v) {
  fold_left(tree2, tree1, fn(acc, key, value) {
    insert(acc, key, value, compare)
  })
}
```

---

## Тесты и метрики

### Unit тесты
- `empty_tree_test()` - создание пустого дерева и проверка `is_empty()`, `size()`
- `single_insert_test()` - вставка одного элемента, проверка `lookup()` и размера
- `multiple_insert_test()` - множественные вставки с проверкой всех элементов
- `delete_test()` - удаление элементов с проверкой корректности
- `update_existing_key_test()` - обновление существующих ключей
- `filter_test()` - фильтрация четных чисел, проверка размера и содержимого
- `map_test()` - отображение значений (умножение на 2), проверка корректности
- `fold_left_test()` - левая свёртка для суммирования значений
- `fold_right_test()` - правая свёртка для конкатенации строк
- `to_from_list_test()` - конвертация дерево→список→дерево с проверкой эквивалентности
- `red_black_invariant_test()` - работа с большим деревом (10 элементов), проверка балансировки
- `semantic_equal_test()` - семантическое равенство (независимо от структуры)
- `structure_equal_test()` - структурное равенство без учёта цветов узлов

### Property-based тесты

1. **Свойства основных операций:**
   ```gleam
   pub fn insert_lookup_property_test() // insert -> lookup инвариант
   pub fn insert_size_property_test()   // размер увеличивается корректно
   pub fn filter_property_test()        // фильтр сохраняет структуру
   pub fn map_property_test()           // map сохраняет структуру
   ```

2. **Свойства свёрток:**
   ```gleam
   pub fn fold_property_test()          // корректность левой/правой свёртки
   ```

3. **Свойства преобразований:**
   ```gleam
   pub fn list_roundtrip_property_test() // to_list -> from_list эквивалентность
   ```

### Тесты моноида

```gleam
// Левая единица: mempty ∘ a = a
pub fn monoid_left_identity_test()

// Правая единица: a ∘ mempty = a  
pub fn monoid_right_identity_test()

// Ассоциативность: (a ∘ b) ∘ c = a ∘ (b ∘ c)
pub fn monoid_associativity_test()

// Коммутативность (для непересекающихся множеств ключей)
pub fn monoid_commutativity_test()
```

### Отчёт тестирования

```
> gleam test
  Compiling lab2
   Compiled in 0.46s
    Running lab2_test.main
.......................
23 passed, no failures
```

### Метрики производительности

| Операция | Сложность|
|----------|------------------------|
| lookup   | O(log n)               |
| insert   | O(log n)               |
| delete   | O(log n)               |
| size     | O(n)                   |
| map      | O(n)                   |
| filter   | O(n log n)             |
| fold     | O(n)                   |

---

## Выводы
Использование ленивых вычислений повышает эффективность использования памяти при операциях со структурами данных высокой вложенности (в нашем случае) ценой cpu на вычисление значения. 
Также использовал типы, а ещё писал своё сравнение без высокоуровневых абстракций.