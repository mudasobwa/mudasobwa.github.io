---
layout: post
title: "Envío as a reincarnation of GenEvent²"
description: "Publishing and subscribing to events with ease"
category: hacking
tags:
  - elixir
  - tricks
  - tools
---

[**`Envío`**](https://hexdocs.pm/envio) is kinda `GenEvent²`, the modern
idiomatic pub-sub implementation of event passing.

In version `1.4`, Elixir core team deprecated
[`GenEvent`](https://hexdocs.pm/elixir/master/GenEvent.html) and introduced
[`Registry`](https://hexdocs.pm/elixir/master/Registry.html). The reason behind
that is `GenEvent` is unable to exploit concurrency out of the box and
processes multiple handlers serially. This was done on purpose because
`GenEvent` was mainly used for logging stuff and one probably wants the
log entries to appear in order as they were emitted. This is not the case for
most event applications, though.

While [José Valim suggests](http://blog.plataformatec.com.br/2016/11/replacing-genevent-by-a-supervisor-genserver/)
using a simple approach involving a `Supervisor` with many instances of
`GenServer` acting as subscribers (this is how it was done in [`ExUnit`](https://github.com/elixir-lang/elixir/commit/e7f2d14036121916fffafda4be9a2137ee39b5bd),)
this way requires a load of redundant boilerplate and it is not as transparent
for the developer as it could be.

That all forced me to introduce [**`Envío`**](https://hexdocs.pm/envio) package.
It is a drop-in replacement for `GenEvent`'like functionality, built on top
of [`Registry`](https://hexdocs.pm/elixir/master/Registry.html) and supporting
both synchronous and asychronous subscriptions (called `:dispatch` and `pub_sub`
respectively, with names gracefully stolen from `Registry` vocabulary.)

With this in mind, the main goal was to drastically simplify creation of both
publishers and subscribers, hide the boilerplate and make things work out of the
box with a minimal amount of additional code required.

**`Envío`** also manages it’s own registry, `Envio.Registry` to deliberately
relieve the amount of code you need to create as a boilerplate.

### Application example

One of most typical examples of how **`Envío`** is supposed to be used, would be
asynchronous publishing notifications to `Slack`. Here is the _whole_ code
needed to provide this functionality in your application:

```elixir
# lib/slack_publisher.ex
defmodule SlackPublisher do
  # use SlackPublisher.broadcast(term()) anywhere to publish
  use Envio.Publisher, channel: :main
end

# config/prod.exs
config :envio, :backends, %{
  Envio.Slack => %{
    {SlackPublisher, :main} => [
      hook_url: {:system, "SLACK_ENVIO_HOOK_URL"}
    ]
  }
}
```

That’s it. Once environment variable `SLACK_ENVIO_HOOK_URL` is setup to point
to any [Slack application](https://api.slack.com/slack-apps) enabled for your
team, you are all set. Do anywhere in your code:

```elixir
SlackPublisher.broadcast(%{
  title: "Foo changed",
  level: :info,
  foo: %{bar: [baz: [42, 3.1415]]}})
```

And receive a notification in your slack channel.

### Complicated workflows

**`Envío`** simplifies the creation of both publishers and subscribers
hiding all the boilerplate behind `use Envio.Publisher` and
`use Envio.Subscriber`. The syntax of [`Envio.Publisher`](https://hexdocs.pm/envio/Envio.Publisher.html#content) is shown above in the
`Slack` example; for subscriber it’s nearly the same:

```elixir
defmodule MySubscriber do
  use Envio.Subscriber, channels: [{MyPublisher, :featured}]

  def handle_envio(message, state) do
    {:noreply, state} = super(message, state)
    IO.inspect({message, state}, label: "Received")
    {:noreply, state}
  end
end
```

[`handle_envio/1`] is the only callback defined for this behaviour. Implement
it to whatever you need and all the messages sent to `:featured` channel by
`MyPublisher` will now be handled.

For `:dispatch` type of the subscription, it’s even easier: just put

```elixir
Envio.register(
  {MySubscriber, :on_envio}, # the function of arity 2 must exist
  dispatch: %Envio.Channel{source: Publisher, name: :featured}
)

```

anywhere in your code and start receiving messages synchronously.

### Backends

**`Envío`** introduces a concept of backends. `Slack` mentioned above would be
one of them, shipped with a package itself. Backends are supposed to implement
[`Envio.Backend`](https://hexdocs.pm/envio/Envio.Backend.html#content) behaviour
currently consisting of the only function `on_envio/2`. The backend, once
specified in the configuration file, will be automatically plugged into the
internally managed `Registry` and subscribed to the channel set in config.

```elixir
config :envio, :backends, %{
  Envio.MyBackend => %{
    {MyPublisher, :featured} => [
      callback_url: {:system, "SLACK_ENVIO_HOOK_URL"},
      callback_headers: %{"X-Envio-From" => "MyPublisher"}
    ]
  }
}
```

`Envio.MyBackend` is expected to exist and impelement `Envio.Backend`.
The options from the config file will be passed alongside message/payload
as a second parameter. For instance, the `Slack` implementation does literally
the following:

```elixir
  @impl true
  def on_envio(message, meta) do
    case meta do
      %{hook_url: hook_url} ->
        HTTPoison.post(
          hook_url,
          format(message),
          [{"Content-Type", "application/json"}]
        )
      _ -> {:error, :no_hook_url_in_envio}
    end
  end
```

That’s it. ¡Envíos feliz!
