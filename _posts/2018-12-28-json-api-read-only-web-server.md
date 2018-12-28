---
layout: post
title: "Plug in JSON API Readonly Webserver"
description: "How to expose some read-only data from the already existing Elixir application with zero code"
category: hacking
tags:
  - elixir
  - tricks
---

All our microservices expose kinda heartbeat interfaces to _Consul_ which we use as a health check. Some of the services also provide some access to the internal data they deal with. I am not talking about their main duties: those are very well handled by `RabbitMQ` and `Redis`.

Just sometimes it makes sense to export data that is indeed there to other services that might require it. For instance, I want to completely get rid of _Redis_ in favour of in-house solution for key-value pair storage as we successfully did exactly one year ago with _PubSub_.

So instead of re-inventing a wheel with every new microservice, I decided to create a pluggable library, that might be serving any arbitrary data from any application with zero code (if we don’t count 5-LoCs `config.exs`.)

The solution is based on this [Dave Thomas’ tweet](https://twitter.com/pragdave/status/1077775018942185472?s=20).

## Lightweight Json API Server, Embeddable Into Any Project

**Camarero** is a ready-to-use solution to add some JSON API functionality to the existing application, or to implement the read-only JSON API from the scratch when more sophisticated (read: _heavy_) solutions are not desirable. Below is the typical picture of how _Camarero_ is supposed to be plugged in.

![Camarero Ties](https://raw.githubusercontent.com/am-kantox/camarero/master/stuff/camarero.png)

It is designed to be very simple and handy for read-only web access to the data. It might indeed be a good candidate to replace _Redis_ or any other key-value store. **It is blazingly, dead fast.**

Here are response times for the 1M key-value storage behind.

![1M key-value storage lookup: 10μs±](https://raw.githubusercontent.com/am-kantox/camarero/master/stuff/1M.png)

Yes, that’s it. The response time for the request against one million key-values store takes _dozens of microseconds_.

## Implementation details

**Camarero** is supposed to be plugged into the functional application. It handles the configured routes/endpoints by delegating to the configured handler modules. The simplest configuration might looks like:

```elixir
config :camarero,
  carta: [Camarero.Carta.Heartbeat],
  root: "api/v1"
```

The above is the default; `/api/v1` would be the root of the web server, single `Camarero.Carta.Heartbeat` module is declared as handler. The handlers might be also added dynamically by calls to `Camarero.Catering.route!`.

### Handlers

_Handler_ is a module implementing `Camarero.Plato` behaviour. It consists of methods to manipulate the conteiner behind it. Any module might implement this behaviour to be used as a handler for incoming HTTP requests.

There is also `Camarero.Tapas` behaviour scaffolding the container implementation inside `Camarero.Plato`.

The default implementation using `%{}` map as a container, looks pretty simple:

```elixir
defmodule Camarero.Carta.Heartbeat do
  use Camarero.Plato
end
```

This is an exact exerpt from `Heartbeat` module that comes with this package. For more complicated/sophisticated usages please refer to the [documentation](https://hexdocs.pm/camarero).

All the methods from both `Camarero.Tapas` and `Camarero.Plato` default implementations are overridable. E. g. to use the custom route for the module (default is the not fully qualified underscored module name,) as well as custom container, one might do the following:

```elixir
defmodule Camarero.Carta.Heartbeat do
  use Camarero.Plato, container: %MyStructWithAccessBehaviour{}

  @impl true
  def plato_route(), do: "internal/heartbeat"
end
```

### Web server config

**Camarero** runs over _Cowboy2_ with _Plug_. To configure _Cowboy_, one might specify in the `config.exs` file:

```elixir
config :camarero,
  cowboy: [port: 4001, scheme: :http, options: []]
```

## Installation

```elixir
def deps do
  [
    {:camarero, "~> 0.1"}
  ]
end
```

Happy serving!
