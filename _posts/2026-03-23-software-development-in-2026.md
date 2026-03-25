---
layout: post
title: "Software Development in 2026"
description: "Three years after the four key developer skills, a modest update: five stages of LLM grief, why the models are glorified T9, why context matters more than the model, and the surprising effectiveness of saying ‘please.’"
category: hacking
tags:
  - elixir
  - erlang
  - programming
  - llm
  - opinion
---

Three years ago I wrote a fairly coherent piece on [four key developer skills](/hacking/2023/11/03/software-development-in-2023), but a good deal of water has flowed under the bridge since then, and while the theses laid out there remain sound, they need a slight adjustment in light of the boon that has descended upon us in the form of large language models.

I went through all five stages of the inevitable over the course of a year.

① **Denial**—I watched my colleagues a year ago raving about autocomplete and hallucinations, and even won a few bets—not unlike the one the Adriano Celentano character [proposes to his accountant](https://youtu.be/GBFt3FF7i2Q) in that great film.

② **Anger**—I kept writing code by hand, but part of my job involves cleaning up colleagues’ messes after shifted concepts (I do a lot of reviews), and the volume of neural slop had crossed every conceivable boundary: even when the code compiled, it looked like Rome from a bird’s-eye view—slovenly fragments of good practices scattered here and there, interspersed with the slums of deeply nested conditionals. I found myself literally rewriting large chunks after the little models, because I take code review seriously and still see it as a tool for teaching apprentices.

③ **Bargaining**—about seven months ago I tried unleashing a model on an old library of mine that was desperately in need of proper documentation; to my surprise, the documentation turned out coherent, nearly complete, and unquestionably better than nothing. I screwed my eyes shut and asked for tests. Half of them tested the standard library and implementation details—but the other half brought genuine value. Like those gruff stubborn men from the joke, I said: “Welllll, damn.” And paid for [Warp](https://www.warp.dev/).

④ **Depression**—in the first month of use I finished two personal projects that had been gathering dust for years, equipped all my libraries with detailed documentation and the missing tests, played around with creating my own programming language, and even trusted the model to fully solve a take-home assignment for one of the companies that had written to me directly with an offer (the assignment sailed through, but I never would have taken the job anyway—their HR had violated every conceivable rule of decency in headhunting). I wasn’t afraid, of course, that I’d be thrown out and Claude hired in my place—the models won’t reach my level of expertise before I retire—but writing code is one of my most beloved occupations in life, and I felt it being taken away from me.

⑤ **Acceptance**—it is now the end of March 2026, and I can say with confidence that language models provide me with substantial help in development, without particularly intruding on the part of my life I cherish: they write excellent documentation, reasonably coherent tests, and—under supervision and with `Ctrl`+`C` at the ready—can shuffle JSON around. Complex code I still write myself, and I’m confident this will continue until my death at the wheel of a sports motorcycle.

---

At the same time, the internet is proliferating with success stories from every variety of blowhard—from startup founders with three grades of parochial school, armed with enthusiasm, a narrow worldview, and the free tier of _ChatGPT_—to bedroom traders whose imaginary profits already permit them to purchase a paper yacht in Bali. In the hands of people far removed from software development, large language models are doomed to two low-yield applications: you can amuse yourself generating memes of piglets drinking mojitos in the Kremlin, or you can reproduce a product that already exists on the market and that in its niche you’ll never catch up to.

To use models effectively (you can now also deploy agents, but this changes nothing whatsoever about the substance), you need—at minimum—to understand the principles by which they operate. It took the automobile industry a hundred years to give users the joy of driving a vehicle without ever having opened the bonnet. Aircraft haven’t reached that stage yet. I see no reason to suppose that very advanced autocomplete is capable of repairing itself. And this is besides the fact that language models are, in principle, a dead end in the development of _artificial intelligence_. Even Yann LeCun has [understood this](https://amilabs.xyz), though unfortunately it remains unclear whether his own ideas aren’t yet another dead end.

Yeah.

If you need to knock together from scratch a shop for the worthless trinkets your wife makes—a modern model will handle it with flying colours. Clean unpretentious design, convenient addition of new bracelets, photos, payment system. The little model will knock you up a website, a mobile app, and lord knows what else. And it will work first try, most likely—because in training it has stared at such dreck in billions of different variations. What everyone finds so astonishing is, in essence, the output of four shell commands: `cp`, `grep`, `sed`, `awk`. Last century this technology bore the proud name “snippet.” For cloning already-existing things, then, the model is a perfectly fine assistant. Web studios that build landing pages will probably indeed die (they should never have existed in principle, but that’s a different question).

As for more complex projects—not necessarily more complex _per se_, but more _unusual_—without an architect to guide it, the model will disgrace itself at the very first hurdle. Because a vaguely described result can be achieved in fifteen different ways, and sooner or later the rough-and-ready decisions of a spring balance (a steelyard, not a precision scale) will lead into a swamp from which there’s no escape—because admitting defeat is not our way, and the model will play roulette to the bitter end, like Dostoevsky in Baden-Baden.

I recently wrote about why elaborate prompts and detailed descriptions cannot produce a good result—see part two of [Artificial ‘Intelligence’](/hacking/2026/03/13/artificial-intelligence)—I won’t repeat myself here, but will quote the key thesis:

> A person capable of breaking a large task down into the minimum number of smaller ones that satisfy the condition of “unambiguous solution” is capable, in today’s reality, of writing a reasonably complex application in a couple of days.

What I mean is that the ability to distinguish tasks with branching logic from multi-step syllogisms is more in demand than ever. Draw a mental flowchart of the execution—and if there are [decision diamonds](https://en.wikipedia.org/wiki/Flowchart#Common_symbols) in it, you need to work them out for the model explicitly (go left here, go right here, snow on head here, very painful). Better still—break the main task into several, to eliminate those “conditions/decisions” entirely. But this is hardly possible if you have no idea how to write such code yourself.

---

Besides the fools who tried to build a website and succeeded—there are also saboteurs. They are considerably more dangerous in that they give the unprepared reader the impression of being “people in the know.” Did I mention that before paying for a subscription to a cloud model I thoroughly understood exactly how they work? I always do. If I get it into my head to drag library `xyz` into a project, I start by digging into its source code. When choosing a technology I don’t read adoption success stories and watch benchmarks—I write my own “trinket shop in the Bronx” with it. To use language models in daily work, and actually pay for the privilege, Altman’s feverish ravings and Karpathy’s coquettish napkin-code are not enough for me. I need to understand how it functions under the hood, so as to preemptively avoid disappointment and the collapse of hopes.

In short, those who have learned by instruction to run models and ask them questions pulled from thin air—supposedly testing or even proving something—would frankly be better off keeping quiet. Because everything that has crossed my field of vision resembles hallucinations from the first version of ChatGPT, Joyce’s _Ulysses_, Castaneda’s astral flights, and in principle any address at a party congress by the secretary of the Upper Walrusville cell, having gorged himself on fly agaric.

Let me skim glissando—or, as Dovlatov used to say, in dotted lines—across the main points.

### Tests and Benchmarks

Comparing different models based on sets of cardboard tests and plastic benchmarks is pure, undiluted charlatanism. It’s enough to look at the language summary table at [AutoCodeBench → Experimental Results](https://autocodebench.github.io/) (yes, this is sarcasm). Claude Opus 4 fails to hit 50% for TypeScript but clears 80% for Elixir. Translating from accountant-speak into plain language (and exaggerating slightly, of course)—if your project is in TypeScript, the model is more of a hindrance; if it’s in Elixir, you can hand it a 1,000-line refactor.

### Context

RAG in any moderately complex project (or more precisely, its “RA” part) matters hundreds of times more than the model itself. Why do all these Claudes burrow into your computers with their IDEs (and lately—CLIs), do you think?—It’s simple: shipping the entire context to the server every time is expensive and inefficient (and despite the flagship advertising promises, nobody can actually process more than a hundred thousand tokens without noticeable quality loss). So every model sends some kind of “distillate” to the server.

It’s important to understand that any language model operates as a finite state machine: `start` → `context` → `query` → `response` → `stop`. There are no “sessions.” You cannot “launch” a model and converse with it—every request you make starts from a blank slate. Models as such have no “memory”—which is why preserving context is critically important. But unlike Hoffman’s character from _Rain Man_, even we cannot memorize six decks of cards—let alone models, with their context window as narrow as the Strait of Hormuz. My slowly-simmering project [Ragex](https://hexdocs.pm/ragex/) is an attempt to somehow formalize—and minimize without loss of generality—the context required for processing sizeable codebases. We’ll see whether I manage it—but the fact that I appear to be alone in this on the visible horizon is not exactly inspiring.

### Plans and Reasoning

When tackling any reasonably non-trivial task, you need to force the model to sketch a plan and ask all the questions that arose for it while creating that plan. It will gladly surrender to you all the internal decision branches from the flowchart. These questions must be answered as clearly as possible—in blunt, clipped phrases that admit no double interpretation. The requirement to supply each phase of the plan with tests and bring all project documentation fully in line with the current state of the codebase must be baked into the general rules.

Each stage calls for a `git diff` with an informal review. I also always use “thinking” models, and watch those reasoning traces in real time—so that the moment it tries to veer off course (and on non-trivial tasks it will always try)—I can kill the little pest with `Ctrl`+`C` and explain why it’s wrong.

### Language

In my experience, it’s best to use the language in which an answer is easiest to find on the internet. For code—always English; for obscure details of Lorca’s biography—Spanish; for a survey of the sexual services market in Berlin—German.

I have no hard evidence, unfortunately—only a general understanding of how this T9 on steroids operates—but the empirical record is copious. My Spanish hovers somewhere around B2–C1 level, so I still try English first; if the result looks underwhelming, I strain my fingers in Spanish—and in the vast majority of cases, I don’t regret it.

### Politeness

After each successful task completion I say something like “Awesome,” or “Astonishing,” or “Stunning,” or words to that effect. I phrase every request as a request and always add “please.” My behaviour affects carbon emissions about as much as it affects democratic elections in a country of fifty million—but it makes things simpler and more pleasant for me. Besides, as Niels Bohr once said: “Of course I am not superstitious. But they say a horseshoe brings luck even to those who don’t believe in such nonsense.”
