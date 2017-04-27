---
layout: post
title: "Dry Behaviour aka Protocol Pattern in Ruby"
description: "Tiny library inspired by Elixir protocol pattern"
category: hacking
tags:
  - ruby
  - elixir
---

Elixir introduced the concept of behaviours. The quote from the [official docs](http://elixir-lang.org/getting-started/protocols.html):

> Protocols are a mechanism to achieve polymorphism in Elixir.
Dispatching on a protocol is available to any data type as long as it implements the protocol.

What is it all about? Well, Elixir entities, aka “terms,” are all immutable.
While in ruby we tend to declare methods on objects, that simply mutate the
objects, in Elixir it is impossible. Everybody had seen the `Animal` example
explaining the polymorphism in a nutshell for any of so-called OO languages:

```ruby
class Animal
  def sound
    raise "I am an abstract animal, I keep silence (and mystery.)"
  end
end

class Dog < Animal
  def sound
    puts "[LOG] I’m a dog, I bark"
    "woof"
  end
end

class Cat < Animal
  def sound
    puts "[LOG] I’m a cat, I am meowing"
    "meow"
  end
end
```

Now we are safe to call `sound` method on any animal, without bothering
to determine what exact type of animal we are facing. In Elixir, on the other
hand, we do not have “methods defined on objects.” The approach to achieve
more or less same functionality (the most typical example of where it’s really
handy is, for instance, the string interpolation,) would be to declare
the protocol.

_Sidenote:_ another approach would be to use [behaviours](http://elixir-lang.org/getting-started/typespecs-and-behaviours.html#behaviours),
but for the sake of our task we would stick to protocols in this post.

The protocol is a pure interface, declared with `defprotocol` keyword.
For the animalistic example above it would be:

```elixir
defprotocol Noisy do
  @doc "Produces a sound for the animal given"
  def sound(animal)
end
```

The implementation goes into `defimpl` clause:

```elixir
defimpl Noisy, for: Dog do
  def sound(animal), do: "woof"
end

defimpl Noisy, for: Cat do
  def sound(animal), do: "meow"
end
```

Now we can use the protocol, without actual care who the animal we have:

```elixir
ExtrernalSource.animal
|> Noisy.sound
```

---

OK. Why would we want to have this pattern in ruby? We indeed already have
polymorphism, right? Yes. And no. The most evident example would be classes,
coming from different external third-party sources, but still having
something in common. The _rails_ approach, widely spread into ruby world by DHH,
would be to monkeypatch everything. The irony here is that _I personally love
monkeypatching_. Yet in some cases I find the `protocol` approach being more
robust. That way, instead of re-opening `Integer` class for declaring date-aware
methods, one might declare the protocol, having `to_days` method.

It in turn might be used as `DateGuru.to_days(something)` instead of
`something.to_days`. That way all the code, responsible for the date
conversions/operations, would be placed together, providing sorta guarantee
that there are no conflicts, no accidental unintended monkeypatches etc.

I am not advocating this approach is better; it is just different.

To try it, we would need to provide some DSL to make it easy to declare
protocols in pure ruby. Let’s do it. We are to start with tests.

```ruby
module Protocols::Arithmetics
  include Dry::Protocol

  defprotocol do
    defmethod :add, :this, :other
    defmethod :subtract, :this, :other
    defmethod :to_s, :this

    def multiply(this, other)
      raise "We can multiply by integers only" unless other.is_a?(Integer)
      (1...other).inject(this) { |memo,| memo + this }
    end
  end

  defimpl Protocols::Arithmetics, target: String do
    def add(this, other)
      this + other
    end

    def subtract(this, other)
      this.gsub /#{other}/, ''
    end

    def to_s
      this
    end
  end

  defimpl target: [Integer, Float], delegate: :to_s, map: { add: :+, subtract: :- }
end
```

Let’s dig a bit into the code above. We have declared the protocol `Arithmetics`,
responsible for adding and subtracting values. Once two operations above
are implemented for instances of some class, we have `multiply` method for granted.
The usage of this protocol would be `Arithmetics.add(42, 3) #⇒ 45`.
Our DSL support _method delegation_, _mapping_ and explicit declaration.

This contrived example does not make much sense as is, but it provides a good
test case for our DSL. Let’s write tests.

```ruby
expect(Protocols::Adder.add(5, 3)).to eq(8)
expect(Protocols::Adder.add(5.5, 3)).to eq(8.5)
expect(Protocols::Adder.subtract(5, 10)).to eq(-5)
expect(Protocols::Adder.multiply(5, 3)).to eq(15)
expect do
  Protocols::Adder.multiply(5, 3.5)
end.to raise_error(RuntimeException, "We can multiply by integers only")
```

Yay, it’s time to finally implement this DSL. This is easy.

---

The whole implementation fits one single module. We would call it `BlackTie`,
since it’s all about protocols. In the first place tt will hold the maps of
declared protocols to their implementations.

```ruby
module BlackTie
  class << self
    def protocols
      @protocols ||= Hash.new { |h, k| h[k] = h.dup.clear }
    end

    def implementations
      @implementations ||= Hash.new { |h, k| h[k] = h.dup.clear }
    end
  end
```

_Sidenote:_ the trick with `default_proc` in hash declarations
(`Hash.new { |h, k| h[k] = h.dup.clear }`) produces the hash that has
a deep `default_proc`, returning an empty hash.

`defmethod` is the most trivial method here, it simply stores the
declaration under respective name in the global `@protocols` hash:

```ruby
def defmethod(name, *params)
  BlackTie.protocols[self][name] = params
end
```

Declaration of the `protocol` is a bit more cumbersome (some details are
omitted here for the sake of clarity, see
[the full code here](https://github.com/am-kantox/dry-behaviour/blob/master/lib/dry/behaviour/black_tie.rb#L19).)

```ruby
def defprotocol
  raise if BlackTie.protocols.key?(self) || !block_given?

  ims = instance_methods(false)
  class_eval(&Proc.new)
  (instance_methods(false) - ims).each { |m| class_eval { module_function m } }

  singleton_class.send :define_method, :method_missing do |method, *args|
    raise Dry::Protocol::NotImplemented.new(:method, self.inspect, method)
  end

  BlackTie.protocols[self].each do |method, *|
    singleton_class.send :define_method, method do |receiver = nil, *args|
      impl = receiver.class.ancestors.lazy.map do |c|
        BlackTie.implementations[self].fetch(c, nil)
      end.reject(&:nil?).first

      raise Dry::Protocol::NotImplemented.new(:protocol, self.inspect, receiver.class) unless impl
      impl[method].(*args.unshift(receiver))
    end
  end
end
```

Basically, the code above has four block. First of all, we check the conditions
the protocol must meet. Then we execute a block given, recording what methods
were added by this block, and exposing them with `module_function`.
In the third block we declare the generic `method_missing` to provide
meaningful error messages on erroneous calls. And, lastly, we declare methods,
either delegating them to respective implementation (when exists,) or throwing
the descriptive exception is there is no implementation for this particular
receiver.

OK, the only thing left is to declare `defimpl` DSL. The code below is a bit
simplified.

```ruby
def defimpl(protocol = nil, target: nil, delegate: [], map: {})
  raise if target.nil? || !block_given? && delegate.empty? && map.empty?

  # builds the simple map out of both delegates and map
  mds = normalize_map_delegates(delegate, map)

  Module.new do
    mds.each(&DELEGATE_METHOD.curry[singleton_class])     # delegation impl
    singleton_class.class_eval(&Proc.new) if block_given? # block takes precedence
  end.tap do |mod|
    mod.methods(false).tap do |meths|
      (BlackTie.protocols[protocol || self].keys - meths).each_with_object(meths) do |m, acc|
        logger.warn("Implicit delegate #{(protocol || self).inspect}##{m} to #{target}")
        DELEGATE_METHOD.(mod.singleton_class, [m] * 2)
        acc << m
      end
    end.each do |m|
      [*target].each do |tgt|
        BlackTie.implementations[protocol || self][tgt][m] = mod.method(m).to_proc
      end
    end
  end
end
module_function :defimpl
```

Despite the amount of LOCs, the code above is fairly simple: we create an
anonymous module, declare methods on it and supply it as the target of
method delegation from the main protocol class methods. Once we have called
`Arithmetics.add(5, 3)`, the receiver (`5`) would be used to lookup the
respective implementation (`defimpl Arithmetics, target: Integer`) and
it’s method `:+` (because of `defimpl target: [Integer, ...], ..., map: { add: :+, ... }`,
`add` is mapped to `:+`) would be called. That’s it.

---

Whether you still think, this is a redundant of-no-practival-use garbage,
imagine the `Tax` protocol. That might be implemented for: `ItemToSell`,
`Shipment`, `Employee`, `Lunch` etc.

❖ [`dry-behaviour` repo](https://github.com/am-kantox/dry-behaviour/). Enjoy!
