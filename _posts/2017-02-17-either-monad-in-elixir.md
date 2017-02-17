---
layout: post
title: "Either Monad in Elixir"
description: "that is not widely known, but an Either monad is already presented in Elixir"
category: hacking
tags:
  - elixir
---

In the beginning was the Hype, and the Hype was with Monads, and the Hype was Monad.

Either this hype makes sense or not. Try it yourself. Right? Left unclear? Anyway.
Yes, `Anyway` monad were my favorite one, if it were existing.

Monads are known to be good in handling side effects and dealing with side effects.
Monads are very simple (despite their cryptographogastroenterologic name.) Monads
are after all handy, producing an _easy-to-read_ code, which is nowadays considered
to be even more valuable then _producing-expected-result_ and even _correct_ code.

OK, jokes aside.

There are many 3rd party libraries, implementing the basic monadic behavior, but
the truth is **Elixir comes with monads onboard**. Out of the box. I am not kidding you.

Our today’s special guest is
[`Kernel.SpecialForms.with/1`](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#with/1).

It is widely used to chain the simple atomic functions returning `{:ok, result}`
tuples:

{% highlight elixir %}
with {:ok, [file | _tail]} <- File.ls,
     {:ok, content} <- File.read(file),
  do: IO.puts content
{% endhighlight %}

but the truth is it actually behaves as simple `Either` monad. That said,
_if the match on any subsequent step failed, the execution will immediately stop
and RHO will be returned_.

Let’s check this trivial contrived example:

{% highlight elixir %}
iex|1 ▶ with 1 <- 1,
...|1 ▶      2 <- "HERE WE GO",
...|1 ▶      3 <- 3, do: "HERE WE WON’T GO"
"HERE WE GO"
{% endhighlight %}

The second match failed and _not matched term had beed returned_. It’s amazing,
is not it?

Let’s turn back to the first example with files. What would be returned in case
we failed to list files? Yes: `{:error, :enoent}` (or similar, and we would
safely skip all the subsequent steps, directly returning `{:error, :enoent}`
to the caller!) What is this?—this is an `Either` monad.

That simple.
