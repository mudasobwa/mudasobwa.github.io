---
layout: post
title: "The Diagnosis ‘SLOP’ Is the New Ad Hominem"
description: "The accusation ‘this is slop’—applied to any body of information, be it letters, pixels, or notes—is pure, undiluted argumentum ad hominem. Let us stop counting bullet points in other people’s texts and return to judging by quality."
category: hacking
tags:
  - programming
  - llm
  - opinion
---

The more powerful language models become, and the wider they spread, the heavier the rain of frogs upon our poor heads. Ten years ago one could still, with reasonable confidence, distinguish a graphomaniac from a literarily gifted individual, and a good developer from a boot-camp graduate with pretensions to expertise. It sufficed to glance at a couple of paragraphs of text—or code—and the picture was clear: this one rhymes “love” with “dove,” and that one sorts collections by brute force.

A good prose writer will never stack three adjectives in a single sentence, and a good programmer will not reach for linked lists where arrays are wanted under heavy indexed access. By elementary logic, these existential quantifiers are reversible: if you have written an `O(n³)` algorithm where `O(n×log(n))` would do—go study the fundamentals, and then come back to our warm little circle of juniors.

The patterns in those days were golden, and the sieve was fine-meshed—not a mouse could slip through. For a take-home assignment, we asked candidates to solve a trivial problem, a hundred lines of code at most. From those hundred lines, one could see how maturely the candidate commanded the language (of programming). Decomposition, idiomatic usage, even variable naming—it was all laid bare. If a person, writing Ruby, declared an accumulator outside the scope and then mutated it inside a loop instead of using a reduce—we were not going to walk the same road (other companies may have other favourite songs, but the general message is clear enough).

And then the assistants arrived: generators of code, novels, verse, and paintings.

An assistant can be asked not merely to fix your spelling, or to rewrite code in idiomatic form—but to be fed a specification outright and to produce, at the other end, a working application. In the case of our hundred-line take-home—even a handsome one. Personally, I would not have enough years left in my life to draw a logo even remotely comparable in quality to what Gemini will produce in five seconds. Though I still write better code, and prefer to do it with my own two hands, without an ensemble of helpers.

Humanity sensed the catch. And began to defend itself.

In the manner customary for the Gaussian median of the population—by the simplest means available.

**Instead of evaluating quality, we evaluate the author** (the producer, the craftsman). “This is slop” is a pre-emptive argument that permits one not to think about the quality of the product at all. The internet overflows with texts (which, by a cruel irony, consist of slop to roughly ninety-eight percent) explaining how to distinguish handcrafted works from the emissions of an artificial assistant running on Californian silicon. Spotify and even SoundCloud explicitly prohibit the distribution of music created with minimized human involvement.

We are throwing the baby out with the bathwater, it seems to me.

Language models (assistants) cram everything into lists not because they enjoy bullet points (they enjoy nothing; they are soulless little biscuits)—but because they learned to do so from our own texts of the pre-model era (let us set aside for now the training loop, the ouroboros of quality, and other such sepulkas—that is a different problem, irrelevant to the one I am attempting to discuss). **Humans absorb systematized information, short sentences, and crisp theses more readily.** Therefore a chopped-up list is better than Dickensian sentences spanning a page and a half—at least in technical writing.

To brand a text “slop” and reject it on that basis alone is foolish. The same applies to code. To understand how good a piece of code is, it suffices to look at a single file; for text, a couple of paragraphs will do.

A good short story, a poem, or an algorithm implementation—an LLM will never write, and this is perfectly obvious for the simple reason that in both literature and software development what is valued is improvisation, novel approaches, imagination, and unconventional thinking; all of which even an impeccably trained model is utterly devoid of, by definition and by mathematical design. But **in the systematization of knowledge—that is to say, in writing articles for Habr, for instance—language models will easily beat ninety-nine percent of anthropomorphic authors**.

The same holds for any routine development task. Writing documentation. Creating unit (I stress: _unit_) tests. Property-based testing, which demands spark and verve in the very definition of those properties—hardly. Creating usage examples in documentation—no, of course not. But the documentation itself—“this module is responsible for establishing a fault-tolerant connection to the database, ...”—easily.

Unfortunately, at every decision fork along the way, the model’s choice of the “correct” branch may prove wrong; the model “turns the wrong way”—and the output is genuine rubbish. Without a competent editor, the creations of an LLM are better left unpublished. I would not, under any circumstances, send so much as a text _translated_ into Chinese—let alone one _composed_ in it—to a living Chinese person. Vibe-coders are people entirely devoid of the instinct of self-preservation, because when it suddenly breaks (and it will break, just as all the hand-written software on which the model was trained breaks)—the client will hold them to the fullest account (and I freelanced in the nineties, so I know firsthand what “the fullest account” means in that context).

Given the competence to proofread, verify, and correct, enlisting an LLM as an assistant no longer seems like something beneath one’s dignity. I personally value my own style—in prose and in code alike—to such a degree that not a single line produced by a generator satisfies me. But for expanding technical documentation—certainly. And if one imagines a professional named Vasya, who tirelessly hammers away in C++ and would gladly share a trick he has found in the latest standard—but whose barely-scraped-through grade in composition dissuades him—I am wholeheartedly in favour of a soulless assistant helping him write the text. After all, this was precisely the function Lifshitz served, and were it not for him, Landau’s _Course of Theoretical Physics_ would never have seen the light of day.

In short, I am categorically opposed to lynching articles (or code) on the principle of “it smells like an LLM.” Open one of your own GitHub projects from five years ago, or the adolescent poetry, the science-fiction stories, whatever you were scribbling under your desk...

Sometimes texts written by an LLM are not merely useful for neophytes, but significantly surpass the homespun variety in quality. The same goes for JSON-wrangling. In the end, assigning a task and inspecting the result is a matter of literally ten minutes. If you don’t like it, you can always `git checkout .` and rewr—write it yourself.

**The accusation “this is slop”—applied to any body of information, be it letters, pixels, or notes—is pure, undiluted [argumentum ad hominem](https://en.wikipedia.org/wiki/Ad_hominem).**

Let us stop counting bullet points in other people’s texts, and return to judging by quality.
