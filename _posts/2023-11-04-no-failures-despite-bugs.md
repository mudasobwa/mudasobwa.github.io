---
layout: post
title: "No Failures Despite Bugs"
description: "Part one of ‘four key developer skills’: how to guarantee fault tolerance even when your code has bugs—and why tests and types are a plastic bag on your head."
category: hacking
tags:
  - elixir
  - erlang
  - programming
  - fault-tolerance
---

_Part one of [four key developer skills](/hacking/2023/11/03/software-development-in-2023)._

> Ability to guarantee fault tolerance even in the presence of bugs in the code.

---

> Large systems will probably always be delivered containing a number of errors in the software, nevertheless such systems are expected to behave in a reasonable manner.
> ~ Joe Armstrong

Ever since the concept of “software” came into existence, people have been forced to live with the fact that it doesn’t always work as expected. Whether it’s a cockroach in the system unit, rats gnawing through a cable, a Norwegian construction worker accidentally slicing it with an excavator bucket, or even—terrifying to utter—errors in the software, introduced by a developer.

People have desperately fought against bugs in source code—Donald Knuth even [established a reward](https://tex.stackexchange.com/a/113658) for problems found in TeX. Unfortunately, Knuth’s approach scales rather poorly. In other words, we cannot ask him to write all the software in the world.

To minimize the number of bugs reaching users, humanity invented tests, types, code reviews, static analysis, and lord knows what else. But spending a couple of hours simply browsing the internet is enough to observe firsthand: none of it works worth a damn. Well, of course, if you measure KPIs, or whatever they measure, the first derivative shows a reduction in the number of bugs, and the second—the speed of that reduction. But if you just imagine yourself to be an ordinary person—nothing works.

Some bugs are non-critical, though still annoying. Literally just the other day I witnessed a user forget to switch their keyboard layout while entering a password into Gmail, and Google displayed an “Error 403” page. Seems fine: the login failed, there’s a specific error code for that, here’s your grenade. The user was thoroughly stumped by this page, decided they had done something forbidden—and wrote to me in near-panic. Grumbling about “user literacy” I leave with distaste to the dimwits who, themselves, think nothing of taking their car to a mechanic, dining at restaurants, and calling an electrician to tighten a tap.

Users will make mistakes—that’s normal. What’s not normal is showing them a `403` instead of simply redirecting them back to the login page. But all of this, I repeat, is non-critical.

The core problem is that programmers make mistakes too. And they will continue to make mistakes. And no tests-schmests and types-schmypes will save them (us) from this. Sooner or later we will introduce a critical bug. And our goal is to protect ourselves from that proactively.

The human brain is a complex thing, but one fact about it is well-established: it distorts objective reality, most often in the direction most convenient to us (the opposite behavior requires at least outpatient treatment). When I test the behavior of my piece of ...ahem... code, I knowingly deceive myself that these two obvious and three non-obvious cases will cover all possible scenarios. Then the tester arrives and tries to pass a lizard as a parameter. The programmer fixes the code. And then the [product ships to users](https://www.reddit.com/r/Jokes/comments/prdi4x/a_software_tester_walks_into_a_bar/).

In every piece of writing longer than a limerick I recommend [Property Based Testing](https://en.wikipedia.org/wiki/Property_testing)—I’ll recommend it here too. This technique will help relieve the tester of duty and keep his lizards at home. But it won’t protect against a non-obvious bug that manifests, for example, when the clocks are moved forward for daylight saving time.

So what is to be done?—Just listen to what Joe Armstrong was saying more than thirty years ago: bugs in code will always exist. Trying to eliminate them with tests and types is like defending yourself against a downpour by putting a plastic bag on your head: your head stays dry, but you look like an idiot, and everything below the neck is soaked through.

What then? Well, for starters, accept that bugs will always exist. You won’t be able to fix them all (unless you are Donald Knuth, of course). After the “acceptance” stage—you might try reading what Joe goes on to say about this.

And what he says is roughly this: in all unexpected cases—stop execution. Do not try to cover every possible path a situation might take. Handle success and the expected error where that makes sense (for example, on a failed login—redirect to the login form). In all other cases, including a lizard crawling in over the network—stop execution. In Erlang, this principle gave the language its famous slogan “Let it crash!” Which means: if something has gone wrong—fail immediately. Code only the narrow road of correct, expected execution—as narrow as a Formula One track.

Then the bugs you do introduce will also be handled—not all of them, but many.

Now simply restart the execution that led to the failure, with the same input data. Something unforeseen may have happened—a connection limit exceeded, a third-party service not responding, anything at all. This is not the time to investigate; just try again. Yes, it’s like the famous “have you tried turning it off and on again”—and it works sometimes. If something else depended on your piece—restart that too. Automate this restart so you don’t have to write it from scratch every time or copy-paste it from the previous project. If after a number of attempts it still hasn’t worked—dutifully dump the error to the log and skip this particular set of input data (without losing it).

Congratulations—we’ve just reinvented an underspecified, buggy, and slow implementation of half an Erlang supervisor tree. The Kubernetes people went roughly down this road too: they even managed to sell their pitiful copy of OTP to the people who swim exclusively in the mainstream.

With this simple trick you can forever protect yourself against unexpected failures: if a failure is normal, expected behavior of your program—it automatically transforms from a repulsive caterpillar into a beautiful butterfly. The most remarkable thing is that such an ecosystem is, in principle, not terribly difficult to implement even in Go—but the language’s concepts inherently assume violence against the programmer rather than lightening his burden, so I doubt anything like this will ever appear there. Especially given that Kubernetes exists and you can just not bother—simply restart the entire world, cooling down the misplaced enthusiasm of the cache, serving `503`s, and generally tormenting your users in every way imaginable; but the entire industry has spent decades working to ensure that users have grown accustomed to being hated and nothing working.

[90% of all internet traffic is handled by Erlang](https://twitter.com/guieevc/status/1002494428748140544)—and this is no accident whatsoever.

Allow me to quote one more passage, explaining precisely what problem Joe Armstrong was solving (and solved).

> At the time, Ericsson built large telephone exchanges that had hundreds of thousands of users, and a key requirement in building these was that they should never go down. In other words, they had to be completely fault-tolerant.

Like all brilliant solutions in life, this one turned out to be fairly simple. To simplify it even further—one must completely forbid object mutability, implement lightweight processes, and allow them to communicate exclusively through asynchronous messages. Then everything described above simply falls into your lap as a gift: supervisor trees practically require no special implementation—they emerge almost out of the box on their own. But that is perhaps a subject better left for next time.
