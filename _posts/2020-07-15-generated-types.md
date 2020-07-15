---
layout: post
title: "Generated Types"
description: "Use metaprogramming to generate nifty types for generated structures"
category: hacking
tags:
  - elixir
  - erlang
---

Consider the implementation of the scaffold module that injects the struct with some custom fields into the module calling `use Scaffold`.
Upon call to `use Scaffold, fields: foo: [custom_type()], ...` we want to implement the proper type in `Consumer` module (`common_field` below comes from `Scaffold`.)

```elixir
@type t :: %Consumer{
  common_field: [atom()],
  foo: [custom_type()],
  ...
}
```

That would be great if we could both precisely specify a type in `Consumer` for the future reference _and_ generate the appropriate documentation for users of our new module.

![Lighthouse in French Catalonia](/img/lighthouse.jpg)

The more comprehensive example would look like.

```elixir
defmodule Scaffold do
  defmacro __using__(opts) do
    quote do
      @fields [
        :version
        # magic
      ]
      @type t :: %__MODULE__{
        version: atom()
        # magic
      }
      defstruct @fields
    end
  end
end

defmodule Consumer do
  use Scaffold, fields: [foo: integer(), bar: binary()]
end
```

resulting after compilation in

```elixir
defmodule Consumer do
  @type t :: %Consumer{
    version: atom(),
    foo: integer(),
    bar: binary()
  }
  use Scaffold, fields: [foo: integer(), bar: binary()]
end
```

Looks pretty easy, doesn’t it?

### Naïve Approach

Let’s start with inspecting what do we receive in `Scaffold.__using__/1`.

```elixir
  defmacro __using__(opts) do
    IO.inspect(opts)
  end
#⇒ [fields: [foo: {:integer, [line: 2], []},
#            bar: {:binary, [line: 2], []}]]
```

So far, so good. Maybe we are almost there?

```elixir
  quote do
    custom_types = unquote(opts[:fields])
    ...
#⇒ == Compilation error in file lib/consumer.ex ==
#  ** (CompileError) lib/consumer.ex:2: undefined function integer/0
```

Bang! Types are special, one cannot simply unquote it anywhere. Maybe unquoting inplace would work?

```elixir
      @type t :: %__MODULE__{
              unquote_splicing([{:version, atom()}, opts[:fields]])
            }
#⇒ == Compilation error in file lib/scaffold.ex ==
#  ** (CompileError) lib/scaffold.ex:11: undefined function atom/0
```

No dice. Types are hard, ask anyone who is doing _Haskell_ for living (and _Haskell_ has a very poor type system yet, dependent types are way better, but two ways harder.)

OK, looks like we need to build the whole clause as an AST and inject it at once, so that compiler would meet the proper declaration from scratch.

### Constructing Type AST

I would skip two hours of my tossing, torments, trial, and errors. Everyone knows that I write code mostly at random, expecting that all of a sudden another permutation would compile and hence work. The issue here is contexts. **We should shove the received fields definitions down to the macro declaring type without unquoting them** because once unquoted, the type like `binary()` would be immediately considered a function and ~~whack-a-mole’ed~~ called by a compiler, resulting in `CompileError`.

Also, we cannot use regular functions _inside_ `quote do` because the whole content of the block passed to `quote` would be quoted.

```elixir
quote do
  Enum.map([:foo, :bar], & &1)
end
#⇒ {​
#   {:., [], [{:__aliases__, [alias: false], [:Enum]}, :map]}, [],
#     [[:foo, :bar], {:&, [], [{:&, [], [1]}]}]}
```

You can see all these `Enum`, `:map` etc there as is. In other words, we should constuct the whole AST of the type outside of the quote and then unquote it inside. Let’s try it.

### Less Naïve Attempt

We need to _inject_ AST as AST. without unquoting it. Fine. Sounds as a stalemate?—Well, not really.

```elixir
defmacro __using__(opts) do
  fields = opts[:fields]
  keys = Keyword.keys(fields)
  type = ???

  quote location: :keep do
    @type t :: unquote(type)
    defstruct unquote(keys)
  end
end
```

All we need to do now, is to produce the proper AST, everything else is OK. Well, let _Elixir_ do that for us!

```elixir
iex|1 ▶ quote do
...|1 ▶   %Foo{version: atom(), foo: binary()}
...|1 ▶ end
#⇒ {:%, [],
#   [
#     {:__aliases__, [alias: false], [:Foo]},
#     {:%{}, [], [version: {:atom, [], []}, foo: {:binary, [], []}]}
#   ]}
```

Maybe something simpler?

```elixir
iex|2 ▶ quote do
...|2 ▶   %{__struct__: Foo, version: atom(), foo: binary()}
...|2 ▶ end
#⇒ {:%{}, [],
#   [
#     __struct__: {:__aliases__, [alias: false], [:Foo]},
#     version: {:atom, [], []},
#     foo: {:binary, [], []}
#   ]}
```

Looks promising, isn’t it? We are ready to get to the resulting code.

### Working Solution

```elixir
defmacro __using__(opts) do
  fields = opts[:fields]
  keys = Keyword.keys(fields)
  type =
    {:%{}, [],
      [
        {:__struct__, {:__MODULE__, [], Elixir}},
        {:version, {:atom, [], []}}
        | fields
      ]}

  quote location: :keep do
    @type t :: unquote(type)
    defstruct unquote(keys)
  end
end
```

![Screenshot of type definition](/img/generated-types.png)

### Appendix. Trick With Quoted Fragment

But what if we already have a complicated quoted block inside our `__using__/1` macro that binds the values quoted? Rewrite a ton of code to unquote everything everywhere? That’s not even always possible, if we want to have an access to anything declared inside the target module. Lucky us, we have a simpler way to achieve that.

> **NB** for the sake of brevity, I would show the success path to declare all custom fields all having `atom()` type, but it would be easily extendable to accept any types from the input parameters, like `GenServer.on_start()` etc, this part would be left as a homework.

Now we are to generate the type _inside_ `quote do` block, because we cannot pass `atom()` bound quoted (it would raise `CompileError` as shown above.) So we’d resort to somewhat like

```elixir
keys = Keyword.keys(fields)
type =
  {:%{}, [],
    [
      {:__struct__, {:__MODULE__, [], Elixir}},
      {:version, {:atom, [], []}}
      | Enum.zip(keys, Stream.cycle([{:atom, [], []}]))
    ]}
```

That’s all good, but how would we inject this AST into `@type` declaration? The very handy Elixir\_ feature named [Quoted Fragment](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#quote/2-binding-and-unquote-fragments) comes to the rescue. It was designed to allow compile-time generated code like

```elixir
defmodule Squares do
  Enum.each(1..42, fn i ->
    def unquote(:"squared_#{i}")(),
      do: unquote(i) * unquote(i)
  end)
end
Squares.squared_5
#⇒ 25
```

_Quoted Fragments_ automagically recognized by _Elixir_ inside quotes having a quotes bindings. Easy-peasy.

```elixir
defmacro __using__(opts) do
  keys = Keyword.keys(opts[:fields])

  quote location: :keep, bind_quoted: [keys: keys] do
    type =
      {:%{}, [],
        [
          {:__struct__, {:__MODULE__, [], Elixir}},
          {:version, {:atom, [], []}}
          | Enum.zip(keys, Stream.cycle([{:atom, [], []}]))
        ]}

    #          ⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓
    @type t :: unquote(type)
    defstruct keys
  end
end
```

This alone `unquote/1` is _allowed_ inside `quote/2` receiving `bind_quote:` keys in the parameters keyword.

---

Happy injecting!
