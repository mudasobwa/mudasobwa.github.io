---
layout: post
title: "Wolf, Goat, Cabbage… and Elixir"
description: "Use asynchronous traversal of a branched state graph to find a solution of a Lewis Carroll’s favorite puzzle"
category: hacking
tags:
  - elixir
  - erlang
---

> The wolf, goat and cabbage problem is a [river crossing puzzle](https://en.wikipedia.org/wiki/River_crossing_puzzle). It dates back to at least the 9<sup>th</sup> century, and has entered the folklore of a number of ethnic groups.  
> Once upon a time a farmer went to a market and purchased a wolf, a goat, and a cabbage. On his way home, the farmer came to the bank of a river and rented a boat. But crossing the river by boat, the farmer could carry only himself and a single one of his purchases: the wolf, the goat, or the cabbage.  
> If left unattended together, the wolf would eat the goat, or the goat would eat the cabbage.  
> The farmer’s challenge was to carry himself and his purchases to the far bank of the river, leaving each purchase intact. How did he do it?  
> — [Wolf, goat, and cabbage problem @Wiki](https://en.wikipedia.org/wiki/Wolf,_goat_and_cabbage_problem)

![Wolf → Goat → Cabbage](https://habrastorage.org/webt/wd/yt/9g/wdyt9getbzfatxvfihnk3udgia0.png)

---

I stumbled upon the article showing this riddle’s solving process in Haskell and all of a sudden I realized, that it’s perfectly suited to demonstrate the power of _Elixir_ parallel processing nature. We are going to build the fully lazy asynchronous parallel iteration to get to the solution(s).

We are to start with the “all on the left bank” state, and at each step we will run a maximum of as many erlang processes as there are animals on this bank (+1 for crossing the river in empty boat.) At the same time, we will always check that the animals that remain on the bank do not bite each other; these branches will be cut off immediately. We will also store the history and cut off cyclical branches that return us to the state we have already seen. This, by the way, is not redundant data—we will return the history of all trips as a result.

So let's start with the prerequisites.

```ruby
defmodule WolfGoatCabbage.State do
  @moduledoc """
  Current state of our microcosm.

  • banks (`true` for the initial one)
  • `ltr` — the direction marker
  • `history` of trips
  """
  defstruct banks: %{true => [], false => []}, ltr: true, history: []
end

defmodule WolfGoatCabbage.Subj do
  @moduledoc """
  The unit of animal life, and who they conflict with.
  """
  defstruct [:me, :incompatible]
end
```

My blog engine’s code parser still lives in XIX century, so here is the screenshot of the initial values.

![Initial values](https://habrastorage.org/webt/ss/pp/gn/ssppgnizme7gfcoxzvuoed6g9p8.png)

Thus, it’s a code time!

### Integrity Check

```ruby
@spec safe?(bank :: [%Subj{}]) :: boolean()
defp safe?(bank) do
  subjs =
    bank
    |> Enum.map(& &1.me)
    |> MapSet.new()
  incompatibles =
    bank
    |> Enum.flat_map(& &1.incompatible)
    |> MapSet.new()

  MapSet.disjoint?(subjs, incompatibles)
end
```

Here we built a set of those who remain, a set of those with whom they cannot coexist, and made sure that there are no intersections. So far, this is trivial.

### Move / One Way Trip

Conditions for an empty trip and a trip with animals are quite different, so it is convenient to split their processing into two clauses (`nil` is a great fit for “nobody”.)

```ruby
@spec move(%State{}, nil | %Subj{}) :: %State{} | false
@doc """
If there is no one in the boat, it is enough to check
that we do not leave the bank in the already seen state,
and directly return the new state.
"""
defp move(%State{ltr: ltr, banks: banks, history: history} = state, nil) do
  with true <- not ltr, true <- safe?(banks[ltr]) do
    %State{state | ltr: not ltr, history: [length(history) | history]}
  end
end

@doc """
When there in the boat they bleat, yap, or emphatically
flap leaves—it’s a bit more complicated.

We move the animals from one bank to the other, making
sure that the trip is safe (there will be no unscheduled
dinner on the bank we just left) and that we haven’t seen
this state yet.

If all criteria are met, we return a new state,
or the terminating `false` otherwise.
"""
defp move(%State{banks: banks, ltr: ltr, history: history}, who) do
  with true <- who in banks[ltr],
        banks = %{ltr => banks[ltr] -- [who],
              not ltr => [who | banks[not ltr]]},
        bank_state = MapSet.new(banks[true]),
        true <- safe?(banks[ltr]),
        true <- not Enum.member?(history, bank_state) do
    %State{
      banks: banks,
      ltr: not ltr,
      history: [bank_state | history]
    }
  end
end
```

### Сruise

It remains, in fact, to write the main part: recursively spawning processes.
Duh, that’d be easy.

```ruby
@initial %State{
            banks: %{true => @subjs, false => []},
            history: [MapSet.new(@subjs)]
         }

@spec go(%State{}) :: [MapSet.t()]
def go(state \\ @initial) do
  case state.banks[true] do
    [] -> # ура!
      Enum.reverse(state.history)

    _some ->
      [nil | @subjs]
      |> Task.async_stream(&move(state, &1))
      |> Stream.map(&elem(&1, 1)) # lazy
      |> Stream.filter(& &1)      # lazy
      |> Stream.flat_map(&go/1)   # lazy + recursively
  end
end
```

Thanks `Stream`, all that code is lazy, meaning nothing would be executed until
asked explicitly. The multiprocess concurrent parody of _Haskell_.

### Check It

I love tests, but I don’t really like to write tests. I consider this a waste of time: it’s indeed much easier to write working code right away. So I’m to simply create `main/0 ' function and display the results on the screen.

There is one caveat: several solutions will return a flat list due to `Stream.flat_map/2`. But it’s not a big deal: each solution ends up with an empty set, so we’ll easily break this flat sheet into chunks. I'm not going to copy-paste the entire code of beautiful output (which is almost as long as the logic behind,) here's [gist](https://gist.github.com/am-kantox/d559895d7297d1a3f0d96eba4cdda5b3) for those who care.

Meanwhile I am to open _REPL_ and…

![Wolf → Goat → Cabbage](https://habrastorage.org/webt/cb/a3/tj/cba3tjk1ikblaviwny-t51eb630.png)

---

Happy agricultural transportationing!
