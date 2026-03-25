---
layout: post
title: "Divide et Impera"
description: "Part two of ‘four key developer skills’: how to break a system into isolated parts, why SRP is the only principle in SOLID worth knowing, and why anyone who says code can’t be tested in isolation should be shown the door."
category: hacking
tags:
  - elixir
  - erlang
  - programming
  - architecture
---

_Part two of [four key developer skills](/hacking/2023/11/03/software-development-in-2023)._

> Ability to break the whole into parts and implement small pieces of a large system in complete isolation from one another.

---

“Divide and conquer”—a time-tested slogan reflecting the strategy for managing large projects, empires included. In English it’s usually rendered as "divide and rule" or "divide and conquer." You’ll notice that the second verb varies considerably across time—from "conquer" through "rule" to "govern." The first, however, is immovable, cast in bronze: _divide_. Slash. Cut the excess from the marble block. Gnaw off your own leg to escape the trap. But I digress.

Whenever humanity invents something new, it first tries to master it by brute force, and then applies well-worn tactics. Programming was no different: at first everyone rushed to bash out code, attempting to write "War and Peace," and then decided to muddy the waters and, like wound-up toys, began inventing all manner of practices, and—forgive the word—patterns.

I never knew what "[SOLID](https://en.wikipedia.org/wiki/SOLID)" stands for, because apart from SRP, all the other principles in there are extremely contradictory and generally inapplicable due to their incorrectness. SRP, however, is applicable at all times, and in any application—it ennobles the code, often beyond recognition.

In any course of lectures, in any conference talk, I always say: take scrupulous care to ensure that every piece of your code performs exactly one task, exposes a clear API, and is packaged as a library—not dragged wholesale into the main project. Need spline interpolation?—A library, with its own tests, with a single exported function. Some peculiar grouping operation?—A library. A different grouping?—Extend the exported API of the previous library. Logging in the application?—A library, your own wrapper over the standard logger. And so on. Only bare, dry business logic has the right to live in the application itself.

This approach comes with several pleasant side effects at once:

- if a bug is found, it’s far easier to fix in the library than in a gigantic project;
- if a colleague needs logging, they’ll use your implementation and the logs will be consistent;
- if you want to test calls to the library, it can export [convenient helpers](https://hexdocs.pm/finitomata/Finitomata.ExUnit.html) for that purpose;
- if the library needs new capabilities, you can cover the new API with [mocks](https://dashbit.co/blog/mocks-and-explicit-contracts) in five minutes and continue developing the application;
- if the library isn’t coupled to business logic, you can always open-source it and get +5 to testing, +10 to new features, and +50 to karma.

When I hear that "this feature can’t be started until that ticket over there is closed," I want to strike the speaker with a keyboard. How are you going to test it, you muppet, if it’s coupled to third-party code? How can you be confident it works at all, if without someone else’s code—it won’t even start? Why on earth did you go into programming, you numpty, when there are so many wonderful professions around—excavator operator, poet, TikToker.

**If anyone tells you that code cannot be tested without other code, or that this particular function is designed to process data, write to the database, and brew coffee simultaneously—that person is a saboteur and should be shown the door.**

Any code can be tested in isolation from the project (integration tests are an entirely different matter). Any code doing three things at once can be split into three different places and tested separately, independently of one another. Anyone currently itching to produce a counterexample—would do well to cool down first and try following the advice given above. It’s rather stupid to suddenly make a fool of yourself over such a trifle.

Strive to ensure that every cup in your dinner service can be used on its own. It’s foolish to take out, dirty, and then wash the soup tureen and 24 saucers—just because you had a cup of coffee.
