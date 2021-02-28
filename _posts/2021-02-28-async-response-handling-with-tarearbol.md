---
layout: post
title: "Handling Async Responses with Tarearbol"
description: "DynamicManager provided by Tarearbol is extremely handy for handling asynchronous responses from external services"
category: hacking
tags:
  - elixir
---

[`Tarearbol`](https://hexdocs.pm/tarearbol) provides a handy helper to work with many similar processes under a supervision of [`Tarearbol.DynamicManager`](https://hexdocs.pm/tarearbol/dynamic_workers_management.html).

Initially, it was created to ease producing and managing many similar processes, described by `id` _and_ `payload`. These processes are running supervised, managed by a classic store-like interface having basically `put/2`, `get/1`, and `del/1` functions exported. The process runs in background, calling `perform/2` implementation and controlling its own lifecycle. Processes might also be easily scaled horizontally, running in distributed environment, using hashring to decide who is to handle this particular request.

![Castell Jalpi](/img/castle.jpg)

The typical application would be, for instance, order management. Imagine an online shop where each visitor has their own cart. This cart is managed by the separate process, keeping the cart content in its state. When the user adds an item to the cart, the process state gets updated, and once per, say, minute, it checks the items availability, current prices, etc., to keep the user up-to-date with the latest data regarding their order.

This approach would not work in cases when the instant real-time updates are required, but it has an advantage in the _almost real time_ processing because of its graceful throttling of requests. Even if a million users will all of sudden come to buy stuff, it’ll spinoff the checkers, but the site running on one instance will be still slowly functioning until engineers add other 10 instances to scale better.

For many processes holding nearly the same state, it saves a lot of boilerplate, claiming to implement `perform/2` callback only (and maybe two optional callbacks `call/3` and `terminate/2`.)

### Asynchronous Request Processing

This approach provides also a great scaffold to handle asynchronous requests to third party services. Consider the application communicating to the external service. If everything goes ok, it expects to place a request there and receive a callback in a matter of seconds. That said we ① want to process a callback immediately and also ② report requests that did not receive a response in a while.

For the sake of simplicity, we can say without a loss of generality, that we use HTTP as a communication protocol. We also have a plug, or even the whole Phoenix to handle responses from the remote service. The machinery processing responses will then be as simple as

```elixir
defmodule Handler do
  use Tarearbol.DynamicManager

  @doc """
  Empty initial state, no responses yet.

  In reality, this might be loaded from some persistent store.
  """
  @impl Tarearbol.DynamicManager
  def children_specs, do: %{}

  @doc """
  Periodic check and alert for stale requests.
  """
  @impl Tarearbol.DynamicManager
  def perform(id, _payload) do
    Logger.log("Expected callback has not been received for #{id}...")
    {:ok, DateTime.utc_now()}
  end

  @impl Tarearbol.DynamicManager
  def call(:process, _from, {id, payload}),
    do: do_process_response({id, payload})

  defp do_process_response({id, payload}), do: ...
end
```

That’s literally all code needed to create a robust, supervised, fault tolerant system, monitoring asynchronous requests without even involving any persistent store. When we send the request to the external service, we start a new process by calling `Handler.put(id, payload)`. When we receive a callback, we call `Handler.synch_call(id, :process)`, followed by `Handler.delete(id)`. That’s it.

---

Happy response-handling!
