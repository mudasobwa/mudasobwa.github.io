---
layout: post
title: "Will No One Rid Me Of This Turbulent GUI"
description: "The biased set of reasons why I think IDE does not bring any good at all to the development process"
category: hacking
tags:
  - elixir
---

All I am going to say is biased and opinionated. Everyone is free to shut up and disagree.

**Graphical tools bring more harm than profit to the development process.**

Don’t get me wrong, I started my professional career with _Delphi32_, meaning it was all _RAD_ (a half-forgotten acronym, reincarnated as _IDE_ years later.) When the developer is hugely unexperienced, unsure of themselves, having zero documentation on hand, and knowing nothing about anything—IDE is probably the only aide.

Experienced professional would be retarded by _IDE_ in the same way as slow cooker helps a lone bachelor to get the stew an hour after a chef finishes a five course meal. Autotransmission is great to easier get the driver license, but _F1_ cars have a manual one.

![Ronda de Camí, Platja d’Ara, Catalunya](/img/turbulent-priest.jpg)

---

Yes, I think on the long run the developer using the console and a basic editor providing syntax highlighting (like `vim`, `emacs`, `vscode`, or even `sublime`) is more productive compared to the one struggling to write a function without IDE. Below is the list of the most common arguments supporting IDE and my complains about.

### Refactoring is Easier

It depends on what we are to call “refactoring.” All that “extract to class,” “produce accessors,” and similar stuff is **not** a refactoring. It’s renaming, relining, refiling, rebranding. It has nothing to do with refactoring, and IDE is absolutely impotent to help with a real refactoring, when _all backward compatibility is preserved_, _modules are reorganized_, and _spaghetti gets untangled_.

This is probably the only part of development process that requires intelligence, and no one IDE has it. All they have is the ability to move a lump of spaghetti from one plate to another. Splitting it into context parts, setting boundaries, decoupling,—is the work that requires the understanding of the business logic, not the language syntax.

And yes, “rename function” is still easier to accomplish with a bit of `awk`, or even `sed`.

### Autocomplete Obsoletes Docs

Bullshit. Docs are not about function signatures (that’s also why “types obsolete documentation” is also bullshit.) Docs are all about examples, best practices, howtos-and-donts, explanation of complex solutions. `Enum.sum(list)` does not require docs, nor types, nor autocomplete. [`Flow.emit_and_reduce/3`](https://hexdocs.pm/flow/Flow.html#emit_and_reduce/3) is something one wants to read _about_, and time required to understand what is the argument order is next to zero compared to what and how to pass there.

### Intellisense Saves Time

If intellisense saves you a time, I’d suggest the following self-improvement techniques (from worst to best)

- learn touch typing
- memorize frequently used functions
- minimize a number of external libraries
- prefer think-then-code over code-then-see

If I were to measure the time I spend thinking vs reading docs vs typing the code, the ration would be 70-20-10. With this ratio I tend to produce ten times less of unnecessary code, and intellisense might save me up to 10% of my working time, even if she was typing everything for me.

### IDE Helps To Read The Code

Professional developers must be able to read the code from the paper printed in sans-serif. Monospaced font and soft syntax highlighting helps to parse it, it’s kinda typography hygiene of the code. Good code does not require the reader to jump back and forth. Shakespeare’s sonnets and Maugham’s novels do not need crosslinks, tooltips, collapse buttons and debug window to be read like a charm. Neither does a good code.

And a mediocre code would not be automagically enhanced by reading it through IDE. No way. Click-jump-click-expand-click-collapse-jump-damn-where-the-heck-am-I does not help much to understand what’s going on there. We still cannot hold many items in the short-term memory, and jumps and compiler output simple add them to the table, instead of reducing complexity.

### IDE Makes Working With Git A Charm

Working with `git` is already a charm. GUI _might_ surely help to make it less painful to rebase on 142 commits, but oval wheels are not any better than squared ones if the goal is to drive the vehicle. Small changes, decoupling, full backward compatibility, and call boundaries work. _GUI_ does not.

Find yourself frequently running `git add -p` on files? There is something wrong in your workflow. _GUI_ would not help it, neither adding the content on per-hunk basis. Dedicate a branch to one single thing, implement it, commit. Repeat.

### The Conclusion

So yeah, in all the cases when _IDE_ seems to help the developer, she actually eliminates the consequences and not the cause. Robust code is easy to read from the phone, version-control with two plain `git` commands without switches, and to type in `vim`. Bad code longer stays somewhat maintainable through _IDE_, but sooner or later it’d inevitably blow up.

And using _IDE_ it’s much easier to miss that last turn to absolutely unmaintainable code. That’s why I suggest to skip it whenever possible.

---

Happy consoling!
