---
layout: post
title: "How Does Clean Code Work?"
description: "Clean Code doesn't work—not because the principles are wrong, but because the real world is dirty, chaotic, unpredictable, and asynchronous. The best code I’ve ever seen violated a good half of Clean Code’s commandments."
category: hacking
tags:
  - programming
  - opinion
---

Let us begin by establishing the axioms, because without them any discussion devolves into measuring the physiological peculiarities of organisms that prevented every last one of us from becoming prima ballerinas at the Bolshoi. Robert Martin—that very Uncle Bob, with the beatific smile of a guru who has seen the light and found it billable—proclaims: clean code must be elegant and efficient, straightforward as good prose. Grady Booch adds that clean code reads like well-written text; it does not cause your brain to boil from the effort of divining the author's intent. Bjarne Stroustrup, creator of C++—that very language which for fifteen years now nobody on Earth has known to any adequate degree, and where templates can sprawl across half a page—asserts that clean code does one thing, but does it well. And Ward Cunningham completes this choir of optimists with the declaration that code is clean when every function does precisely what you expected.

Splendid. Now that we have established that clean code is the unicorn of programming, existing in a parallel universe where managers do not press deadlines and clients know exactly what they want, let us talk about reality.

I borrowed the cover image from a site called [How Does Homeopathy Work?](https://www.howdoeshomeopathywork.com/)—because a better answer to this question simply cannot be given:

![How Does Clean Code Work](/img/how-does-clean-code-work.png)

Let us walk through the points.

## Clean code saves time in the long run

This pearl is especially beloved at conferences, where it is repeated over free coffee by people pretending they have never hammered a crutch into the codebase on a Friday evening. In theory, it sounds convincing: spend an hour on refactoring now, save a week six months hence. In practice, it transpires that six months later this beautifully refactored module has been tossed onto the rubbish heap, because the business pivoted one hundred and eighty degrees while you were polishing an architecture that nobody needs. Clean code saves time in roughly the same way an expensive gym membership saves your health—in theory, yes, but the membership card is still gathering dust in a forgotten drawer.

## Names should be self-documenting

Ah, these magical variable names. `UserAccountManagerFactoryBuilderSingleton`—now everyone immediately understands what this class does, don’t they? No documentation needed when you have such eloquent nomenclature. The trouble is that the code transforms into verbal diarrhea, every line spilling past the edge of the screen, and you scroll horizontally, trying to determine where this accursed method name finally ends. And here is the truly amusing part: a month later it emerges that `UserAccountManager` actually only sends emails, while the managing is handled by `UserService`—but renaming it is too terrifying, because it will break half the project.

## Functions should be short

Uncle Bob says: a function should be no longer than five lines. Excellent advice—if you are writing a calculator for primary school. In the real world, following this rule transforms your codebase into a matryoshka doll: a function calls a function that calls a function that calls a function. To understand what actually happens when the user clicks “Submit,” you must dive seven levels deep, open twenty files, and draft a flowchart on a sheet of draughting paper. Congratulations: your code is now clean as a teardrop, and equally useless for understanding the logic.

## Comments are a sign of bad code

“If you need to write a comment, your code isn’t expressive enough.”

This is the mantra of Clean Code, repeated like an incantation. The result is predictable: you stare at bitwise operations, at a cunning optimization algorithm, at a workaround for a bug in a third-party API, and nowhere is there a single word explaining why this works the way it does. The previous developer was convinced his code was self-documenting, and you spend three hours searching the internet, trying to understand why he shifts bits left and adds them to some magic constant. Spoiler: it was a workaround for a driver bug. But the driver has since been updated, the code can be simplified, and nobody knows this—because there are no comments.

## DRY (Don’t Repeat Yourself) is sacred

Spotted two similar functions? Abstract immediately. Three lines repeat? Extract into a separate method. The result is a system so entangled by shared abstractions that changing a single line somewhere in the depths of your architecture breaks functionality in three unrelated modules. And then it emerges that those two _similar_ functions were actually doing slightly different things, and you find yourself adding parameters, flags, conditions—transforming an elegant abstraction into a monster with a dozen optional parameters and logic comprehensible only to its creator.

Here I must add a caveat, for perceptive readers will surely remind me that I have said three hundred times: “Think one step ahead; YAGNI is the enemy; better to measure once now than to re-cut seven times later.” Quite so, and there is no contradiction. If a piece of code looks like something that can be abstracted away, and quacks accordingly—don’t wait for a second repetition, extract it at once. But if it doesn’t—better a copy-paste than a `utils` module stuffed with single-use functions, disposable as prophylactics. One simply needs to be guided by common sense, not by the principles of “Clean Code.”

## Tests make code cleaner

TDD fanatics promise that if you write tests before you begin the implementation, your code automatically becomes cleaner. Practice demonstrates that you simply acquire two codebases instead of one, and both require maintenance. Half the tests verify the obvious—that two plus two equals four—while the other half are so brittle they shatter at the slightest refactoring. And ninety percent coverage gives you a false sense of security, until production reveals that the remaining ten percent is precisely the critical payment logic.

Coverage in general is a mediocre metric. I have a library with one hundred percent coverage, and just the other day I found a bug in it the size of a tropical cockroach. One of our old microservices, which I wrote ten years ago in a week and which brings in tens of millions annually, has no unit tests whatsoever—because it is entirely dependent on external sources, and the only viable testing strategy is graceful failure in production with a very detailed log and immediate adjustment to third-party APIs that change their interfaces without so much as a declaration of war.

## SOLID principles solve all problems

Oh yes, the silver bullet. Single responsibility, open-closed, Liskov substitution, interface segregation, dependency inversion—it all sounds like incantations from Harry Potter, and is approximately as applicable in real life. An attempt to follow all five principles simultaneously transforms a simple CRUD into an architectural masterpiece of twenty layers of abstraction, where adding a single field to a form requires modifying seven interfaces, creating three new classes, and updating the dependency injection container configuration. And then a new developer arrives, gazes upon all this magnificence, and asks: “Couldn’t you have just added a column to the database?”

---

And there you have the whole truth about clean code. It doesn’t work—not because the principles are wrong; no, in a vacuum they are splendid. It doesn’t work because the real world is dirty, chaotic, and unpredictable (and asynchronous, too, yes). Because deadlines don’t move, requirements change, budgets run out, and the client wants everything at once. Because ideal code is the code that solved a real problem yesterday, not the code that will look elegant in a textbook the day after tomorrow.

The best code I have seen in my career violated a good half of Clean Code’s commandments. It was straightforward, occasionally rough, with comments where they were needed and without superfluous abstractions where they were not. It worked, it could be understood, and it could be changed. And this, it turns out, is genuine cleanliness—not in the following of dogmas, but in the solving of problems.

The only trouble is that such an approach formalizes very poorly (it is precisely to this fact that we owe the emergence of that peculiar term, “idiomatic code”). Selling a book in millions of copies, or courses, or consulting—is practically impossible. And so it is far more profitable to invent a term, build a theory around it, demonstrate on toy examples that everything works... and move on to something else entirely—breeding newts, for instance.

Whoever caught the reference in the previous sentence is a true hacker.
