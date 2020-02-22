---
layout: post
title: "WordCount in Elixir"
description: "Prove of that Elixir/Erlang can be not a mile behind C/Haskell"
category: hacking
tags:
  - elixir
  - erlang
---

Half of year ago, Chris Penner had posted [_Beating C With 80 Lines Of Haskell: Wc_](https://chrispenner.ca/posts/wc). The preface states:

> The challenge is to build a _**faster**_ clone of the hand-optimized **C** implementation of the `wc` utility in our favourite high-level garbage-collected runtime-based language: **Haskell**! Sounds simple enough right?

Down the road Chris went through _ByteStrings_ implementation, _Monoids_, _Inlined Monoids_, and, finally came to _multicore_ version of the above that could slightly beat pure _C_ code in execution time on four cores.

Several days ago, there was a related article posted on [habr](https://habr.com/ru/post/489136/) (Russian only at the moment, sorry.) The author proved the ability to build an _idiomatic Haskell_ version in 20 (twenty) lines of code that is almost ten times faster than _idiomatic C_ implementation.

Meanwhile I advocate to use _Haskell_ (actually, [_Idris_](https://www.idris-lang.org/) for its dependent types) and [_Coq_](https://coq.inria.fr/) to indeed prove the critical concepts in our codebase only; the new production code is still coming 100% in Elixir/Erlang/OTP for its fault tolerance. I wanted to make sure I am not shitting my pants here, so I decided to check how can we do with _Idiomatic Elixir_ for the very same task.

Below you’ll see some tricks I used to speed up the execution. I am a grown man and I don’t believe in Tooth fairy anymore, so I was far from the hope that _Elixir_ might actually beat languages compiled into a native machine code. I just wanted to make sure we didn’t fall behind at the finish line by a lap.

I am to use the [very same test file](http://eforexcel.com/wp/wp-content/uploads/2017/07/1500000%20Sales%20Records.zip) as `@0xd34df00d` used in his experiments. Grab it and glue it with itself ten times.

```sh
% for i in `seq 1 10`; cat part.txt >> test.txt
% du -sh test.txt
1.8G    test.txt
```

On my machine (8 cores / 16G) it is handled by `wc` in 10 seconds approx.

```sh
time LANG=C LC_ALL=C wc data/test.txt 
  15000000   44774631 1871822210 data/test.txt
LANG=C LC_ALL=C wc data/test.txt  9,69s user 0,36s system 99% cpu 10,048 total
```

Let’s see how far behind we’d be with OTP.

### Naïve. Too Naïve Approach

I started with a most naïve recursive implementation, parsing the stream symbol by a symbol.

```elixir
@acc %{bc: 0, wc: 1, lc: 0, ns?: 1}

@type acc :: %{
        bc: non_neg_integer(),
        wc: non_neg_integer(),
        lc: non_neg_integer(),
        ns?: 0 | 1
      }

@spec parse(<<_::_*8>>, acc()) :: acc()
def parse("", acc), do: acc

def parse(
      <<?\n, rest::binary>>,
      %{bc: bc, wc: wc, lc: lc, ns?: ns}
    ),
    do: parse(rest, %{bc: bc + 1, wc: wc + ns, lc: lc + 1, ns?: 0})

def parse(
      <<?\s, rest::binary>>,
      %{bc: bc, wc: wc, lc: lc, ns?: ns}
    ),
    do: parse(rest, %{bc: bc + 1, wc: wc + ns, lc: lc, ns?: 0})

def parse(<<_, rest::binary>>, acc),
  do: parse(rest, %{acc | bc: acc.bc + 1, ns?: 1})
```

This function is fed from either greedy `File.read!/1`, or lazy `File.stream!/3` in the following way.

```elixir
@spec lazy(binary) :: acc()actually
def lazy(file),
  do: file |> File.stream!() |> Enum.reduce(@acc, &parse/2)

@spec greedy(binary) :: acc()
def greedy(file),
  do: file |> File.read!() |> parse(@acc)
```

As one might expect, the results are too disappointing. I even did not run it on the whole file; I ran it on one tenth part, where `wc` had done for less than a second, and our naïve implementaion did more than ten times worse (results below are in μs.)

```elixir
iex|1 ▶ :timer.tc fn -> Wc.lazy "data/part.txt" end
#⇒ {16_737094, %{bc: 185682221, lc: 1500000, ns?: 1, wc: 4477464}}
iex|2 ▶ :timer.tc fn -> Wc.greedy "data/part.txt" end
#⇒ {13_659356, %{bc: 187182221, lc: 1500000, ns?: 1, wc: 4477464}}
```

Shall we throw our toolchain away and migrate to _Haskell_ tomorrow? Not yet.

### Pattern Match Wisely

What if we could count non-empty bytes by chunks? Sure, good question. Let’s generate functions to pattern match next `?\s` or `\?n` as far from the current point as we can. Looking ahead, I should say that looking ahead way too far makes the code run slower, possibly because of the overhead on the necessity to handle too many functions for no reason (even Finnish words are rarely longer than forty characters.)

```elixir
@prehandle 42
@sink @prehandle + 1

@spec parse(<<_::_*8>>, acc()) :: acc()

Enum.each(0..@prehandle, fn i ->
  def parse(
        <<_::binary-size(unquote(i)), ?\n, rest::binary>>,
        %{bc: bc, wc: wc, lc: lc, ns?: ns}
      ),
      do: parse(rest, acc!(unquote(i), bc, wc, lc + 1, ns))

  def parse(
        <<_::binary-size(unquote(i)), ?\s, rest::binary>>,
        %{bc: bc, wc: wc, lc: lc, ns?: ns}
      ),
      do: parse(rest, acc!(unquote(i), bc, wc, lc, ns))
end)

def parse(<<_::binary-size(@sink), rest::binary>>, acc),
  do: parse(rest, %{acc | bc: acc.bc + @sink, ns?: 1})

Enum.each(@prehandle..0, fn i ->
  def parse(<<_::binary-size(unquote(i))>>, acc),
    do: %{acc | bc: acc.bc + unquote(i), ns?: 1}
end)
```

`acc!` above is a syntax sugar macro that shortens this snippet, one might see it in the whole code listing below.

What the heck is happening above and how it it a promised _Idiomatic Elixir_? Well, it is. During a compilation time, we generate 130 different clauses (43 for matching the _next EOL_, the same amount to match the next space, handles for the tail _and_ the handle for the list of Welsh and New Zealand’s toponyms

- [Taumatawhakatangi­hangakoauauotamatea­turipukakapikimaunga­horonukupokaiwhen­uakitanatahu](https://en.wikipedia.org/wiki/Taumatawhakatangihangakoauauotamateaturipukakapikimaungahoronukupokaiwhenuakitanatahu), NZ
- [Llanfair­pwllgwyngyll­gogery­chwyrn­drobwll­llan­tysilio­gogo­goch](https://en.wikipedia.org/wiki/Llanfairpwllgwyngyll), Wales

Let’s see how it performs.

```elixir
iex|1 ▶ :timer.tc fn -> Wc.greedy "data/part.txt" end      
#⇒ {2_569929, %{bc: 187182221, lc: 1500000, ns?: 1, wc: 4477464}}
iex|1 ▶ :timer.tc fn -> Wc.lazy "data/part.txt" end  
#⇒ {6_616190, %{bc: 185682221, lc: 1500000, ns?: 1, wc: 4477464}}
```

Well, much better, but it’s still six times longer than the native `wc` for a lazy version (and promising 2.5 times only worse for the greedy load.)

Here one could stop, saying I’d trade being 2.5 times slower for the fault tolerance and hot uploads, but we are here not for that. When I started this journey I promised myself I won’t cheat. All that creepy stuff, like `NIF`s written in `Rust` as it is fashionable nowadays. Pure _Elixir_ code only, no spices. But hey, _Erlang/OTP_ brings concurrency for free, so we might probably use it for free. Unless we need to write some sophisticated monoidal code (that I cannot write anyway) as Chris did in his trip. Luckily enough, everything is already there; welcome [`Flow`](https://hexdocs.pm/flow).

### Use More Than 12% Of What We Have Paid For

The good news is literally _no_ code changes are needed in our parsing code. There is a new dependency in `mix.exs` (I also extended it with `escript` generation for the face-to-face test afterward.)

```elixir
def project do
  [
    app: :wc,
    version: "0.1.0",
    elixir: "~> 1.9",
    start_permanent: Mix.env() == :prod,

    escript: [main_module: Wc.Main],
    deps: [{:flow, "~> 1.0"}]
  ]
end
```

Now we need to implement a new function in the main module.

```elixir
@chunk 1_000_000

@spec flowy(binary()) :: acc()
def flowy(file) do
  file
  |> File.stream!([], @chunk)
  |> Flow.from_enumerable()
  |> Flow.partition()
  |> Flow.reduce(fn -> @acc end, &parse/2)
  |> Enum.to_list()
end
```

I have heuristically (by randomly picking different numbers) discovered, than the optimal chunk would be somewhat around several megabytes, so I choosed chunks of the size `1M`. The results differ insignificantly.

Let’s test it!

```elixir
iex|1 ▶ :timer.tc fn -> Wc.flowy "data/part.txt" end
#⇒ {0_752568, %{bc: 187182221, lc: 1500000, ns?: 1, wc: 4477464}}
iex|2 ▶ :timer.tc fn -> Wc.flowy "data/test.txt" end
#⇒ {7_815592, %{bc: 1871822210, lc: 15000000, ns?: 1, wc: 44774631}}
```

Wow. The result is as impressive that I even ran it for the whole `1.8G` file. Yes, we indeed were _faster_ than `wc` on that contrived, grown in hothouse, showing nothing and proving nothing, example. Save for now we are more or less sure _Elixir/OTP_ is _fast enough_ for our purposes, even compared to compiled into native code languages. I also ran `mix escript.build` and finally clean-compared results in the same race.

```sh
time LANG=C LC_ALL=C wc data/test.txt
  15000000   44774631 1871822210 data/test.txt
LANG=C LC_ALL=C wc data/test.txt  9,71s user 0,39s system 99% cpu 10,104 total

time ./wc data/test.txt
	15000000	44774631	1871822210	data/test.txt
./wc data/test.txt  41,72s user 2,31s system 706% cpu 6,355 total
```

Almost twice as fast in total.

---

Below is the whole code (including `main` implementation for `escript`) in a case one would want to experiment with.

```elixir
defmodule Wc do
  @acc %{bc: 0, wc: 1, lc: 0, ns?: 1}
  @prehandle 42
  @sink @prehandle + 1
  @chunk 1_000_000

  @type acc :: %{
          bc: non_neg_integer(),
          wc: non_neg_integer(),
          lc: non_neg_integer(),
          ns?: 0 | 1
        }

  @spec lazy(binary) :: acc()
  def lazy(file),
    do: file |> File.stream!() |> Enum.reduce(@acc, &parse/2)

  @spec greedy(binary) :: acc()
  def greedy(file),
    do: file |> File.read!() |> parse(@acc)

  @spec flowy(binary) :: acc()
  def flowy(file) do
    kw =
      file
      |> File.stream!([], @chunk)
      |> Flow.from_enumerable()
      |> Flow.partition()
      |> Flow.reduce(fn -> @acc end, &parse/2)
      |> Enum.to_list()

    m =
      [:bc, :lc, :wc, :ns?]
      |> Enum.into(%{}, &{&1, Keyword.get_values(kw, &1) |> Enum.sum()})

    m
    |> Map.update!(:wc, &(&1 + 1 - m.ns?))
    |> Map.put(:ns?, 1)
  end

  defmacrop ns!(0, ns), do: ns
  defmacrop ns!(_, _), do: 1

  defmacro acc!(i, bc, wc, lc, ns) do
    quote do
      %{
        bc: unquote(bc) + unquote(i) + 1,
        wc: unquote(wc) + unquote(ns),
        lc: unquote(lc),
        ns?: ns!(unquote(i), unquote(ns))
      }
    end
  end

  @spec parse(<<_::_*8>>, acc()) :: acc()

  Enum.each(0..@prehandle, fn i ->
    def parse(
          <<_::binary-size(unquote(i)), ?\n, rest::binary>>,
          %{bc: bc, wc: wc, lc: lc, ns?: ns}
        ),
        do: parse(rest, acc!(unquote(i), bc, wc, lc + 1, ns))

    def parse(
          <<_::binary-size(unquote(i)), ?\s, rest::binary>>,
          %{bc: bc, wc: wc, lc: lc, ns?: ns}
        ),
        do: parse(rest, acc!(unquote(i), bc, wc, lc, ns))
  end)

  def parse(<<_::binary-size(@sink), rest::binary>>, acc),
    do: parse(rest, %{acc | bc: acc.bc + @sink, ns?: 1})

  Enum.each(@prehandle..0, fn i ->
    def parse(<<_::binary-size(unquote(i))>>, acc),
      do: %{acc | bc: acc.bc + unquote(i), ns?: 1}
  end)

  defmodule Main do
    defdelegate lazy(file), to: Wc
    defdelegate greedy(file), to: Wc
    defdelegate flowy(file), to: Wc

    @spec main([binary()]) :: any
    def main([]), do: IO.inspect("Usage: wc file _or_ wc method file")
    def main([file]), do: main(["flowy", file])

    def main([m, file]) do
      %{bc: bc, wc: wc, lc: lc} = apply(Wc, String.to_existing_atom(m), [file])

      ["", lc, wc, bc, file]
      |> Enum.join(<<?\t>>)
      |> IO.puts()
    end
  end
end
```

---

Happy wordcounting!