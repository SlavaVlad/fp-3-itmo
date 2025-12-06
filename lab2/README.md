# lab2

[![Package Version](https://img.shields.io/hexpm/v/lab2)](https://hex.pm/packages/lab2)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lab2/)

```sh
gleam add lab2@1
```
```gleam
import lab2

pub fn main() -> Nil {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/lab2>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

# Red-Black Tree с ленивыми вычислениями

## Описание

Реализация красно-чёрного дерева (Red-Black Tree) с ленивыми вычислениями на языке Gleam. Красно-чёрное дерево - это самобалансирующееся двоичное дерево поиска, которое гарантирует логарифмическую сложность операций вставки, удаления и поиска.

### Особенности реализации

- **Ленивые вычисления**: Поддеревья создаются только при необходимости, что экономит память и время
- **Полиморфность**: Дерево работает с любыми типами ключей и значений
- **Неизменяемость**: Все операции создают новые версии дерева, не изменяя исходное
- **Структура моноида**: Поддерживает операции объединения с нейтральным элементом

## API

### Основные операции

- `empty()` - создание пустого дерева
- `insert(tree, key, value, compare)` - вставка элемента
- `lookup(tree, key, compare)` - поиск элемента
- `delete(tree, key, compare)` - удаление элемента
- `contains(tree, key, compare)` - проверка наличия ключа

### Функции высшего порядка

- `map(tree, f)` - отображение функции на все значения
- `filter(tree, predicate, compare)` - фильтрация элементов
- `fold_left(tree, acc, f)` - левая свёртка
- `fold_right(tree, acc, f)` - правая свёртка

### Операции моноида

- `mempty()` - нейтральный элемент (пустое дерево)
- `concat(tree1, tree2, compare)` - объединение деревьев

### Вспомогательные функции

- `size(tree)` - размер дерева
- `to_list(tree)` - преобразование в список
- `from_list(list, compare)` - создание из списка
- `keys(tree)` - получение всех ключей
- `values(tree)` - получение всех значений
- `equal(tree1, tree2, key_eq, value_eq)` - сравнение деревьев

## Сложность операций

| Операция | Сложность |
|----------|-----------|
| lookup   | O(log n)  |
| insert   | O(log n)  |
| delete   | O(log n)  |
| size     | O(n)      |
| map      | O(n)      |
| filter   | O(n)      |
| fold     | O(n)      |

## Пример использования

```gleam
import lab2
import gleam/int

// Функция сравнения для целых чисел
fn int_compare(a: Int, b: Int) -> order.Order {
  int.compare(a, b)
}

pub fn main() {
  // Создание дерева и вставка элементов
  let tree = lab2.empty()
    |> lab2.insert(5, "five", int_compare)
    |> lab2.insert(3, "three", int_compare)
    |> lab2.insert(7, "seven", int_compare)
    |> lab2.insert(1, "one", int_compare)
  
  // Поиск элемента
  case lab2.lookup(tree, 5, int_compare) {
    Some(value) -> io.println("Found: " <> value)
    None -> io.println("Not found")
  }
  
  // Фильтрация чётных ключей
  let even_tree = lab2.filter(tree, fn(key, _) { key % 2 == 0 }, int_compare)
  
  // Отображение: удвоение длины строк
  let doubled = lab2.map(tree, fn(value) { value <> value })
  
  // Свёртка: подсчёт элементов
  let count = lab2.fold_left(tree, 0, fn(acc, _, _) { acc + 1 })
}
```

## Свойства моноида

Структура данных удовлетворяет аксиомам моноида:

1. **Ассоциативность**: `concat(concat(a, b), c) ≡ concat(a, concat(b, c))`
2. **Левая единица**: `concat(mempty(), a) ≡ a`
3. **Правая единица**: `concat(a, mempty()) ≡ a`

## Тестирование

Проект включает в себя comprehensive test suite:

- **Unit тесты**: Проверка корректности отдельных функций
- **Property-based тесты**: Проверка инвариантов и свойств структуры данных
- **Тесты моноида**: Проверка аксиом моноида

Запуск тестов:
```bash
gleam test
```

## Инварианты красно-чёрного дерева

1. Каждый узел либо красный, либо чёрный
2. Корень дерева чёрный
3. Все листья (NULL-узлы) чёрные
4. Если узел красный, то оба его потомка чёрные
5. Для каждого узла все пути от него до листьев содержат одинаковое количество чёрных узлов

Эти инварианты гарантируют, что самый длинный путь от корня до листа не более чем в 2 раза длиннее самого короткого пути, что обеспечивает логарифмическую сложность операций.
