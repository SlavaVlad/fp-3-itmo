-module(lab3_ffi).
-export([get_args/0, read_line/0]).

get_args() ->
    % Получаем аргументы командной строки без имени программы
    % Конвертируем из charlists в strings
    Args = init:get_plain_arguments(),
    lists:map(fun(Arg) -> 
        unicode:characters_to_binary(Arg, utf8)
    end, Args).

read_line() ->
    % Читаем строку из стандартного ввода
    case io:get_line("") of
        eof -> {error, nil};
        {error, _} -> {error, nil};
        Line -> {ok, string:trim(Line, trailing, "\n")}
    end.
