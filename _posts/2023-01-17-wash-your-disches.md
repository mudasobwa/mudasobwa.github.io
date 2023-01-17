---
layout: post
title: "Wash your dishes"
description: "What to look at when you interview people (spoiler: not their imminent knowledge)"
category: hacking
tags:
  - ideas
  - erlang
---

Many years ago I’ve read Joe Armstrong’s brilliant description of how they invented [_erlang_](https://www.erlang.org). It was based on the principles of functioning of society in general and the human brain in particular. Instead of inventing behavioral rules and laws out of the blue, the authors of the new programming language simply transferred patterns that are well known from history and sociology as useful in communication.

![Baeza](/img/baeza.jpg)

This is how the _erlang_ syntax appeared, copying, as far as possible, the English text not only with the spelling of keywords, but also with syntax and punctuation. Similarly, an actor model was chosen because it imitates the standard algorithm of human interaction (“I can’t read minds”).

> We don’t have shared memory. I have my memory. You have yours. We have two brains, one each. They are not joined. To change your memory, I send you a message: I talk, or I wave my arms.
> You listen, you see, and your memory changes; however, without asking you a question or observing your response, I do not know that you have received my messages.
> _~ Joe Armstrong, Programming Erlang_

Since then, I have been trying to solve all the problems I encounter in my work by projecting them onto my (or someone else’s) life experience. Such examples help a lot to understand where you are right and where you are very wrong.

I often cite culinary analogies in disputes about the industry. Not even because cooking is in many ways akin to software development (although this is also the case), but to heighten the contrast. A different subject area allows you to focus more clearly on important aspects and not go into terminological discussions about minor details.

Surely everyone is familiar with the type of “great chef by chance.” You know, a person who doesn’t like to cook much, considers the time spent in the kitchen lost, but has a couple of signature dishes in stock, which they invariably strive to impress new acquaintances. “Nah, Harley, you never change!”

These dishes, thanks to repeated permutations and a mechanical procedure honed over the years, always turn out really, really tasty. Without a twist, like ones you’ve got in a good restaurant having no Michelin stars. There is nothing surprising here, a hare can be taught to smoke, if there would be some time and diligence invested. That’s why I always sneak a peek into the kitchen after the accomplished ritual of cooking the crown foie gras under olive marmalade with truffles. And—if a mountain of unwashed dishes stealthily looks at us from the sink—I’d rather have a lime slice for a snack waiting to buy a pizza on my way home. A good chef does not expect an errand boy to wash the dishes for him.

Software baking is exactly the same. While industry gurus rank code by execution speed, readability, maintainability, scalability, and God knows what other criteria, I approach the assessment very superficially. The code just needs to be neat. Sloppy code always tends to be slow, unreadable and difficult to amend let alone maintain. The neatness of the code—think of the dishes washed after cooking—will tell the observant viewer a whole story: about the experience of supporting your own code, fixing someone else’s bugs, maintaining projects, and many other very important (contrary to so-called ‘design patterns’) things.

Aesthetic taste in general is an exceptional (and perniciously underrated) attribute of a really good programmer. That’s why I get a little tense when people praise _Go_ or use _IDEA_ in their work. That’s why I spend an hour adjusting the color scheme, fonts and environment, even of alien laptops I borrow to take to the conference for three days. Unfortunately, people who lack good taste are also very _influenceable_ by fashion trends. Hence all these iphones, louisvuittons and ugly jeeps of recent years. It’s hard to imagine that twenty years ago, all these phones and cars (not to mention clothes), they managed to make them stylish. But then the trees were tall, and the grass was green.

A well-designed programming language literally prevents you from writing dirty, aesthetically unpleasant code. Every time I find myself in the wilds of a conditional operator on elixir, I mercilessly erase the entire piece I just wrote that got me there, and start with a clean slate. Confusing, clumsy, unsightly? “So you did something wrong, man. Rewrite it from scratch.”

Unfortunately, most languages simply do not provide the ability to write elegant code. It is enough to run the autoformatter in a rather non-trivial piece on _Haskell_, and it becomes obvious. Even _Java_, with its verbosity that defies any intelligible explanation, does not look as disgusting. Triple-cover your everything with algebraic types, but they would not allow you to write intelligible code when you have five hundred functions in _Prelude_ with indistinguishable four—letter names meaning whoever knows what. Which line you need to put a closing bracket on and how many spaces should be in the tab is a matter of habit, nothing else. But the python code, in which the eye literally has nothing to cling to, is beyond good and evil. Therefore, any python project on the hundredth line of code turns into a mess, understandable only to the author. Even _Perl_ looks more profitable in this regard, despite it is confusing, invented by aliens, understandable only to Larry Wall,—but it is aesthetically elegant.

Returning to the original thesis, I just wanted to say that if instead of tricky questions about design patterns in general and closures in the javascript in particular—you’d simply take the candidate to the kitchen and see how they cook curry—much more will come out. If they do not know what chicken carry stands for, this is a _YAGNI_ type with a narrow outlook and a desire to do everything according to the only pattern that they have with them since the first year in the university. If they demand thyme and sage besides a mill for cilantro grains, they are a pedant who will torment you with claims to the tools, the environment and five hundred third—party libraries. Will they put chicken in a saucepan and sprinkle unpeeled garlic cloves on top?—This is a work-life balancer who has a job instead of a bedside table from which he gets money. But if the candidate silently cooks something, washes the dishes after themselves and only then calls you, hiding a smile—release the offer out of your pocket. This is your developer. Don’t miss the oportunity.

