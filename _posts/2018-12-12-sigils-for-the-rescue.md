---
layout: post
title: "Sigils To The Rescue"
description: "Exvalibur does now allow custom guards and pattern matching of values"
category: hacking
tags:
  - elixir
  - tricks
  - tools
---

As I continue to work on [`Exvalibur`](https://hexdocs.pm/exvalibur/Exvalibur.html), the generator for blazingly
fast validators of maps based on sets of predefined rules, I have implemented custom guards and pattern matching
of values. Now one might specify rules as

```elixir
rules = [
  %{matches: %{currency_pair: ~Q[<<"EUR", _::binary>>], valid: ~Q[valid]},
    conditions: %{rate: %{min: 1.0, max: 2.0}},
    guards: ["is_boolean(valid)"]
  }]
```

What’s going on here? The above will match the map, having keys `currency_pair` and `valid` (specified explicitly)
and key `rate` specified implicitly through the `condition`. The resulting validator module will contain the
following positive validation clause:

```elixir
def valid?(%{currency_pair: <<"EUR", _::binary>>, valid: valid} = mâp)
    when rate >= 1.0 and rate <= 2.0 and is_boolean(valid) do

  {:ok,
    %{currency_pair: mâp[:currency_pair],
      valid: mâp[:valid],
      rate: mâp[:rate]}}

end
```

As one can see, the quoted expression are to be used for both pattern match declaration _and_ introducing
the variable to be used in custom guard. The reason is we cannot just put an arbitrary expression as a map value.
That said, `rules = [%{currency_pair: <<"EUR", _::binary>>}]` won’t pass the compilation stage.

To quote the expression we use the [custom sigils](https://elixir-lang.org/getting-started/sigils.html#custom-sigils).

---

We ultimately want to support interpolation inside this sigil to allow dynamic expressions

```elixir
def rule_for_currency(<<currency::binary-size(3), _::binary>>) do
  [%{currency_pair: ~q[<<"#{currency}", _::binary>>]}]
end
```

Luckily enough, there is the Elixir core where we might borrow the implementation from, slightly modified.
I would post here the most interesting clause, the rest might be easily found in the source code repository.

```elixir
defmacro sigil_q({:<<>>, meta, pieces}, []) do
  tokens =
    case :elixir_interpolation.unescape_tokens(pieces) do
      {:ok, unescaped_tokens} -> unescaped_tokens
      {:error, reason} -> raise ArgumentError, to_string(reason)
    end

  quote do
    Code.string_to_quoted!(
      unquote({:<<>>, meta, tokens}), unquote(meta)
    )
  end
end
```

We delegate the interpolation to Elixir core, and then construct an AST out of this string. Easy-peasy.

For plain variables, as in the first example, `~Q[var]` works exactly as `Macro.var(var, nil)`, constructing an AST tuple
like `{:var, [line: 1], nil}`.

## Conclusion

Custom sigils are nifty and I always wanted to find the application for one. Here I go.

Happy custom validating!
