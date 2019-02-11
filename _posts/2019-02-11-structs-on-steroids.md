---
layout: post
title: "Elixir Structs on Steroids"
description: "Tiny library adding validation support, reasonable Access and Collectable implementations and more to Elixir Structs"
category: hacking
tags:
  - elixir
  - tricks
  - opensource
---

![Cami de Ronda](/img/cami-de-ronda.jpg)

Elixir structs are very powerful but sometimes they require too much boilerplate to use them as strict data mappers. If desired, validation should be chained here and there. If the struct has more than three fields,
pattern matching in the function head is to be copy-pasted over the whole module or extracted into a cryptic macro. Even then, although, it quickly becomes hardly maintainable due to _unused variables warnings_ thrown whenever one calls the all-in-one macro and does not use all the variables injected.

I am talking about somewhat like this:

```elixir
defstructs MyStruct, [:f1, :f2, :f3, :f4, :f5]

defmacrop cont() do
  quote do
    %MyStruct{
      f1: var!(f1),
      f2: var!(f2),
      f3: var!(f3),
      f4: var!(f4),
      f5: var!(f5)
    } = var!(my_struct)
  end
end

...

def update_f3(cont(), value) do
  %MyStruct{my_struct | f3: value}
end
```

The above somehow works, but emits 4 unsolicited warnings for the unused variables `f1`, `f2`, `f4`, and `f5`. Also, if the validation is required, it would bring another set of copy-pasta. And copy-pasta begets spaghetti; hardly readable, noisy, unmaintainable code.

Another issue I met in my last project was I have a bunch of function clauses I need to pipe / recursively call one from another. All having the same signature `def foo(%MyStruct{}, params)` and all returning the modified `%MyStruct{}` back. That sort of task usually arises when one parses text byte-by-byte or transforms the input several times according to some predefined rules. I needed a monadic behaviour there (once any call in the pipe failed, I want the rest transformations to be skipped and the error immediately returned back.)

When I see the clean _use-case_, say _pattern_, I produce the reusable package to handle this pattern. Immediately. I'm not really confident about Sandy Metz’ competence in general and I am pretty sure it’s better to avoid code duplication at any reasonable cost. Extracting the code that seems to conform a pattern into a separate reusable package requires exactly the same time and effort as copy-pasting it across the current project.

That said, I created [`Pyc`](https://github.com/am-kantox/pyc) package. It allows transparent validation across inserted data with [`Exvalibur`](https://hexdocs.pm/exvalibur), chaining functions in a monadic-like way, and have all the keys as local variables inside methods declared with `defmethod` without warnings.

It also reasonably implements [`Access`](https://hexdocs.pm/elixir/Access.html) behaviour for wrapped structs and [`Collectable`](https://hexdocs.pm/elixir/Collectable.html) protocol _with_ validation.

Basically, the code using this utility would look like:

```elixir
defmodule MyStruct do
  use Pyc,
    definition: [foo: 42, bar: %{}, baz: []],
    constraints: [
      %{matches: %{bar: ~Q[bar]},
        conditions: %{foo: %{min: 30, max: 50}},
        guards: %{check_bar: "is_map(bar)"}}]

  defmethod :collect_baz, [value] when is_integer(value) do
    %__MODULE__{this | baz: [value | baz]}
  end
end
```

Local variables `this` alongside with `foo`, `bar` and `baz` are available inside a block. The function `MyStruct.collect_baz/3` might be invoked in the following way:

```elixir
%MyStruct{}
|> MyStruct.collect_baz(42)
|> MyStruct.collect_baz(43)
|> MyStruct.collect_baz(44)
#⇒ %MyStruct{bar: %{}, baz: ',+*', foo: 42}
```

Also, one might build the struct with comprehesions:

```elixir
for {k, v} <- [bar: %{some: :other}, baz: [42]],
  do: {k, v}, into: %MyStruct{}
#⇒ %MyStruct{bar: %{some: :other}, baz: '*', foo: 42}
```

If validation fails, all subsequent calls in the pipeline are skipped and the last value caused the validation error is returned.

```elixir
%MyStruct{}
|> MyStruct.put(:foo, 32)
|> MyStruct.put(:foo, 42)
|> MyStruct.put(:foo, 52)
|> MyStruct.put(:foo, 62)
#⇒ {:error, %MyStruct{bar: %{}, baz: [], foo: 52}}
```

`validate/1` might be invoked at any moment passing an instance of the struct to it.

---

_Sidenote:_ for anybody curious, `Pyc` name refers to `🐍 PYthon Class` since all the functions declared with `defmethod/3` macro implicitly receive the instance of `self` as the first argument (called `this` to admire Javascript naming of implicit garbage injected into the current context.)

---

Happy structuring!
