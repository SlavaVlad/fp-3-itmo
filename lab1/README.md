# lab1

### Описание задачи
Цель: освоить базовые приёмы и абстракции функционального программирования: функции, поток управления и поток данных, сопоставление с образцом, рекурсия, свёртка, отображение, работа с функциями как с данными, списки.

В рамках лабораторной работы вам предлагается решить несколько задач [проекта Эйлер](https://projecteuler.net/archives). Список задач -- ваш вариант.

Для каждой проблемы должно быть представлено несколько решений:

1. монолитные реализации с использованием:
   - хвостовой рекурсии;
   - рекурсии (вариант с хвостовой рекурсией не является примером рекурсии);
2. модульной реализации, где явно разделена генерация последовательности, фильтрация и свёртка (должны использоваться функции reduce/fold, filter и аналогичные);
3. генерация последовательности при помощи отображения (map);
4. работа со спец. синтаксисом для циклов (Gleam не применимо);
5. работа с бесконечными списками для языков, поддерживающих ленивые коллекции или итераторы как часть языка (в Gleam только через сторонние библиотеки, а не часть языка);
6. реализация на любом удобном для вас традиционном языке программирования для сравнения. (Kotlin)

Требуется использовать идиоматичный для технологии стиль программирования.

Содержание отчёта:

- титульный лист;
- описание проблемы;
- ключевые элементы реализации с минимальными комментариями;
- выводы (отзыв об использованных приёмах программирования).

Примечания:

- необходимо понимание разницы между ленивыми коллекциями и итераторами;
- нужно знать особенности используемой технологии и того, как работают использованные вами приёмы.

### Задачи к выполнению

## [Task 1](https://projecteuler.net/problem=1)
If we list all the natural numbers below $10$ that are multiples of $3$ or $5$, we get $3, 5, 6$ and $9$. The sum of these multiples is $23$.
Find the sum of all the multiples of $3$ or $5$ below $1000$.

## [Task 30](https://projecteuler.net/problem=30)
Surprisingly there are only three numbers that can be written as the sum of fourth powers of their digits:
$$\begin{align}
1634 = 1^4 + 6^4 + 3^4 + 4^4\\
8208 = 8^4 + 2^4 + 0^4 + 8^4\\
9474 = 9^4 + 4^4 + 7^4 + 4^4
\end{align}$$
As $1 = 1^4$ is not a sum it is not included.
The sum of these numbers is $1634 + 8208 + 9474 = 19316$.
Find the sum of all the numbers that can be written as the sum of fifth powers of their digits.

### Проверка

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

```sh
>gleam run
  Compiling lab1
   Compiled in 0.50s
    Running lab1.main
======================================================================
TASK 1: Sum of multiples of 3 or 5 below 1000
======================================================================
1. Tail recursion:
   Result: 233168
2. Regular recursion:
   Result: 233701
3. Modular (filter + fold):
   Result: 233168
4. Map-based:
   Result: 233168

======================================================================
TASK 2: Sum of numbers equal to sum of 5th powers of digits
======================================================================
1. Tail recursion:
   Result: 443839
2. Regular recursion:
   Result: 443839
3. Modular (filter + fold):
   Result: 443839
4. Map-based:
   Result: 443839
```

### И референс на kotlin
```kotlin
fun main() {
    // Task 1: Sum of multiples of 3 or 5 below 1000
    val sum1 = (1 until 1000).filter { it % 3 == 0 || it % 5 == 0 }.sum()
    println("Task 1: $sum1")

    // Task 30: Sum of numbers equal to sum of fifth powers of their digits
    val sum30 = (2..443839).filter { num ->
        val digits = num.toString().map { it.digitToInt() }
        val powerSum = digits.sumOf { it.toDouble().pow(5).toInt() }
        powerSum == num
    }.sum()
    println("Task 30: $sum30")
}
```

```sh
Task 1: 233168
Task 30: 443839
```