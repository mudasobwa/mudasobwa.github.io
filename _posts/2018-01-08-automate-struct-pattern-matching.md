---
layout: post
title: "Automate pattern matching for structs"
description: "How to bulk pattern match structs in function clauses in Elixir"
category: hacking
tags: elixir, tricks, dwim
---

In the previous post we’ve been dealing with
[pattern matching `Protocol`s]({% post_url 2018-01-03-pattern-matcher-for-protocols %}).

Now let’s dive into Elixir macro world even deeper to see if we can provide
a handy way to pattern match arbitrary structs. I am not sure this code might
be of any value, neither I can invent any meaningful application of it; that’s
why I decided to write this post. I hate throwing the working code away.

The goal would be to produce a simple syntax to tell Elixir “Hey, I want these
functions’ arguments to be pattern matched against these structs respectively.”

The possible application would be to use this technique in the domestic logger
implementation with an ability to tune _types_ of objects to be logged. That
could help in real-time debug (for non-matched structs we are to yield zero AST.)

The code is more of an example of macro dealing, rather that a ready-to-use
drop-in for anything. Also, it might be used as a drop-in, for those braves
[there is a gist](https://gist.github.com/am-kantox/17540ab90343c87e76071ed2b7f428a2).

For all others I have a step-by-step explanation. What we want is to have
something like this in our target class:

```elixir
defmodule MyLogger do
  use DryStructMatch,
    log: [
      {LoginChecker, {Logger, :warn}},
      {User, &IO.inspect/1},
      {[Post, Comment], {IO, :inspect, [[label: "inplace"]]}}]

  def log(_), do: :ok
end
```

Now if we call `MyLogger.log(object)` somewhere in the code,
the call will be properly routed to whatever handler we have provided.
If no handler is provided, the fallback, declared in the core module,
will be used.

While there is not much sense of using this notation instead of four
normal `def` clauses with different parameters, the implementation of
this senseless module is intriguing. Let’s start with the basics.

First of all, let’s define callbacks for our handlers. As it might be seen
in the example above, we are to support all kinds of notations:

- anonymous functions `fn arg -> arg end`;
- references to functions `&IO.inspect/1`;
- ready-to-apply functions `{IO, :inspect, [label: "★"]}`.

The quoted code for that would be:

```elixir
# assuming we have `name` on hand
quote do
  defp unquote(:"#{name}_callback")({mod, fun}, result), do: apply(mod, fun, [result])

  defp unquote(:"#{name}_callback")({mod, fun, args}, result) when is_list(args),
    do: apply(mod, fun, [result | args])

  defp unquote(:"#{name}_callback")(fun, result) when is_function(fun, 1),
    do: fun.(result)

  defp unquote(:"#{name}_callback")(_, result), do: result
end
```

Here we declare three callback handlers and _match-it-all_ handler to pass
the result through when the handler is not allowed. Now the issue is to
generate all the clauses; let’s start with declaring a helper for that:

```elixir
defmacrop clause!(name, mod, fun) do
  quote bind_quoted: [name: name, mod: mod, fun: fun] do
    quote do
      def unquote(name)(
            unquote({:%, [],
              [{:__aliases__, [alias: false], [mod]},
               {:%{}, [], []}]}) = struct
          ) do
        result = struct # NB here one might tweak input
        unquote(:"#{name}_callback")(unquote(fun), result)
      end
    end
  end
end
```

That helper will produce a function, specified by `name` argument, that in turn
will call the `name_callback` helper from the previous snippet. One might
probably write a matcher in more readable way, but I ❤ AST.

OK, we are almost done. Let’s cheat with `__using/1` macro to embed this to
our target modules:

```elixir
# assuming we have `mods` as the list of handlers
#    in one of the allowed forms
Enum.map(mods, fn
  {mods, fun} when is_list(mods) ->
    Enum.map(mods, &clause!(name, &1, fun))
  {mod, fun} ->
    clause!(name, mod, fun)
  mod ->
    clause!(name, mod, nil)
end) ++
[{:defoverridable,
    [context: Elixir, import: Kernel],
    [[{name, 1}]]}]
```

We just construct the quoted expressions for everything passed as parameters
with a help of `clause!` private macro described above. In the very end, we
don’t forget to allow all our functions to be overridable.

Let’s see how it works.

```elixir
defmodule(Foo, do: defstruct(foo: 42))
defmodule(Foo1, do: defstruct(foo: 42))
defmodule(Foo2, do: defstruct(foo: 42))
defmodule(Bar, do: defstruct(bar: 42))
defmodule(Baz, do: defstruct(baz: 42))

defmodule A do
  use DryStructMatch,
    update: [
      Foo,
      {Bar, &IO.inspect/1},
      {[Foo1, Foo2],
      {IO, :inspect, [[label: "inplace"]]}}],
    empty: Foo1

  def empty(input), do: super(input) && IO.inspect(input, label: "overloaded")
end

IO.inspect(A.update(%Foo{}), label: "explicit")
#⇒ explicit: %Foo{foo: 42}

A.update(%Bar{})
#⇒ %Bar{bar: 42} # via callback

A.update(%Foo2{}) # via callback
#⇒ inplace: %Foo2{foo: 42}

A.empty(%Foo1{})
#⇒ overloaded: %Foo1{foo: 42}

# raises `FunctionClauseError`
A.update(%Baz{})
# ** (FunctionClauseError) no function clause matching in A.update/1
#    The following arguments were given to A.update/1:
#        # 1
#        %Baz{baz: 42}
#    A.update/1
#    (elixir) lib/code.ex:678: Code.require_file/2
```

The summing up, we have the following code:

<script src="https://gist.github.com/am-kantox/17540ab90343c87e76071ed2b7f428a2.js"></script>

Enjoy!
