---
layout: post
title: "`is_empty` Guard for Binaries in Elixir"
description: "nifty trick that provides the same functionality as [not existing] is_empty guard"
category: hacking
tags:
  - tricks
  - elixir
---

I have many times heard the question “How would one implement `is_empty` guard
for binaries in `Elixir`.”

It is impossible out of the box, basically because guards are compile-time beasts.
The documentation on [`Guards`](https://hexdocs.pm/elixir/master/guards.html)
states:

> Guards are a way to augment pattern matching with more complex checks;
**they are allowed in a predefined set of constructs** where pattern matching is allowed.

That said, one can not just put `String.trim(s) == ""` because call to `String.trim`
is not allowed in guard:

```elixir
iex|1 ▶ defmodule TestEmpty, do: def test(s) when String.trim(s) == "", do: :ok
** (CompileError) iex:1: cannot invoke remote function String.trim/1 inside guard
```

So far, so bad. But there is a nifty workaround: one might explicitly `trim_leading` the
`String` with pattern match:

```elixir
defmodule TestEmpty do
  def trimmer(<<" " :: binary, rest :: binary>>), do: trimmer(rest)

  def trimmer(string) when string == "",
    do: IO.puts "Empty input"
  def trimmer(string) when is_binary(string),
    do: IO.puts "Left trimmed string is: [#{string}]"
end

TestEmpty.trimmer "       "
#⇒ Empty input
TestEmpty.trimmer "    ☆  "
#⇒ Left trimmed string is: [☆  ]
```

This approach won’t work if one needs to deal with the original input
unless it is “empty,” but in most cases it would do the trick. After all,
we for some reason already treat spaces as empties.
