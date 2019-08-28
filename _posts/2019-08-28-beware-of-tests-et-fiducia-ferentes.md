---
layout: post
title: "Beware of Tests et Fudicia Ferentes"
description: "Post-mortem of one internal discussion on whether or not everything must be covered with tests"
category: hacking
tags:
  - elixir
  - erlang
  - ruby
---

![To test or not to test?—’Tis the question.](/img/platja-de-aro.jpg)

**Beware.** This writing is very biased and exaggerated. Don’t scroll down if your condition is unstable.

### Tests Are Our Saviors And Heroes

In the stone age there were no tests and developers were lacking the ability to produce robust software; the code was full of bugs and the whole development process was called “debugging.”

_There is nothing wrong with this, except that it ain't so._

[TeX](https://en.wikipedia.org/wiki/TeX) was released by _Donald Knuth_ in 1978.

> Donald Knuth offers monetary awards to people who find and report a bug in TeX. [...]
> Knuth has lost relatively little money as there have been very few bugs claimed.

Guess, how many many tests existed in the original TeX implementation.

Don’t get me wrong; I am not advocating back to live in the cave. Sometimes tests bring joy to our lives. But my concern is tests in general bring more harm than value to the modern development.

Yes, I said that, throw your stones at me.

In a nutshell, tests bring the excessive confidence whereas they usually prove things that are easy to reason about without any tests. Meanwhile tests hide issues, glitches, and pitfalls because “c’mon it’s all tested.” Yes, I know about _mutation_ and/or _property_ testing. They are great. Occasionally. In the vast majority of cases they are an extreme overkill, bringing a complexity into both maintainance and support. To areas, where it should not belong to at all.

102% coverage means both Dev and QA teams involved are very diligent and assiduous. And nothing more.

While I am not banned from the dev internet yet, let me get to the arguments.

### When Tests Are Great

Let’s start with listing applications where tests are great.

- pure functions (unit tests, doctests)
- cross-interaction (integration tests)
- unclear / non-trivial execution flow (property tests)
- concurrency
- cases where tests are easier to tackle with than REPL
- custom cases when you get an insight “I need to test it”

This is all clear, so let me get directly to the topic of this writing.

### When Tests Are Not Panacea

Tests won’t make the bad architecture any better, in the first place. Any coverage may at the best prove that the existing implementation **works as expected**. Which is way less valuable and important than the proof that the existing implementation is at least robust. I am not talking about being maintainable, flexible, and extensible.

When we deal with third-party service, we tend to mock it, and write a gazillion tests covering all the corner cases. We respond properly to `200`, `302`, `404`, `500`, etc. Do we really need all these tests? I doubt. All of them testing `case` operator in our language of choice. And you know what? Chances are it works properly. What could actually blow our application up is network latency, timeouts, malformed response. To test all these we do not need to mock anything. Perform a call to `http://localhost:200000` and see what happens with your code. Provide a sink-all clause with `rescue` or pattern-match the response to `_` and log it to some explicitly dedicated `unexpected.log`. 3rd-party service would use any chance to surprise you, don’t try to predict it. Log it and deal with it later.

Another case would be a trivial function like `def answer, do: 42`. Please, do not waste time checking whether it returns 42. It does. Unless you are writing the compiler for the new language, or course.

Do not test that `map` maps, `reduce` reduces. They were tested before they became a part of the language. Test things that you are uncertain in.

Sometimes it’s indeed handy to write a test and then write the code that should pass the test. People even invented the name for it: TDD. That’s all cool, but please let’s not fool ourselves. If it was easier to test the same behavior in REPL, we’d better do it in REPL. Because once written, this function works and the test on its own becomes _a legacy piece of code_, that makes a testsuite running forever. Leave two to make sure it works for some random input and it fails gracefully for some garbage passed. If you implementation of _Fibonacci sequence calculuator_ works for `42`, it works for everything else by induction (I am exaggerating here a bit, but still.)

Did I hear “Objection! Regression!” outcry or is this my mental issues? If you are aware of regression, there is something wrong with how you architect your project. The function should not break when the _input is extended_. Unless it is a function performing an explicit check for the fact that the input was not extended. And no one function in the world may _change_ the expectations for the input. That’s not how sane developers maintain their codebase. Backward compatibility is not a luxury, it’s a must. And it’s extremely easy to follow. Need an extended functionality? Create a new function dealing with this kind of input. Do not break the old one. Create new. That simple.

It’s getting too long already, so I am to sum it up.

Tests could be a tremendous help. In the cases I listed above. But tests never should be treated as an insurance that the code works, survives updates and even is somewhat robust.

A dozen of tests covering the calculation of the square root for different inputs won’t make it deal properly with some floats, because floats are broken. Using proper type for handling decimals in the project that requires math of that type costs more than all the tests on the Earth.

Proper shape of a supervision tree is hardly testable; it’s easy to reason about, though, and it’s easy to start `observer` and manually kill all workers, one by one, and see what’s happening. And this behavior won’t change in the future, until you’ve extended the tree. The thing is old tests would nevertheless fail now, so open REPL, start `observer`, click-through, make sure it works as expected, and forget about. Do not write tests. They have zero value here.

### What Now?

Now, when you have a lot of spare time, freed up because you stopped testing all sorts of nonsense, what do you do with it?

That’s easy. Write an extensive documentation. With samples of _how to use your code_. With reasoning about why it was done that way. With snippets that could be copy-pasted into external projects and _simply run_.

That is a hundred times more valuable than freaky testing controllers responding different requests.

Thank you and happy testing!
