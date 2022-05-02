---
layout: post
title: "Parser for Markdown Family"
description: "What’s wrong with markdown and how can we improve it"
category: hacking
tags:
  - elixir
---

Last several months I’ve been lazily working on markdown parser. My goal was not to compete with [`earmark`](https://github.com/pragdave/earmark) or any other markdown parser already existing in the wild. Even more, from the day one I knew I am not going to make it fully compatible with [`Commonmark`](https://commonmark.org/). What I actually was after would be to produce a blazingly fast, _customizable_‌ markup parser.

I created a tool for myself in the first place and I wanted to allow custom syntax in markdown spirit, like `^2^` for superscript, [@mudasobwa](https://twitter.com/mudasobwa) for twitter handles, `#hashtag` for hashtags etc. Markdown itself has a lot of contrived features, which are barely known and literally never used by regular adopters. Did you know you could have a bulleted list inside a blockquote which lives withing an item of another numbered list? Well, now you know; would you ever use it?

![Seaview in El Masnou](img/el-masnou-beach.jpg)

I have no clue who had introduced the alignment in tables with colons in the head separator (`|:---:|`,) but this fellow developer surely never thought about they broke the whole markdown paradigm by introducing a markup that has an effect on _the content before declaration_. Yes, these colons change the alignment of the text in head’s columns, introducing the necessity for lookbehinds and drastically ruin the performance (and the original idea in general.)

[`Md`](https://hexdocs.pm/md) is SAX-like parser, which goes through the input, pattern-matching the control sequences as they come and emits parsed stuff as _XHTML_. It does not do lookbehinds and it’ll never do. Whenever one needs to be full-compliant with _Commonmark_ tests, I’d suggest to pick any other library, generously presented on the market.

`Md` is five times faster than `earmark` because of its approach (and lack of some features which I voluntarily decided to be redundant, like the aforementioned table column alignment.) That does not mean `Md` is unusable for the average user, dealing with markdown; I‌have it tested against the whole _Elixir_ documentation and it gets parsed without a glitch.

Still, the main advantage of using `Md` compared to other markdown implementations is its full customization. Let’s see how one would implement _Slack_ parser.

```elixir
defmodule SlackParser do
  use Md.Parser

  @syntax %{
    flush: [{"---", %{tag: :hr, rewind: true}}],
    paragraph: [{">", %{tag: :blockquote}}],
    list: [
        {"- ", %{tag: :li, outer: :ul}},
        {"* ", %{tag: :li, outer: :ul}}
    ],
    block: [
        {"```", %{tag: [:pre, :code], mode: :raw, pop: %{code: :class}}}
    ],
    brace: [
      {"*", %{tag: :b}},
      {"_", %{tag: :i}},
      {"~", %{tag: :s}},
      {"`", %{tag: :code, mode: :raw, attributes: %{class: "code-inline"}}}
    ],
    magnet: [
      {"@", %{transform: &SlackHandle.apply/2}}
    ]
  }
end
```

What if we wanted to support headers as well?

```diff
-    paragraph: [{">", %{tag: :blockquote}}],
+    paragraph: [
+      {"##", %{tag: :h2}},
+      {"###", %{tag: :h3}},
+      {">", %{tag: :blockquote}}
+    ],
```

Table?—Nothing could have ever be easier.

```elixir
    matrix: [
      {"|", %{tag: :td, outer: :table, inner: :tr, first_inner_tag: :th, skip: "|-"}}
    ],
```

Allow some custom tag?—Sure, despite we suggest to use a dedicated syntax, why not?

```elixir
    tag: [{"sup", %{}}, {"sub", %{}}]
```

---

Besides the standard syntax definition through `@syntax` attribute (it’s accumulated, btw, so one might break the definition into several ones,) we support _DSL_. For instance, defining the allowed tags via DSL would look like

```elixir
defmodule MyDSLParser do
  
  use Md.Parser
  @syntax %{…}

  import Md.Parser.DSL

  tag "sup", %{}
  tag "sub", %{}
  ...
end
```

With all that freedom, one might easily extend the syntax to support their business needs (custom tags, named entities, youtube embeds, etc.)

---

Happy marking it right!
