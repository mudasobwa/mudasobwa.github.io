---
layout: post
title: "Stop Abusing Nihil"
description: "nil / null is a perfectly valid useful first class citizen in many languages, and here is why"
category: hacking
tags:
  - elixir
  - ruby
---

> I call it my billion-dollar mistake.  
> <small><em>Sir Charles Antony Richard Hoare</em></small>

![Sequoia Gegant](/img/sequoia.jpg)

This quote quickly became famous amongst static typing adepts,
pure functional programming evangelists and many other cults disciples.
The truth is Tony Hoare never mentioned **`nil` value**. The full quote is:

> I call it my billion-dollar mistake. It was the invention of the _**null reference**_ in 1965.

Emphasis is mine. Null reference! It has nothing to do with `null` in _Java_, which is a pass-by-value.
But _Kotlin_ authors seemed to not bother reading the whole quote and they indeed re-invented the wheel.

> Kotlin makes a distinction between nullable and non-nullable data types. All nullable objects must be declared with a "?" postfix after the type name.  
> <small><em>[Kotlin @Wiki](https://en.wikipedia.org/wiki/Kotlin_(programming_language))</em></small>

I doubt there are any reasons of doing that besides the religious worship to the strong typing hype.

---

The truth is in the real world _everything_ is nullable. When I come home in the evening my fridge
might serve me a beer, a sausage, or an apple — depending on how good was my day.
When I am back from my vacations, there is _nothing_ in the fridge. None. Nihil. Nil. Null.

I cannot tell (and nobody could,) there are three different `nil`s:

- `nil` of nullable beer,
- `nil` of nullable sausages,
- `nil` of nullable apples.

5 years old would tell you this is bullshit. There is just one `nil` in my fridge, meaning _there is nothing in there_.

And here we come to the main mistake people using languages having `nil` objects make all the day.
Developers tend to distinguish “no value” and “nil value.” Which is a complete nonsense either.

Joe Armstrong nailed the proper way of developing computer languages:

> Once you’ve split the world into parallel components, the only way they can talk
to each other is through sending messages. This is almost a biological, a physical
model of the world. When a group of people sit and talk to each other, you can view
them as having independent models in their heads and they talk to each other through
language. Language is messages and what’s in their brain is a state machine.
This seemed a very natural way of thinking.  
> <small><em>[Let's #TalkConcurrency with Joe Armstrong](https://www.erlang-solutions.com/blog/let-s-talkconcurrency-with-joe-armstrong.html)</em></small>

This is applicable to the software development process in general. Abstractions
should be as adhered to our real life as possible. Nature in any case does it
better than we.

I’ll tell nobody, feel free to share: did you ever carefully handle `nil`s in your hashmap values using
[`Hash#fetch`](https://ruby-doc.org/core/Hash.html#method-i-fetch) or how would it be called in your
language of choice?

```ruby
foo = hash.fetch(:foo) { |key| raise "Key #{key} is missing!" }
```

If the answer is yes, you are doing it wrong. I have been there for almost twenty years too.
I carefully handled corner cases, I kept `nil`s where they belongs, after all one still might
query `Hash#keys` and we must return those _existing but having `nil` values_.

Nope. `hash[:foo]` is good enough. And the healthy `Hash#keys` function should filter out the
keys having `nil` values:

```ruby
def proper_keys(hash)
  hash.map { |k, v| k unless v.nil? }.compact
end
```

Let me state it again: `nil` means an absense. Value `nil` means there is no such thing.
Absense of a key means there is no such thing. They are identically equal. That simple.
If you are using `nil`s for denoting somewhat else, you are doing it wrong. Somewhat else
desires its own type. If you need to explicitly state somewhat else, create a typed
object and make it having a state. But when there is _no such object_, `nil` is pretty good.

Purists loudly advocate nullable types, monads, all that crap,—might not only help us
to catch errors on compilation stage (static code analysis stage for interpreted languages,)
but it even might obsolete tests. Well, maybe. In academical research papers dealing with toy datasets.
But in the real life, the code as _νούμενον_, as Kant’s _Ding an sich_ makes a little sense.
To bring a value, the code must deal with some input data. And unless you are
a prison director, you are hardly able to convince your users bringing input data
to always provide a bullet-proof valid datasets.

So the validity check would be still needed. And instead of dealing with enormous
boilerplates of instances of nullable types, just resort to `nil`. That is my gained
by blood and sweat advise: use `nil`s to denote an absense. Because an absense of
a lemon does not differ from an absense of two apples. We do not receive from the user
_the nullable absense of password_. We just do receive nothing. Maybe they
wanted to send us a token instead, but failed. The intent does not matter at all.
If `params['password']` returns `nil`, we should consider the data lacks a mandatory
field. No matter whether we have a key `'password'` in our hash with `nil` value,
or we don’t have such a key at all.

---

In _Ruby_ we can check if the value is there explicitly with `foo.nil?`. In _Elixir_
we might pattern match on `nil`s:

```elixir
def foo(nil), do: :error
def foo(value), do: {:ok, value}
```

Even _Javascript_ allows an explicit check for `null`/`undefined` (having both is
not a billion-dollar mistake, but it is surely a mistake that is worth a couple of grands;
`null` is literally `undefined`.) But people continue shooting their own legs
overcomplicating natural things and bringing stillborn abstractions like
[_Null object pattern_](https://en.wikipedia.org/wiki/Null_object_pattern),
_Rails_ `Object#try` method, `C#`/`Ruby2.5+`/`Kotlin`/...
[_safe-call operators_](https://en.wikipedia.org/wiki/Safe_navigation_operator), etc.

There is no scenario in which the following method should be called if there is
a value, and _simply ignored_ if there is not. Well, actually I could come up with
some contrived examples, like “send email if the address is there, do nothing otherwise,”
but it is still a code smell and a clear sign of a design flaw. If we are to perform
an action on presented value, we _likely_ are to take some other action on its absense.

Either we want to send an email, and then we should enforce the user to provide it,
or we don’t bother and the whole call is redundant.

Yes, I am exaggerating a bit, but in general it works that way.

Use `nil` where it belongs to. Don’t let religious fanatics to spread their monads
everywhere. Types are fine when they are applied as `@spec`s in _Elixir_. Aside.
Waiting there for the static analysis. Not sticking a stick in the wheels and
not getting in our way. We are mature enough to decide ourselves, whether we want
to allow `nil`, or gracefully reject, or fail fast, or whatever.

Happy nulling!
