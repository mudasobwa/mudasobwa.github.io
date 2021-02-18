---
layout: post
title: "Dynamic Nested Function Call"
description: "Macro to the rescue: how to build the nested function call dynamically with a bit of metaprogramming"
category: hacking
tags:
  - elixir
---

During my lazy work on [`Tyyppi`](https://hexdocs.pm/tyyppi), I encountered the necessity to dynamically build the deeply nested function. I use [`StreamData`](https://hexdocs.pm/stream_data) for property-based generators, and to produce a generator for the [`Tyyppi.Struct`](https://hexdocs.pm/tyyppi/Tyyppi.Struct.html), I recursively call generators on all the fields and then I am to [`StreamData.bind/2`](https://hexdocs.pm/stream_data/StreamData.html#bind/2) all of them to each other.

The number of fields is unknown in advance, as well as field types. So I am after dynamic generation of somewhat like

```elixir
alias StreamData, as: SD
SD.bind(SD.list_of(SD.integer(), min_length: 1), fn list ->
  SD.bind(SD.member_of(list), fn elem ->
    SD.constant({list, elem})
  end)
end)
```

the above is nested the number of times equal to the number of fields, each generator is taken from the field, and I could have been all set unless the inner `SD.constant/1` call.

![Sunset in Montgat](/img/nested-function-call.jpg)

To simplify things, let’s consider we are to dynamically build this

```elixir
@spec foo(atom(), (any() -> any())) :: any()

foo(:bar, fn arg1 ->
  foo(:baz, fn arg2 ->
    ...
      foo(:bzz, fn argN ->
        {arg1, arg2, ..., argN}
      end)
    ...
  end)
end)
```

As we can see, the inner return _captures_ values from all the outer closures. This looks pretty straightforward when written down, but unfortunately it cannot be produced with any kind of `reduce/3`, because the tuple size returned from the inner clause (which is equal to a level of nesting by the way) is unknown upfront, and all the closure captures are done downwards.

This is where metaprogramming is _mandatory_ to accomplish a task.

Let’s start with examining the AST produced by the example above.

```elixir
quote do
  foo(:bar, fn arg1 ->
    foo(:bar, fn arg2 -> 
      {arg1, arg2}
    end)
  end)
end
```

results in

```elixir
{:foo, [], [
   :bar,
   {:fn, [], [
      {:->, [], [
         [{:arg1, [], Elixir}],
         {:foo, [], [
            :bar,
            {:fn, [], [
               {:->, [], [
                  [{:arg2, [], Elixir}],
                  {​{:arg1, [], Elixir}, {:arg2, [], Elixir}}
                ]}]}]}]}]}]}
```

Beware! we are going to deal with the raw _AST_ to save keystrokes. The inner clause is simple, let’s produce a function that returns it.

```elixir
defp leaf(args),
  do: {:{}, [], args}
```

Tuples of size less than 3 might be also quoted with `:{}`, so we opt-in for the generic solution here.

Let’s now gaze at the closure.

```elixir
{:foo, [], [
  :bar,
  {:fn, [], [
      {:->, [], [[__ARG__, __ACC__]}]}]}
```

macro variable `__ARG__` there denotes the argument of _current_ anonymous function and `__ACC__` stays for the accumulator that came from the previous recursive iteration. So, we might now create our `branch` function

```elixir
defp branch({field, arg}, acc),
  do: {:foo, [], [field, {:fn, [], [{:->, [], [[arg], acc]}]}]}
```

`field` above is passed as a hint of how to customize each step when needed. OK, we are almost done. Let’s build up the whole clause for `N` arguments.

```elixir
defp nested(fields) do
  args =
    fields
    |> length()
    |> Macro.generate_arguments(__MODULE__)
    |> Enum.reverse()
  fields_args = Enum.zip(fields, args)

  Enum.reduce(fields_args, leaf(args), &branch/2)
end
```

The only tricky part there is the generation of arguments; we simply build a list of the same length as fields. Now we can finally create a macro that would use all the above to return the AST of the desired nested call.

```elixir
defmacrop generate(fields),
  do: nested(Macro.expand(fields, __CALLER__))
```

Let’s see what does it produce!

```elixir
def foo(atom, rest) when is_function(rest),
  do: foo(atom, rest.(atom))

def foo(_, rest),
  do: rest

def test do
  generate([:bar, :baz])
end
```

and now `test()` results in `{:bar, :baz}`.

---

Happy recursing!
