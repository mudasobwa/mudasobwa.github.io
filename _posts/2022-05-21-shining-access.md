---
layout: post
title: "Shining Access"
description: "Access is the most underrated feature of Elixir"
category: hacking
tags:
  - elixir
---

Probably, the most irritating expierence in immutable languages for those coming from the OOP, would be updating the deeply nested structures. I have answered a ton of questions on [StackOverflow](https://stackoverflow.com/questions/tagged/elixir) related to how to deal with GraphQL-like structures.

When my _Elixir_ journey has been just starting, I even wrote the library [`Iteraptor`](https://github.com/am-kantox/elixir-iteraptor), allowing the deep structure traversal with updates, doing somewhat similar to what [`Macro.traverse/4`](https://hexdocs.pm/elixir/Macro.html#traverse/4) does to _AST_. I would not recommend to use it though, because _Elixir_ comes equipped with much better solution.

![Roses en Tossa de Mar](/img/roses-en-tossa.jpg)

This solution is extremely underrated and newbies tend to either have no idea about it, or find it too cumbersome, which is a complete nonsense. It’s the most beautiful and clean architectural pattern I have ever seen. Welcome [`Access`](https://hexdocs.pm/elixir/Access.html) behaviour.

`Access` is already implemented for the internal erlang structures, like maps and lists; what is more impressive, everyone might implement it for their custom structs by defining [three callbacks](https://hexdocs.pm/elixir/Access.html#callbacks) only.

When I ran `mix new estructura` in my shell, I was mostly after bringing the default `Access` implementation to user structs for free. That is how [`Estructura`](https://hexdocs.pm/estructura) library was born. Soon I was even asked whether I have plans to evolve it, and I answered, probably no. I was wrong.

When [@wojtekmach](https://twitter.com/wojtekmach) [announced](https://twitter.com/wojtekmach/status/1525226000283467776?s=20&t=V8g0hIFa-WXT7rcKibHmrQ) [`Req`](https://github.com/wojtekmach/req) library, I was like, eh, wait, we need lazy maps to store a potentially huge rarely accessed values.

Consider the file system viewer written in _Elixir_. It’d be kinda natural to keep the directory tree in the deeply nested map. In the `v2` we would be likely to implement a file viewer. Which should probably cache content at least for a while. Somewhat like

```elixir
%{
  "/" => %{
    "home" => %{
      "am" => %{
        ".zshrc" => ??????,
        ...
      }
    },
    ...
  }
}
```

Greedy loading contents of all the files does not sound as a good idea (unless you are utilizing NASA clusters to list files on your local.) What can we do to load it lazily?—Of course. `Access`.

`listing["/"]["home"]["am"][".zshrc"]` should result is loading the file content and returning it. That was easy. But how would we approach caching?

---

I spent some time writing and deleting code then. And, I hope, I find the least annoying way to accomplish this task. I have introduced `Lazy` struct in the first place, keeping the lazy getter, possibly loaded and cached value, and some internal stuff.

```elixir
@type t :: %{
  __struct__: Lazy,
  expires_in: non_neg_integer() | :instantly | :never,
  timestamp: nil | DateTime.t(),
  payload: any(),
  value: cached(),
  getter: (Map.key(), Map.value() -> {:ok, value()} | {:error, any()})
}
```

As one might see, I prematurily optimized the struct to be able to deal with expiration, as all the caches should do. I also have a `payload`, which I tend to have everywhere (who knows what users would want to keep alongside this structure?—it’s like a process state, it might be empty all the day long, but it must be provided to the user.)

Upon external call to retrieve the data, the `value` will be retrieven, `timestamp` will be amended on successful update, etc. The only thing left now would be to make it friend with `Access`.

Here I introduced `LazyMap`, the whole idea of which is shamelessly stolen from `MapSet` implementation. I have a “lazy data,” used to retrieve the real data (it’d be a file name in the file-system-listing example above,) and key-value pairs where values are instances of `Lazy`. The contrived example below, taken from tests, shows how it all works.

```elixir
def parse_int(bin),
  do: with {int, _} <- Integer.parse(bin), do: {:ok, int}
...
lazy =
  LazyMap.new([
    foo: Lazy.new(&parse_int/1),
    ...
  ],
  "42"
)
...
lazy[:foo] = 42
```

This works, but it does not update the map itself, the next call to `get_in/2` would pass through the getter, missing cache. Clear, that’s because everything is immutable, including the map’s values. Let’s play smarter.

```elixir
{value, lazy} = get_and_update_in(lazy, [:foo], &{&1, &1})
```

Now `lazy` contains the updated version of the map, with `value` and `timestamp` set in the value associated with key `:foo`. Subsequent call to `get_in/2` would hit the cache (until the value gets expired.)

That approach might be helpful when one deals with a data which is unlikely to be accessed, or with remote data having expiration time, or even with data, that should not be long-lived in the memory.

---

Happy accessing everything!
