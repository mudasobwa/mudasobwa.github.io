---
layout: post
title: "Yet Another Markup Parser"
description: "Elixir library for customizable blazingly fast markup parsing with callbacks"
category: hacking
tags:
  - elixir
---

[`Markdown`](http://daringfireball.net/projects/markdown/syntax) is great. The original philosophy is lined out by its creator John Gruber as

> Markdown is intended to be as easy-to-read and easy-to-write as is feasible.
> Readability, however, is emphasized above all else. A Markdown-formatted document should be publishable as-is, as plain text, without looking like it’s been marked up with tags or formatting instructions.

Which is great until it is not. All markdown parsers I am aware of do implement their own dialect, neither customizable nor fulfilling everyone’s needs. Yes, markdown allows a subset of `HTML` to be embedded, but this just ruins the main advantage of it being _easy-to-read_.

![Seagull at the beach](/img/seagull-at-the-beach.jpg)

Some people often use `<abbr>` tag, others want to be able to use `--foo--` as a marker to strike `foo` out, etc. That is the main rationale behind [`md` the library](https://hexdocs.pm/md).

`Md` is definitely not a competitor of [`earmark`](https://github.com/pragdave/earmark) or any other library implementing the proper parser for the bare markdown. On the contrary, `md` is faster and fully customizable backbone to build your own markup dialect. Yes, `md` comes with its own implementation of a subset of Gruber markdown (plus some Github flavor,) but this is not the main goal.

The main goal would be to provide a support of still easy-to-read custom markup language, somewhat similar to markdown but not necessarily the same. The [very first issue](https://github.com/am-kantox/md/issues/4) created in the repository after `md` turned _PoC_ is to implement a zero-code (configuration only) support for [OrgMode](https://orgmode.org).

## Single-pass and Streaming

`Md` is a **single-pass streaming** parser. That said, it never looks behind and therefore is normally faster than competitors.

```
## Md.Bench
benchmark  iterations  average  time
md                500  6124.09  µs/op
earmark           100  28803.86 µs/op
```

The benchmark above is not absolutely honest, because `earmark` supports way more tags, but while `md` intentionally does not support stuff like tables (at least, at the moment of writing,) adding them won’t drastically change the benchmark. It will remain single-pass forever.

## Custom parsers

`Md` allows to declare custom parsers for any opening sequence. For that to work, one should implement [`Md.Parser`](https://hexdocs.pm/md/Md.Parser.html) behaviour. For instance, to turn twitter handles into links, one might do:

```elixir
defmodule My.Parsers.TwitterHandle do
  @behaviour Md.Parser

  @href "https://twitter.com/"

  @impl Md.Parser
  alias Md.Parser.State

  def parse("@" <> rest, state) do
    state = %State{state | bag: Map.put(state.bag, :handle, "@")}
    parse(rest, state)
  end

  def parse(<<x::utf8, rest::binary>>, state) when x not in [?\s, ?\n] do
    bag = Map.update!(state.bag, :handle, & &1 <> <<x::utf8>>)
    state = %State{state | bag: bag}
    parse(rest, state)
  end

  def parse(<<_::size(8), _::binary>> = rest, state) do
    {handle, bag} = Map.pop(state.bag, :handle)
    state = %State{
      state
      | bag: bag,
        path: [{:a, %{href: @href <> handle}, [handle]} | state.path]
    }
    {rest, state}
  end
end
```

and in `config.exs`

```elixir
  # config/prod.exs

  config :md, syntax: %{
    custom: %{
      {"@", {My.Parsers.TwitterHandle, %{}}}
    }
  }
```

Luckily enough, this case is already handled as `:magnet` kind in `Md`, and
one might use a configuration instead

```elixir
  # config/prod.exs

  config :md, syntax: %{
    magnet: [
      {"@", %{transform: &Md.Transforms.TwitterHandle/2}}
    ]
  }
```

And yes, this is already incorporated into `Md`, so no changes is needed.

## Custom syntax

`Md` syntax can be fully overwritten, or updated to introduce more markup. For instance, to make `Md` to understand the `abbr` tag, one simply needs to amend the syntax with

```elixir
  config :md, syntax: %{
    pair: {"?[",
      %{
        tag: :abbr,
        closing: "]",
        inner_opening: "(",
        inner_closing: ")",
        outer: {:attribute, :title}
      }}
  }
```

the above will effectively convert `?[foo](bar)` into `{:abbr, %{title: "that"}, ["this"]}` AST and into `<abbr title="that">this</abbr>`. This is also incorporated into default `Md` syntax.

## Advantages

As it was already shown, `Md` does not aim for covering all the Gruber markdown, but rather it provides a configurable and fully customizable platform for declaring custom markups and deal with them. Being also blazingly fast, it could be a greater choice for custom blog engines or even markups for online shops and similar.

For instance, when Github introduced their “footnote” feature, adding it to `Md` would be a matter of one syntax update.

---

Happy marking everything up and down!
