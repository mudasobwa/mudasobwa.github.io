---
layout: post
title: "Struct With Hash-like Default Proc"
description: "How to implement default_proc functionality in ruby structs"
category: hacking
tags:
  - ruby
---

This question was originally asked on [StackOverflow](http://stackoverflow.com/questions/41114667/how-to-implement-autovivification-for-ruby-structs/41115465#41115465),
and the answer is more-or-less trivial; in any case I find myself explaining
some of this metaprogramming techniques as often, as I decided to finally
write this short post on the topic.

**_Q._ How to implement autovivification for Ruby structs?**

Everybody programming ruby at least three months should have met the
[`Hash#default_proc`](http://ruby-doc.org/core/Hash.html#method-i-default_proc)
behaviour. This `default_proc` might be also passed directly to the constructor
of the hash:

{% highlight ruby %}
▶ hash = Hash.new { |h, k| h[k] = 42 }
#⇒ {}
▶ hash[:answer]
#⇒ 42
{% endhighlight %}

One might require the sane functionality from structs (why not, after all?)
Indeed, this is easy.

Let’s start with the complete working example.

{% highlight ruby %}
module StructVivificator
  def self.prepended(base)
    raise 'Sorry, structs only!' unless base < Struct

    base.singleton_class.prepend(Module.new do
      def new(*args, &λ) # override `new` to accept block
        super(*args).tap { @λ = λ }
      end
    end)
    base.send(:define_method, :default_proc=) { |λ| @λ = λ }
    base.send(:define_method, :default_proc) { |&λ| λ ? @λ = λ : @λ }

    # override accessors (additional advantage: performance/clarity)
    base.members.each do |m|
      base.send(:define_method, m) { self[m] }
      base.send(:define_method, "#{m}=") { |value| self[m] = value }
    end
  end
  def [](name)
    super || default_proc && default_proc.(name) # or more sophisticated checks
  end
end

############################################
#####   usage example
############################################

Foo = Struct.new(:bar, :baz) do
  prepend StructVivificator
end
{% endhighlight %}

Here we declared the module to `prepend`. Once prepended, it checks
whether it was prepended to `Struct`, and declares two methods
on the base class: getter and setter for `default_proc`. Also, it overwrites
the default [`Struct#[]`](https://ruby-doc.org/core/Struct.html#method-i-5B-5D)
_property getter_, trying to call the superior method and gracefully falling
back to the call to `default_proc`, if declared.

Since the `.property` access calls `[:property]` under the hood
through `method_missing` magic, the only thing to overwrite is a `Struct#[]` method.

So far so good. Let’s test it.

{% highlight ruby %}
foo = Foo.new
foo.default_proc = ->(name) { name == :bar ? 42 : 0 }
puts foo.bar          # => 42
puts foo[:bar] += 1   # => 43
puts foo.bar += 1     # => 44
puts foo[:baz] += 1   # => 1
{% endhighlight %}
