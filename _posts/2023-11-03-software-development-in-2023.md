---
layout: post
title: "Software Development in 2023"
description: "Four skills that actually matter in 2023, or: a blanket glorification of Elixir masquerading as a balanced opinion piece."
category: hacking
tags:
  - elixir
  - erlang
  - programming
  - opinion
---

I was tempted to call this piece “five myths” to fully merge in ecstasy with the bullshit that has been pouring into the ears of the conscientious reader lately, but it seemed like overkill.

I’ve been writing code since 1986, when my Euclidean algorithm in Fortran booted on the third attempt from punch cards on an ES-1060. Since then I’ve written in so many different languages that I’ve lost count. For roughly a dozen of them I’ve been paid actual money. All my life I carefully avoided any managerial roles, but CEOs turned out to be perceptive, and after some time I’d find myself with actual human beings reporting directly to me. I wanted to write code and wasn’t particularly dreaming of associating with my own kind.

The greatest compliment I’ve ever received in my life was a casually dropped phrase by Roma Ivanov, when at some meeting about product development at Yandex (the only time in my career when my job title on the payroll contained the word “manager”), I started going deep into technical implementation details and someone waved their hand: “What does it matter, you won’t be the one implementing it anyway!” Roman snorted and loudly muttered: “Him?—He will.”

When the HR department at my current firm went berserk and issued a demand—for that salary, this person ought to have their own team—the CTO met me halfway once again, and now I officially head “Aleksei Team,” consisting of one person.

---

In the time I’ve been pressing buttons on a keyboard for sustenance, several eras have come and gone. Someone else’s code finally acquired something resembling documentation. Programming languages proliferated—written by clever people, professionals in their field, who mistakenly assumed that a programmer was, by default, not stupid, and should be given as many capabilities as possible. Perl, Ruby, even Python were created to make the process of writing code exciting, and the programmer’s expressive power practically limitless. This substantially lowered the profession’s entry threshold and spawned a crowd of craftsmen who literally achieved results by random poking. When the fraction of dimwits in the profession exceeded any conceivable limit, something had to be done, and the most farsighted ones devised making it as difficult as possible to write non-working code: thus tests appeared, and in their wake—types (in those languages where they’re not needed in the slightest).

Matz was creating a language in which literally nothing would obstruct the programmer, and that’s exactly why Ruby is adored by its devotees (of which I am one). But this approach works well only on the condition that the developer actually knows what they’re doing. Unfortunately, in the modern world one cannot count on that at all, which is why the coherent and actually quite interesting-in-concept _JavaScript_ grew heavy with ponderous and pointless _TypeScript_. _Python_—with those damned annotations that literally affect nothing. _Perl_ was simply forgotten, because the nearly unlimited power of its syntax demands too significant a cognitive effort. _PHP_ lives only thanks to Facebook.

Amid all this obscurantism, people with pretensions dusted off _Haskell_ from a dusty closet (which I worked with in 2000–2002, and which ultimately ruined our project back then due to the absence of dependent types). It is 2023, and there are still no dependent types, which makes the choice of Haskell rather dubious for any project—given the absence of any pronounced upsides and the enormous number of equally pronounced downsides (which, in principle, the authors never concealed: the language is academic, experimental, “avoid success at all costs,” and so on). Idris, ideologically absolutely correct, turned out to be too complex for dysfunctional poseurs and is essentially being chiseled along by its author alone.

Also, while we were striding in seven-league boots toward the bright future, the language support teams completely ignored the thoroughly changed paradigm of use. While the community in chorus was hammering type wedges between the tightly fitted logs of code and pursuing one hundred percent test coverage, computers became multi-core and the network became more accessible than hard drives.

In the modern world, fast algorithms are not needed (because the bottleneck will most likely be elsewhere). Micro-optimizations are not needed (because throwing more memory at the problem is cheaper than debugging an assembly insert). Approaches and practices dragged in from the previous century become meaningless—things like properly naming variables and splitting code into modules.

On the other hand, people who understand the direction of applied programming’s evolution and can write code that scales in every direction simply by plugging in additional capacity are worth their weight in gold. It suddenly turned out that such people existed even in the era of antediluvian computers; [Joe Armstrong’s dissertation](https://erlang.org/download/armstrong_thesis_2003.pdf) contains everything one needs to understand about designing fault-tolerant distributed systems, and [erlang](https://erlang.org)—everything required for writing such code.

I’ve often heard from various people that Erlang’s syntax is ...umm... a bit exotic. I strongly disagree with this claim (like all other brilliant decisions, Joe took it from real life—it mirrors the syntax of the English language), but I’ve still chosen [elixir](https://elixir-lang.org) for my work—not for the grammar, of course, but for its truly impeccably implemented metaprogramming. Comparable metaprogramming existed only in LISP, but LISP is too cumbersome and its infrastructure is dreadful.

So, to keep this text from appearing to be blanket praise for Elixir (which it genuinely is, but I’d like to conceal that fact)—let me present the four most important skills, in my not entirely amateur opinion, that are in demand in 2023:

* [ability to guarantee fault tolerance even in the presence of bugs in the code](/hacking/2023/11/04/no-failures-despite-bugs);
* [ability to break the whole into parts and implement small pieces of a large system in complete isolation from one another](/hacking/2023/11/09/divide-et-impera);
* [ability to design software such that the first version contains not a single line “in anticipation of future changes,” while future changes don’t touch existing code in any way](/hacking/2023/12/25/yagnin-but-yagnil);
* [ability to immediately build a horizontally scalable solution without adding any special code for it in the first version](/hacking/2023/12/26/horizontal-scaling).

And that’s about the lot. As for all those algorithms, optimizations, memory consumption...—well, it’s better if you can estimate algorithmic complexity and avoid traversing a list back and forth with nested loops. Probably `O(n⁵)` is worth avoiding right from the start. But pursuing `O(log n)` instead of `O(n)` is almost never necessary, and if it is—there’s almost certainly a working implementation out there already. “You can’t read the entire table into memory!”—a colleague once told me, in horror. I asked him: “Why?”—“There could be a million records!” At that point there were about five hundred records, and each was under a kilobyte. I waved my hand: “Even a billion—this machine has 120 gigs of RAM; if we hit failures, we’ll add paging.”

There was already a `get_page(from = 0, count = -1)` function in my code that always returned the entire table. It’s four years old now, and it will be implemented more seriously someday. Around 2037.
