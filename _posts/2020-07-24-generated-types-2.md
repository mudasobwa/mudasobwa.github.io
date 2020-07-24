---
layout: post
title: "Generated Types II — Down the Rabbit Hole"
description: "Use metaprogramming to deal with erlang typespec at runtime"
category: hacking
tags:
  - elixir
  - erlang
---

While I was writing [Generated Types](https://rocket-science.ru/hacking/2020/07/15/generated-types) post, I was under naïve impression that I managed to use _erlang_ typespecs to declare types inside my client _Elixir_ code. That was indeed ingenuous.

The linked above approach works fine for explicit inline declarations, like `use Foo, var: type()` but it is doomed in many ways when we are to declare types upfront with, say, module attribute as we usually do for structs

```elixir
# @fields [foo: 42]
# defstruct @fields

@definition var: atom()
use Foo, @definition
```

![Lighthouse in French Catalonia](/img/lighthouse-2.jpg)

Unfortunately, we cannot handle it at all. It won’t even get to the call to our macro, `@definition var: atom()` would raise `** (CompileError) undefined function atom/0`.

### Naïve Approach

One of my most beloved quotes on computer science is _“Weeks of coding can save you hours of planning”_ (usually attributed to [@tsilb](https://twitter.com/tsilb/status/65488255566614529), but the user was suspended by twitter, so I am not sure.) I love it so much that I am saying it on every next standup, but as it always happens with inviolable life principles, I often fail to follow it myself.

So I started with introducing _two_ `__using/1` clauses, one accepting the list (assuming it consists of `field → type()` pairs,) and another one accepting everything else, where types are either quoted, or introduced as `{Module, :type, [params]}` tuples. I used sigil [`~q||`](https://github.com/am-kantox/exvalibur/blob/master/lib/sigils.ex#L13-L21), gracefully stolen from one of my ancient pet projects, to allow `foo: ~q|atom()|` notation. I constructed a list that was later passed to the clause accepting lists. The whole code was a nightmare. I doubt I saw something less intricate in my whole career, despite I feel myself absolutely comfortable with regular expressions, I like them and I use them a lot. I once won the bet on memorizing [email regex](https://regular-expressions.mobi/email.html) and still, this code dealt with a plain old good erlang type was way more cumbersome.

That all sounded insane. I have a gut feeling that accepting erlang types in runtime should not need an enormously complicated overmacroed code that looked like a spell that can summon the devil’s spirits. So I stepped back and started to think instead of writing code that nobody could ever understand later (me included.)

Here is a link to the [working version](https://github.com/am-kantox/vela/blob/v0.9.4/lib/macros.ex), for historical reasons. I am not proud of this code, but I am pretty sure we must share all the errors we met on incorrect paths taken, not only success stories. After all, they are always more inspiring and thrilling than dry presentation of the final result.

### `Tyyppi`

In a couple of days I went to the beach and there I all of a sudden understood, that I am facing the [XY Problem](http://xyproblem.info/). All I need is simply to make erlang types a first class citizen in _Elixir_. That’s how [`Tyyppi`](https://hexdocs.pm/tyyppi) library was born.

There is not documented [`Code.Typespec`](https://github.com/elixir-lang/elixir/blob/v1.10.4/lib/elixir/lib/code/typespec.ex) module in the _Elixir_ core, that made my life easier. I started with very simple approach of validating terms against types. I loaded all the types available in my current session and start to cover different cases, recursively expanding remote types. Frankly, that was not funny. That ked me towards the first usable part of this library [`Tyyppi.of?/2`](https://hexdocs.pm/tyyppi/Tyyppi.html#of?/2) which accepts a type and a term and returns a boolean.

```elixir
iex|tyyppi|1 ▶ Tyyppi.of? GenServer.on_start(), {:ok, self()}
#⇒ true
iex|tyyppi|2 ▶ Tyyppi.of? GenServer.on_start(), :ok
#⇒ false
```

I needed some internal representation for the types, so I decided to store everything in a struct named [`Tyyppi.T`](https://hexdocs.pm/tyyppi/Tyyppi.T.html). And here is a sibling of `Tyyppi.of?/2` — `Tyyppi.of_type?/2` accepting my internal representation of the type and the term.

```elixir
iex|tyyppi|3 ▶ type = Tyyppi.parse(GenServer.on_start)
iex|tyyppi|4 ▶ Tyyppi.of_type? type, {:ok, self()}
#⇒ true
```

The only caveat of this approach is I need to load and keep all the types, available in the system, and this information won’t be available in releases. At the moment, I am fine with storing this info into some file with `:erlang.term_to_binary/1`, bundling it with the release, and loading it through a custom [`Config.Provider`](https://hexdocs.pm/elixir/Config.Provider.html).

### Structs

Now I was fully armed to turn back to my original task: creating a handy way to declare a typed struct. With all that luggage onboard, it was easy. I decided to restrict the struct declaration itself to be explicit inline literal having `key: type()` pairs. Also I have implemented `Access` for it, checking types upon upserts. With this on hand, I decided to borrow a couple of ideas from [`Ecto.Changeset`](https://hexdocs.pm/ecto/Ecto.Changeset.html), and introduced overridable `cast_field/1` and `validate/1` functions.

Now we might declare a struct that would allow upserts if and only types of values are correct, and the custom validation passes.

```elixir
defmodule MyStruct do
  import Kernel, except: [defstruct: 1]
  import Tyyppi.Struct, only: [defstruct: 1]

  @typedoc "The user type defined before `defstruct/1` declaration"
  @type my_type :: :ok | {:error, term()}

  @defaults foo: :default,
            bar: :erlang.list_to_pid('<0.0.0>'),
            baz: {:error, :reason}
  defstruct foo: atom(), bar: GenServer.on_start(), baz: my_type()

  def cast_foo(atom) when is_atom(atom), do: atom
  def cast_foo(binary) when is_binary(binary),
    do: String.to_atom(binary)

  def validate(%{foo: :default} = my_struct), do: {:ok, my_struct}
  def validate(%{foo: foo} = my_struct), do: {:error, {:foo, foo}
end
```

I am not sure if there is a huge value of this library in production, but it surely might be a great helper during development, allowing to narrow down weird errors addressed to dynamic nature of types in _Elixir_, specifically when dealing with external sources.

Also, I am already using it to cast keywords passed as arguments to maps transparently.

---

Happy runtimetyping!
