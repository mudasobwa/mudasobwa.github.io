---
layout: post
title: "URL Shortener"
description: "How Would You Design a URL Shortener Service Like TinyURL?"
category: hacking
tags:
  - elixir
---

One of my friends pointed me to [the solution](https://www.geeksforgeeks.org/system-design-url-shortening-service/) of kinda popular nowadays interview task. It is “How would you design an URL shortener service like [TinyURL](https://tinyurl.com/)?”

To my pity, I am an inquisitive person, that’s why I immediately jumped into reading it. What I read made me promise to propose my own solution, because accepting what is suggested there was hard if not impossible.

![Tramvia](/img/tramvia.jpg)

### How It Started

The aforementioned post starts with the wise bit of advice

> When you’re asked this question in your interviews don’t jump into the technical details immediately.

This is a great statement, I would even broaden it to “When you have a task to solve, don’t jump into the technical details immediately.” The time you actually type a solution using your keyboard should not increase 10–20% of the whole time spent on the task. Thinking in advance pays back better than fixing issues afterward.

But then the author rushes into the abyss of unjustified assumptions, framing themselves in the illusion of a lovingly constructed ivory tower.

> Let’s assume our service has 30M new URL shortenings per month.

No, please don’t. Do assume the service _might_ grow to handle millions new shortenings per month and be ready to scale. If you are hired to handle the existing traffic of 30M/m, you’ll be asked very different questions during the interview, like “what the existing service are we to buy,” trust me.

> To convert a long URL into a unique short URL we can use some hashing techniques like _Base62_ or _MD5_.

Eh. Before discussing what hashing technique to use, we should clarify the most important requirement: should we generate the new short URLs for the same long URL upon subsequent requests, or shall we return the already generated one. The latter approach is way harder to implement, but usually we don’t care about that. Here I went to [BitLy](https://bit.ly) and made sure they don’t. So won’t we.

The ability to not keep track of backward references (_Long_ → _Short_) makes it easy to forget about hashing at all and just use random sequences as _ID_, btw.

> Database

Wait, what? Who said we ever need a database? Then the author compares RDBMS against NoSQL, and comes to the controversial conclusion “handle this amount of huge traffic on our system relational databases are not fit and also it won’t be a good decision to scale the RDBMS.” That was the exact place in the original post where I decided, OK, I’ll write down how would _I_ handle it.

### How Is It Going

My approach would be slightly less biased from scratch.

- the service must be optimized for reads over writes
- we don’t choose the backend to store the links right away
- we start with an approach to handle _some_ traffic, keeping in mind the scalability

That’s it.

The cool story about the task is we don’t need the highly coupled storage, even more: we don’t need it to be coupled at all. The best approach to shuffle the requests between different “shards” (whatever it means in this context) would be [`Hashring`](https://en.wikipedia.org/wiki/Consistent_hashing), but there is an issue: changing the size of the hashring (scalability!) on the fly would result in rehashing, and this is not something we can afford. That said, the short link `abcdefg` should always go to the same _shard_, no matter what, and the number of shards is surely to be increasing.

Okey-dokey. Then what?

They say, programmers accept only three kinds of numbers: `0`, `1`, `∞`. Everything should be infinitely extendable. If I could create the third shard, I must be able to create the 1_000_000_003<sup>rd</sup> one. But I am not a real programmer by this definition, I’m perfectly fine the initial scaling up to `62` shards (and when we run out of it, I’d sell the business, or, shame to admit, will switch to 8-symbols short URLs.) That said, the first letter in the short URL would point to the physical shard, hardcoded. I am to start with the single instance, serving early adopters, named `a`. All the links would have `a` as a first letter. Like, `abcdefg` or `a8GH0ff`. Then, after first billion or so users, I’ll go with `b`. This is a nasty, inelegant hack, I hear you. But still, bear with me.

So far, so good. Now what do we do _within the same instance_? Oh, here is where `Hashring` shines. I’d create `N` separated storages (read: tables in the DB, or even directories on the file system,) where `N` is fixed. I am too lazy to calculate the exact number here, but it could be got by dividing the whole storage size by acceptable for the quick access substorage size. Some benchmarking would probably be required here. Let’s for now assume `N` is also `62`, just because `62` is a great number after all.

Upon the request to shorten the URL, I would produce the short `6`-symbols gibberish, prepend `a` to it (the current “prefix” denoting the actual physical shard/node), and check if it already exists in the storage.

If it exists, I’m to retry with the another one. If it does not, I would run `Hashring.who?(six_symbols)`, get to its local shard and store the key-value pair there.

An access to the long URL would be drastically fast:

```
abcdefg
^       physical nore/shard name
 ^^^^^^ local shard key to hashring
```

And then select from the storage by the key itself.

### Implementation

Remember, I said, there might be no need for _DB_ at all? All we need from scratch would be an interface looking like a pair of `get/1` and `put/2` (and maybe `delete/1`, but we can think about it later) functions. The naïve but robust implementation of this interface would be a bunch of directories on the file system, organized in the same way as linux distros keep packages: for the 7-symbols key it would be a path like `/hashring-id/b/c/d/e/f/g` where `g` is the file having content representing the long original URL. `inode`s work slowly when there are too many files/subdirectories in the directory, but here we have `62` tops on each level, so we are all set and the access would be instant. If it won’t, we’ll move to `62` tables in the RDBMS, or `62` shards in `NoSQL`, or whatever else.

That’s basically it.

### Further Improvements

We might easily keep the number of accesses via shortened link, as well as any other attached data. Even more, we might extend this approach to re-use short links, which would increase the write-time, but keey the access time the same (dealing with collisions would be the most interesting part of this solution, I’d leave its design to the astute reader.)

---

Happy shortening everything!
