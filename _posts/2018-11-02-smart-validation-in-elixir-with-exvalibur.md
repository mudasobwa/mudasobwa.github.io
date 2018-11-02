---
layout: post
title: "Smart Validation In Elixir With Exvalibur"
description: "Use generated module with pattern matching clauses and guards to validate any input given as a map"
category: hacking
tags:
  - elixir
  - tricks
  - tools
---

As documentation states, [`Exvalibur`](https://hexdocs.pm/exvalibur/0.3.1/Exvalibur.html) is the generator for blazingly fast validators of maps based on sets of predefined rules.

Generally speaking, one provides a list of rules in a format of a map:

```elixir
rules = [
  %{matches: %{currency_pair: "EURUSD"},
    conditions: %{rate: %{min: 1.0, max: 2.0}}},
  %{matches: %{currency_pair: "USDEUR"},
    conditions: %{rate: %{min: 1.2, max: 1.3}}},
]
```

and calls `Exvalibur.validator!/2`. The latter produces a validator module with as many clauses of `valid?/1` function as we have rules above (plus one sink-everything clause.) Once generated, the `valid?/1` function might be called directly on the input data, providing blazingly fast validation based completely on pattern matching and guards.

This makes sense when the input coming from the third party / user requires validation of kind “if this field has a value _foo_, and that field has a value _bar_, and that failed might have a numeric value in a range from _this_ to _that_, consider it’s valid.”

## Workflow

As stated above, the first step would be to feed `Exvalibur.validator!/2` with a list of rules, each being a map having two keys: `matches` and `conditions`. Matches are used to generate different clauses of the validator and conditions are converted to guards within these clauses.

The module might be generated using [`Flow`](https://hexdocs.pm/flow) (by providing `flow: true` option in call to `validator!` to fasten the parsing of relatively huge rulesets.

The name of generated module is to be passed as `module_name: MyApp.MyValidator` option where the value is an atom for the name of the generated module.

By default, rules are _merged_ into the existing ruleset. To replace the ruleset one might use `merge: false` option. The ruleset is hard-compiled into the module in the form of `term_to_binary(rule) => rule` map and is accessible via call to `MyApp.MyValidator.rules/0`.

## Usage

Assuming we already have the validator module compiled, the typical usage would be:

```elixir
case MyApp.MyValidator.valid?(input) do
  {:ok, _validated_fields} ->
    input
  :error ->
    Logger.warn("Wrong input!")
    nil
end
```

## Matches And Guards

At the moment, rules do not support matching patterns (yet,) only static values are allowed. In a nutshell, `%{matches: %{foo: 42}}` rule would generate `def valid?(%{foo: 42})` clause and the condition `%{conditions: %{foo: {eq: 42}}}` would generate `def valid(%{foo: foo}) when foo == 42` clause.

## Guards

Out of the box `Exvalibur` provides [`Exvalibur.Guards.Default`](https://hexdocs.pm/exvalibur/0.3.1/Exvalibur.Guards.Default.html#content) module implementing the following set of guards:

- `eq(var, val)` → guard for conditions like `%{eq: 1.0}`, exact equality
- `greater_than(var, val)` → guard for conditions like `%{greater_than: 1.0}`, like `min/2`, but the inequality is strict
- `less_than(var, val)` → guard for conditions like `%{less_than: 1.0}`, like `max/2`, but the inequality is strict
- `max(var, val)` → guard for conditions like `%{max: 2.0}`, implies actual value is less or equal than the parameter
- `min(var, val)` → guard for conditions like `%{min: 1.0}`, implies actual value is greater or equal than the parameter
- `max_length(var, val)` → guard for conditions like `%{max_length: 10}`, checks the byte length of the binary parameter
- `min_length(var, val)` → guard for conditions like `%{min_length: 10}`, checks the byte length of the binary parameter
- `one_of(var, val)` → guard for checking the includion in the list like `%{one_of: [42, 3.14]}`
- `not_one_of(var, val)` → guard for checking the excludion from the list like `%{not_one_of: [42, 3.14]}`

If this set is not enough, one might implement their own set of guards. The guard implementation should be the function of arity 2, returning the AST which is valid as Elixir guard, e. g. suitable for use in guard expressions, exactly as [`Kernel.defguard/1`](https://hexdocs.pm/elixir/master/Kernel.html#defguard/1) does. Below is shown the typical implementation for such a module.

```elixir
defmodule MyApp.Guards do
  import Exvalibur.Guards.Default, except: [min_length: 2, max_length: 2]

  def min_length(var, val) when is_integer(val) do
    quote do
      is_bitstring(unquote(var)) and bytesize(unquote(var)) >= unquote(val)
    end
  end

  def bullshit(var, val) when is_integer(val) do
    quote do
      is_bitstring(unquote(var)) and unquote(val) == "bullshit"
    end
  end
end
```

## Coming Soon

- allow generic patterns in matches, like `%{matches: %{currency_pair: <<"EUR", _ :: binary-size(3)}}`
- allow transformers in rules, like `%{transform: {MyMod, :to_changeset}}` applying to _validated_ input, so that one might use the validator as a mapper
- allow the ruleset given in CSV (or some kind of external format.)

Several Imagine the application that receives some data from the external source. For the sake of an example let’s assume the data is currency rates stream.

The application has a set of rules to filter the incoming data stream. Let’s say we have a list of currencies we are interested in, and we want only the currencies from this list to pass through. Also, sometimes we receive invalid rates (nobody is perfect, our rates provider is not an exception.) So we maintain a long-lived validator that ensures that the rate in the stream looks fine for us and only then we allow the machinery to process it. Otherwise we just ignore it.

Happy validating!
