---
layout: post
title: "Ruby Shorthand to Yield Within Blocks"
description: "Example of using shorthand to yield keyword"
category: hacking
tags:
  - ruby
  - tricks
---
I’m definitely a _lambda-guy_. I’m addicted to simplicity, beauty and intelligibility of closures.
He who claims there is syntax clearer than `arr.each { |e| … }`, let him throw the first stone at me.
After all yielding is much more of human nature than jumping.

However there are two cases when `yield` seems to be hardly used. First is the `&`-shorthand to method
within another codeblock:

{% highlight ruby %}
def uglify items
  raise ArgumentException.new unless items.respond_to? :each
  items.each { |e| yield e }
end
{% endhighlight %}

If we try to shorten the `|e| yield e` clause with `&`-notation we’ll gain no success, since `yield` is
a keyword rather than method of a very superclass (like `Object` or `Kernel`.) But who cares?

Well, I do. Because there is a second, much more vital situation when `yield` sucks. It is re-passing a
codeblock to a subsequent method:

{% highlight ruby %}
def cleanup
  # do some cleanup if block_given?
end

def evaluate_lua
  cleanup yield if block_given?
  # do actual evaluate
end
{% endhighlight %}

The latter will throw an odd error `ArgumentError: wrong number of arguments (1 for 0)`.
The `cleanup &yield` neither works, if one were curious.

What’s the problem to use explicit `&cb` param here? There are two as usual. First is
an aesthetics, which matters a lot in Ruby. The last and not the least is that instantiating
a new `Proc` object leads to a surprisingly heavy performance penalty (≈ five times slower.)
Happily, there is a not wide-known [feature](http://www.ruby-doc.org/core-2.0/Proc.html#method-c-new)
of `Proc.new` constructor. Being called _without a block within a method with an attached block_, it
_converts_ that block to the `Proc` object. It means that both

{% highlight ruby %}
def uglify items
  raise ArgumentException.new unless items.respond_to? :each
  items.each(&Proc.new)
end
{% endhighlight %}

and

{% highlight ruby %}
def cleanup if block_given?
  # do some cleanup if block_given?
end

def evaluate_lua
  cleanup Proc.new
  # do actual evaluate
end
{% endhighlight %}

will work as expected without extra performance penalty.
