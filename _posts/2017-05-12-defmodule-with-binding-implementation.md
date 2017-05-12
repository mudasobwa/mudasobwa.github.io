---
layout: post
title: "Define module in Elixir with initial binding"
description: "tiny library that provides the same binding mechanism as quote bind_quoted: [] does"
category: hacking
tags:
  - tricks
  - elixir
---

This post is mostly a tutorial on Elixir macros, yet by the end we’ll have a
helper module that supports bound variables passed to `defmodule` built.

### The problem

Nested modules in `Elixir` derive the “context” if one treats context as
fully name qualification. In all other aspects, these two codepieces
are equivalent:

```elixir
defmodule A.B do
end

# versus

end
defmodule A do
  defmodule B do
  end
  # the only difference is that here
  #       we can refer B module as B
end
```

Usually when one nests anything, they expect to derive _more_ context. Like
module variables, or whatever. Even more, the context switch should probably
allow passing a binding through. At least, `quote` macro does:

```elixir
block = quote bind_quoted: [var: 42] do
  var == 42
end
Code.eval_quoted block
#⇒ {true, [{\{:var, Elixir}, 42}]}
```

The above trick is specifically handy when writing macros:

```elixir
defmodule A do
  defmacro a(var) do
    quote bind_quoted: [var: var] do
      IO.puts var # use it as is, without `unquote`
    end
  end
end

require A
A.a(42)
#⇒ 42
```

OK, so we are to implement binding passing through for `defmodule`. The
code that might use our implementation, would look like:

```elixir
defmodule WithBinding do
  # our module, that implements custom `defmodule` macro
  require Atadura

  Atadura.defmodule DynamicModule, status: :ok, message: "¡Yay!" do
    def response, do: [status: status, message: message]

    IO.inspect message, label: "Message (local)"
    #⇒ Message (local): "¡Yay!"
    IO.inspect @message, label: "Message (attribute)"
    #⇒ Message (attribute): "¡Yay!"
    IO.inspect ~b|status message|, label: "Message (sigil)"
    #⇒ Message (sigil): [:ok, "¡Yay!"]
  end
end

WithBinding.DynamicModule.response()
#⇒ [status: :ok, message: "¡Yay!"]
```

As one might see, both `status` and `message` variables were bound to
newly created module in three different ways:

- as local functions;
- as module variables;
- as smart sigil.

Also the module was granted with `bindings/0` function, returning the bindings
keyword list as is.

Under the hood, the nested module `WithBinding.DynamicModule.Bindings` was also
created, having two interesting macros, `bindings!/0` and `attributes!/0`.
The former populates the binding as local variables, the latter declares
modules attributes (it is internally used to declare module attributes for
the binding in the example above.)

#### `bindings!/0`

```elixir
require WithBinding.DynamicModule.Bindings
WithBinding.DynamicModule.Bindings.bindings!
#⇒ [:ok, "¡Yay!"]
status
#⇒ :ok
```

#### `attributes!/0`

```elixir
defmodule A do
  require WithBinding.DynamicModule.Bindings
  WithBinding.DynamicModule.Bindings.attributes!

  def status, do: @status
end
A.status
#⇒ :ok
```

### Implementation

The implementation is simple, though it might look a bit cumbersome at the
first glance. Let’s start with `Atadura.defmodule/{2,3}`.

If no bindings were given, `Atadura.defmodule/2` would gracefully fallback
to `Kernel.defmodule/2`, without any impact on the compiled code.

Here is the complete code of this module, including some comments:

```elixir
# function declaration; needed to allow importing w/out
#   conflicts with `Kernel.defmodule/2` and fallback to it
#   when no parameters are given.
defmacro defmodule(name, bindings \\ [], do_block)

# fallback to `Kernel.defmodule/2`
defmacro defmodule(name, [], do: block) do
  quote do: Kernel.defmodule(unquote(name), do: unquote(block))
end

# handler for non-bracketed call (not available on import)
defmacro defmodule(name, [], bindings_and_do) do
  block = Keyword.get(bindings_and_do, :do, nil)
  bindings = Keyword.delete(bindings_and_do, :do)
  quote do: Atadura.defmodule(unquote(name), unquote(bindings), do: unquote(block))
end

# main handler
defmacro defmodule(name, bindings, do: block) do
  # we are to build the module name in the first place
  # it’s done before `quote do` because `defmodule` below
  # does not accept `Module.concat(unquote(name), Bindings)`
  binding_module = with {:__aliases__, line, names} <- name do
                     {:__aliases__, line, names ++ [:Bindings]}
                   end

  quote do
    # `Bindings` nested module, passes `bindings` to
    #    `Atadura.Binder`, that will declare all the
    #    stuff in `__using__` callback
    defmodule unquote(binding_module) do
      use Atadura.Binder, unquote(bindings)
    end

    # OK, that is the exact reason we were quoting
    #    and unquoting everything: call to `use binding_module`
    #    is required to update (patch, extend, younameit) the
    #    module that is being created
    defmodule unquote(name) do
      use unquote(binding_module)

      unquote(block)
    end
  end
end
```

