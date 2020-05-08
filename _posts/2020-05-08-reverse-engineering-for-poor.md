---
layout: post
title: "Reverse Engineering for Poor"
description: "Quick, nasty, and dirty hack to quickly grasp how the foreign code works"
category: hacking
tags:
  - elixir
---

There was a [question](https://stackoverflow.com/questions/61659551/what-does-the-alphanumeric-value-mean-in-an-elixir-mix-lock-file) published yesterday on _Stack Overflow_, asking

> what the alphanumeric value like `"d<i62n>2"` represents in the slice of `mix.lock` file?

Well, I am kinda familiar with _Elixir_ core code, but this is _mix_ which I never scratched my head of. First glance at sources didn’t help much; the entry format in `mix.lock` looks like

```elixir
"nimble_parsec": {
  :hex,
  :nimble_parsec,
  "0.5.3",
  "def21c10a9ed70ce22754fdeea0810dafd53c2db3219a0cd54cf5526377af1c6", # ??? 1
  [:mix],
  [],
  "hexpm",
  "589b5af56f4afca65217a1f3eb3fee7e79b09c40c742fddc1c312b3ac0b3399f"  # ??? 2
}
```

There are two hashes, the latter is a checksum of the package at [hex.pm](https://hex.pm/packages/nimble_parsec/0.5.3) (check the bottom right corner below)

![Checksum 589b5af56f4afca65217a1f3eb3fee7e79b09c40c742fddc1c312b3ac0b3399f](/img/nimble_parsec_hex_checksum.png)

but the former is something I could not `grep` easily. I am an inquisitive guy, so I went to source code. It quickly revealed that this is not something `mix` creates on its own, so I needed to understand who is the one this data is delegated to. The good entry point of investigation would be [`Mix.Dep.Lock.{read/0,write/1}`](https://github.com/elixir-lang/elixir/blob/5984c6cc29a41d5bc78d49427730c8786d75e2c9/lib/mix/lib/mix/dep/lock.ex#L13-L43) functions.

I am aware of [`IEx.Pry.break/4`](https://hexdocs.pm/iex/IEx.Pry.html#break/4), but sometimes a _nasty hack_ is way more handy than the _proper approach_, whatever it means. So I grabbed _Elixir_ source, compiled it with `make clean test` and instructed `asdf` to use the source distribution locally for the newly created project with a single `hex` dependency with `asdf local elixir path:/home/am/Proyectos/elixir`.

---

Then I went to aforementioned `Mix.Dep.Lock.write/1` and amended it with

```elixir
def write(map) do
  ...

  try do
    raise "BOOM"
  rescue 
    _ -> 
      IO.inspect({map, __STACKTRACE__}, label: "Mix.Dep.Lock.write/1")
  end

  ...
end
```

 Since _OTP 20_, [`__STACKTRACE__`](https://hexdocs.pm/elixir/Kernel.SpecialForms.html?#__STACKTRACE__/0) might be used in the context of currently handled exception to get, well, the stacktrace. I could have used `Process.info(self(), :current_stacktrace)` instead, but raising an exception gives more flexibility in grokking the behaviour later on (_spoiler:_ it wasn’t necessary.) After `make compile` _Elixir_ and `rm -rf mix.lock deps _build && mix deps.get` in my new project directory, I got the stack trace

 ```elixir
 [
  {Mix.Dep.Lock, :write, 1, [file: 'lib/mix/dep/lock.ex', line: 34]},
  {Mix.Dep.Fetcher, :do_finalize, 3,
   [file: 'lib/mix/dep/fetcher.ex', line: 106]},
  {Mix.Dep.Fetcher, :all, 3, [file: 'lib/mix/dep/fetcher.ex', line: 17]},
  {Mix.Tasks.Deps.Get, :run, 1, [file: 'lib/mix/tasks/deps.get.ex', line: 31]},
  ...
 ```

what led me to `Mix.Dep.Converger.converge/4` and then to `remote.converge/2`. I put another `IO.inspect/2` there to confirm my expectation; yes, `remote` there had a value [`Hex.RemoteConverger`](https://github.com/hexpm/hex/blob/v0.20.5/lib/hex/remote_converger.ex).

The mystery was solved in 10 minutes and two `IO.inspect/2` in the foreign code.

That said, both `__STACKTRACE__` and `Process.info(self(), :current_stacktrace)` could tell you more of an alien code structure than all the documentation in the world.

---

Happy inspecting!