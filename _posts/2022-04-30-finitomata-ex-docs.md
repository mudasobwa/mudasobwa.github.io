---
layout: post
title: "Finitomata :: First Class Documentation"
description: "The FSM implementation that exposes proper documentation"
category: hacking
tags:
  - elixir
---

I have [already introduced](https://rocket-science.ru/hacking/2022/04/02/finitomata) the [`finitomata`](https://github.com/am-kantox/finitomata) library, yet another implementation of [Finite Automata](https://en.wikipedia.org/wiki/Finite-state_machine). The main reason I’ve decided to climb the low hill that has not been yet conquered by lazy developers only, was I‌ felt like DSL‌ does not fit well the main purpose of _FSM_ declaration. It’s not …ahem… declarative. The _FSM_‌ is best described with a diagram, not with a plain English text.

![Mambie](/img/mambie.jpg)

This is Mambie, by the way. He is 31 and he happily lives in Valencia zoo. He has nothing to do with finite automata at all, but look, how declarative he is. Anyway.

I‌ wanted _FSM_ implementation to be as easy and succinct as possible. That’s why I have chosen [`PlantUML`](https://plantuml.com/en/state-diagram) syntax to declare it. Later I was given [an advise](https://elixirforum.com/t/elixir-blog-post-finitomata-the-proper-fsm-for-elixir/46983/11) to support [`Mermaid`](https://mermaid.live/) as well.

The huge advantage of supporting `Mermaid` is that it can be natively embedded into library documentation. Actually, `ex_doc` can do way more of a cool stuff rather than the regular user (read: me) could ever imagine. It natively supports [admonition blocks](https://hexdocs.pm/ex_doc/readme.html#admonition-blocks), [KaTeX math expressions](https://hexdocs.pm/ex_doc/readme.html#rendering-math), [Vega-Lite plots](https://hexdocs.pm/ex_doc/readme.html#rendering-vega-lite-plots), and, yes, [_Mermaid graphs_](https://hexdocs.pm/ex_doc/readme.html#rendering-mermaid-graphs).

It’s all possible with introducing `before_closing_body_tag` keyword parameter for `docs` section in `mix.exs` file and implementing the respective handler as shown below (the excerpt is taken from `ex_doc` docs.)

```elixir
docs: [
  # ...
  before_closing_body_tag: &before_closing_body_tag/1
]

# ...

defp before_closing_body_tag(:html) do
  """
  <!-- HTML injected at the end of the <body> element -->
  """
end

defp before_closing_body_tag(_), do: ""
```

---

That said, I was able to generate _FSM diagrams_ directly in the documentation of the generated _FSM implementation_.

```elixir
defmodule MyFSM do
  @moduledoc "FSM implementation for 3-state conditional flow"

  @fsm """
  s1 --> |to_s2| s2
  s1 --> |to_s3| s3
  """

  use Finitomata, {@fsm, Finitomata.Mermaid}
end
```

The above code produces the following documentation

![FSM drawn with Mermaid](/img/fsm-mermaid.png)

---

Happy rich documenting!
