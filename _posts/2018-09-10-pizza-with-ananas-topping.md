---
layout: post
title: "Hipe Demythified or Pizza With Pineapple Topping"
description: "Don’t blindly follow the paradigms. Here is why."
category: hacking
tags:
  - ruby
  - elixir
  - coding
---

## The Problem

This post is made mostly as a response to [Learning Elixir, Frst Impressions](https://elixirforum.com/t/learning-elixir-frst-impressions-plz-dont-kill-me) posted yesterday at [Elixir Forum](https://elixirforum.com). The real matter I have finally come to writing this would be I feel a necessity to sum up what I constantly tell to my colleagues, mates and wife. Here it is:

>
#### thou shalt not make into thee any graven image; do not worship anything or anybody blindly

This writing would consist of a number of modern hipe topics demythified (spelling intended.)

## Functional Programming Is The Path

If I were to publish this 10 years ago, the “OOP Is A Way To Go” would come first. Even that makes me think that taken as a doctrine it’s a bullshit. Functional programming is not better than procedural, object oriented, or even the one using assembly language and machine codes. The correct answer is “it depends.” Whether one is constantly producing new CRUD endpoints for the long-lived, stored in the database, tightly bound and twisted, objects—sooner or later they have Rails invented. Which is—I insist—way better for CRUDing basecamp entities than any fancy modern approach. That is the perfect tool to solve this particular task.

Not to solve _all the tasks_. Not to solve _your current task_, unless it’s similar to what DHH is solving for decades.

The same way being pure functional is brilliant when you are doing an academical talk entitled _Adjusting Models With Category Theory In New Generation Language Paradigm_, but when you are being paid for less sexy stuff, like doing what’s called Data Science in a startup, you’d better pick up `R` and/or `Python`. No matter how _pure_ and _elegant_ they are (they are not at all.)

Being functional might help, it might injure, it might even hurt. The developer might like it, might hate it, might use it, might be like “wut the heck is functional.” There is no goodness in function purity. There is no goodness in currying as is. I hear your objections, and here goes my answer: you are wrong. Data-first or data-last, currying or piping, purity or side effects—all that crap does not matter much. There are tons of different problems when strong typing is obstructing and impeding. There are great developers who never need currying (thank God.) Nobody should ever care whether data-is-last or data-is-first. Even data in the middle is fine, if it works.

And here we smoothly pass to the second myth.

## OOP Is A Way To Go

Nah. The father of OOP, [Alan Kay](https://en.wikipedia.org/wiki/Alan_Kay), the inventor of _classes_ and _objects_ said in the mid of 1990s:

> I'm sorry that I long ago coined the term “objects” for this topic because it gets many people to focus on the lesser idea. The big idea is “messaging.”

That does not mean _objects_ are not a good concept. Mutable objects. I said that. You heard me. Mutable objects are great, they are a better, cleaner and easier-to-get-to concept, than pure immutable data. After all, when we break the glass of our office fire siren alarm (trust me, don’t check it yourself, please)—we end up with a harrowing siren alarm _and_ a broken glass, not with a brand new broken glass _and_ an original one, untouched and intact. Objects are fine.

Everybody who had a chance to develop with [Apache Haddop](https://en.wikipedia.org/wiki/Apache_Hadoop) would tell you: this is a perfect example of extremely well put paradigm. Mappers and even reducers there are great because they are using unceasingly mutated objects. That’s more straightforward and less memory-consuming, and all that stuff.

Being object-oriented might help, but it might injure, it might even hurt. One should check what the real consequences of using an OOP paradigm are before going fully OOP. And even inside OOP paradigm, there are still many places where functional approaches work very well.

## Immutability Is A Silver Bullet

Bullshit. There are tons of applications where mutability is a pure virtue, besides aforementioned basecamps and hadoops. For instance, any task that involves a conveyor and some state-dependent local storage would make you life a nightmare if you cannot mutate the state.

## Strong Typing Is A Panacea

There are fashionable rumors all around pushing that strong typing drastically decreases the number of mistakes, allows to catch any error on compilation stage and even obsoletes testing. In academic test stands maybe. In fancy slides. Not in the real life.

Because real life is full of side effects. One gets data from third parties, from the internet, from the user, from the universe. And the universe (I am not talking about the users) is not strongly typed.

That does not mean I deny the profit from applying the category theory to computer science. Not at all. There are areas where it works pretty well. Unfortunately, there are areas where it does not. And being 100% strong types hinders there.

## Monads Are A Godsend

They are not. Sometimes they work. Sometimes they just bring a boilerplate of the inconceivable size for nothing. If the control flow is best described as a chain, each step might succeed or fail and we are to stop in the case of fail and immediately return the result—monads are great. But hey, how many processes in our lives are as straightforward? Even bringing `tee` monad makes the code piece an unreadable crap.

## The Summing Up

There is no pill. The salad is almost always more tasty than a cucumber, a tomato, or an olive oil. Pizzas are usually made from many ingredients. Try to order a pizza with salami. Literally: a piece of dough covered with cropped salami; roommates would consider you a nerd.

Don’t hesitate to pick the most applicable patterns from different paradigms and mix them to achieve the best result for this particular task. There is nor a prophet neither a fortuneteller who knows what’s best for _you_ and _your current problem_. And always ask for a weird topping, like pineapple or something. Here is the key to both most satisfactory and most profitable development process:

## The Gold Ratio

There were many languages invented because of the real need, with business goals in mind. Those are (including but not limited to):

- `c` to make an assembly language a bit more humane (and `rust` now as a great disciple)
- `erlang` to make a telecom work with millions of connections simultaneously
- `php` to make static webpages dynamic for no cost
- `javascript` to make drop-down menus and poison the `marquee` tag
- `haskell` to prove some mathematical concepts and make a perfect ideal academic language in a vacuum to teach students
- `java` to support enterprise-level scalability
- `ruby` to make programmers happy (according to Matz, and I agree)
- `go` to drastically decrease an entry level and learning curve to make it possible to hire teenagers

All of them are great in their niches. One might even write pure immutable fully-functional code with ruby, or spawn a million of parallel tasks with javascript. The thing is one should not abuse languages for what they are not good enough. Don’t be a slave of technology, hipe, fashion, public opinion, authorities.

Use the best from each world. Use strong typing when it applies and forget about it where it does not. Use currying if the language treats it as a first class citizen and avoid building a weird surrogates to support currying in the languages that are built with another control flow in mind. Benefit from `while(*dest++ = *src++);` implementation of `strcpy` where it makes sense.

I could have been providing examples for another hundred of pages, but enough is enough. There is no one single paradigm as by now that works well under any circumstances. Let me repeat: **don’t be a slave of technology, hipe, fashion, public opinion, authorities**. Pick up the set of patterns accordingly to the problem, not to what you are most familiar with, or love more, or were told is the best thing ever.
