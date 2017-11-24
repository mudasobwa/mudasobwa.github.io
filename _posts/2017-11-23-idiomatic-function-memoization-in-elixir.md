---
layout: post
title: "Idiomatic function memoization in Elixir"
description: "How to memoize the function in Elixir"
categories: hacking, elixir
tags: elixir, tricks, dwim
---

Today there was a [question raised on SO](https://stackoverflow.com/questions/47452163/writing-the-function-once-in-elixir).

> “it's possible to write a higher order function ‘once’ which returns a function
> that will invoke the passed in function only once, and returns the previous
> result on subsequent calls?”

>
    var once = (func) => {
      var wasCalled = false, prevResult;
      return (...args) => {
        if (wasCalled) return prevResult;
        wasCalled = true;
        return prevResult = func(...args);
      }
    }

The above is an example of this behaviour in JS, provided by OP. There were
many different approaches given.

The first would be to use an
[`Agent`](https://hexdocs.pm/elixir/Agent.html#content) to store the value
and lookup it before any subsequent execution.

Another one would be to use the
[`Process`](https://hexdocs.pm/elixir/Process.html#content) dictionary when all
the calls are done within the same process, or `ETS`/`DETS` for inter-process
memoization.

I don’t think any of this would be an idiomatic approach. I would introduce the
dedicated [`GenServer`](https://hexdocs.pm/elixir/GenServer.html#content) for
this, that will run the heavy function inside it’s `init` callback:

```elixir
defmodule M do
  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_args) do
    Process.sleep(1_000)
    {:ok, "42"}
  end

  def value() do
    label =
      case start_link() do
        {:error, {:already_started, _}} -> "using memoized value: "
        {:ok, _} ->  "calculated the value: "
      end
    label <> GenServer.call(__MODULE__, :value)
  end

  def handle_call(:value, _from, state) do
    {:reply, state, state}
  end
end
```

to check it’s working as expected, one might use:

```elixir
iex|1> (1..5) |> Enum.each(&IO.inspect(M.value(), label: to_string(&1)))

#⇒ one second delay happens here
#  1: "calculated the value: 42"
#  2: "using memoized value: 42"
#  3: "using memoized value: 42"
#  4: "using memoized value: 42"
#  5: "using memoized value: 42"
```

One might notice, that the first value is printed with a delay,
while all subsequent values are printed immediately.

This is an exact analog of the memoized function from JS, built using
`GenServer`. `GenServer.start_link/3` returns one of the following:

```elixir
{:ok, #PID<0.80.0>}
{:error, {:already_started, #PID<0.80.0>}}
```

and this value is used in the code above to print the leading label.
In the real life it might be just omitted:

```elixir
  def value() do
    start_link()
    GenServer.call(__MODULE__, :value)
  end
```

The `GenServer` will not be resstarted if it’s already started.
We can not bother to check the returned value since we are all set in any case:
if it’s the initial start, we call the heavy function. If the server was already
started, the value is already at fingers in the state.

That might be turned into a helper module, like:

```elixir
defmodule Memoized do
  defmacro __using__(opts) do
    with {:ok, fun} <- Keyword.fetch(opts, :fun),
         {:ok, name} <- Keyword.fetch(opts, :name) do
      block =
        quote do
          use GenServer

          def start_link(_opts \\ []),
            do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

          def init(_args) do
            {:ok, unquote(fun).()}
          end

          def value() do
            start_link()
            GenServer.call(__MODULE__, :value)
          end

          def handle_call(:value, _from, state),
            do: {:reply, state, state}
        end

      quote do: Kernel.defmodule(unquote(name), do: unquote(block))
    end
  end
end

defmodule M do
  use Memoized, name: Fun, fun: fn -> Process.sleep(1_000); 42 end

  def check(), do: Enum.each(1..5, &IO.inspect(Fun.value(), label: to_string(&1)))
end

M.check()
#⇒ 1 second delay
#  1: 42
#  2: 42
#  3: 42
#  4: 42
#  5: 42
```

That’s it.
