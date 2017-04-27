---
layout: post
title: "New Hash Syntax for the Rescue"
description: "Why using new hash syntax might significantly improve the code quality"
category: hacking
tags:
  - ruby
---

Ruby 1.9 introduced new hash syntax: instead of cool hashrockets there came something barely
looking as native Ruby. It was more like a javascript injection (or should I’ve called it infection?)

```ruby
    # { :foo => 'bar' } # legacy syntax, do not use
    { foo: 'bar' }      # cool new syntax, inspired by, well, json
```

I am not a slave of my habits and customs. When I join new development team, I study
the style guide book (or, frankly, it is usually style guide page, or even style guide link.)
Whether my colleagues are to put the opening curly bracket on the same line as function
declaration, I would do it (though it is obviously unreadable, misleading and insane.)

So, years ago I switched from fancy hashrockets to silly wonky colons. After all,
it saves a keystroke per hash key. Only yesterday I realized, why using colons is safer
and leads to the better, less error-prone code in general.

Everybody who ever used Rails, should be aware of `with_indifferent_access` helper, that
Rails brings to hash instances. It allows us to not bother whether the keys are strings,
or atoms (symbols.)

```ruby
    hash = { 'foo' => 42, :bar => 'baz' }
    hash['foo']                        #⇒ 42
    hash[:foo]                         #⇒ nil
    hash.with_indifferent_access[:foo] #⇒ 42
```

That is cool, but once we’ve forgotten to call this magic 23-symbols-in-name helper method, we
lose. The performance penalties on using this methods are also obvious.

With the new syntax, though, one would never make such a silly mistake. We are now forced
to use symbols as keys, unless the intent of using string / object is clearly stated. No more
pain in the ass grepping for “did I make this key a string, or a symbol?”

And you know what? Ruby 2.3.0 makes this even more standard, allowing strings as hash keys
in the new syntax. They will just be converted to symbols:

```ruby
    ▶ hash = { a: 5, 'b': 6, :'c' => 7 }
    #⇒ { :a => 5, :b => 6, :c => 7 }
```

Farewell, my dear Rails helper friend, `with_indifferent_access`. You are out of business.