---

That’s almost it. The only thing remains is to implement `__using__` there
in `Atadura.Binder`. Since it’s a bit of hardcore, let’s continue with
usage advises on that module. The post’s tail will cover the tech details
of the implementation, I promise.

### Tips and tricks

```elixir
import Atadura, only: [:defmodule, 3]
```

The above allows to still use default `Kernel.defmodule/2` unless
the keyword list is given as the second parameter:

```elixir
import Atadura, only: [:defmodule, 3]

# Plain old good `Kernel.defmodule/2` without bindings
defmodule A1, do: def a, do: IO.puts "★★★"

# `Atadura.defmodule/3` with bindings
defmodule A2, [b: 42], do: def a, do: IO.puts "★★★"
```

Without explicit `import`, `Atadura.defmodule/{2,3}` would gracefully
fallback to `Kernel.defmodule/2` if no bindings were given. Unfortunately,
there is no chance to distinguish between two following calls:

```elixir
defmodule A1, do: def a, do: IO.puts "★⚐★"
defmodule A2, bound: 3.14, do: def a, do: IO.puts "★π★"
```

because both examples are `defmodule/2` clauses, and we would be conflicting
with always imported `Kernel`. So, when `import Atadura` is used, the
brackets around the second argument in call to `defmodule` are mandatory.

### `Atadura.Binder.__using__/1`

Dear José, thanks for still bearing with me, in case you wonder how ugly I had
this written, here are the implementation details.

```elixir
defmodule Atadura.Binder do
  @moduledoc ~S"""
    Since we want to hide the implementation details inside
      `Bindings` nested module, we’ll do nested `__using__`.
    See `Atadura.defmodule/3` for details.
  """

  defmacro __using__(bindings) do
    [
      quote do
        # bindings require two unquotes, on each subsequent quote
        bindings = unquote(bindings)
        # this will be used in nested `Bindings` module, that will
        #   be in turn `use`d by `Atadura.defmodule/3`
        defmacro __using__(_opts \\ []) do
          module = __MODULE__ # to get it properly inside quote
          quote do
            require unquote(module), as: Bindings
            import unquote(module)
            # Bindings.bindings! # declare local variables: not very handy
            Bindings.attributes! # declare module attributes

            # just an example of how module documentation
            #    might be constructed on the fly
            Module.add_doc(__MODULE__, 0, :def, {:version, 0}, [],
              ~s"""
              Returns a binding for this module, supplied when it was created.
              This module #{__MODULE__} was created with the following binding:

                  #{inspect Bindings.bindings}

              Enjoy!
              """)
            # the plain function, that returns all the bindings
            def bindings, do: Bindings.bindings
          end
        end
        # back to `Bindings` module level, here it’s macro called 3 LOCs above
        defmacro bindings, do: unquote(bindings)
        # local variables producer, might be called from everywhere
        #   to populate the current context with binding
        defmacro bindings! do
          Enum.map(unquote(bindings), fn {attr, val} ->
            {:=, [], [{attr, [], nil}, val]}
          end)
        end
        # module attribute producer, might be called from inside
        #   of any module to populate the current context with binding
        defmacro attributes!() do
          Enum.map(unquote(bindings), fn {attr, val} ->
            quote do
              Module.register_attribute(__MODULE__, unquote(attr), accumulate: false)
              Module.put_attribute(__MODULE__, unquote(attr), unquote(val))
            end
          end)
        end
        # sigils producer; when called with a single attribute name,
        #   e.g. `~b|status|`, returns it’s value as is.
        # when called with many, returns a list of values.
        defmacro sigil_b(keys, _modifiers) do
          bindings = unquote(bindings)
          {:<<>>, _, [key]} = keys
          case String.split(key, ~r/\s+/) do
            [key] when is_binary(key) -> # single value requested
              quote do: unquote(bindings)[String.to_atom(unquote(key))]
            keys when is_list(keys) ->   # multi values
              Enum.map(keys, fn key ->
                with bindings <- unquote(bindings),
                 do: quote do: unquote(bindings)[String.to_atom(unquote(key))]
              end)
          end
        end
      end |

      # functions returning bindings by name, appended to the AST.
      Enum.map(bindings, fn {attr, val} ->
        quote do
          def unquote(attr)(), do: unquote(val)
        end
      end)
    ]
  end
end
```

Yes, that is it. There is no more code in the package, besides the above,
but for those picky persons, we have
[atadura @ github](https://github.com/am-kantox/atadura), also the package
is [available @ hex.pm](https://hex.pm/packages/atadura).
