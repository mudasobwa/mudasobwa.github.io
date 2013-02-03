---
layout: post
title: "Shorthands in ruby code blocks"
description: "Syntactic sugar using ampersand notations"
category: hacking
tags: [ruby, snippets, tricks]
---
{% include JB/setup %}

Sometimes Ruby, being like a functional language, unobtrusively forces us to use
code blocks within iterators (such as [map](http://www.ruby-doc.org/core-1.9.3/Array.html#method-i-map), 
[each](http://www.ruby-doc.org/core-1.9.3/Array.html#method-i-each), etc.) More than offen, these codeblock
are kinda one-liners and woo-`do-|o|-end` magic makes a code looking overdriven:
{% highlight ruby %}
  arr.each do |x|
    x.name
  end.join(" ")
{% endhighlight %}
Well, there are curly-brackets-notation available, hence we may rewrite the code above within one line.
But there is still a lot of absolutely unnecessary garbage hiding the core of what’s being actually done.

The good news is: ruby provides us with a syntactic sugar for that stuff. Let’s look at this:
{% highlight ruby %}
  arr.each (&:name).join(" ")
{% endhighlight %}
It is fully equivalent to the `do-|o|-end` codepiece above, but the readability is drastically improved.

How the hell does it work? As \[almost\] all the other shorthands in ruby, it’s calling some method. In that case 
the method is `#to_proc` on a `Symbol`’s instance (because `:name.class == Symbol`). The `Symbol#to_proc` method 
was originally added by `ActiveSupport` but has been integrated into Ruby since 1.8.7.

To enable this shorthand for classes other than `Symbol`, e. g. for an `Array`:
{% highlight ruby %}
class Array
  def to_proc
    lambda { |recv| recv.send *self }
  end
end
{% endhighlight %}
Now we can write:
{% highlight ruby %}
[ "Apple", "Orange", "Pear" ].map &[ :+, " is a fruit." ]
[ "Apple", "Orange", "Pear" ].map &[ :match, "[a-z]e" ]
{% endhighlight %}
yielding:
{% highlight ruby %}
#=> ["Apple is a fruit.", "Orange is a fruit.", "Pear is a fruit."]
#=> [#<MatchData "le">, #<MatchData "ge">, nil]
{% endhighlight %}
Methods are being called on array elements (on `String`s in the example above.)

----
Kinda same trick may be done for external methods using `&method` shorthand. Let’s say we have:
{% highlight ruby %}
  arr.each do |x|
    get_fullname x
  end.join(" ")
{% endhighlight %}
Thus, assuming we have the `get_fullname` method defined, we can rewrite it as:
{% highlight ruby %}
  arr.each &method(:get_fullname)
{% endhighlight %}

In other words, 
{% highlight ruby %}
  %w{ first second third }.map &method(:puts)
{% endhighlight %}
will print the array content out (expanding to `{ |s| puts s }`).
