---
layout: post
title: "Finite Automata with Tarearbol"
description: "DynamicManager provided by Tarearbol is extremely handy for FSM implementation"
category: hacking
tags:
  - elixir
---

[`Tarearbol`](https://hexdocs.pm/tarearbol) provides a handy helper to work with many similar processes under a supervision of [`Tarearbol.DynamicManager`](https://hexdocs.pm/tarearbol/dynamic_workers_management.html). I have already [written about it in general](https://rocket-science.ru/hacking/2021/02/28/async-response-handling-with-tarearbol); now I want to show how to use workers having a predetermined lifecycle, that can be implemented as an FSM.

![Pigeon’s over the tent](/img/pigeon.jpg)

Consider the following example. Our system has a 3rd-party service provider to validate some objects. It might me a compliance check, of some external storage, or whatever. We are to send objects there and wait for the object’s state change in the remote system to, say, `processed`. While the best feasible way to implement such a functionality would be to provide a webhook and wait for the callback after submission, some services might require polling.

The polling lifesycle is a straightforward finite automata, shown below.

![Polling](/img/polling.jpg)

With `Tarearbol.DynamicManager`, we start a process, that handles the current FSM state within its internal state, and using different return values from perform, we control the FSM itself. The code below is taken from the real project.

```elixir
defmodule MyApp.Negotiation do
  use Tarearbol.DynamicManager,
    distributed: true,
    init: &MyApp.Negotiation.continue/1,
    defaults: [timeout: 10_000]

  defmodule State do
    @type state :: :virgin | :submitted | :succeeded | :failed
    defstruct state: :virgin, payload: %{}, response: nil
  end

  ...
end
```

The only thing left would be to handle all the types of possible responses, gracefully transitioning the FSM inside `State` through the states. The first request might be done directly in `continue` callback of the `DynamicWorker`.

```elixir
  @doc "The `DynamicManager`’s continue callback"
  def continue(%State{state: :virgin, payload: payload} = state) do
    payload
    |> post_to_3rd_party()
    |> case do
      {:ok, response} -> %State{state | state: :submitted, response: response}
      {:error, error} -> %State{state | state: :failed, response: error}
    end
  end
```

Now we need to properly handle all the possible responses, depending on what state we are currently in.

#### Failure

```elixir
  @impl Tarearbol.DynamicManager
  def perform(id, %State{state: :failed, response: error} = state) do
    Logger.error("Errored: #{id}")
    # Do whatever with the error returned, *do not shutdown the process*
    {​{:timeout, 0}, payload} # switch off subsequential calls to `perform/2`
  end
```

#### Success

```elixir
  def perform(id, %State{state: :succeeded, response: response}) do
    Logger.info("Processed: #{id}")
    # Do whatever with the response returned, *shutdown kill the process*
    :halt
  end
```

#### Pending

```elixir
  def perform(id, %State{state: :submitted} = state) do
    Logger.info("Re-requesting the state of the #{id}")

    payload
    |> get_to_3rd_party()
    |> case do
      :pending ->
        {:ok, state}

      {:ok, response} ->
        {:replace, %State{state | state: :succeeded, response: response}}

      {:error, error} ->
        {:replace, %State{state | state: :failed, response: error}}
    end
  end
```

#### Further Improvements

As we can see here, the code is well-separated and easily extendable. Once needed, we can add new states and juggle the FSM sending it from one state to another using return values. It’s also easy to get to all currently running processes, their state, last returned values etc.

---

Happy finite automating!
