---
layout: post
title: "Md. Another Word About Markdown"
description: "A humanitarian story about how I decided to write my own markdown parser with a customizable grammar and how it went"
category: hacking
tags:
  - elixir
---

**_NB_ This post is in English, [Russian version is here](/2022-08-06-md-under-the-hood.md)**

## Intro

I never liked visual tools to cook text (well, except for _Delphi32_, which fed me a few years in the 1990s). I used _LaTeX_ for my masters and other hand-written poems, but it always made me feel a little sick to know that I was using a microscope to nail up the screws. As you probably already guessed, there were quite a few formulas in my diploma, and even fewer in my poems.

Then I learned about _SGML_, and with the arrival of the web in our homes, about _HTML_; I learned a couple of tags by heart and began to design texts for my three and a half loyal readers using it. Even then, in 1996, I was incredibly angry that for some standard design samples (three asterisks for an empty verse title, for example) I have to literally copy-paste a few lines of unreadable spaghetti from my snippet store. This is how my first self-written blog engine was created. It was a single _XML_ file with all the texts and an _XSLT_ transformation that created a bunch of _HTML_ pages from it. Unfortunately, the code for this work of art has been lost.

![Anis del Mono](/img/anis-del-mono.jpg)

This solution worked perfectly for me, because the tag `<verse caption="none">` literally without my participation was uniformly converted into the very exact spaghetti that annoyed me in pure _HTML_. Then _LiveJournal_ appeared and I abandoned my blog for several years, then I don’t remember what, but when I wanted to publish something in my personal space again, markdown has bloomed everywhere. Which at first glance is fine, because lists of asterisks and a slope of underscores are exactly what you need to design a neat text that is not required to approved by _NASA_ standards. Still, the same problem with the very title of the verse straightened my shoulders again. I absolutely do not have the opportunity to pretty-format a link to the _Twitter_ account in the form [`@mudasobwa`](https://twitter.com/mudasobwa) or to a reddit thread using `[rd /f/foo/1234]`, or something like that. So I decided to write my own parser.

## Self-baked Parser

Home-cooked parser is good because one can explicitly set the proper grammar for themselves (I often use superscript, and each time typing `<sup>foo</sup>` instead of the obvious and absolutely natural markdown `^foo^` is kinda weird.) The problem is, I hate everything that’s nailed down hardcodedly. I am an apologist for screws. I want to be able to grab a screwdriver, unscrew the chandelier, and screw on the gallows hook instead. I write all the code in this way, which often leads to closing tasks from the backlog as if retroactively. That said, I decided that the grammar should be customizable.

I also knew that I wasn’t going to set a goal to fully pass the existing tests for common markdown. People who need tables inside a list inside a table are not my clients (as a result, oddly enough, almost all such exotics were supported naturally by the code which was not meant to support them.)

First of all, I tried to organize the subspecies of the standard markdown markup. Here’s what comes to mind right away:

* paragraphs (separated by two or more line breaks)
* code (I’m a programmer, it’s important to me)
* “parentheses” (bold, emphasized, anything that looks and feels as _parentheses_)
* escaped characters
* simple substitution (the `<` sign should become `&lt;` and so on)
* headers, etc. (from here to the end of the line)
* separators (`<hr/>` siblings)
* lists

That’s enough for starters. Then I added comments, tags, footnotes, and whatnot, and you can see the full list today in the [documentation](https://hexdocs.pm/md/Md.html#module-markup-handling).

## How Do We Parse?

I’ve always been a fan of the _XMPP_ protocol because it allows to work with an infinite stream of bytes rather than with a file. For the same reason, I prefer _SAX_ parsers. We devour the available part of the stream, process it, call third-party registered handlers, and sit there in peace waiting for new data.

I must say that I always, in all projects, without exception, provide the possibility of connecting callback listeners. Has something, that the outside world might potentially want to know about, happen? Well, “register a listener and I’am to call it back.” Therefore, the consumer might connect a listener to my parser and quickly learn about the twists and turns of parsing.

Summing up, there are to exist: custom syntax (within compliance with the original markdown;) the ability to connect listeners; one pass. The last requirement was born simply because in an infinite stream it is impossible to provide support for lookbehind, sooner or later I will be forced to cut off the tail of this snake.

Well, cool. It’s now time to do the actual parsing. I’d like to make a statement that this task is not necessarily feasible in languages without strong support for pattern matching. In pure `C`, it can be solved by simulating it by looking ahead to the length of the maximum _tag_ (in the current version of markdown, this number is 3, for `---` and similar markup, and for custom syntax it can be calculated.) _Idris_ would allow to solve this problem beautifully without explicit pattern matching using dependent types (and _Haskell_ sucks on the matter, of course.) But hey, I have _Elixir_ in which pattern matching is the first class citizen. So I’d simply sort the opening tags from the grammar description by length and match the input to these samples, recursively calling the same function on the remaining thread.

Everything should be fine, but. There is still a hierarchy of tags (e. g. escaping is stronger than parentheses,) context dependence (inside a piece of code, an underscore is just an underscore, not the emphasized text marker,) and terminating sequences of characters (the beginning of a new paragraph should close all open tags). Thus, we are in a need to push some knowledge about the already processed text further.

## Custom Grammars

Strictly speaking, it would be possible to just read the grammar from the config file and pile up all sorts of conditional operators, but this would be damn slow, and the pattern matching would have to be emulated. I wanted the parser to work with the selected grammar as if it were written specifically for it, without redundant checks and superfluous processor ticks. Therefore, based on the configuration of the selected grammar, I do generate a processing code. All of it. If someone understands _Elixir_ code while not being afraid of harsh metaprogramming, here’s the [generation process](https://github.com/am-kantox/md/blob/v0.8.1/lib/md/parser/engine.ex#L50-L81) code. For the simplest version (like slack grammar,) the generated code will be about 8-10 times faster than code with full markdown support, due to a much smaller number of pattern matching function clauses.

## Custom Handler

In addition to mandatory callbacks from wherever it makes sense, I always provide the opportunity to write a custom handler in addition to the existing ones. When I laid out this opportunity, I didn’t even know why, but it finally came in handy. It really did, as always. What does a standard markdown do when it encounters a separate link? <https://github.com/am-kantox/md> — at best, it would highlight it. The existence of custom handlers and the ability to connect them to each and every _tag_ allowed me to implement [pulling out a _TwitterCard/OG_ by link](https://github.com/am-kantox/md/blob/v0.8.1/lib/md/transforms.ex#L7) and showing a preview, as _Twitter_ does. When the card isn’t there, I’m still able to show the correct title for the anchor and the descriptionit as an alternative text. And such a plan of expansion is possible almost for free, thanks to custom handlers.

That’s probably it. I received some feedback about this library, and all negative reviews came down to the fact that I was violating the standard. Well, yes, I probably shouldn’t have mentioned _markdown_ at all; if you need a perfect mathematically proven parser which passes all the tests, just go for something else, probably. But if you want to have full control over parsing, callbacks and your own grammars… Hmmm, maybe [`md`](https://hexdocs.pm/md) would suit your expectations.

Happy marking it upside-down!
