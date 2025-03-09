---
layout: post
title: "Long-lived Process and State Recovery After Crashes"
description: ""
category: hacking
tags:
  - elixir
---

When talking about erlang/elixir, people usually come up with three main associations: lightweight processes, an actor model, and fault tolerance. Erlang made it possible to run hundreds of thousands (with fine—tuning of a virtual machine, millions) of “processes” (what were later called greentreads, and even later goroutines)—almost forty years ago. Joe Armstrong, in his dissertation, half-jokingly characterized language through the catachresis of _everything is a process_. With the actor model, of course, this is a direct influence of Alan Kay and his ideas about _everything is an object_ (sending _messages_ to each other).

![Phoenix From Ashes](/img/phoenix-from-ashes.jpg)

> Once you divide the world into parallel components, they will only be able to communicate with each other by sending messages. It's almost a biological, physical model of the world. When a group of people sits and talks to each other, you can imagine that they have independent models in their heads, and they communicate with each other using language. Language is messages, and what is in their brain is a finite automaton. This seems to be a very natural way of thinking. — [Concurrency in Computing](https://www.erlang-solutions.com/blog/lets-talkconcurrency-with-joe-armstrong/) with Joe Armstrong

But with fault tolerance, everything is a little more interesting. Armstrong’s PhD thesis is titled “Making reliable distributed systems in the presence of software errors.” Unlike almost all other language creators, from Matz the Extremist, who believed that every programmer was so smart that they did not need to be limited in anything at all, to the dull pragmatist Pike, who invented a language for not very smart students so that they [would at least not spoil anything](https://news.ycombinator.com/item?id=16143918), Armstrong lived in the real world and he perfectly understood that there would be mistakes, and instead of preventing their introduction (which is impossible,) it is necessary to deal with the consequences.

This is how the famous slogan “Let It Crash” was born. Here Joe Armstrong [explains it](https://erlang.org/pipermail/erlang-questions/2003-March/007870.html). In short, no one has ever suggested that errors should not be handled at all, crashing everything no matter what. The point is that we are never to be able to handle all the errors anyway; partly because of the unpredictability of complex code behavior in corner cases, and partly because of hardware failures over which the software has no control. Therefore, one does not need to try to process all errors (which is impossible)—one needs to process the expected ones and not be afraid that if things do bonkers, the process is to bring the entire application down with it or to stop providing the required functionality. This is provided by supervisor trees—once down, the process will restart in a state known as “good.”

This paradigm works great (and was even imitated in kubernetes, not quite ingeniously anyway). The paradigm works, but there is one problem.

### Long-lived processes with a condition

Erlang was created for telecom. The finite automata of the processes there are very simple, such as `idle` → `calling` → `in_call` → `idle`. The internal state of the process is not quite bushy, too. Did the process crash in the middle of the call?—Well, it doesn’t matter, the main thing is that the subscriber’s phone doesn’t become a brick, so just restart the process (and it will enter the initial `idle` state.)

In the modern world, business tasks have emerged that require long-lived, state-changeable processes. For example, a counter (I know that erlang provides a quick and easy-to-use module out of the box: [`:counters`](https://www.erlang.org/doc/apps/erts/counters.html), this is just an example.)

And if we measured something there, and then we crashed, the process will restart, but its accumulated state is to be lost. This behavior creates incredible crutches, such as saving the state to a third-party repository. And if it’s still a back-and—forth for the counter, then it’s just a paranoia bordering on madness for the hot cache. Erlang should be able to solve this problem by himself. (I know about `DETS`, but they are local; I also know about `mnesia`, but it is extremely difficult to maintain it in containers.) And—let me repeat this—there must be a solution that does not require turning erlang into java and dragging some radishes with it.

### Peeper

It was in order to solve this problem once and for all that I isolated my code to support the state saved during restarts of the `GenServer` process into the [`Peeper`](https://hexdocs.pm/peeper) library. And although this solution is practically a drop-in replacement for a regular `GenServer`, I strongly disencourage using it everywhere, because in many cases it can mask the problem, sweep the dust of unscheduled restarts under the carpet and confuse the developer, who sees that everything is working fine (and tests are all green,) while in fact, each process is restarted three hundred times per second.

It makes sense to use it if you have a long—lived process with a mutable state (the simplest and clearest example is a hot cache,) to which you do not want to attach third-party storage.

Let’s see how it works though.

```elixir
defmodule MyGenServer do
  @moduledoc false

  #                     we support listener, see below
  use Peeper.GenServer, listener: Peeper.Impls.Listener

  @impl Peeper.GenServer
  def init(state), do: {:ok, state}

  @impl Peeper.GenServer
  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_call(:raise, _from, _state) do
    # test callback to make sure state is saved between restarts
    raise "boom"
  end

  @impl Peeper.GenServer
  def handle_info(:inc, state), do: {:noreply, state + 1}

  @impl Peeper.GenServer
  def handle_cast(:inc, state),
    do: {:noreply, state, {:continue, :inc}}

  # yeah, `handle_continue/2` too
  @impl Peeper.GenServer
  def handle_continue(:inc, state),
    do: {:noreply, state + 1}
end
```

And let’s play with it a bit.

```elixir
iex|🌢|2 ▶ {:ok, pid} = MyGenServer.start_link(state: 0, name: MyServer)
{:ok, #PID<0.250.0>}
iex|🌢|3 ▶ Peeper.call(pid, :state)
0
iex|🌢|4 ▶ Peeper.cast(pid, :inc)      # handle_cast/2
:ok
iex|🌢|5 ▶ Peeper.send(MyServer, :inc) # handle_info/2
:inc
iex|🌢|6 ▶ Peeper.call(pid, :raise)
11:29:50.248 [error] GenServer MyServer.GenServer terminating
** (RuntimeError) boom
[…]
State: %{state: 2, […]}
[…]
** (exit) exited in: GenServer.call(#PID<0.252.0>, :raise, 5000)
    ** (EXIT) an exception was raised:
        ** (RuntimeError) boom
iex|🌢|6 ▶ Peeper.call(pid, :state)
2 # state is resurrected
```

As you can see, the behavior does not differ at all from the usual `GenServer`, but the state has been restored.

No one would give the absolute guarantee, because if one extinguishes any `Supervisor` higher up the tree, no miracle would have happened, and the state is to be lost. It is not worth storing the amount in the client’s bank account using this approach.

But in the vast majority of cases, when it is possible to more or less clearly specify the conditions for restarting the entire tree, and when a sudden loss of state due to a cable gnawed by mice is not so critical, this approach makes error handling even easier.

And if you still need to play it safe and backup the state changes in some event storage, the library provides the opportunity to connect [`Peeper.Listener`](https://hexdocs.pm/peeper/Peeper.Listener.html) that would be asynchronously called when the state changes (though wouldn’t be if the state from the callback has not changed,) and when the process is stopped. To grab this state from the storage at startup, one would be about to implement the [`init/1`](https://hexdocs.pm/peeper/Peeper.GenServer.html#c:init/1) callback in their `Peeper.GenServer`.

The library supports hot code upgrade, if anyone else besides me is interested in it in our era of docker.

Happy statepreserving!
