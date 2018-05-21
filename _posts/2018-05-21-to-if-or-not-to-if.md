---
layout: post
title: "To IF Or Not To IF—That’s The Conditional Statement"
description: "Why do I consider using if operator to be a code smell"
category: hacking
tags:
  - “…”
  - elixir
  - ruby
---

This post is written mostly as a response to [that discussion thread](https://dev.to/genta/theres-no-else-if-in-js--24f9). I was advocating
to never use `if` conditional statement and many people were arguing.

**TL;DR:** The text below is very biased and opionated. That does not mean
it’s plain wrong. I consider `if` statements a code smell. Period.

I am not a blinkered moron, though, and I understand there are circumstances
under which `if` might be of perfect use. The rule having a dozen of
exceptions is hard to memorize, that’s why I state the rule as
“don’t use `if` statements.” “Unless you pretty fine understand why do
you use `if`,” adds my internal rubber duck whom I have proofread the
draft of this writing to.

---

## Stone Age

In the stone age there were no programming languages and to kindly
ask the machine to perform any operation, humans were using
[codes](https://en.wikipedia.org/wiki/Machine_code) that were understood
by the machine as is. One of the first books I was able to get on
programming was [one of these by Peter Norton](https://www.goodreads.com/author/list/163189.Peter_Norton). Sorry, Peter,
I do not remember which one. It started with a chapter explaining the
source of _Norton Disk Editor_ utility, written completely in machine
codes. Line by line. It looked like that (don’t try to run it, I just
randomly generated a garbage for the sake of an example):

```
61 01 67 30  30 8D 65 A4
E1 4C 9F 3F  96 B1 EB 85
F6 54 92 B8  51 E1 E5 7D
05 93 EC 2D  BF 10 34 FB
98 AD E0 96  B7 52 21 09
50 FA 45 59  05 DA 17 CB
6B 95 0C 4F  E7 24 60 1F
DE 5D BA F9  72 B7 F8 09
03 10 13 1A  8D 75 79 BF
5E 8D 05 B3  F0 2C F6 D8

```

I spent a week trying to understand the code and finally realized, I was
worse than any machine in understanding codes. (FWIW, I still am.)

I believe I was not the only person frustrated by the necessity to talk
to machines using _their_ language, and
[Assembly](https://en.wikipedia.org/wiki/Assembly_language) came to the scene.

That was indeed a huge step towards preserving sanity of human minds. Now the
program listing became ...uuuhm... readable:

```asm
mov al, 42
mov ah, .answer
cmp al, ah
jne .answer_err
```

_Move_ `42` to the register named `al`, _move_ the value of `.answer` variable
into the register `ah`, _compare_ values and _jump_ to `.answer_err`
instruction if values are not equal. If this is not a poetry, I don’t know what is.

The reason behind this structure of the code is that the CPU cannot
permorm some sophisticated operations, like “make a cappuccino.” It can
add integer numbers, and it can transfer a control. That’s it.

Note for those bored and falling asleep: I am not going to describe
the whole evolution process of programming languages. Actually, I just
wanted to show this piece of assembly because I am going to refer to it later.

---

## We Are Human Beings

Unlike computers, we don’t need to decompose compound tasks into the 
sequence of additions and conditional jumps. We just know whether we
want to eat an apple right now or not. There is no `if` implied there.
We don’t think like “if I want an apple, I’ll eat it, otherwise I won’t.”

This is important.

I don’t know how exactly it’s done inside my head (I have heard, even
neuroscientists are somehow in doubt,) but from my point of view it
looks like “Oh, an apple, I’ll take it.” Or I just ignore it. I don’t
think about what I’d do if I wanted it, I just damn don’t give a shit.
Pardon my appleish.

Every single morning, save for weekends, I am leaving my house, 
heading towards the office. I use a metro to reach the office building.
The route has one transfer. And, for the sake of this post,
I decided to write a code, that could deliver me to the office.

I am going to use ruby, but the syntax should be considered a pseudocode.

---

## Making Decisions

The first naïve attempt would be to use `if` to check if today
is a workday in the first place. Because, you know, I am not writing
my PhD anymore and I don’t work on Saturdays. Not in the office, at least.

That said, the early adopted intent would be to start with something like:

```ruby
if (1..5).cover? Date.today.wday
  go_to_the_office
end
```

Well, so far so good. The code is clean and easy to read. But wait,
on Tuesdays and Thursdays I go to gym:

```ruby
today = Date.today
if (1..5).cover? today.wday
  if today.tuesday? || today.thursday?
    go_to_the_gym
  end
  go_to_the_office
end
```

Oh, jeez, I have forgotten to mention that on Wednesdays I am working from home:

```ruby
1  today = Date.today
2  if (1..5).cover? today.wday
3    if today.tuesday? || today.thursday?
4      go_to_the_gym
5    end
6    if !today.wednesday?
7      go_to_the_office
8    end
9  end
```

At this point the code is already very hard to maintain. Also, there are 9 LOCs
and we all expect it should be easy to tell what the code is doing, but unfortunately
that’s not the case. The _real code_ there is actually contained in lines 4 and 7,
all the other stuff is about checking conditions.

_Sidenote:_ yes, I pretty fine understand this example is highly exaggerated,
there are postfix conditionals in ruby etc. But trust me: what had been started
as a single nifty `if` sooner or later will become this kind of spaghetti monster.
The road to hell is paved with good intentions.

## Stop Making Unnecessary Decisions

The pill would be to use so-called [“Fail-fast](https://en.wikipedia.org/wiki/Fail-fast)”
ideology. 

### OOP Approach

Once I decided to provide a ruby code snippets, and ruby is somehow
an object-oriented language, let’s start with just OOP to implement the desired
functionality. Prepare to see an unexpectedly huge boilerplate, but it’ll pay back
very soon (if one is writing a one-time-run shell script, I’d suggest to stop
reading this and go with an `if`.)

```ruby
module Schedule
  class Day
    def trip!
      go_to_the_gym
      go_to_the_office
      go_home
    end
    def go_to_the_gym
    end
    def go_to_the_office
      Metro.office!
    end
    def go_home
      Metro.home!
    end
  end
end
%w[mon wed fri].each do |wd|
  Schedule.const_set("#{wd.capitalize}Schedule", Class.new(Day) do
  end)
end
%w[tue thu].each do |wd|
  Schedule.const_set("#{wd.capitalize}Schedule", Class.new(Day) do
    def go_to_the_gym
      Metro.gym!
    end
  end)
end
```

Now we can _instantiate_ the respective class, basing on current week day
and call it’ instance `trip!` method. For both Saturday and Sunday this
instantiation would throw an exception, _which is just fine_ (assuming we
handle exceptions on the top level and don’t leak them as is to the user.)

### FSM Approach

[Finite-state automata](https://en.wikipedia.org/wiki/Finite-state_machine)
could be used instead of OOP. The code would be looking pretty much as in
the previous (OOP) approach, save for instead of different classes we’d
use different transitions from the state `home` depending on the day
of the week. One might argue that there will be `if`s, and I’d say yes,
but a) they might be completely avoided if desired and b) they are hidden
for the user of this FSM behind the proper abstraction. Also, SRP won’t be
violated.

Since Ruby does not have an FSM implementation in the core lib, I am
to omit the code example here. It’s more or less trivial.

### Pattern matching

Ruby does not support pattern matching out of the box, therefore we’d
use Elixir to demonstrate the control flow.

```elixir
defmodule Schedule do
  def trip! do
    go_to_the_gym
    go_to_the_office
    go_home
  end
  def go_to_the_gym(day) when day in ~w|tue thu| do
    Metro.gym!
  end
  def go_to_the_gym(day) when day in ~w|mon wed fri| do
  end
  def go_to_the_office
    Metro.office!
  end
  def go_home
    Metro.home!
  end
end
```

As in the OOP example, the code is readable, maintainable, and—most importantly—extendable.

### This Is Not True

Well, it indeed is. Whether in doubt, try to add the weekend activity to any
of the aforementioned approaches, then try to do the same with the very first
nested `if`s structure.

## Conclusion

Any time I found myself blindly typing `if ` I pause for a while and
talk to my internal rubber duck (her name is Jess, btw.) “Jess, is there any
way to avoid `if` clause here?” I ask inevitably. And you know what?—In most
cases she responds with “yes” and we invent a robust well-designed solution
for a problem together.

Sometimes she responds “no,” it’s a perfect use-case for an `if`, like
yesterday when I was to implement a function producing a string representation
of current time for an American audience. I ended up with

```ruby
if hours < 12 then 'AM' else 'PM'
```

I understand why I used `if` there (thanks, Jessica,) and it was a last resort.
It was a wisely made decision. There is no room for any abstraction. The calendar
and the string time representation are not going to change until I am retired.

In all other cases I ended up with a better abstraction, that saved me tons
of hours of refactoring, just because I had asked myself (and Jess) whether we could
do better than just `if`. And we usually did.

That is why I insist on memorizing the rule “`if` statements are a code smell, period.”
Even despite it sounds too cruel and arrogant. Vague and blurry rules always
lose. Solid rules do win. And they surely do have exceptions.