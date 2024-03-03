---
layout: post
title: "Finitomata FTW"
description: "Why would one use Finite Automata for almost anything having state"
category: hacking
tags:
  - elixir
---

It’s been a year since I started to implement my own _FSM_ library in _Elixir_. Now it’s funny to read my writings from the time when I had only a gut feeling I’m doing it right.

- [The Proper FSM for Elixir](/hacking/2022/04/02/finitomata)
- [First Class Documentation](/hacking/2022/04/30/finitomata-ex-docs)
- [Finitomata ❤ Mox](/hacking/2023/03/06/finitomata-mox-testing)

Now I have a proof that my premonitions were correct.

When I shared my approach to keeping the local cache of some external incoming value as a bunch of [`Finitomata`](https://hexdocs.pm/finitomata) instances to my boss, he replied with the following. 

> The simple value as an FSM? Have you gone mad man?

No, I haven’t. And here is why.

---

We do receive the external values via some kind of stream, where we might receive a full snapshot for the key, a delta against the previously received snapshot for that key, and a delta against the snapshot for another key. The flow might contain tens thousands values per a second and the total number of keys might be up to one hundred thousand. This all might need more sophisticated infrastructure than a bare [`DynamicSupervisor`](https://hexdocs.pm/elixir/DynamicSupervisor.html) or even a [`PartitionSupervisor`](https://hexdocs.pm/elixir/PartitionSupervisor.html). We need a handy lookup, and we might later decide to scale it horizontally.

[`Infinitomata`](https://hexdocs.pm/finitomata/Infinitomata.html) runs transparently on the cluster, which means all one needs to use more memory/cores to process state transitions, would be adding new nodes to the cluster. `Infinitomata` will use them transparently upon addition.

But what’s wrong with leveraging a standard [`:pg`](https://www.erlang.org/doc/man/pg.html), would probably ask a careful reader. After all, `Infinitomata` is built on top of `:pg` and we unlikely would need any _FSM_ goodness to carry simple values. Negative. We definitely might rely on conditionals within values updates, but it would quickly become clumsy making it hard to reason about. On the contrary, we might keep the current state of the value in the _FSM_ state, abstracting it out of the business logic. We won’t need to validate anything, because transitions are either possible (allowed,) or ignored.

As I said, we might receive a delta, which implies to get to the actual value, the snapshot must be already there. Yes, we might do somewhat along

```elixir
value =
  if state.snapshot?, do: apply_delta(), else: :ignore
```

or even pattern-match in the function clause, but it’d be cumbersome, because deltas might rely on the snapshots for other keys. Instead, we might handle the transition for “local” delta if and only we already have a snapshot, meaning we are in the state `ready`. The transition handler for deltas relying on “external” keys would be as easy as

```elixir
def on_transition(current_state, :foreign_delta, {foreign_key, delta_values}, state) do
  target_state =
    case Infinitomata.state(key) do
      {:error, :not_started} -> Logger.info("…")
      %{state: :idle} -> Logger.warn("…")
      %{state: :ready} -> apply_delta(delta_values)
    end

  if target_state == :ok,
    do: {:ok, current_state, state},
    else: {:ok, target_state, state}
end
```

This is clean, applies to `:foreign_delta` event only, and leaves the _FSM_ in the correct state no matter what. We do gain the sequential processing for free as well. Also, there is no chance one forgets about some combination of state and event and leaves it unhandled. The `:finitomata` compiler would tell the _FSM_ is inconsistent, if there are orphans or unhandled transitions.

All the [`on_transition/4`](https://hexdocs.pm/finitomata/Finitomata.html#c:on_transition/4) callbacks might be as a matter of fact implemented as a `with/1` chain, logging the error, if any, and leaving the _FSM_ in the state it was before the event came. There is no chance to end up with some inconsistency.

Even if the _FSM_ definitions is as simple as

```elixir
  @fsm """
  idle --> |snapshot| ready
  ready --> |snapshot| ready
  ready --> |delta| ready
  ready --> |foreign_delta| ready
  ready --> |shutdown| down 
  """

  use Finitomata, fsm: @fsm, auto_terminate: true
```

I prefer to use _FSM_ because it abstracts a lot of boilerplate out and makes me to implement business logic only, with all the guarantees and validations, provided by `Finitomata` _and_ all the necessary `on_transition/4` handlers I am to implement, ready to pattern-match on meaningful states and events. 

With a sleek learning curve, first-class test support with [`Finitomata.ExUnit`](https://hexdocs.pm/finitomata/Finitomata.ExUnit.html#test_path/3), and plain text FSM declaration as both code and documentation, it’S a pleasure to deal with.

Happy infinite automating!
