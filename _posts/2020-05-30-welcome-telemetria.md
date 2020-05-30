---
layout: post
title: "Telemetría"
description: "The handy helper to work with :telemetria library without an enormous boilerplate needed"
category: hacking
tags:
  - elixir
  - erlang
---

12 Jul 2018 the project `:telemetry` got its [first initial coomit](https://github.com/beam-telemetry/telemetry/commit/8e553556fd683c17f4f97f72972332a4fefd355b). It was pushed by [Arkadiusz Gil](https://github.com/arkgil) but the README [states](https://github.com/beam-telemetry/telemetry#copyright-and-license) _“Telemetry is copyright (c) 2018 Chris McCord and Erlang Solutions”_ and the last commit ATM was made by José Valim.

![Big Brother is Watching You](/img/mascarilla.jpg)

The library introduces itself as:

> _Telemetry_ is a dynamic dispatching library for metrics and instrumentations. It is lightweight, small and can be used in any Erlang or Elixir project.

The main advantage of the library is it’s deadly simple. One _registers_ the event, which _is composed of a numeric value and can have metadata attached to it_, _sends_ it whenever needed, and it would be delivered to a _handle_ which might do whatever, usually it’s kinda logging or something alike. Decoupling business logic and metrics/visibility at its best.

The main disadvantage of using `:telemetry` as is, it requires an enormous amount of boilerplate that hs to be maintained in several places. Refactoring project with intensive usage of telemetry might become a disaster. To change the event name one should amend the code in three different places: event registration, event firing, event handling. If one forgets to register newly created event, firing it would silently succeed, but handler would have been never called. Etc.

---

What I felt was discrepant. I love to have metrics embedded everywhere, but I cannot consent that `grep -r telemetry\.execute ./{lib,test}/**/*.ex*` is something I want to inject into my build pipeline. So I came up with a handy wrapper for `:telemetry` called `Telemetría`. I pursued the following goals:

- simple way to attach `:telemetry` to functions _and_ expressions
- automatic event name generation based on the context
- compile-time generation of config to register all and only actual events
- automatic inclusion of _VM_ and system metrics via `:telemetry_poller`
- custom configurable handlers for different cases, based not only on event name
- full support for releases
- zero boilerplate.

### Intro

The project is currently in the kindergarten, but it’s already fully usable. All you need to start using it (and hence to jump on our telemetry users wagon,) would be to modify `mix.exs` to include `:telemetria` _and_ to provide a minimal config.

```elixir
# mix.exs
def project do
  [
    ...
    # needed for autogeneration of events
    compilers: [:telemetria | Mix.compilers()]
  ]
end

def deps do
  [
    ...
    {:telemetria, "~> 0.5"}
  ]
end

```

The full list of supported options might be always found in [docs](https://hexdocs.pm/telemetria/Telemetria.html#module-options), the only mandatory one is `:otp_app`.

```elixir
config :telemetria,
  otp_app: :my_app,
  polling: [enabled: true]
```

With these settings, the VM and system metrics would be delivered to the default handler, which roughly logs them with `:info` level every five seconds.

### Helpers

`Telemetría`’s interface is also very simple. It provides three macros and one annotation to handle `:telemetry` events. The macros are `deft/2`, `defpt/2`, and `t/2` to wrap functions, private functions, and custom expressions, with `:telemetry` events. Basically, all three are [aspects](https://en.wikipedia.org/wiki/Aspect-oriented_programming), that are expanded in _grab metrics → make wrapped call → grab metrics, send event_ triple. The annotation `@telemetria true` is essentially the same as changing the annotated call to `deft/2`/`defp/2`. Consider the following example.

#### With Macro 

```elixir
defmodule Geom do
  import Telemetria

  @spec circle_area(float()) :: float()
  deft circle_area(radius),
    do: 2 * 3.14 * radius
end
```

Once compiled, this code would emit event `[:geom, :circle_area]` upon calls to `Geom.circle_are/1`

```elixir
iex|1> Geom.circle_area 2.0

14:59:49.686 [info] [event: [:geom, :circle_area],
  measurements: %{consumed: 3162, reference: "#Reference<0.12.34.56>",
  system_time: [system: 1590843589680306588,
                monotonic: -576460720784457,
                utc: ~U[2020-05-30 12:59:49.681885Z]]},
  metadata: %{context: [], env: #Macro.Env<aliases: [], context: nil, ...},
  config: #PID<0.314.0>]

#⇒ 12.56
```

#### With Annotation

```elixir
defmodule Geom do
  use Telemetria

  @telemetria true 
  @spec circle_area(float()) :: float()
  def circle_area(radius),
    do: 2 * 3.14 * radius
end
```

This code does effectively the same as the code above.

### Compiler

Also not mandatory, working with `Telemetría` would be easier if you add the custom compiler to the list of compilers in your `mix.exs` 

```ruby
def project do
  [
    ...
    compilers: [:telemetria | Mix.compilers()]
  ]
end
```

The compiler collects added/removed events, maintains a manifest file behind the scene to always have an up-to-date list of events and provides diagnostics to the main _Elixir_ compiler.

It also builds and exposes JSON config that might be found in `config` folder locally and might be used as a JSON config within releases. `Telemetría` understands it with a config provider that is included.

### Config

The configuration allows:

- global enabling/disabling the telemetry (purging on compiler level)
- enabling _VM/system telemetry polling_, with an interval
- elixir configuration of additional events, directly handled with `:telemetry`
- json configuration of additional events (useful for releases)
- setting your own custom handler for telemetry events

See [`Options`](https://hexdocs.pm/telemetria/Telemetria.html#module-options) section in the documentation for more details.

### Internals

The deep diving into implementation details are surely out of scope of this ad writing, but a couple of words to be said about how is it built.

If one is interested in easy jumping into adding metrics to their application, please stop reading here and refer to the code snippets in the chapter entitled _Intro_.

If, on the opposite, you are interested in some tricks and tweaks, here is the list of what might be of your interest.

- [★](https://github.com/am-kantox/telemetria/blob/master/lib/options.ex) always valid, auto-documented options through [`nimble_options`](https://hexdocs.pm/nimble_options)
— [★](https://github.com/am-kantox/telemetria/blob/master/lib/telemetria.ex#L110-L111) annotation [implementation](https://github.com/am-kantox/telemetria/blob/master/lib/telemetria/module_hooks.ex) through `@on_definition` and `@before_compile` [_Module Compile Callbacks_](https://hexdocs.pm/elixir/Module.html#module-compile-callbacks)
— [★](https://github.com/am-kantox/telemetria/blob/master/lib/telemetria/application.ex#L24-L26) starting the application in phases to ensure full availability of `:telemetry` before anything
- [★](https://github.com/am-kantox/telemetria/blob/master/lib/mix/tasks/compile/telemetria.ex) implementation of custom compiler for _Elixir_ to collect events and maintain the manifest file

---

Happy metric-measuring!