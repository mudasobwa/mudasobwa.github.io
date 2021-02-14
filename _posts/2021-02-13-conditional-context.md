---
layout: post
title: "Conditional context for macros"
description: "The trick allowing to implement the extended functionality of macros depending on the context they were called from"
category: hacking
tags:
  - elixir
---

Elixir 1.11 brought to us (amongst other very exciting features) [`is_struct/2`](https://hexdocs.pm/elixir/Kernel.html#is_struct/2) guard. It, by the way, might have been used as an example of more straightforward not backward compatible example in my yesterday’s [writing](https://rocket-science.ru/hacking/2021/02/12/conditional-defguard), but I avoided it for a reason that will become clear below.

Gazing for the first time into the documentation examples, I was confused. This example is

```elixir
iex> is_struct(URI.parse("/"), URI)
#⇒ true
```

Wait, what? There is no way the remote call `URI.parse("/")` would have been allowed in guards, but the documentation states it will.

![Context Differs](/img/context.jpg)

Well, the documentation is cheating on us. Of course, remote call cannot be used in guards, but `is_struct/2` _without remote calls_ can. How is that? Let’s find out.

### Conditional Context

There is no doubt, the compiler allows `is_struct/2` to be more permissive when it’s used as a bare macro, in a raw code, outside of guards. How does she know what AST to inject depending on the context? Easy. The macro tells her.

There is a [`__CALLER__`](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#__CALLER__/0) special form, providing the current calling environment. It can be used only inside defmacro and defmacrop (_is available_, as an exception raised on any attempt to call it from outside macros, says.) It holds a whole bunch of interesting stuff within it, including, but not limited to `context` and `context_modules`.

The purpose of latter we’ll see a bit later, now let’s focus on the former.

It has a type [`Macro.Env.context()`](https://hexdocs.pm/elixir/Macro.Env.html#t:context/0) which means it can be an atom, either `nil`, or `:match` or `:guard`. These three contexts mean, respectively, the following

* `:guard` means the macro gets expanded within a function guard context, as in `def foo(s) when is_struct(s, URI)`
* `:match` means it gets expanded inside a match, as in `def foo(is_struct(s))`
* `nil` means elsewhere

All three cases are [handled differently](https://github.com/elixir-lang/elixir/blob/v1.11.3/lib/elixir/lib/kernel.ex#L2314-L2341) in the case of `is_struct/2` macro, and from the source code linked above, one can see that it’s not allowed in match clauses.

For what it worth, in the case of `:guard`, it gets expanded into `is_map(s) and s.__struct__ == S` which I directly used yesterday to simplify things.

### Context Module

Another glitch I met literally today, is I have created a module, exporting a fancy functionality via `__using__/1` special form. I have it thoroughly tested, and all, and it worked perfectly. Then I decided to add `use MyFancy` to my `.iex.exs` file to steroidize my elixir shell.

It blowed up with a very cryptic message.

One might see the nearly same message by calling `use GenServer` from the shell.

But all I wanted was to inject some fancy stuff into my current context! Apparently, the AST to inject, besides setting a ton of environment, contained some stuff that makes sense within the module context only. One cannot call `def/2` from outside of the module, or set the module attribute (this is what the cryptic error message above was actually referring to,) just out of the thin air.

Aforementioned `__CALLER__` has [`context_modules`](https://hexdocs.pm/elixir/Macro.Env.html#t:context_modules/0) field to help us. According to the [documentation](https://hexdocs.pm/elixir/Macro.Env.html), this field contains the list of modules defined in the current context. One example expresses it better than the thousand of words:

```elixir
IO.inspect(__ENV__.context_modules, label: "top level")
defmodule M do
  IO.inspect(__ENV__.context_modules, label: "inside M module")
  defmodule N do
    IO.inspect(__ENV__.context_modules, label: "inside nested N module")
  end
end

#⇒ top level: []
#⇒ inside M module: [M]
#⇒ inside nested N module: [M.N, M]
```

So, I simply split the AST to inject into two parts, one that made sence only within a module context, and another one, that I might have injected anywhere. And then I simply conditionally concatenated them.

```elixir
defmacro __using__(opts \\ []) do
  modulewise =
    case __CALLER__.context_modules do
      [] -> []
      [_some | _] -> build_modulewise_ast()
    end

  modulewise ++ build_module_agnostic_ast()
end
```

Two functions above, starting with `build_` are out of scope here, they simply build the AST.

That was it. Now I am able to call `use MyFancy` from `.iex.exs`.

---

Happy context-depending!
