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
  # when prepended, this module will extend struct with
  # getter and setter for the default proc;
  # an exception will be raised when tried to be prepended to non-struct
  def self.prepended(base)
    raise 'Sorry, structs only!' unless base < Struct

    base.send(:define_method, :default_proc=) { |λ| @λ = λ }
    base.send(:define_method, :default_proc) { @λ }
  end
  def [](name)
    # checks here might be more sophisticated
    super || default_proc && default_proc.(name)
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
puts foo[:bar] += 1   # => 43
puts foo.bar += 1     # => 44
puts foo[:baz] += 1   # => 1
{% endhighlight %}

Of course, to fully conform the `Hash`’s autovivification one should also:

{% highlight ruby %}
base.singleton_class.send(:define_method, :new) do |*args, &λ|
  super(*args)
  @λ = λ
end
{% endhighlight %}

inside `self.prepended` callback. I have not put it in the first snippet
for the sake of keeping code clean and tiny.
