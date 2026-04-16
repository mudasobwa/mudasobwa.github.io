---
layout: post
title: "The Long Road to Cure"
description: "Just under a year ago I started building a BEAM language with dependent types and first-class FSMs—chose the wrong implementation language, wrote spaghetti, had an LLM tell me it was garbage, shipped something embarrassing, then spent months rethinking. Here is what I learned and where Cure stands today."
category: hacking
tags:
  - elixir
  - cure
  - programming
  - compiler
  - type-system
---

Just under a year ago I set out to fulfil a long-standing ambition: building a language that compiles to BEAM and implements two capabilities essential to my daily work—dependent types resolved and verified at compile time, and verifiable finite state machines as a first-class language primitive.

I chose Erlang as the implementation language because it seemed to me that writing a compiler would be easier that way. I piled together a heap of attractive little baubles, many of which were added simply “because it is fun to have them.” Quite quickly I lost my way, and before long I lost control of the resulting spaghetti. I stopped understanding what was breaking and why whenever I added something that looked innocuous. I brought in an LLM, and the blasted thing informed me that the codebase had been authored by a drunk lumberjack with a primary-school education—someone who could not be trusted with anything more complex than bubble sort. Not in those exact words, but close enough.

That upset me. I lost my temper, demanded that the wretched language model knock together a presentation site in five minutes on the spot (without specifying any details whatsoever) and shipped it. The announcements, predictably, were received with polite indifference. People liked the ambition behind the idea (naturally!), but calling the implementation good was something not even my mother would have attempted.

I shelved the coding—and recoding—for several months and set about thinking about what I had done wrong.

First: over the last decade I had worked primarily with Elixir, and choosing Erlang had been a momentary, entirely unjustified whim. One can call `:compile.forms/2` perfectly well from Elixir. Moreover, the ecosystem allowed me to abandon `make`-files and a rather crude build setup.

Second: on my first approach to the apparatus I was trying to hunt ducks, hares, and wild boar simultaneously. There was nothing systematic about that approach—I just kept adding and adding new things, propping up the collapsing frame with sticks as I went. Adding a new operator could break module parsing entirely. In the current version I followed the plan strictly: better slow and coherent than fast and obscure.

And most importantly: in the first version I was in such a hurry that I repeated the mistake of almost every existing language—the AST was present as an annexe, a shed around the back. The lexer and parser could hand control directly to the compiler. That turned out to be the critical error.

Having reconsidered all this, I decided to start the rebuilding from the foundations. That is how the [`metastatic`](https://hexdocs.pm/metastatic) library came into being. Put another way: I not only placed the AST at the centre of things but made it tower above every other entity in the system.

> Metastatic is a library that provides a unified MetaAST (Meta-level Abstract Syntax Tree) intermediate representation for parsing, transforming, and analyzing code across multiple programming languages using a three-layer meta-model architecture.
> Build tools once, apply them everywhere. Create a universal meta-model for program syntax that enables cross-language code analysis, transformation, and tooling. Metastatic provides the foundation—the MetaAST meta-model and language adapters. Tools that leverage this foundation (mutation testing, purity analysis, complexity metrics) are built separately.

If you look closely, `MetaAST` bears a strong resemblance to Elixir’s own AST, because there is simply no better way to represent a tree than `{node, meta, children}`. In any case, I invested considerable effort in creating and debugging this new AST. It became the foundation of my second attempt at a “dependently-typed programming language for the BEAM virtual machine with first-class finite state machines and SMT-backed verification,” as it reads on the landing page.

After that I opened the casket marked “things from the previous century,” pulled out an actual pen and a notebook, and wrote out all the features from the first version that I had managed to implement, however imperfectly. I grouped them by importance, utility, and complexity. At this first stage I decided to forgo support for true dependent types—`fn len(l: Vector(_, n)) -> NonNegInt = n`—but [a great deal of interesting things survived](https://cure-lang.org/type-system).

FSMs as first-class citizens are still in a fairly embryonic state, but I am in no hurry now, and I shall bring them to completion steadily and carefully.

Give [https://cure-lang.org](https://cure-lang.org) a try—perhaps you will like it.
