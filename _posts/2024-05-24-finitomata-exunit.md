---
layout: post
title: "Make your library test-friendly"
description: "Finitomata ships with a testing framework"
category: hacking
tags:
  - elixir
---

_Elixir_ community is great. The average quality of the libraries is superb. We all know that and we all love that. Right?

Well, yes. But no.

## Shall I write tests?

While the code is usually indeed enormously awesome, and we all take it as granted, the developers effort in helping to test
the functionality provided by the library is usually miserable. Yes, I said that. Sorry, but it’s true. I hope that everyone
here understands I am not insulting nor depreciating the value of the brilliant work done by developers. I am only calling for
the better support we all kinda miss.

Just a couple of examples, in a random order.

### `exq` — the job processing library

The library is really good, in the first place. It’s easy to tackle and it does its job (pun intended) perfectly.
But (there is always a but in whatever I am saying) let’s see how would I test my code using this library.

Sure thing, the library [provides mocks](https://hexdocs.pm/exq/readme.html#testing) to avoid polluting `redis` in `:test`.
Which is already great, thanks for that. And… that’s it.

What testing support would I expect from such a library? OK. It’s a job processing, which is a deferred asynchronous execution
of some code, right? What would I test for this kind of functionality? I personally would love to test that once I have the job
spawned, sooner or later I’d get the result of the execution on hand. In a pseudo-elixir-code, it’d be somewhat alongside

```elixir
test_job MyWorker, "my_queue", ["arg1", "arg2"] do
  with job <- enqueue(self()) do
    assert_in_delta execution_time(job), 0.1, 0.1
    assert result(job) == {:ok, "some"}
    assert_sent MyJobListener, :some_message_job_sends_to_listener
  end
end
```

That kind of stuff. I do not have an access to `exq` internals (and I obviously should not,) hence I expect the library
(which apparently does have an access to its internals) to provide me _test helpers_ like this `assert_sent/2` above.
Measurements, too. The result, which would be discarded in the real execution, but hey, everything is an expression,
expose it to me for my checks!

I am mot saying I am unable to handle all that myself, I surely can. But it would require an enormous boilerplate. Let alone
execution time which I doubt I have any access to. Once again, the library itself performs fantastic, but testing my code
against it is …ahem… cumbersome.

### `ecto` — the database wrapper and query generator

I am staying here awaiting for all these rotten eggs thrown to me. `ecto` is excellent, I hear voices. It surely is.
But [testing](https://hexdocs.pm/ecto/testing-with-ecto.html) it is a nightmare.

What do I want to actually test? I could not trust more `ecto` authors. I am not to test that `Repo.insert/2` works
as expected. Rather I am to test **my silly code**. Which means, I’d like to have helpers like

```elixir
test_query MyMod, :get_posts do
  assert_tables [:user, :post]
  assert_records_number <= 100
end

test_changeset MyMod, :changeset do
  refute_when empty(:posts)
  refute_when date_before(~D[2024-01-01])
end
```

Yes, I understand these examples are contrived, but I barely do anything with CRUD/DB and I am pretty sure these examples
can be extended and improved by any experienced web develop (who I am not,) but not discarded.

### `jason` — a blazing fast JSON parser and generator

Anyone who used _json_ with huge structures, would tell how it’s annoying to validate the result has been built properly.
Say, you have a complicated result assembly, from different sources. Deeply nested. Yet `Jason` (being more than awesome
in its core, architecture, all that `@derive` and stuff) does not provide a single helper to validate minor result changes
at all. How about

```elixir
test_json MyMod, :get_json do
  assert_diff Post.get(1), Post.get(2), %{address: %{location: %{street: ["Nevsky", "Rambla"]}}}
  assert_presence Post.get(3), %{address: %{location: %{street: "Rambla"}}}
  refute_presence Post.get(3), %{address: %{location: %{street_2: _}}}
end
```

I even was forced to introduce [`Estructura.diff/3`](https://hexdocs.pm/estructura/Estructura.html#diff/3) for such kind
of tests, but hey, how about it came with the library itself?

---

OK, enough is enough, I hate blaming anyone for not doing OSS as I wish they did, and this is all **not about blaming**.

**Hereby I call the developers to improve this aspect of their libraries’ codebases.**

---

## `Finitomata.ExUnit`

My lovely library [`Finitomata`](https://hexdocs.pm/finitomata) comes with a testing framework, and the only purpose of this 
rant is to share how it’s not hard and how we could have simplified the life of developers using our library at next to zero cost.

Below is the excerpt from its documentation.

There are several steps needed to enable extended testing with `Finitomata.ExUnit`.

In the first place, `mox` dependency should be included in your `mix.exs` project file

  ```elixir
    {:mox, "~> 1.0", only: [:test]}
  ```

Then, the `Finitomata` declaration should include a listener. If you already have the
listener, it should be changed to `Mox` in `:test` environment, and the respecive `Mox`
should be defined somewhere in `test/support` or like

  ```elixir
  @listener (if Mix.env() == :test, do: MyFSM.Mox, else: MyFSM.Listener)
  use Finitomata, fsm: @fsm, listener: @listener
  ```

  If you don’t have an actual listener, the special `:mox` value for `listener` would do
    everything, including an actual `Mox` declaration in `test` environment.

  ```elixir
  use Finitomata, fsm: @fsm, listener: :mox
  ```

The last thing you need, `import Mox` into your test file which also does
`import Finitomata.ExUnit`. That’s it, now your code is ready to use `Finitomata.ExUnit`
fancy testing.

  ## Example

  Consider the following simple FSM

  ```elixir
  defmodule Turnstile do
    @fsm ~S[
      ready --> |on!| closed
      opened --> |walk_in| closed
      closed --> |coin_in| opened
      closed --> |switch_off| switched_off
    ]
    use Finitomata, fsm: @fsm, auto_terminate: true

    @impl Finitomata
    def on_transition(:opened, :walk_in, _payload, state) do
      {:ok, :closed, update_in(state, [:data, :passengers], & &1 + 1)}
    end
    def on_transition(:closed, :coin_in, _payload, state) do
      {:ok, :opened, state}
    end
    def on_transition(:closed, :off, _payload, state) do
      {:ok, :switched_off, state}
    end
  end
  ```

Of course, in the real life, one would not only collect the total number of passengers passed
in the state, but also validate the coin value to let in or fail a transition, but
for the demonstration purposes this one is already good enough.

We now want to test it works as expected. Without `Finitomata.ExUnit`, one would
write the test like below

  ```elixir
  # somewhere else → Mox.defmock(Turnstile.Mox, for: Finitomata.Listener)
  test "standard approach" do
    start_supervised(Finitomata.Supervisor)

    fini_name = "Turnstile_1"
    fsm_name = {:via, Registry, {Finitomata.Registry, fini_name}}

    Finitomata.start_fsm(Turnstile, fini_name, %{data: %{passengers: 0}})

    Finitomata.transition(fini_name, :coin_in)
    assert %{data: %{passengers: 0}}} = Finitomata.state(Turnstile, "Turnstile_1", :payload)

    Finitomata.transition(fini_name, :walk_in)
    assert %{data: %{passengers: 1}}} = Finitomata.state(Turnstile, "Turnstile_1", :payload)

    Finitomata.transition(fini_name, :switch_off)

    Process.sleep(200)
    refute Finitomata.alive?(Turnstile, "Turnstile_1")
  end
  ```

At the first glance, there is nothing wrong with this approach, but it requires
an enormous boilerplate, it cannot check it’s gone without using `Process.sleep/1`,
but most importantly, it does not allow testing intermediate states.

If the FSM has instant transitions (named with a trailing bang, like `foo!`) which
are invoked automatically by `Finitomata` itself, there is no way to test intermediate
states with the approach above.

OK, let’s use `Mox` then (assuming `Turnstile.Mox` has been declared and added
as a listener in test environment to `use Finitomata`)

  ```elixir
  # somewhere else → Mox.defmock(Turnstile.Mox, for: Finitomata.Listener)
  test "standard approach" do
    start_supervised(Finitomata.Supervisor)

    fini_name = "Turnstile_1"
    fsm_name = {:via, Registry, {Finitomata.Registry, fini_name}}
    parent = self()

    Turnstile.Mox
    |> allow(parent, fn -> GenServer.whereis(fsm_name) end)
    |> expect(:after_transition, 4, fn id, state, payload ->
      parent |> send({:on_transition, id, state, payload}) |> then(fn _ -> :ok end)
    end)

    Finitomata.start_fsm(Turnstile, fini_name, %{data: %{passengers: 0}})

    Finitomata.transition(fini_name, :coin_in)
    assert_receive {:on_transition, ^fsm_name, :opened, %{data: %{passengers: 0}}}
    # assert %{data: %{passengers: 0}}} = Finitomata.state(Turnstile, "Turnstile_1", :payload)

    Finitomata.transition(fini_name, :walk_in)
    assert_receive {:on_transition, ^fsm_name, :closed, %{data: %{passengers: 1}}}
    # assert %{data: %{passengers: 1}}} = Finitomata.state(Turnstile, "Turnstile_1", :payload)

    Finitomata.transition(fini_name, :switch_off)
    assert_receive {:on_transition, ^fsm_name, :switched_off, %{data: %{passengers: 1}}}

    Process.sleep(200)
    refute Finitomata.alive?(Turnstile, "Turnstile_1")
  end
  ```

That looks better, but there is still too much of boilerplate. Let’s see how it’d look like with `Finitomata.ExUnit`.

  ```elixir
  describe "Turnstile" do
    setup_finitomata do
      parent = self()
      initial_passengers = 42

      [
        fsm: [implementation: Turnstile, payload: %{data: %{passengers: initial_passengers}})],
        context: [passengers: initial_passengers]
      ]
    end

    test_path "respectful passenger", %{passengers: initial_passengers} do
      :coin_in ->
        assert_state :opened do
          assert_payload do
            data.passengers ~> ^initial_passengers
          end
        end

      :walk_in ->
        assert_state :closed do
          assert_payload do
            data.passengers ~> one_more when one_more == 1 + initial_passengers
          end
        end

      :switch_off ->
        assert_state :switched_off
        assert_state :*
    end
  ```

With this approach, one could test the payload in the intermediate states, and validate
messages received from the FSM with `assert_receive/3`.

No other code besides `assert_state/2`, `assert_payload/1`, and `assert_receive/3` is
permitted to fully isolate the FSM execution from side effects.

---

Happy helpertesting!
