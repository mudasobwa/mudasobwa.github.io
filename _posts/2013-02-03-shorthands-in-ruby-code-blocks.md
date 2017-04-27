---
layout: post
title: "Shorthands in Ruby Code Blocks"
description: "Syntactic sugar using ampersand notations"
category: hacking
tags:
  - ruby
  - tricks
---
Sometimes Ruby, being like a functional language, unobtrusively forces us to use
code blocks within iterators (such as [map](http://www.ruby-doc.org/core-1.9.3/Array.html#method-i-map), 
[each](http://www.ruby-doc.org/core-1.9.3/Array.html#method-i-each), etc.) More than offen, these codeblock
are kinda one-liners and woo-`do-|o|-end` magic makes a code looking overdriven:

```ruby
arr.each do |x|
  x.name
end.join(" ")
```

Well, there is curly-brackets-notation available, hence we may rewrite the code above within one line.
But there is still a lot of absolutely unnecessary garbage hiding the core of what’s being actually done.

The good news is: ruby provides us with a syntactic sugar for that stuff. Let’s look at this:

```ruby
arr.each (&:name).join(" ")
```

It is fully equivalent to the `do-|o|-end` codepiece above, but the readability is drastically improved.

How the hell does it work?

The `&obj` is evaluated in ruby in the following way:

 * if object is a `block`, it converts the block into a simple `proc`.
 * if object is a `Proc`, it converts the object into a block while preserving the `lambda?` status of the object.
 * if object is not a `Proc`, it first calls `#to_proc` on the object and then converts it into a block.

In our case 
the method is `#to_proc` on a `Symbol`’s instance (because `:name.class == Symbol`). The `Symbol#to_proc` method 
was originally added by `ActiveSupport` but has been integrated into Ruby since 1.8.7.

To enable this shorthand for classes other than `Symbol`, e. g. for an `Array`:

```ruby
class Array
  def to_proc
    lambda { |recv| recv.send *self }
  end
end
```

Now we can write:

```ruby
[ "Apple", "Orange", "Pear" ].map &[ :+, " is a fruit." ]
[ "Apple", "Orange", "Pear" ].map &[ :match, "[a-z]e" ]
```

yielding:

```ruby
 #⇒ ["Apple is a fruit.", "Orange is a fruit.", "Pear is a fruit."]
 #⇒ [#<MatchData "le">, #<MatchData "ge">, nil]
```

Methods are being called on array elements (on `String`s in the example above.)

----
Kinda same trick may be done for external methods using `&method` shorthand. Let’s say we have:

```ruby
arr.each do |x|
  get_fullname x
end.join(" ")
```

Thus, assuming we have the `get_fullname` method defined, we can rewrite it as:

```ruby
arr.each &method(:get_fullname)
```

In other words, 

```ruby
%w{ first second third }.map &method(:puts)
```

will print the array content out (expanding to `{ |s| puts s }`).
