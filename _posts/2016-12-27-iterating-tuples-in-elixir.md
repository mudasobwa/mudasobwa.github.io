---
layout: post
title: "Iterating Tuples in Elixir"
description: "handy way of making tuples enumerable"
category: hacking
tags:
  - elixir
---

According to [erlang docs](http://erlang.org/doc/reference_manual/data_types.html#id68683),

> A tuple is a compound data type with a fixed number of terms:
>
    {Term1,...,TermN}

> Each term `Term` in the tuple is called an **element**.
The number of elements is said to be the **size** of the tuple.

`Tuple`s are known to be faster than `List`s (and even `Map`s)
for elements’ direct access. Also, some libraries/packages often format
a response as tuples.

So, `Tuple`s are good. Save for one single glitch: they are not iterable.
That said, `Tuple`s do not implement `Enumerable` protocol. The goal of this
small post is to show how this protocol might be implemented for tuples
in non-naïve way (the naïve way would be to just convert tuples to lists.)

{% highlight elixir %}
defmodule Tuple.Enumerable do
  defimpl Enumerable, for: Tuple do
    @max_items 42

    def count(tuple), do: tuple_size(tuple)

    # member? implementation is done through casting tuple to the list
    #  it’s not required for iteration, and building all those matched
    #  clauses seems to be an overkill here
    def member?([], _), do: {:ok, false}
    def member?(tuple, value) when is_tuple(tuple) do
      tuple |> Tuple.to_list |> member?(value)
    end
    def member?(tuple, value) when is_list(tuple) do
      for [h | t] <- tuple do
        if h == value, do: {:ok, true}, else: member?(t, value)
      end
    end


    def reduce(tuple, acc, fun) do
      do_reduce(tuple, acc, fun)
    end

    defp do_reduce(_,       {:halt, acc}, _fun),   do: {:halted, acc}
    defp do_reduce(tuple,   {:suspend, acc}, fun)  do
      {:suspended, acc, &do_reduce(tuple, &1, fun)}
    end
    defp do_reduce({},      {:cont, acc}, _fun),   do: {:done, acc}
    defp do_reduce({value}, {:cont, acc}, fun),    do: do_reduce({}, fun.(value, acc), fun)

    Enum.each(1..@max_items-1, fn tot ->
      tail = Enum.join(Enum.map(1..tot, & "e_#{&1}"), ",")
      match = Enum.join(["value"] ++ [tail], ",")
      Code.eval_string(
        "defp do_reduce({#{match}}, {:cont, acc}, fun), do: do_reduce({#{tail}}, fun.(value, acc), fun)", [], __ENV__
      )
    end)

    # list fallback for huge tuples
    defp do_reduce([h | t], {:cont, acc}, fun)     do
      do_reduce((if Enum.count(t) <= @max_items, do: List.to_tuple(t), else: t), fun.(h, acc), fun)
    end

    # fallback to list for huge tuples
    defp do_reduce(huge,    {:cont, acc}, fun) when huge > @max_items do
      do_reduce(Tuple.to_list(huge), {:cont, acc}, fun)
    end
  end
end
{% endhighlight %}

The code above builds `@max_items` function match clauses for `Tuple`s
having not more than `42` members. That guarantees no conversion to `list`
happens for those.

Huge `Tuple`s, having more than `42` members, will be converted to lists
before operating.

The approach above might be useful in the case when one needs to use
`Tuple`s for quick access: changing `@max_items` to super high value
would drastically increase _the compilation time_, while the _execution_ time
will remain very impressive, comparing to `List`s.
