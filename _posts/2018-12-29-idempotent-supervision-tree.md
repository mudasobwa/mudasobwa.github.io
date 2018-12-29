---
layout: post
title: "Idempotent Supervision Tree"
description: "The main advice on how to keep a supervision tree immune to members crashes"
category: hacking
tags:
  - elixir
  - tricks
  - tutorial
---

One of the most exciting features of [OTP](https://learnyousomeerlang.com/what-is-otp), the heart of _Erlang VM_, would be the _Supervision Tree_. The long-lived processes are maintained as a tree structure, containing [_Supervisors_](https://hexdocs.pm/elixir/Supervisor.html) and _Workers_. The latter are _leaves_ in the tree. We do not need to be babysitting each and every process, instead we practice [_Let It Crash_](http://verraes.net/2014/12/erlang-let-it-crash/) religion. If something went wrong, in most cases _we do nothing_. We just let the failed process crash and the supervisor will restart it gracefully.

This is one of the best design decision I can think of.

Wrong input?—Let it crash. Third party service failure?—Let it crash. Need the process to re-initialize itself?—Let it crash. The supervisor will take care of it.

That approach has one slight drawback though. The supervision tree must be elaborated very thoughtfully. **Process restarts must be idempotent.** Since we don’t handle crashes manually, we cannot know in advance when and under what circumstances our process would crash. That means, it might be restarted in literally every single moment, maybe several times. That is why idempotency is a must.

There are many aspects to be taken into account here, the margins here are too small to list them all. I am going to show probably the most common glitch with process re-initialization that makes it not idempotent and how to overcome the issue.

---

All of us do create our own `GenServer`s. The most common approach is to implement our `start_link/{0,1}` function to delegate to the [`GenServer.start_link/3`](https://hexdocs.pm/elixir/GenServer.html#start_link/3):

```elixir
@doc ~s"""
Starts a new #{__MODULE__} linked to the current process.
"""
def start_link(_opts \\ []),
  do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
```

Sooner or later we’ll need to perform some more cumbersome initialization upon startup and the first intent would be to do something like:

```elixir
def start_link(_opts \\ []) do
  result = GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  do_initialization()
  result
end
```

Lo and behold! We had just broken the idempotency. If this function will be called twice in a row, the initialization will be performed _twice_. Which is rarely if never a desired behaviour.

Luckily, `GenServer.start_link/3` is smart enough to report how the linked start went. It returns one of those [`on_start`](https://hexdocs.pm/elixir/GenServer.html#t:on_start/0):

```elixir
@spec ... :: {:ok, pid()} | :ignore | {:error, {:already_started, pid()} | term()}
```

So, the better way seems to be to explicitly match to `{:ok, pid}` and perform initialization only then.

```elixir
def start_link(_opts \\ []) do
  {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  do_initialization()
  {:ok, pid}
end
```

Right?—Nope. The code above will blow up when the process is already started. By default, the supervisor will attempt to restart it three times (the number is configurable) and give up then. Yes, the process was likely already started, so no issue, but this is incorrect; the process should not blow up all of sudden for no reason.

The proper solution would be to act on successful start and _let anything else sink to the caller_. [Kernel.SpecialForms.with/1](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#with/1) _monad-like_ construct comes to the rescue:

```elixir
def start_link(_opts \\ []) do
  with {:ok, pid} <- GenServer.start_link(__MODULE__, %{}, name: __MODULE__) do
    do_initialization()
    {:ok, pid}
  end
end
```

Now if the process has started successfully, we perform the required initialization. If not, we just _pass the error returned to the calling process_. Let them deal with the issue. This is the correct way to perform idempotent initialization of the process.

Happy reloading!
