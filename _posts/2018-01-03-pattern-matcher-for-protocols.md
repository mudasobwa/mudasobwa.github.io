---
layout: post
title: "Pattern matcher for Protocols"
description: "How to pattern match a protocol in Elixir"
category: hacking
tags: elixir, tricks, dwim
---

One of the best features of Erlang (and hence Elixir) is the ability to
pattern match and use guards directly in function clauses:

```elixir
defmodule M do
  def m(nil), do: "nil given"
  def m([]), do: "empty list given"
  def m([h|_]), do: "non-empty list given (head: #{inspect(head)}.)"
  def m(msg) when is_binary(message), do: "message given (msg: #{msg}.)"
end
```

That works perfectly, routing the calls to respective handlers. But what if
we want to pattern match _the implementation of the protocol_?

That is not possible out of the box and might seem to be tricky. The naïve
approach would be to _emulate_ pattern matching:

```elixir
defprotocol P, do: def pm(this), do: inspect(this)

defmodule M do
  def m(p) do
    unless P.impl_for(p), do: raise MatchError, term: p
    # ...
  end
end
```

That kinda works, but hey! We have all the ingredients: we have macros in Elixir,
we have
[`Kernel#replections`](https://hexdocs.pm/elixir/Kernel.html#defprotocol/2-reflection)
for protocols, we also have . Let’s cook the matchers ourselves.

We are going to generate all the clauses for all the consolidated protocols,
known to the system. Let’s do it:

```elixir
defmodule ProtoMatcher do
  defmacro defprotomatchers(name, mod, fun) do
    quote do
      with {:consolidated, mods} <- unquote(mod).__protocol__(:impls) do
        for impl <- mods do
          def unquote(name)(%{__struct__: impl} = this) do
            unquote(fun).(this)
          end
        end
      else
        :not_consolidated ->
          raise [
            "Protocols are not consolidated.",
            "That usually happens in `iex`.",
            "Please start iex as `iex -S mix`",
            "    in the project directory to use this feature."]
            |> Enum.join("\n")
      end
    end
  end
end
```

Now this might be used as:

```elixir
defmodule M do
  require ProtoMatcher
  ProtoMatcher.defprotomatchers(:checker, Enumerable, fn this -> inspect(this) end)
end

M.checker(%{})
#⇒ ** (FunctionClauseError) no function clause matching in M.checker/1

M.checker(%File.Stream{})
#⇒ "%File.Stream{line_or_bytes: :line, modes: [], path: nil, raw: true}"
```

That said, the `defmodule M` above produced:

```elixir
{:module, M,
 <<70, 79, 82, 49, 0, 0, 5, 56, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 174,
   0, 0, 0, 17, 8, 69, 108, 105, 120, 105, 114, 46, 77, 8, 95, 95, 105, 110,
   102, 111, 95, 95, 9, 102, 117, 110, 99, ...>>,
 [
   checker: 1,
   checker: 1,
   checker: 1,
   checker: 1,
   checker: 1,
   checker: 1,
   checker: 1,
   checker: 1,
   checker: 1,
   checker: 1,
   checker: 1,
   checker: 1
 ]}
```

with 11 implementations of `M.checker/1`:

```elixir
M.__info__(:functions)
#⇒ [checker: 1]
```

Now you have a function (a set of 11 functions, to be precise,) that effectively
matches _only_ implementations of the `Enumerable` protocol.
