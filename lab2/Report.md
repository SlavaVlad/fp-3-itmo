# Отчёт по лабораторной работе №2

**Университет ИТМО**  
**Факультет программной инженерии и компьютерной техники**  

**Студент:** Владимиров Владислав Александрович 
**Группа:** P3222

**Тема:** Реализация Red-Black Tree с ленивыми вычислениями  
**Лабораторная работа №2**  
**Дисциплина:** Функциональное программирование  

---

## Требования к разработанному ПО

### Цель работы
Освоиться с построением пользовательских типов данных, полиморфизмом, рекурсивными алгоритмами и средствами тестирования (unit testing, property-based testing), а также разделением интерфейса и особенностей реализации.

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
/// Цвета узлов красно-черного дерева
pub type Color {
  Red
  Black
}

/// Ленивое значение для отложенных вычислений
pub type Lazy(a) {
  Thunk(fn() -> a)  // Отложенное вычисление
  Value(a)          // Уже вычисленное значение
}

/// Красно-черное дерево с ленивыми вычислениями
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
/// Форсирует вычисление ленивого значения
fn force(lazy: Lazy(a)) -> a {
  case lazy {
    Value(val) -> val
    Thunk(f) -> f()
  }
}

/// Создаёт ленивое значение из функции
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
/// Нейтральный элемент
pub fn mempty() -> RBTree(k, v) {
  empty()
}

/// Операция объединения
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
   - `empty_tree_test()` - создание пустого дерева
   - `single_insert_test()` - вставка одного элемента
   - `multiple_insert_test()` - множественные вставки
   - `delete_test()` - удаление элементов
   - `filter_test()` - тестирование фильтрации
   - `map_test()` - тестирование отображения
   - `fold_left_test()`, `fold_right_test()` - тестирование свёрток
   - `to_from_list_test()` - конвертация в список и обратно

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
/// Левая единица: mempty ∘ a = a
pub fn monoid_left_identity_test()

/// Правая единица: a ∘ mempty = a  
pub fn monoid_right_identity_test()

/// Ассоциативность: (a ∘ b) ∘ c = a ∘ (b ∘ c)
pub fn monoid_associativity_test()

/// Коммутативность (для непересекающихся множеств ключей)
pub fn monoid_commutativity_test()
```

### Отчёт тестирования

```
Running lab2_test.main
.....................
21 passed, no failures
   Compiled in 0.46s
```

### Метрики производительности

| Операция | Теоретическая сложность | Реализованная сложность |
|----------|------------------------|------------------------|
| lookup   | O(log n)               | O(log n)               |
| insert   | O(log n)               | O(log n)               |
| delete   | O(log n)               | O(log n)               |
| size     | O(n)                   | O(n)                   |
| map      | O(n)                   | O(n)                   |
| filter   | O(n log n)             | O(n log n)             |
| fold     | O(n)                   | O(n)                   |

---

## Выводы

### Использованные приёмы программирования

1. **Ленивые вычисления (Lazy Evaluation):**
   - **Преимущества:** Экономия памяти, возможность работы с потенциально бесконечными структурами, отложенные вычисления только при необходимости
   - **Реализация:** Тип `Lazy(a)` с конструкторами `Thunk` и `Value`
   - **Эффект:** Поддеревья создаются только при обращении к ним, что снижает накладные расходы

2. **Полиморфизм:**
   - **Преимущества:** Универсальность структуры данных для любых типов ключей и значений
   - **Реализация:** Параметрические типы `RBTree(k, v)`
   - **Эффект:** Возможность использования с различными типами данных без дублирования кода

3. **Неизменяемые структуры данных:**
   - **Преимущества:** Отсутствие побочных эффектов, thread-safety, упрощение рассуждений о коде
   - **Реализация:** Все операции возвращают новые версии дерева
   - **Эффект:** Функциональная чистота и предсказуемость

4. **Структурная рекурсия:**
   - **Преимущества:** Естественность выражения алгоритмов для древовидных структур
   - **Реализация:** Паттерн-матчинг на конструкторах типа
   - **Эффект:** Читаемый и понятный код

5. **Моноид (Monoid):**
   - **Преимущества:** Математические гарантии корректности операций объединения
   - **Реализация:** Операции `mempty()` и `concat()` с проверкой аксиом
   - **Эффект:** Композируемость и предсказуемость операций

6. **Функции высшего порядка:**
   - **Преимущества:** Абстракция над общими паттернами обработки данных
   - **Реализация:** `map`, `filter`, `fold_left`, `fold_right`
   - **Эффект:** Выразительность и переиспользуемость кода

### Особенности языка Gleam

1. **Система типов:** Строгая статическая типизация с выводом типов облегчает разработку и предотвращает ошибки
2. **Паттерн-матчинг:** Удобный и безопасный способ работы с алгебраическими типами данных
3. **Отсутствие null:** Использование `Option(a)` делает код более безопасным
4. **Interoperability:** Возможность компиляции в Erlang и JavaScript расширяет область применения

### Проблемы и ограничения

1. **Упрощённое удаление:** Реализованный алгоритм удаления не полностью поддерживает все инварианты Red-Black Tree
2. **Производительность:** Ленивые вычисления могут добавлять накладные расходы в некоторых случаях
3. **Сложность балансировки:** Полная реализация всех случаев балансировки требует дополнительной работы

### Общая оценка

Реализация Red-Black Tree с ленивыми вычислениями на языке Gleam продемонстрировала эффективность функциональных подходов к программированию. Использование неизменяемых структур данных, полиморфизма и функций высшего порядка привело к созданию гибкой, безопасной и переиспользуемой библиотеки.

Ленивые вычисления показали свою полезность для оптимизации производительности при работе с большими деревьями, где не все поддеревья могут быть использованы.

