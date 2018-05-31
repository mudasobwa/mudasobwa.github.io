---
layout: post
title: "Ruby Challenges as QotD"
description: "The selected challenges from our company’s weekly Monday greeting"
category: hacking
tags:
  - ruby
---

## Intro

In our company we have a custom to have weekly challenges. Once a week,
sometimes more frequent, sometimes more rare, we publish to slack channel
the small ruby challenge. The reason of doing this is mostly to stretch the
cerebral muscle and/or learn some new fancy ruby tricks.

Below are the top 10 challenges (on my own taste). Feel free to pick some
to interview ruby developers.

## Quizzz

What will be printed?

```ruby
print ?A<<?A.to_i(16)
```

---

What would be the output executing this?

```ruby
enum = (1..3).each
print enum.next
enum.each { |i| print i }
enum.next
loop { print enum.next }
```

---

What would be the result of the following code?

```ruby
def m(o)
  o << '_O'
end
o = 'O';
"#{o} | #{m o} | #{m o} | #{o}"
```

---

What would be printed in both cases?

```ruby
def foo1(**kw); puts kw; end
foo1(arg?: 42)

def foo2(arg?:, **kw); puts kw; end
foo2(arg?: 42)
```

---

What would be the difference between `instance.is_a?(MyClass)`
and `instance.class <= MyClass`?

---

What would be the result?

```ruby
def a1
  :normal
ensure
  :ensure
end

def a2
  return :normal
ensure
  return :ensure
end

def a3
  :normal
finally
  :finally
end

def a4
  return :normal
finally
  return :finally
end

[
  (a1 rescue :raised),
  (a2 rescue :raised),
  (a3 rescue :raised),
  (a4 rescue :raised)
]
```

---

Correct the function below so that it completes successfully.

_NB:_ relatively hard.

```ruby
def print_down_to(input, down_to)
  p input
  print_down_to(input - 1, down_to) if input > down_to
end
print_down_to(1_000_000, 1)
#⇒ .... lots of integers
#⇒ ** SystemStackError
```

---

What would be the output of:

```ruby
true == true == true
```

---

What would this code produce?

```ruby
[*?a..?z].each do |e|
  next unless (e =~ /[aeiou]/)..(e =~ /[aeiou]/)
  print e
end
```

---

Given a huge array of integers, calculate an amount of `1`, followed by `2`
(not necessarily immediately). The solution must be not worse than `O(N)`
(and `O(1)` on memory.) E.g. if the list is `[3,1,2,2,1,1,1,3,2]`,
the answer would be `2` (indices `1` and `6`.) Ask me for hints and tips
(mine is 36 symbols.)

_NB:_ relatively hard task (50+ symbols solution is relatively easy.)

---

## Happy Challenging!
