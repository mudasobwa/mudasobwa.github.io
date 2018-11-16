---
layout: post
title: "Iteraptable → Swiss Knife For Structs"
description: "Simple way to make the struct all Enumerable, Collectable and Accessable"
category: hacking
tags:
  - elixir
  - tricks
  - tools
---

Elixir _structs_ are [_are bare maps underneath_](https://elixir-lang.org/getting-started/structs.html#structs-are-bare-maps-underneath). While they provide the nifty way to _restrict keys to the predefined set_, _specify default values_, _require keys_, _pattern match selectively_, and _more_, they are still bare maps with some syntactic sugar on top of them. Structs exports [`__struct__/1`](https://github.com/elixir-lang/elixir/blob/v1.7.4/lib/elixir/lib/kernel.ex#L4162-L4168) method, allow [protocol implementation inheritance](https://github.com/elixir-lang/elixir/blob/v1.7.4/lib/elixir/lib/kernel.ex#L4182-L4185) and allow pattern match _struct types_ to distinguish different structs by their definition in different clauses.

Structs purposedly do not allow to iterate them over out of the box. Neither do they provide the default `Access` implementation. I would guess that’s because Elixir is very strict language in the sense of everything should work as expected no matter what, without exceptions. And neither `Enumerable` nor `Collectable` could not be ultimately defined for structs. Also, `Access` behavior requires `pop/3` to be implemented, which is impossible for structs be design.

But sometimes, you know, we are not as captious. We just want to make it working:

```elixir
Enum.each(%MyStruct{}, ...)
# or
[foo: 42, bar: :baz] |> Enum.into(%MyStruct{})
# or 
put_in(%MyStruct{}, [:foo], 42)
```

Once we understand all the consequences, we indeed have an ability to implement all the above for structs ourselves. It rather quickly becomes boring. In 99% of cases implementations are literally equal. Keeping in mind, that I nevertheless have plans to support structs for deep iterations in [`Iteraptor`](https://hexdocs.pm/iteraptor), I decided to provide a syntactic sugar for implementing the above in custom structs. Please note, it probably won’t work in `iex` for playing around, since protocol implementations should be consolidated, and they already are during `iex` startup. Also, this won’t work for dynamically created modules. `Access`, being a behaviour, would work though. 

### Syntax

To make the struct `Enumerable`, implement an `Access` and derive the implementation of the protocol `Foo`, one should do inside the struct module:

```elixir
use Iteraptor.Iteraptable skip: Collectable, derive: Foo
```

Arguments to keyword parameters might be both atoms or lists of atoms. Below I am going to share the approach I have taken. Another tiny tutorial on using macros in _Elixir_.

To enable `Access` for the struct created dynamically, one might use

```elixir
use Iteraptor.Iteraptable skip: [Enumerable, Collectable]
```

### Enumerable

This would be the easiest one. Honestly, I am unsure why it’s not included by default. The implementation is _correct_ by any mean and works for literally all structs without limitations. The only trick we need to exclude `__struct__` key that contains the metainformation and is put into maps by Elixir itself to help both compiler and runtime to distinguish structs. So, delegate everything to the `map` save for `count/0`:

```elixir
def count(map) do
  # do not count :__struct__
  {:ok, map |> Map.from_struct() |> map_size()}
end
```
I do not use `{:ok, map_size(map) - 1}` since I want it to continue work properly when another private meta field will be added to structs by core team.

### Collectable

It’s even shorter. I spent half of an hour thinking about how should I deal with an attempt to collect the key-value pair with a key not belonging to this struct, and found the simplest solution: _I do not do anything_. Struct itself will raise a proper error. _Fail Fast_.

```elixir
defimpl Collectable, for: __MODULE__ do
  def into(original) do
    {original,
      fn
        map, {:cont, {k, v}} -> :maps.put(k, v, map)
        map, :done -> map
        _, :halt -> :ok
      end}
  end
end
```

### Access

That was the hardest one. `pop/3` contract is to pop up the value for the key and return a tuple `{value, rest}`. The thing is I cannot remove keys from maps. I decided to nullify the value in the returned struct. Why not?

Besides the above, everything is quite straightforward.

### `use Iteraptor.Iteraptable`

Here is the most exciting part. We need to embed the implementations into the caller’s context. Since we provide `skip` parameter, we cannot just build an AST and inject it. The goal is to build AST _selectively_.

Also we want to raise on attempt to `use` our helper in non-structs. Simple check for whether struct is declared on module won’t work, since `defstruct` will be likely called _after_ our code injection. But hey, it’s Elixir. We have [compile hooks](https://hexdocs.pm/elixir/Module.html#module-compile-callbacks)!

```elixir
checker = quote(location: :keep, do: @after_compile({Iteraptor.Utils, :struct_checker}))
```
While we could simply inject `__after_compile__/2`, that might conflict with the callback declared by the module owner. That’s why we delegate to our own function (that in turn simply calls `env.module.__struct__` and allows Elixir to provide nifty error message is it is undefined.)

Then we prepare an AST for `@derive` [if needed](https://github.com/am-kantox/elixir-iteraptor/blob/master/lib/iteraptor/iteraptable.ex#L138-L149).

And the most exciting part would be the selective injection of implementations. For that we prepare a map of the following structure:

```elixir
@codepieces %{
  Enumerable =>
    quote location: :keep do
      defimpl Enumerable, for: __MODULE__ do
        ...
  Collectable => ...
```

and iterating through all the possible implementations, we check whether this one should not be skipped, and if not, we inject it:

```elixir
Enum.reduce(@codepieces, [checker | derive], fn {type, ast}, acc ->
  if Enum.find(excluded, &(&1 == type)), do: acc, else: [ast | acc]
end)
```

Voilà.

### Usage

```elixir
defmodule Iterapted do
  use Iteraptor.Iteraptable
  defstruct foo: 42, bar: :baz
end

Enum.each(%Iterapted{}, &IO.inspect/1)
#⇒ {:bar, :baz}
#  {:foo, 42}
```

Happy iterating!
