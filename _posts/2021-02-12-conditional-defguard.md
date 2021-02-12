---
layout: post
title: "Conditional guard for structs of an explicit type"
description: "The trick allowing to declare the guard that gracefully falls back on earlier versions of Elixir/OTP"
category: hacking
tags:
  - elixir
---

Starting with Elixir 1.11 / OTP 23, one can easily define a guard to check the argument is a particular struct. That might be handy in rare cases when the single function clause is ready to accept a mixed argument, and pattern matching directly on the argument would not work.
To be backward compatible, though, we cannot simply do

```elixir
defguard is_foo(value)
  when is_map(value) and value.__struct__ == Foo
```

the above would raise on earlier versions during compilation.

Direct `if` in the code on the top level, surrounding `defguard` clause wouldn’t work either, the compiler would nevertheless attempt to parse `value.__struct__ == Foo` and raise (I am unsure if it’s a desired behaviour, but still.)

The solution would be to introduce another macro, declaring this guard, that will check the version _before_ returning the AST. Somewhat along these lines would work.

```elixir
@spec can_struct_guard? :: boolean()
@doc "Returns `true` if we can declare a proper guard, false otherwise"
defp can_struct_guard? do
  String.to_integer(System.otp_release()) > 22 and
    Version.compare(System.version(), "1.11.0") != :lt
end

@spec maybe_struct_guard(name :: atom(), struct :: module()) :: Macro.t
@doc "Returns the AST that would compile for the current Elixir/OTP"
defmacro maybe_struct_guard(name \\ nil, struct) do
  # Derive the guard name from the struct name unless passed explicitly
  name =
    if is_nil(name),
      do: struct |> Module.split() |> List.last() |> Macro.underscore(),
      else: name
  name = :"is_#{name}"

  if can_struct_guard?() do
    quote do
      @doc "Helper guard to match instances of struct #{inspect(unquote(struct))}"
      defguard unquote(name)(value)
               when is_map(value) and value.__struct__ == unquote(struct)
    end
  else
    quote do
      @doc """
      Stub guard to match instances of struct #{inspect(unquote(struct))}. Upgrade to 11.0/23 to make it work.
      """
      defguard unquote(name)(value) when is_map(value)
    end
  end
end
```

Now we can declare guards as

```elixir
maybe_struct_guard(MyStruct)
```

and use it as

```elixir
def foo(value) when is_list(value) or is_my_struct(value),
  do: IO.inspect(value, label: "Expected value")
```

---

Happy guarding!
