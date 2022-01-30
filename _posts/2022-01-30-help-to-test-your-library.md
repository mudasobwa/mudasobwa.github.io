---
layout: post
title: "Help To Test Your Library"
description: "How to make your library a charm to test with a minimal effort"
category: hacking
tags:
  - elixir
---

I like to keep applications as tiny as possible. Everything that is not related to business logic, might and should be extracted into packages. Packages are great, reusable and better testable; once created and tested (and hopefully benchmarked,) it does not require the application to bother about its internals. It just works™. [hex.pm](https://hex.pm/pricing) provides private package functionality for those hesitating to open source their general-purpose libraries.

Despite the proven robustness of external libraries, we would probably still want to test their integration though. Any library might be great on its own, but how would it fit our application quirks?

![Girl in Palma](/img/palma.jpg)

Well, greatest libraries are welcoming for integration testing. _Ecto_ [provides a sandbox for testing](https://hexdocs.pm/ecto/testing-with-ecto.html#content). _Broadway_ comes with a [DummyProducer](https://hexdocs.pm/broadway/Broadway.html#module-testing).

Providing a sandbox might be cumbersome and tricky in general, while `DummyWorker` is a must in any library shipped with love and care. Apparently, it’s both extremely useful for users of your library and easy to implement. Follow _Broadway_’s path, send a message to the calling process instead of performing real job. That simple.

---

Imagine we have a library that posts a slack message into some channel within your company workspace. Our application has some actions which should end up with a message in this slack channel. The integration test should then test that a call to `perform_this_action` has some side effects actually performing a real job _and_ notifies the slack channel afterward. We use homebrewed `SlackPoster` library, which is thoroughly tested and is proven to work well with posting messages. But how would we go about integration test? Check the slack channel ensuring the message had indeed arrived? Nah.

This imaginary `SlackPoster` library is probably already having a behaviour defining the callback similar to that

```elixir
@callback post(message :: map()) :: :ok | {:error, reason} when reason: any()
```

If the library author was kind enough, they should have provided a real implementation

```elixir
defmodule SlackPoster do
  @behaviout Poster

  @impl Poster
  def post(%{} = message),
    do: message |> Jason.encode!() |> Engine.send_message()
  …
```

alongside with a dummy implementation for better testing

```elixir
defmodule DummyPoster do
  @behaviout Poster

  @impl Poster
  def post(%{} = message) do
    {callback_pid, message} =
      Map.pop(message, :callback, @default_value)
    send(callback_pid, {:slack_sent, message})
  end
```

And now one can test the integration easily with [`ExUnit.Assertions.assert_receive/3`](https://hexdocs.pm/ex_unit/ExUnit.Assertions.html#assert_receive/3)

```elixir
test "slack integration" do
  # wait how would I supply a pid of process here?!
  assert_receive {:slack_sent, ^expected_message}
end
```

Yes, there is still a glitch. When it’ll come to `DummyPoster.post/1`, it would require a `pid` to provide callback, and there is no way to supply it transparently without bringing test logic into application core, which is meh. Is it a deadend?—Not at all.

Your library should provide a _message proxy_ process. It is to be started within a test suite (e. g. from [`setup/1`](https://hexdocs.pm/ex_unit/ExUnit.Callbacks.html#setup/1) callback,) to route messages to the test process. Then we might do the following.

```elixir
defmodule DummyPoster do
  @behaviout Poster

  @impl Poster
  def post(%{} = message) do
    {callback_pid, message} =
      Map.pop(message, :callback, Application.get_env(:my_app, :dummy_proxy))
    Process.send(callback_pid, {:slack_sent, message}, [])
  end
```

and in our test we would need to register ourselves right before `assert_receive/1`

```elixir
test "slack integration" do
  expected_message = ...

  proxy = Application.get_env(:my_app, :dummy_proxy)
  proxy.register(expected_message, self())
  assert_receive {:slack_sent, ^expected_message}
  proxy.unregister(expected_message, self())
end
```

The draft implementation of proxy process is trivial.

---

Another way would be to use `PubSub` mechanism for routing messages, but this is slightly more cumbersome. [`Envío`](https://hexdocs.pm/envio) library aims to cover a boilerplate for pubsub internals, allowing simple drop-in implementations for publishers and subscribers. One day I’d write about it in details too.

---

Happy making your customers happy testing!
