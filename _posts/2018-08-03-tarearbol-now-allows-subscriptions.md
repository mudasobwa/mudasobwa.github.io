---
layout: post
title: "Tarearbol now allows subscriptions to task results"
description: "Tarearbol gracefully uses Envío’s functionality to subscribe to task execution results"
category: hacking
tags:
  - elixir
  - tricks
  - tools
---

### Intro

[**`Tarearbol`**](https://hexdocs.pm/tarearbol/intro.html) is a lightweight task manager, allowing retries, callbacks, assurance that the task succeeded, and more. It starts and manages the task supervision tree for granted. With `Tarearbol` one might ensure the task, that might occasionally fail due to reasons beyond caller’s control, will be retried until succeeded. It’s highly configurable and allows callbacks on:

* task successful completion,
* task retries,
* task fail (when the max limit of retries is reached.)

It also provides a functionality to manage many tasks at once with [`Tarearbol.ensure_all/2`](https://hexdocs.pm/tarearbol/Tarearbol.html#ensure_all/2) and [`Tarearbol.ensure_all_streamed/2`](https://hexdocs.pm/tarearbol/Tarearbol.html#ensure_all_streamed/2), run tasks with a delay using
[`Tarearbol.run_at/3`](https://hexdocs.pm/tarearbol/Tarearbol.html#run_at/3) and [`Tarearbol.run_in/3`](https://hexdocs.pm/tarearbol/Tarearbol.html#run_in/3), and drain the scheduled tasks queue with [`Tarearbol.drain/1`](https://hexdocs.pm/tarearbol/Tarearbol.html#drain/1).

Starting with [version 0.8.1](https://github.com/am-kantox/tarearbol/releases/tag/v0.8.1) it married [`Envío`](https://hexdocs.pm/envio) to make it drastically easy to subscribe to task processing callbacks.

### `Tarearbol` common syntax

The most widely used function of `Tarearbol` would be probably [`ensure/2`], accepting a job either in a form of anonymous function ir as a MFA-tuple, and a set of options. Options are:

* `attempts` _[default: :infinity]_ number of attemtps before fail, the integer value
* `delay` _[default: 1 msec]_ number of milliseconds between attempts, `1_000` or `1.0` for one second, `:timeout` for five seconds, etc
* `timeout` _[default: 5_000]_ the timeout for the underlying task
* `raise` _[default: false]_ whether `ensure/2` should `raise` on fail
* `accept_not_ok` _[default: true]_ when `false`, only the `:ok` atom or `{:ok, _}`
tuple considered to be valid returned values from the task
* `on_success` _[default: nil]_ the function to be called on successful execution (`arity` ∈ `[0, 1]` or tuple `{Mod, fun}` where fun is of arity zero or one,) for the 1-arity, the result of task execution is passed
* `on_retry` _[default: nil]_ same as above, called _on retries_ after insuccessful attempts or one of `[:debug, :info, :warn, :error]` atoms to log a retry with default logger
* `on_fail` _[default: nil]_ same as above, called when the task finally failed after attempts amount of insuccessful attempts

The usual invocation might look like:

```elixir
case Tarearbol.ensure(fn -> raise "¡?" end, attempts: 1, raise: false) do
  {:error, %{job: _job, outcome: outcome}} ->
    Logger.log("Error. Returned outcome: #{inspect outcome})
  {:ok, result} ->
    result
end
```

The above always returns an error (because the wrapped function does always raise)
and logs the exception.

### Pub_Sub instead of logging

Logging is not always handy when it comes to the real life. One might want to handle the task results from some other process, sending emails on fails, or retrying in a smarter way, or whatever. For that purpose all three callbacks are now publishing a message to subscribers using `Registry` through it’s handy wrapper `Envío` (effective `@since 0.8.1`.)

Channels are:

* `{Tarearbol.Publisher, :error}` to subscribe to task failures only,
* `{Tarearbol.Publisher, :warn}` to subscribe to task retries only,
* `{Tarearbol.Publisher, :info}` to subscribe to task successful executions only,
* `{Tarearbol.Publisher, :all}` to subscribe to everything above.

Now the application using `Tarearbol` might simply add a subscriber into their supervision tree:

```elixir
defmodule MyApp.Subscriber do
  use Envio.Subscriber, channels: [{Tarearbol.Publisher, :error}]
  def handle_envio(message, state) do
    IO.inspect(message, label: "Task failed")
    {:noreply, state}
  end
end
```

From now on _all_ task failures will be handled by the module above.

Happy subscribing!
