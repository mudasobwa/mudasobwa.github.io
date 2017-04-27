---
layout: post
title: "StackOverflow Achievements"
description: "Why we post answers on StackOverflow and why we should keep doing it that way"
category: hacking
tags:
  - ruby
---

This post should have been named “Open Letter to `@tadman`”. I decided to write it
when I got a “don’t do it” comment under my very correct answer on StackOverflow.

[Here is a link](http://stackoverflow.com/a/36775404/2035262), if anybody is curious.

For those, who does not like surfing, here goes the **tl;dr**:

> **Q.** I need to construct a 3D matrix out of existing data.

> **A.** One might use the [`Hash#default_proc`](http://ruby-doc.org/core-2.3.0/Hash.html#method-i-default_proc)
in the following manner:
```ruby
result = Hash.new { |h1, k1|
  (0...col1.size) === k1 ? h1[k1] = Hash.new { |h2, k2|
    (0...col2.size) === k2 ? h2[k2] = Hash.new { |h3, k3| do
      o3 = col3.detect { |o| o.id == k3 }
      o3 ? h3[k3] = Obj.new(col1[k1].att, col2[k2].att, o3.att) : nil
    } : nil
  } : nil
}
```
> **C.** This is one crazy intense nugget of code.

The comment above was given by the person, I know as being experienced,
highly professional, talented ruby developer. I put the disclaimer into my answer,
saying “please do not do it at home.” That’s it.

From this very moment I feel myself frustrated. I am convinced that:

* this code is not complex by no means;
* it is very maintainable, since it delegates everything to ruby internal
  implementation of `default_proc`, which I trust;
* it has an added value.

BTW, I would not ever have decided to write a post on the topic, just because
somebody thinks my code is ugly. I was mostly disappointed by indirect claim
that we should stick to giving answers in the “ruby for dummies” style.

I volunteer to StackOverflow for nearly five years. I deserve (and desire) some
payback. This is not about achievements, reputation, badges and +10s. This is
about my willingness to understand that I help people to learn. I am there not
because I want to write the code for others for free. I don’t. That simple.

I feel pity that nowadays the development process is not about R&D anymore.
It’s mostly about S&A (aka Search’N’Apply.) I don’t think I bring any goodness
to the universe by providing another piece of code, that might be copy-pasted
into some application without any thought.

Rails framework is so great that it is awful. It brings an ability to stop
thinking at all, just constantly apply patterns found in the internet. An
average Rails programmer requires neither research nor development. It is
sufficiently enough to `google || ask_on_so && copy_paste`.

And—let me repeat that—I am there on StackOverflow not to multiply the amount
of dumb snippets, that are to be blindmindly applied.

While I have an ability to demonstrate the technique, pattern, younameit—I am to
keep doing that. In hope, that maybe experienced and talented programmers won’t
consider the trivial codepieces like the one above as being “rather complicated
thing to throw at someone.”
