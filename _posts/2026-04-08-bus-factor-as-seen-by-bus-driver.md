---
layout: post
title: "Bus Factor as Seen by the Bus Driver"
description: "Bus factor comes in two varieties. The first is provoked by saboteurs who write deliberately unreadable code. The second—far more common—arises because only one person on the team is capable of solving the hard problems, and nobody else can be bothered to learn. The cure for the second kind is not better documentation; it is better hiring."
category: hacking
tags:
  - programming
  - teams
  - opinion
---

> _A phone call. A father of three daughters picks up the receiver and hears. “Is that you, my little frog?” — “No. This is the owner of the pond.”_

It has become fashionable of late to invoke the [bus factor](https://en.wikipedia.org/wiki/Bus_factor) as though it were an inexorable law of nature, destined to bury your project the instant you hire so much as one competent specialist. Business, we are told, requires nothing but interchangeable cogs—each fitted with a correctly tuned heterodyne of work--life balance, each capable of wielding the frameworks and libraries handed down from on high—and, above all, nothing more.

Unfortunately, if your team has no stars, you will never produce a stellar product. A plush-toy shop in the outer reaches of the metropolitan sprawl, the kind that will feed you after a fashion—certainly. Something more ambitious, more serious, more profitable—hardly. Because every serious product contains parts that demand original, not-yet-librarified, genuinely difficult solutions.

I am not speaking of the bus factor (let us call it BF of the first kind, or BF-1, in honour of the glue[^1]) that is provoked entirely by a degenerate fellow who fears losing his job and therefore writes unreadable code—comprehensible only to himself (the two of them, really: him and a half-litre of vodka), deliberately tangled, wilfully obscure. If any developer on your team cannot, or will not, explain their code to colleagues, they should not merely be dismissed but hung on a pillory before the gates of IT, so that all who enter here may see and know what becomes of such saboteurs.

Unfortunately, such unsavoury characters do not exhaust the wellsprings of bus factor. The principal cause—far more common—is that **there is only one person on the team capable of understanding the problem correctly and embodying its solution in code that is both elegant and reliable**.

In the aforementioned online plush-toy emporium, such problems may never arise. In serious business, they materialise out of thin air every month. Google, for instance, designed an entire programming language for the dim-witted, so that they would not damage what the professionals had built while continuing to contribute at least some value to the company.

The bus factor is a problem not of the development guru alone—nor even principally—but of their colleagues. A true professional is always happy to explain the subtleties of a solution they have proposed and implemented. To teach. To clarify. To help. But colleagues often simply lack the skill, the experience, the education—the sheer capacity, at the end of the day—to understand that very solution.

At this point, the info-charlatans appear on the horizon—the Martins and the Fowlers (_pun intended_)—who promise that clean code is a panacea resolving every possible misunderstanding, healing the repository, and generally unclogging the carburettor. Ha. Take any implementation of elliptic-curve cryptography and try to simplify it with clean code. I promise to bring you oranges at the psychiatric ward for the full ten years of your rehabilitation.

All developers divide into two categories: those who believe that truly difficult problems have long since been solved by open-source libraries, that there is no need to reinvent bicycles... and those who no longer believe this. In any industry beyond the mass-production of cookie-cutter online shops, unsolved problems abound. Problems that can be prototyped head-on right now—but which, should the business prove successful, will have to be solved properly.

“Let us cram Kafka and a three-instance multi-region Postgres into our little shop serving three customers, right from the front door”—not exactly a recipe for success. Unless you are personally bankrolled by a magnate, of course. Kubernetes, it transpires, does not solve the problem of horizontal scaling if any coupling whatsoever exists in the cluster. A hundred thousand parallel threads (green threads, coroutines, goroutines, processes) are not particularly easy to debug. Third parties begin to misbehave at the least opportune moment. And so on.

Here, as the old riddle has it, the road forks. If your team lacks an engineer—or engineers—capable of devising an architectural solution and implementing it, what follows is crutchification[^2]: one hack piled atop another until the next spectacular failure. If there are several such engineers, they descend upon the problem from all sides, solve it, verify the solution, and the cart rolls on. Usually, alas, if such engineers exist at all, there is exactly one. To solve a difficult problem with architectural correctness sometimes requires such a fusion of competence, experience, intellect, and practical skill that the resulting solution turns out to be, shall we say, _not simple_. But correct, withal.

And thus arises the bus factor of the second kind (BF-2). The lead engineer would be glad—delighted, in fact—to explain everything to their colleagues: they have written the documentation, showered it with tests, furnished usage examples throughout the codebase, and generally done everything right. But some colleagues cannot be bothered; others are too lazy; and still others are simply too thick to understand the solution and apply it correctly wherever it is warranted.

In BF-2, the lead engineer is not to blame—and cases of this sort arise far more frequently than sabotage, yet no one teaches us how to deal with them. Strictly speaking, this text may well be one of the first on the internet that does not lump both types into a single heap. BF-1 is fairly simple to cure, because it has a single bottleneck: the saboteur, who can be corrected, dismissed, or flogged with birch rods—something will surely help. In the case of BF-2, the point of failure is the entire team, managers and tech lead included, if such a person exists (and yes, it happens that an excellent lead is incapable of grasping a complex solution—that is not what they were raised for).

What to do in this second situation is unclear. I have regularly conducted courses right in the workplace: the picture is a mirror image. Someone cannot be bothered; someone is not up to it; someone’s mind is occupied with other things entirely. And the perennial trump card—“what sort of free courses from a colleague? courses are a talking head on the internet, and they cost a fortune”—never goes away.

I have brought meetups to the office and organised internal TechTalks. The result is precisely the same. To the glory of Pareto, twenty percent of one’s colleagues scarcely need teaching at all, while eighty percent have no desire to learn. What is one to do in such a situation? How does one defeat apathy, the active desire to avoid responsibility, the unwillingness to develop—unless a cheque is written on the spot?

I do have an answer, as it happens. I built a team along roughly these lines, and completely offloaded my own head and backlog. We essentially stopped hiring seniors and mid-levels. We began hiring juniors. I shall never tire of repeating that **a capable junior can easily be taught good habits in a year, whereas an average senior will take no less than a year merely to be _untaught_ the bad ones**.

When companies _en masse_ grasp that for every one senior there should be three to five mid-levels and approximately ten juniors, BF-2 will vanish of its own accord. But when everyone around you is a damn senior who earned the stripe through years of service rather than through solutions—all bets are off.

And what do you think?

---

[^1]: BF — a Soviet-era adhesive brand, universally known throughout the former USSR. The coincidence with the abbreviation is too good to waste.

[^2]: Russian engineering slang: the progressive accumulation of crutches, hacks, and workarounds until the entire structure resembles something out of a Terry Gilliam film.
