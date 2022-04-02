---
layout: post
title: "Finitomata :: The Proper FSM for Elixir"
description: "The FSM implementation that’s worth it to give a try"
category: hacking
tags:
  - elixir
---

I’m a big fan of [Finite Automata](https://en.wikipedia.org/wiki/Finite-state_machine). Always have been. Whenever we deal with a long-lived objects, they eventually have states and _FSM_ does an enormously great job by attesting consistency, eliminating human errors and leaving the implementation with a business logic only. In a mediocre project, fifty `if`-`then`-`else` conditionals might perform as well as one _FSM_, but unless you are paid for the number of LoCs, _FSM_ is drastically easier to carry on.

![Cherrytree](/img/sakura.jpg)

Of course, I am not alone, and there are many implementations of _FSM_ in different languages. During my _Ruby_ journey, I loved [`workflow`](https://github.com/geekq/workflow) gem for its simplicity, clarity, and robustness. Nowadays I mostly do _Elixir_ and I surely searched through available libraries to minimize _FSM_ boilerplate.

The package that comes up first when doing an internet search would be [`fsm`](https://github.com/sasa1977/fsm) by Saša Jurić. But the author explicitly says on the very top of _README_

> […] I don't advise using [this library]. Pure functional FSMs are still my preferred approach (as opposed to `gen_statem`), but you don’t need this library for that. Regular data structures, such as maps or structs, with pattern matching in multiclauses will serve you just fine.

That said, the proposed approach would be to have a `GenServer` with multiple clauses of, say, `transition/2` function and messages containing events. Somewhat like

```elixir
@impl GenServer
def handle_call(:event1, %{} = state), do: …
def handle_call(:event2, %{} = state), do: …
def handle_call(:event3, %{} = state), do: …
```

---

I admire Saša’s contribution in _Elixir_ ecosystem, and he is definitely one of the smartest persons I ever met, so I used this approach for years. Until I found myself in a position of copy-pasting a boilerplate for that from one project to another. I surely felt it might be done better, but the actual implementation eluded me.

Last week I had been presenting the _FSM_ concept to non-tech auditory during one of our internal tech talks, and it finally clicked. That’s how [`finitomata`](https://github.com/am-kantox/finitomata) library was born.

---

The most important thing I wanted to _automate_ would be the _FSM_ pure description itself. I wanted something, that is fault-tolerant, not error-prone, and easy to grasp. I wanted the result to be drawable out of the box. That’s why I recalled [PlantUML format](https://plantuml.com/en/state-diagram). Instead of scrolling the editor window back and forth and memorizing all the transitions handled, the definition of the entire _FSM_ would be in the very single place! That sounded as a great idea.

```
[*] --> s1 : to_s1
s1 --> s2 : to_s2
s1 --> s3 : to_s3
s2 --> [*] : ok
s3 --> [*] : ok
```

So I took [`NimbleParsec`](https://hexdocs.pm/nimble_parsec), the great parser combinators library by [Dashbit](https://dashbit.co/) and started with _PlantUML_ parsing. I ensured the parsed _FSM_ consistency as: one single state, no orphan states, at least one final state. Also I have plans to implement a `mix` task to generate a visual representation of _FSM_ as a diagram (the respective [issue](https://github.com/am-kantox/finitomata/issues/1) is marked as _Help Wanted_ FWIW :))

I already had the approximate architecture in my mind. I wanted _FSM_ to leverage `GenServer` functionality under the hood, and several callbacks for the _real_ consumer actions when the transaction gets performed. These callbacks were intended to allow the cosumer to concentrate on business logic only, without a necessity to deal with processes, messages and supervision trees. It should have been absolutely imperative for the consumer yet fully _OTP_ under the hood.

_Draft implementation:_ the consumer initiates a transition by calling somewhat like `transition(object, event)`, then the `GenServer` does its magic and the callback `on_transition` gets called. From inside this callback, the consumer implements the business logic and returns the result (the next state to move the _FSM_ to.) Soon I figured out we need also `on_failure` and `on_terminate` callbacks to allow easy handling of errors and to perform a final cleanup respectively.

---

All the callbacks do have a default implementation, which would perfectly handle transitions having a single `to` state and not requiring any additional business logic attached.

Upon start, it moves to the next to initial state and sits there awaiting for the transition request. Then it would call an `on_transition/4` callback and move to the next state, or remain in the current one, according to the response.

Upon reachiung a final state, it would terminate itself, that’s where `on_terminate/3` callback is called from. The process also keeps all the history of states it went through, and might have a payload in its state.

That’s how the whole implementation would look like

```elixir
defmodule MyFSM do
  @fsm """
  [*] --> s1 : to_s1
  s1 --> s2 : to_s2
  s1 --> s3 : to_s3
  s2 --> [*] : ok
  s3 --> [*] : ok
  """

  use Finitomata, @fsm

  def on_transition(:s1, :to_s2, event_payload, state_payload),
    do: {:ok, :s2, state_payload}

  def on_transition(…), do: …

  def on_failure(…), do: …

  def on_terminate(…), do: …
end
```

---

The library includes a supervision tree with a [`DynamicSupervisor`](https://hexdocs.pm/elixir/DynamicSupervisor.html) carrying all the _FSM_ and the `Registry` instance to allow anything to be an _FSM_ name with [`{:via, module, term}`](https://hexdocs.pm/elixir/GenServer.html#module-name-registration).

The snippet below demonstrates how one would use the _FSM_ implementation above

```elixir
# Starts an FSM supervised
#                    ⇓ IMPL  ⇓ NAME         ⇓ PAYLOAD
Finitomata.start_fsm MyFSM, "My first FSM", %{foo: :bar}

Finitomata.transition "My first FSM", {:to_s2, nil}
Finitomata.state "My first FSM"                    
#⇒ %Finitomata.State{current: :s2, history: [:s1], payload: %{foo: :bar}}

Finitomata.allowed? "My first FSM", :* # state
#⇒ true
Finitomata.responds? "My first FSM", :to_s2 # event
#⇒ false

Finitomata.transition "My first FSM", {:ok, nil} # to final state
#⇒ [info]  [◉ ⇄] [state: %Finitomata.State{current: :s2, history: [:s1], payload: %{foo: :bar}}]

Finitomata.alive? "My first FSM"
#⇒ false
```

That’s it for now, but the library is still in the kindergarten, it’s `v0.1.0` so one might expect more sugar to come soon.

---

Happy finite automating!
