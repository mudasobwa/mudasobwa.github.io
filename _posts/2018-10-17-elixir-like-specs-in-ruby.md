---
layout: post
title: "Ruby metaprogramming for beginners → Elixir-like specs"
description: "Hacky implementation of Elixir-like specs in pure ruby with examples"
category: hacking
tags:
  - elixir
  - ruby
  - tricks
  - tools
---

### Typespecs

_Erlang_ and hence _Elixir_ are dynamically typed languages. They both have an extended abilities to type check in compile time using _typespecs_. Here are [an introduction](https://elixir-lang.org/getting-started/typespecs-and-behaviours.html) and [more detailed documentation](https://hexdocs.pm/elixir/master/typespecs.html#content).

Basically one might declare the specification of the function and if the actual function declaration violates this contract, the static code analysis tool called [dialyzer](http://erlang.org/doc/man/dialyzer.html) will report an issue. The format of typespecs looks pretty nifty:

```elixir
@spec concat(binary(), any()) :: {:ok, binary()} | {:error, any()}
def concat(origin, any), do: origin <> IO.inspect(any)
```

During the work on explicit function typing in [`Dry::Protocols`](https://github.com/am-kantox/dry-behaviour) I experimented with the syntax of specs. The most exciting syntax I was able to get working was the almost copy of the Elixir’s one:

```ruby
include Dry::Annotation

@spec[(this), (string | any) :: (string)]
defmethod :append, :this, :any

def append(this, any)
  this << any.inspect
end
```

This `@spec` line is parsed and evaluated by standard ruby parsed, if anybody’s curious. In this writing I am going to show how I had it implemented. For those brave who think they can do some ruby, I’d strongly suggest doing this golf yourselves, it was an exciting couple of hours while I get everything up and parsing properly (through crashes and weird error messages).

### Getting to the task

Well, for the sake of making the task exciting, I wanted to replicate Elixir’s syntax as close as possible. Of course I might go with boring Rails style declare-verbose-DSL-and-we-are-all-set. But this is so dull!

So, let’s see what we can do here. An orphan instance variable would be ignored by Ruby (well, it’s value will be returned and immediately discarded,) so I had two options here: to assign the “type” to theit, or to call it. I found `@spec[...]` (which is an alias for `@spec.call` btw) to be most sexy.

```diff
- @spec = ...
- @spec.(...)
+ @spec[...]
```

Now we need to handle parameters. The easiest way to gorge a list of words with Ruby interpretor is to create an instance of some specifically dedicated _accumulator_ class and return `self` from each call to it’s `method_missing`. To avoid clashes, I’d derive this class from [`BasicObject`](https://ruby-doc.org/core/BasicObject.html), not from the standard `Object`:

```ruby
class AnnotationImpl < BasicObject
  def initialize
    @types = {args: [], result: []}
  end

  def 🖊(name, *args, &λ)
    @types[:args] << [args.empty? ? name : [name, args, λ]]
    self
  end
end

module Annotation
  def self.included(base)
    base.instance_variable_set(:@annotations, AnnotationImpl.new)
    base.instance_variable_set(:@spec, ->(*args) { puts args.inspect })
    base.instance_eval do
      def method_missing(name, *args, &λ)
        @annotations.__send__(:🖊, name, *args, &λ)
      end
    end
  end
end
```

I give such weird names to methods on purpose: I want to avoid name clashes as much as possible. Also, please note, that this approach is very dangerous because we are to overwrite `method_missing` on any class `Annotation` will be included into.

It’s fine for the demonstration purposes, though. And, apparently, for `Dry::Protocols`, because they are very isolated, are not supposed to be inherited and declare very few methods by design.

So far so good. We already have everything to support `@spec[foo, bar, baz]` syntax. Include `Annotation` into some fresh class and try it.

```ruby
class C
  include Annotation
  @spec[foo, bar, baz]
end
#⇒ NoMethodError: undefined method `inspect' for #<AnnotationImpl:0x00564f9d7e0e80>
```

Sure thing, it’s an instance of `BasicObject`. Let’s define it:

```ruby
def inspect
  @types.inspect
end
```

Now the syntax somehow works. When I say “works” I just mean it does not blow up neither consuses both Ruby parser and interpreter.

### Hardcore: boolean _or_ for types

But wait, we don’t want to stick to the only type permitted; we want to allow boolean `or` for them! In Elixir syntax that is done with a vertical bar `|`, so I decided to fully replicate this functionality. It might sound more complicated than just collecting words, but in fact it is not. Ruby classes _allow_ redefinition of the `#|` method:

```ruby
def |(_)
  @types[:args].push(
    2.times.map { @types[:args].pop }.rotate.reduce(&:concat)
  )
  self
end
```

What happens here? We pop two last elements from the array (the current one and the previous one,) join them together (preserving the order) and push them back to the array of arguments:

- **`@types[:args]`** before: `[[:foo], [:bar], [:baz]]` where the `:baz` just came in
- after 2 pops: `[[:foo]]` and `[[:baz], [:bar]].rotate.reduce(&:concat)` ≡ `[[:bar, :baz]]`
- **`@types[:args]`** after: `[[:foo], [:bar, :baz]]`

That was simple. Also, to make it cleaner and to avoid the mess with precedence, I decided to explicitly require to surround the parameters with parentheses `@spec[(foo), (bar | baz)]`.

### Nightmare: result type

OK, that is where I expected issues. Of course, I could use hashrocket as lazy unambitious fellas do, but I am not like that. I didn’t want that trash, I wanted fancy Elixir-like colons:

```diff
- @spec[(foo), (bar, baz) => (boo)]
+ @spec[(foo), (bar, baz) :: (boo)]
```

But does this seem to be possible?—Yes, apparently it does. Remember one might call methods with double colon like `42::to_s #⇒ "42"`? Here we go.

```ruby
def call(*)
  @types[:result] << @types[:args].pop
  self
end
```

Double colon invokes `call` method on the instance under the hood. When our implementation experiences _call_, it just pops the last argument and pushes it to the `result` array. Frankly, I though it’s gonna be harder.

### Summing it up

Technically, we are all done. The implementation is ready to go. Well, almost. There are some cosmetic changes to make it work with several different `@spec`s (the same way as `desc` works with rake tasks definitions, just collecting them and picking up the last one.)

Below is the whole code, for those still curious. I must repeat this: do not do that in real life. Not because the code is cumbersome and hard to read: it’s pretty vivid, clean and simple. But because polluting the space of the class including our module with heaps of nasty garbage as Rails do isshould be avoided. Whether we need a full load of unpredictable behaviours and tons of arisen from nowhere methods, we already have `ActiveSupport` for that. Enough is enough.

The code is provided mostly as an example of Ruby nearly infinite capabilities to habdle whatever crap comes to the developer’s head. In [`Dry::Protocol`] we’ll use way less sexy symbols for annotations.

---

### Appendix I :: complete source code

```ruby
module Dry
  class AnnotationImpl < BasicObject
    def initialize
      @spec = []
      @specs = []
      @types = {args: [], result: []}
    end

    def 📝 &λ
      return @spec if λ.nil?
      (yield @spec).tap { @spec.clear }
    end

    def 📝📝
      @specs
    end

    def 📇
      @types
    end

    def to_s
      @specs.reject do |type|
        %i[args result].all? { |key| type[key].empty? }
      end.map do |type|
        "@spec[" <<
          type.
            values.
            map { |args| args.map { |args| "(#{args.join(' | ')})" }.join(', ') }.
            join(' :: ') << "]"
      end.join(' || ')
    end

    def inspect
      @specs.reject do |type|
        %i[args result].all? { |key| type[key].empty? }
      end.inspect
    end

    def call(*)
      @types[:result] << @types[:args].pop
      self
    end

    def |(_)
      @types[:args].push(
        2.times.map { @types[:args].pop }.rotate.reduce(&:concat)
      )
      self
    end

    def 🖊️(name, *args, &λ)
      @types[:args] << [args.empty? ? name : [name, args, λ]]
      self
    end
  end

  module Annotation
    def self.included(base)
      annotations = AnnotationImpl.new
      base.instance_variable_set(:@annotations, annotations)
      base.instance_variable_set(:@spec, ->(*args) {
        impl = args.first
        last_spec = impl.📇.map { |k, v| [k, v.dup] }.to_h

        # TODO WARN IF SPEC IS EMPTY
        %i[args result].each do |key|
          last_spec[key] << %i[any] if last_spec[key].empty?
        end

        base.instance_variable_get(:@annotations).📝📝 << last_spec
        base.instance_variable_get(:@annotations).📝.replace([last_spec])

        impl.📝📝 << last_spec
        impl.📇.each { |k, v| v.clear }
      })

      base.instance_eval do
        def method_missing(name, *args, &λ)
          @annotations.__send__(:🖊️, name, *args, &λ)
        end
      end
    end
  end
end
```
