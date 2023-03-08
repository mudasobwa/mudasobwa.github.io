---
layout: post
title: "Finitomata ❤ Mox"
description: "Synchronization points: the proper way to test FSM in details of how to control data flow (opinionated approach)"
category: hacking
tags:
  - elixir
  - ideas
---

While pushing for FSMs in general and [`Finitomata`](https://hexdocs.pm/finitomata) in particular, I needed to provide a robust and handy way to test the beast. The ideology of `Finitomata` approach is to spawn a process per each entity alive, where _alive_ means _in some intermediate state_. Generally speaking, that does not make the conventional testing a charm. Consider a process which might change its state (or, in terms of `Finitomata`, _can transition from one state to another_,) not only as a result of an explicit intervention, like a message sent to it, or, which is nearly the same, via `Finitomata.transition/4`, but also as a consequence or even a coincidence of some several external occasions.

![Camina Ronda](/img/camina-ronda.jpg)

Testing asynchronous interoperation is not the most trivial part of dealing with OTP, although we still might cook it right and make delicious. To simplify it and make testing pleasant and easy, I needed to inject some synchronization points, somewhat like _mutexes_, or, if you wish, erlang _schedulers_.

I always have been a big fan of callbacks. I tend to allow listener injection to each and every process I am implementing. If there are several phases of the process, I’d allow listening on phases change. If there is an input parsed, I’d welcome a listener on each line parsed. You got the point. FSM literally implies the existence of `on_transition` callback for some listener(s).

This listener would be an ideal [_noun to mock_](https://dashbit.co/blog/mocks-and-explicit-contracts). During testing, this listener is to play the single role of **process synchronization guard**, but it must play it great. It can and should be used to synchronize control flow between testing and tested processes (and the whole outer world, if desired.) By introducing several synchronization points which are roughly speaking the callbacks themselves, it provides the catch-up scenario for the test code via `assert_receive/2`.

---

The main issue with implementing this idea was `Mox` demanded the process to call mocks to be started at the moment of mock declaration, which results is what I call _alive-lock_, as a contrary to notorious _dead-lock_ from Java world. To declare mock, I needed a process and to test a process I needed the already declared mocks. To make my initial plan happen, I provided a pull request to `Mox` to allow deferred `pid` resolution, based on the process name. It has been merged and it might be tested right away with a dependency specified as `git: :master`.

So far so good, now I have a clean interface of any possible interop between testing process and the test itself.

Here is an example taken from `Finitomata` tests, which shows the approach.

```elixir
Mox.defmock(Finitomata.Test.Listener, for: Finitomata.Listener)

defmodule Finitomata.Test.Mox do
  @fsm """
  idle --> |start!| started
  started --> |do| done
  """

  use Finitomata, fsm: @fsm, auto_terminate: true, listener: Finitomata.Test.Listener
  …
end
```

This is the standard declaration of `Finitomata` worker: _FSM_, having three states, an unconditional transition to `started` and a normal transition to `done`. After `start!` event we might want to test initialization and after `do` we might want to test actual behaviour.

Here is the code in test doing exactly that, and I finally like how this code looks like.

```elixir
    parent = self()

    Finitomata.Test.Listener
    |> allow(parent, fn -> GenServer.whereis(fsm_name) end)
    |> expect(:after_transition, 3, fn id, state, payload ->
      parent |> send({:on_transition, id, state, payload}) |> then(fn _ -> :ok end)
    end)

    …

    Finitomata.start_fsm(…)

    …

    # test payload after initialization
    assert_receive {:on_transition, ^fsm_name, :idle, %{foo: ^bar}}
    # test payload after unconditional state advance
    assert_receive {:on_transition, ^fsm_name, :started, %{data: _}}

    Finitomata.transition("MyFSM", {:do, event_payload})
    # test payload after conditional transition
    assert_receive {:on_transition, ^fsm_name, :done, %{outcome: _}}
```

---

Next step would be to export helper macros to decrease an amount of code needed to be written in each test.

---

Happy synchrotesting!
