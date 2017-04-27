---
layout: post
title: "Match or Not Die"
description: "Match string painless without superfluous if-then clauses"
category: hacking
tags:
  - ruby
  - tricks
---
Let’s imagine we want to regexp a string and print the capitalized match out.
We start with one of the followings:

```ruby
str.match(/(regexp)/)[1].capitalize
/(regexp)/.match(str)[1].capitalize
```

This works fine on matched strings. Being called on the input with no matches
it indeed results in annoying:

```ruby
# ⇒ NoMethodError: undefined method `[]' for nil:NilClass
```

So we come to spaghetti `if-then` checks like:

```ruby
m = str.match(/(regexp)/)
m1 = m[1] if m
cap = m1.cap if m1
```

We got bogged down in checking while the only goal was to write a oneliner to
either capitalize match or gracefully keep silent. Happily, ruby has a not
wide well-known way to perform exactly the task we wanted. It’s the 
`String#[regexp, fixnum]` method:

```ruby
(str.match[/(regexp)/, 1] || '').capitalize
```


