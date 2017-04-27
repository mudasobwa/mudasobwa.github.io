---
layout: post
title: "Recursion Without Explicit Method"
description: "Ruby way to organize recursion with infinite loop"
category: hacking
tags:
  - ruby
---

Recursion is being associated with evaluating factorial. There are well-known common approaches to
implement is in ruby:

```ruby
(1..num).reduce(&:*) || 1
```

There are more sophisticated methods, like one presented [here](https://bugs.ruby-lang.org/issues/9528)
(AFIUK, the patch was not accepted.) OK, ruby is friendly in building recursive functions, unless
one tries to accomplish something a bit less trivial than factorial calculation. In other words,
the complexity comes with unknown iterations count.

Let’s imagine we want to build the breadcrumbs for one deeply nested page on a website. For unknown
reason, we have a page structure stored as hash:

```ruby
page = {
  title: 'Contacts',
  parent: {
    title: 'Everything',
    parent: {
      title: 'Additional',
      parent: {
        title: 'Landing'
      }
    }
  }
}
```

Common approach would be to declare a method, receiving hash and recursively call it subsequently,
until the nested hash is absent. I could imagine something like that:

```ruby
def navigate hash, memo = []
  navigate(hash[:parent], memo) if hash[:parent]
  memo << hash[:title]
end
navigate page
#⇒ [ 'Landing', 'Additional', 'Everything', 'Contacts' ]
```

But wait, we already have memo! Can we get rid of redundant method? Sure.

Infinity is cool. Ruby has an infinite method [`Kernel#loop`](http://ruby-doc.org/core-2.2.0/Kernel.html#method-i-loop).
Let’s take advantage of it, since we can not predict how many iterations we’ll need after all:

```ruby
loop.inject({result: [], hash: page}) do |memo|
  memo[:result] << memo[:hash][:title]
  break memo[:result] unless memo[:hash] = memo[:hash][:parent]
  memo
end.reverse
#⇒ [ 'Landing', 'Additional', 'Everything', 'Contacts' ]
```

One might claim, that the former variant with a method is cleaner, and I must admit: yes, it is.
I just wanted to demonstrate the technique and prove, that infinite `loop`s are useful. Sometimes.
And yes, I know, this is not a canonical recursion. Anyway, I like it.

Turning back to factorial evaluation:

```ruby
loop.reduce([1, 6]) do |memo|
  memo[0] *= memo[1]
  memo[1] -= 1
  break memo.first if memo.last.zero?
  memo
end
#⇒ 720
```

Not the best example to advertise the power of infinite loops, huh?
