# ОТЧЁТ

Университет ИТМО

**Лабораторная работа № 1**  
По дисциплине "Функциональное программирование"

**Выполнил:** Владимиров Владислав Александрович  
**Группа:** P3322  
**Дата:** 18 ноября 2025 г.

## Описание проблемы

[Полное описание задания лабораторной работы](/lab1/README.md)

Если кратко:

**Задача 1:** Сумма всех чисел ниже 1000, делящихся на 3 или 5 (ответ: 233 168)

**Задача 2:** Сумма чисел, равных сумме пятых степеней своих цифр в диапазоне [2, 354 294]

Реализация на **Gleam**

## Ключевые элементы реализации

### Задача 1: Sum of multiples

**1. Хвостовая рекурсия**

```gleam
pub fn sum_multiples_tail_recursive(limit: Int) -> Int {
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
```

Аккумулятор сохраняет сумму, рекурсивный вызов в "хвосте" функции

**2. Настоящая рекурсия**

```gleam
pub fn sum_multiples_recursive(limit: Int) -> Int {
  case limit - 1 {
    n if n <= 0 -> 0
    n if n % 3 == 0 || n % 5 == 0 -> n + sum_multiples_recursive(n)
    n -> sum_multiples_recursive(n)
  }
}
```

Рекурсивный вызов внутри выражения, больше памяти на стек

**3. Модульная реализация (filter + fold)**

```gleam
pub fn sum_multiples_modular(limit: Int) -> Int {
  list.range(1, limit - 1)
  |> list.filter(fn(n) { n % 3 == 0 || n % 5 == 0 })
  |> list.fold(0, fn(acc, n) { acc + n })
}
```

Генерация, фильтрация, свёртка в едином пайплайне

**4. Map-based подход**

```gleam
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
```

Преобразование в значения или нули, затем суммирование

### Задача 2: Sum of powers of digits

**1. Хвостовая рекурсия**

```gleam
pub fn sum_power_equals_tail_recursive(power: Int, max_limit: Int) -> Int {
  tail_recursive_helper(2, max_limit, 0, power)
}

fn tail_recursive_helper(current: Int, max: Int, acc: Int, power: Int) -> Int {
  case current > max {
    True -> acc
    False -> {
      let digit_sum = digits_power_sum_tail(current, power)
      case digit_sum == current {
        True -> tail_recursive_helper(current + 1, max, acc + current, power)
        False -> tail_recursive_helper(current + 1, max, acc, power)
      }
    }
  }
}

fn digits_power_sum_acc(n: Int, power: Int, acc: Int) -> Int {
  case n {
    0 -> acc
    _ -> {
      let digit = n % 10
      let pow_val = int_pow(digit, power)
      digits_power_sum_acc(n / 10, power, acc + pow_val)
    }
  }
}

fn int_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * int_pow(base, exp - 1)
  }
}
```

Двухуровневая хвостовая рекурсия, внешний цикл по числам, внутренний по цифрам

**2. Настоящая рекурсия**

```gleam
pub fn sum_power_equals_recursive(power: Int, max_limit: Int) -> Int {
  case max_limit < 2 {
    True -> 0
    False -> {
      let sum_of_powers =
        string.inspect(max_limit)
        |> string.to_graphemes()
        |> list.map(fn(c) {
          let assert Ok(d) = int.parse(c)
          recursive_pow(d, power)
        })
        |> list.fold(0, fn(acc, n) { acc + n })

      case sum_of_powers == max_limit {
        True -> max_limit + sum_power_equals_recursive(power, max_limit - 1)
        False -> sum_power_equals_recursive(power, max_limit - 1)
      }
    }
  }
}

fn recursive_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * recursive_pow(base, exp - 1)
  }
}
```

Конвертирование в строку, разбиение на char, парсинг цифр

**3. Модульная реализация**

```gleam
pub fn sum_power_equals_modular(power: Int, max_limit: Int) -> Int {
  list.range(2, max_limit)
  |> list.filter(fn(n) {
    let sum_of_powers =
      string.inspect(n)
      |> string.to_graphemes()
      |> list.map(fn(c) {
        let assert Ok(d) = int.parse(c)
        modular_pow(d, power)
      })
      |> list.fold(0, fn(acc, x) { acc + x })
    sum_of_powers == n
  })
  |> list.fold(0, fn(acc, n) { acc + n })
}

fn modular_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * modular_pow(base, exp - 1)
  }
}
```

Фильтрирование подходящих чисел, затем суммирование

**4. Map-based подход**

```gleam
pub fn sum_power_equals_map(power: Int, max_limit: Int) -> Int {
  list.range(2, max_limit)
  |> list.map(fn(n) {
    let sum_of_powers =
      string.inspect(n)
      |> string.to_graphemes()
      |> list.map(fn(c) {
        let assert Ok(d) = int.parse(c)
        map_pow(d, power)
      })
      |> list.fold(0, fn(acc, x) { acc + x })

    case sum_of_powers == n {
      True -> n
      False -> 0
    }
  })
  |> list.fold(0, fn(acc, n) { acc + n })
}

fn map_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * map_pow(base, exp - 1)
  }
}
```

Трансформирование каждого числа в значение или ноль

## Выводы

**Хвостовая рекурсия** компилируется в цикл, безопасна и более экономична по памяти, естественный выбор для больших данных

**Настоящая рекурсия** выражает математику красиво, но требует стека и больше памяти, работает только на малых входных данных

**Filter + fold** разделяет логику четко, читается как поток данных. Более высокоуровневые абстракции для фп, может быть избыточно

**Map-based** универсален, но менее понятно что от него ожидать, ибо опять же высокий уровень

Gleam обеспечивает гарантированную оптимизацию хвостовой рекурсии (компилятор трансформирует в цикл), pattern matching для четкости, pipe-оператор для читаемости, типизацию для безопасности. 

**Отзыв о методах:**
1. Писать на gleam понравилось, паттерн pipeline был необычен, как и синтаксис в целом. 
2. И Александр Владимирович говорил про странные записи математики типа 2 + { 2 *. 2.0 }, это действительно плохо читается\)
3. Также интересно писать без циклов, при этом имея доступ к высокоуровневым функциям типа map, которые если писать самому во-первых boilerplate, а во вторы хуже читаются
4. В общем, язык по синтаксису лаконичен, очень хочется перейти к асинхронности и начать эксплуатировать BEAM по полной