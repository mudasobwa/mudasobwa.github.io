---
layout: post
title: "Beware of YAGNI"
description: "How to stop procrastinating and start to be a good developer"
category: tips
tags:
  - tricks
  - dwim
---

> “You aren't gonna need it” (_acronym:_ YAGNI) is a principle of extreme
> programming (XP) that states a programmer should not add functionality
> until deemed necessary.
>
> XP co-founder Ron Jeffries has written: “Always implement things when you
> actually need them, never when you just foresee that you need them.”
>
> <small> [You ain’t gonna need it @Wiki](https://en.wikipedia.org/wiki/You_aren't_gonna_need_it)</small>

This is the most misinterpreted and hence awful, hazardous, and detrimental
principle ever stated in the Book of the Wrong Advises for Developers.

As far as I can tell, originally it meant “Don’t install a fifth wheel on your
car unless you are participating the 5-wheeled-cars-rally.” Nowadays it’s widely
used as an excuse to reject doing their job from the lazy and arrogant
developers. I rarely agree with Martin Fowler, but this is a brilliant wording
explaining the issue:

> Yagni only applies to capabilities built into the software to support
> a presumptive feature, it does not apply to effort to make the
> software easier to modify.
>
> <small> [Yagni @MartinFowler](https://www.martinfowler.com/bliki/Yagni.html)</small>

This principle works well when a Smart Senior Developer does a code review for
an ambitious young Junior, who wants to conquer the world with their first PR.
Being given a task to implement a flag in the user profile, denoting whether
the user is active or not, Juniors often tend to invent a whole General Purpose
Flag Subsystem. With an embedded LISP implementation for easy DSL, running
in the cloud as an independent microservice, written in Lua to make it possible
to launch it as Nginx plugin.

In that particular case YAGNI multiplied by the authority of this Smart Senior
does the trick: the flag remains the boolean column in the database, the task
is delivered in time (meaning, in this century, as an opposite to what was
proposed by the proactive Junior) and everybody (including the business) is happy.

> Truth is mighty and will prevail. There is nothing wrong with this, except that
> it ain't so.
>
> <small> Mark Twain</small>

That’s the thing. Even a kitchen knife might be used to kill people, and this
YAGNI concept is a perfect example of such a menace. It’s a great excuse to
reject nearly any CR suggestions: “this already works, _yagn_ anything else,
period.” Unfortunately, in my experience 9 out of 10 times I accepted YAGNI
argument, it resulted in _me_ implementing the stuff we were not going to need.
Usually it happens in a month, sometimes—tomorrow. In some cases it was not only
implementing what I suggested, but _completely rewriting_ the whole code piece,
because _that_ YAGNI implies unmaintainable, not ready for extensions code.

In 1930s Pepsi-Cola launched 12oz bottles fighting Coca-Cola’s domination.
Coca-Cola responded with YAGNI and lost 30% of the market.

In 1970s Toyota, Nissan, Mistubishi and smaller Japanese companies made
a bid on low fuel consumption. YAGNI, responded American autoconcern and
lost nearly half of the market in the next decade.

Nowadays every single YAGNI used as an excuse for unwillingness to accomplish
the task considering all the consequences, results in 10× times to recover from
the YAGNI-code. Which is nearly always unmaintainable, error-prone and
not ready for any subsequent changes. The rule of thumb would be:

> _While in code review, the reviewer might use YAGNI to prevent a waste of time_
> _on unwanted and/or unexpected features. The code owner has no right to use_
> _YAGNI as an argument to proof their delusion and/or reluctance to make the_
> _code friendly to future changes._

That simple, thus it works.

And, the last but not the least: never, never excuse yourself with YAGNI.
There are usually many people all around: team leader, project manager, product
manager, CTO, CEO, your spouse whining about you spend too little time with them,
to prevent you from doing a redundant stuff. There are many, many colleagues,
who will tell you ‘YAGNI’ when needed. But as soon as you have caught youself
choosing the easiest path because of YAGNI, find the strength in yourself to
resist. Unless you are going to qualify as Development Evangelist and Coach in
Silicon Valley next year, of course. There works any garbage.
