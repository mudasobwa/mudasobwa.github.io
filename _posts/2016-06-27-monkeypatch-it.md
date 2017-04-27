---
layout: post
title: "Monkeypatch It!"
description: "In Ruby, we love and hereby use monkeypatching"
category: hacking
tags:
  - ruby
---

More than one month ago, [Piotr Solnica](http://solnic.eu/about.html) wrote
a manifesto [My time with Rails is up](http://solnic.eu/2016/05/22/my-time-with-rails-is-up.html).

I felt myself agitated. I waited—while the foam settles—on purpose: I wanted to express
my opinion, unbiased and calm. I kinda agreed completely, but as time was passing,
I was getting an impression that I was zombied. After all I love all that mess,
I love open classes and monkeypatching for it’s incomparable ability to bring
elegance to where it never has belonged.

Once one month elapsed, I am ready to articulate my opinion: in Ruby,
**monkeypatching is one of the best things all around and should be used extensively**.
Yes, I said that. I do and I will use monkeypatching (refinements where it’s appropriate,
and monkeypatching elsewhere.) An axe is a great tool, but when one wants to
install the screw, she’d better use a hammer. Or a screwdriver, whether she
is graduated in cabinetry.

Ruby is all about _elegance_, _intuitively clear solutions_, _fast ans pleasant
code creation_. Nobody sane would use Ruby as is there in low-memory devices,
real-time systems, high-load message processing etc. Once twitter succeeded,
guys left Ruby. Not because Ruby is bad, not at all. Because Ruby is just
not about that. Failure of an axe to install screws [in robust way] does
not make an axe the bad tool in general.

Cooking a dinner for myself, I fry steaks _and_ seethe potatoes. I have salted
cucumbers, pickled pepper, sauces and drinks: all that _frontend_, you know. But
even for _backend_ I have the steaks and the potatoes.

I have beach shoes and office shoes. I have desktop and notebook. I use Ubuntu
at home and Gentoo at work. I believe you got the point.

What LOC is more readable, elegant and _easier in general_:

```ruby
elapsed = 2.business_days('EUR', 'USD').after(Time.zone.now)
# or
elapsed = BusinessDaysFactory.for_currencies('EUR', 'USD')
                             .add(Time.zone.now, 2)
```

---

Ruby yielded it’s popularity because of Rails. I _am not_ a fan of Rails. But
I am mature enough to face facts as they are: unless Rails existed, we’ve got
two popular scripting languages only: `php` and `python`.

Rails yielded it’s popularity because of monkeypatching. It is proven to work,
to be robust, to be maintainable and to continue producing success stories for
startups.

So, unless you are an academician, writing your seventh PhD thesis on functional
patterns in Haskell, please, get your hands off monkeypatching. It is by no means
bad pattern. Even more: _it is a great pattern_, while used where it is
applicable to.

---

I’ve had a colleague, who was geeky on pattern matching. Pattern matching is a
great feature, that is not a part of Ruby. That simple. He tried to bring
pattern matching to Ruby, he even implemented sorta working prototype... The only
problem is that Ruby has an aversion to it. Ruby existing syntax just rejected it.
Ruby is a perfect language, but whether you need pattern matching, please,
consider to switch to Erlang/Elixir/±20 other languages that have it natively
supported. Ruby just has not.

On the other hand, as you have chosen Ruby, please, stop tinkering anything else
out of it. Use monkeypatching. Use open classes. Use criptic variables. Create your
own `.rubocop.yml` file, allowing non-ascii method names, increased cyclomatic
complexity and multiline block chains.

Ruby does not need a plastic surgery, it is beautiful enough as it was conceived.
