---
layout: post
title: "Iteraptor → Unforeseen utilization"
description: "Using Iteraptor in test environment to test deeply nested maps/lists passed as JSON"
category: hacking
tags:
  - elixir
  - tricks
---

[**`Iteraptor`**](https://github.com/am-kantox/iteraptor) library was initially conceived as a helper to iterate/map/reduce deeply nested enumerables, like maps, keywords and lists. Today I occasionally discovered a new—initially undesired—application for it.

I was introducing [property-based testing](https://elixir-lang.org/blog/2017/10/31/stream-data-property-based-testing-and-data-generation-for-elixir/) for [`Camarero`](https://github.com/am-kantox/camarero). The latter serves JSON, so the integration test looked like

```elixir
defmacrop key_value, do: quote(do: map_of(key(), map_or_leaf()))

test "properly handles nested terms" do
  check all term <- key_value(), max_runs: 25 do
    Enum.each(term, fn {k, v} ->
      Camarero.Carta.Heartbeat.plato_put(k, v)
      conn =
        :get
        |> conn("/api/v1/heartbeat/#{k}")
        |> Camarero.Handler.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body |> Jason.decode!() |> Map.get("value") == v
    end)
  end
end
```

Here is the thing: the above fails because atoms are jsonified (jsonificated?) as binaries / strings. When we need to check if the _real data_ is sent as JSON properly, it might quickly become cumbersome to check the outcome. Also, there would be issues to produce JSON out of keywords because keywords are nothing but lists of 2-elements tuples and tuples are not JSON-serializable.

Luckily enough, I had already the library to modify deeply nested terms, so I decided to add the new function to it. Here is it.

```elixir
@spec jsonify(Access.t(), opts :: list()) :: %{required(binary()) => any()}
def jsonify(input, opts \\ [])

def jsonify([{_, _} | _] = input, opts),
  do: input |> Enum.into(%{}) |> jsonify(opts)

def jsonify(input, opts) when is_list(input),
  do: Enum.map(input, &jsonify(&1, opts))

def jsonify(input, opts) when not is_map(input) and not is_list(input),
  do: if(opts[:values] && is_atom(input), do: to_string(input), else: input)

def jsonify(input, opts) do
  Iteraptor.map(
    input,
    fn {k, v} when is_list(k) ->
      {k |> List.last() |> to_string(), jsonify(v, opts)}
    end,
    yield: :all
  )
end
```

It converts keywords to maps and atom keys to strings, and—optionally (if `values: true` is passed as the second parameter)—converts atoms to binaries in values.

I am posting this code here mostly to promote `Iteraptor` itself to show how easy it would be to transform any nested term with it.

Turning back to the original intent, to test the JSON response for deeply nested list/map/term one would tell `mix` to include `Iteraptor` package for `:test` environment only:

```elixir
  {:iteraptor, "~> 1.0", only: :test}
```

and use somewhat like the code below to deep-compare the JSON against original data:

```elixir
  term = Iteraptor.jsonify(term, values: true)

  conn =
    :get
    |> conn("/api/v1/my_term")
    |> MyJsonEndpoint.call(@opts)

  assert conn.resp_body |> Jason.decode!() == term
end
```

Whether one needs to be able to transparently serve terms that might include keywords, `Iteraptor` should be included as dependency in all environments and the call to `Iteraptor.jsonify(term)` should be done before passing the term to JSON encoder. `values: true` parameter is not needed in this scenario since JSON serializers are able to take care of atoms.

Happy testing!
