---
layout: post
title: "Gospel of Barabbas or Concurrent Execution"
description: "The beginner-friendly explanation of what concurrency is and why it ever matters"
category: hacking
tags:
  - elixir
  - tricks
  - tutorial
---

![Concurrent Execution](/img/guillotine.jpg)

> “Premature optimization is the root of all evil” — Donald Knuth.

This is indeed true, unless it is not. People tend to snatch a phrase out of context and make the dictum out of it. This is indeed awful habit, but we all do that, specifically when the saying is vivid, concise, actually demanding to be graved in stone.

The sleep of reason produces monsters standing on the shoulders of giants. “Prefer duplication over the wrong abstraction” by [Sandy Metz](https://www.sandimetz.com/blog/2016/1/20/the-wrong-abstraction), while being _somewhat_ reasonable by itself, is a nonsense in general. It might be paraphrased as “prefer shooting yourself in the foot rather than in the head.” Or, “prefer worse over worst.”

If I had no choice but one of the above, I’d definitely pick up the duplication. But I live in the more or less free world, where we also have “good,” “better,” and even “best” solutions. Taken out of context, too literally, this wording loses the essence, even if there was any. That’s why I hate all these silver bullets for developers, arising from the ashes every decade to sink into oblivion a decade later. Ten years ago this goddamn hype panacea was TDD, nowadays it’s rich typing. All of those bring some goodness to the development process, both are by no mean 42 (nor the answer to the ultimate question of life, the universe, and everything.)

OTOH, there are paradigms and concepts sitting there for over half of a century. They are not as touted, but they indeed are applicable technically everywhere. AST on hand, VM for execution, isolated process memory, garbage collection, error isolation, preemptive multitasking. Many languages benefit from one or more of the above. Erlang benefits from all of them. And here we gradually come to the topic of this writing, to _multitasking_. **Each and every system in the universe, while growing, gets to the point of no return, where it becomes mandatory to serve several tasks simultaneously.**

There are at least three confusing terms, that are nearly synonyms, showing up when the “multitasking” is mentioned. Those are: concurrency, parallelism, asynchronous processing. Unfortunately, they do mean different things. In Layman’s terms, **parallelism** is used for **𝔸 executed when 𝔹 is executed**, **concurrency** is used for **𝔸 and 𝔹 are executed simultaneously, _interleaved_**, and **asynchrony** is used for **𝔸 has no contract to finish before it returns the control flow**.

As one might see, the latter does not mention _𝔹_ process at all; asynchronous processing has basically nothing to do neither with concurrency nor with parallelism. It’s worth it to mention, that “concurrency” is to some extent a subset of “parallelism,” and today we are going to talk about concurrency.

![Concurrency :: Courtesy of Merriam-Webster Dictionary](/img/concurrent-mw.png)

The image above appeared here only to dilute the wall of tedious plain text. While in CS we borrow words from English, they should be always treated as loanwords. The real meaning might vary.

Concurrent execution abilities imply three main things:

- the underneath software (VM and/or OS) should allow as many _execution contexts_ as we need;
- the intercommunication between _execution contexts_ should be somehow possible
- the _execution contexts_ should not become zombie, whatever it means.

I intentionally did not use words “process,” “thread,” and alike in the statement above, since multitasking might use OS processes, OS threads, VM lightweight processes (as in Erlang,) Modula2–like coroutines (as in Go,) and even the mixture of all of them.

Lightweight processes are in general more robust, because of their total count does not depend on the underlying OS limitations:

```sh
cat /proc/sys/kernel/threads-max
#⇒ 94389 # on your system this might differ
```

The number above might be adjusted as needed, but OS would not feel good when the number increases millions, and 1M of processes for ErlangVM is nothing to worry about.

---

When we talk about _multitasking_, we should distinguish between whether it is preemptive or not. According to [Techopedia](https://www.techopedia.com/definition/8949/preemptive-multitasking),

> Preemptive multitasking is a type of multitasking that allows computer programs to share operating systems (OS) and underlying hardware resources. It divides the overall operating and computing time between processes, and the switching of resources between different processes occurs through predefined criteria.
>
> Preemptive multitasking is also known as time-shared multitasking

The opposite to preemptive multitasking would be a “cooperative multitasking.” Cooperative multitasking is what makes _Java VM_ to stop the world to GC and _Go_ to become zombie when the amount of long-running go-routines exceeds an amount of cores on the target machine. Please don’t try cooperative multitasking at home or school.

The main advantage of using concurrent processing is involving all the compute power available. My laptop, having 8 cores, technically could process anything 8× times faster than in non-concurrent mode. Well, not _as_ anything.

> “I got 99 problems with performance.”  
> “So I used concurrency.”  
> “100 I Now problems. have”  
> — _inspired by [Perl Problems by Randall Munroe](https://www.xkcd.com/1171/)_

It turns out, we cannot simply instruct the process to run concurrently in a hope everything would eventually be right. It would work if and only results do not depend on history (read: on previous results.) Sometimes it’s true. Sometimes it’s not.

For instance, the factorial could hardly be computed concurrently. Reading and processing text files, on the other hand, is perfectly being parallelized. We just need to make sure we did not screw the order of rows up in the very end, and this is easy done with e. g. indexing.

---

Complicated business flows are usually a mix of what _could be_ parallelized and what _could not_. Often huge flows might be _somewhat_ parallelized into execution blocks that must be executed subsequentially (we usually call this process partitioning.)

Imagine we supply [John Napier](https://en.wikipedia.org/wiki/John_Napier) with a multicore laptop to alleviate his effort in producing _Mirifici Logarithmorum Canonis Descriptio_. Then he probably would feed the machine with numbers, calculate the logarithms _concurrently_, collect the result, and finally print the values _sequentially_, smaller to greater, to simplify search for those having no XXI century laptop on hand.

In the next chapter I am going to reveal how complicated business flows might be split into parts that could be processed concurrently to increase both performance and reliability.

Happy concurring!
