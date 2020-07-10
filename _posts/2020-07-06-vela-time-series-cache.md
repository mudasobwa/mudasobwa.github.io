---
layout: post
title: "Vela → Time Series Cache"
description: "The library providing easy maintaining of the self-expiring cache for several time series"
category: hacking
tags:
  - elixir
  - erlang
---

Here in _Fintech_, we frequently deal with a huge load of rates for different currency pairs. We receive them from so-called _Liquidity Providers_, and each one has its own understanding of how the rates will be tomorrow, in a month, or even in six years. Some have more credibility, some deliver a holy crap for some pairs. And we need to decide which one is the best one so that we can show it to our customers. We literally need to _specially adapt our bills to separate mud and silt from the food we eat_, like flamingos.

![Flamingos](/img/flamingos.jpg)

> Flamingos filter-feed on brine shrimp and blue-green algae as well as insect larvae, small insects, mollusks and crustaceans making them omnivores. Their bills are specially adapted to separate mud and silt from the food they eat, and are uniquely used upside-down. The filtering of food items is assisted by hairy structures called lamellae, which line the mandibles, and the large, rough-surfaced tongue. — https://en.wikipedia.org/wiki/Flamingo#Feeding

This necessity gave a birth to [`Vela`](https://hexdocs.pm/vela) library, the cache-like state holder for several _series_. It sieves the incoming data and keeps last _N_ non-stale correct values for each serie.

Imagine we consume rates for three currency pairs. The basic definition of `Vela` would be

```elixir
defmodule Pairs do
  use Vela,
    eurusd: [sorter: &Kernel.<=/2],
    eurgbp: [limit: 3, errors: 1],
    eurcad: [validator: Pairs]

  @behaviour Vela.Validator

  @impl Vela.Validator
  def valid?(:eurcad, rate), do: rate > 0
end
```

### Updating

[`Vela.put/3`](https://hexdocs.pm/vela/Vela.html#put_in/2) function will:

- call `validator` on the value if it’s defined (see _Validation_ section below)
- insert the value into the serie if validation passed, or into `:__errors__` otherwise
- call the `sorter` for the serie if it’s defined (otherwise the value will be inserted on top, _FILO_, see _Sorting_ section below)
- and return the updated `Vela` instance back

```elixir
iex|1 ▶ pairs = %Pairs{}
iex|2 ▶ Vela.put(pairs, :eurcad, 1.0)
#⇒ %Pairs{..., eurcad: [1.0], ...}
iex|3 ▶ Vela.put(pairs, :eurcad, -1.0)
#⇒ %Pairs{__errors__: [eurcad: -1.0], ...}
iex|4 ▶ pairs |> Vela.put(:eurusd, 2.0) |> Vela.put(:eurusd, 1.0)
#⇒ %Pairs{... eurusd: [1.0, 2.0]}
```

Under the hood `Vela` implements [`Access`](https://hexdocs.pm/elixir/Access.html) behaviour, making it possible to access series with standard nested update functions and macros in [`Kernel`](https://hexdocs.pm/elixir/Kernel.html), such as [`Kernel.get_in/2`](https://hexdocs.pm/elixir/Kernel.html#get_in/2), [`Kernel.put_in/3`](https://hexdocs.pm/elixir/Kernel.html#put_in/3), [`Kernel.update_in/3`](https://hexdocs.pm/elixir/Kernel.html#update_in/3), [`Kernel.pop_in/2`](https://hexdocs.pm/elixir/Kernel.html#pop_in/2), and [`Kernel.get_and_update_in/3`](https://hexdocs.pm/elixir/Kernel.html#get_and_update_in/3).

### Validations

Validator might be declared in several different ways.

- external function of arity 1, passed as `&MyMod.my_fun/1`, it will receive a value only
- external function of arity 2, passed as `&MyMod.my_fun/2`, it will receive `serie, value` arguments
- module implementing [`Vela.Validator`](https://hexdocs.pm/vela/Vela.Validator.html#content) behaviour
- `threshold` configuration parameter, used with optional `compare_by` parameter, see _Comparison_ section below

If validation passes, the value gets inserted into the serie, otherwise `{serie, value}` tuple gets added to `:__errors_`. 


### Comparison

Values stored in the series might be any. To compare them, one should pass `compare_by` keyword argument to the serie definition (unless the terms might be natively compared with `Kernel.</2`) of type `(Vela.value() -> number())`. Default is `& &1`.

Techically, one might also pass `comparator` keyword argument to calculate deltas (`min`/`max`) values; e. g. by passing `Date.diff/2` as comparator, one would receive correct deltas back.

Another handy option would be to pass a `threshold` keyword argument which specifies the ratio of new value to `{min, max}` interval for the new value to be considered valid. Because it’s given in percentages, the validation does not go through `comparator`, but it still uses `compare_by`. For example, to specify a threshold for datetimes, one would specify `compare_by: &DateTime.to_unix/1` _and_ `threshold: 1`, resulting in new values would be allowed if and only they are within `±band` interval from the current values.

After all, one might use `Vela.equal?/2` to compare two velas. If values have `equal?/2` or `compare/2`, these functions would be used, otherwise the dumb `==/2` comparison would take a place.

### Getting Values

To operate `Vela`, one typically starts with `Vela.purge/1` which removes all the legacy values, if `validator` deals with timestamps. Then one might call `Vela.slice/1` that would return back the keyword with series as keys _and_ top values as their values.

`get_in/2`/`pop_in/2` might also be used for low-level to the top value of any serie.

### Application

`Vela` is extremely useful as the time-series cache used as a state in the `GenServer`/`Agent`. We don’t want to use legacy rates, so we simply maintain the state as a `Vela`, with `validator` looking like

```elixir
@impl Vela.Validator
def valid?(_key, %Rate{} = rate),
  do: Rate.age(rate) < @death_age
```

and `Vela.purge/1` takes care about removing legacy. `Vela.slive/1` given an access to the most recent, actual rates, and we also might give back the history of any valid rate back to several values by request.

---

Happy timeseriesing!