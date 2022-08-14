---
layout: post
title: "FSM Driven Development"
description: "A new library to manage statefull processes as Finite Automatæ and the impudent proposal for the HTTP verbs extentions"
category: hacking
tags:
  - elixir
  - ideas
---

> There are only two hard things in Computer Science: cache invalidation and naming things.  
> — Phil Karlton

Well, actually my whole experience says there are three, and the third one is the most challenging one. It’s **data consistency**.

All the paradigms, methodologies, best practices, and all these accumulated decades of knowledge teach us how to store data, derive data, operate data, transform data, but none tells us how to keep data consistent. Which is way more important compared to naming (hey, Fortran 77,) and cache invalidation which might always be fixed by switching the cache heartfully off.

![Rainbow in Montgat](/img/rainbow.jpg)

HTTP verbs, REST, GraphQL, all the ORM, even databases—each and every _framework_ does literally nothing to keep the data consistent. Yeah, databases are guilty less than others, but still indices and foreign keys fail miserably on cases when the relationship involves _states of entities_. Consider the cloying, stuck in the teeth, example: posts with comments. Any mediocre developer would tell you that the comment might be added to the _published_ posts only, not to drafts or deleted posts. Can we express this in DB constraints?—Hell, no.

In the evolving applications, ties and relationships grow exponentially. One cannot tag the suspended author, a legacy post cannot receive comments after two weeks, you name it. It all results in the cumbersome full-of-conditional-statements spaghetti business logic, applied here and there in the random places of the application. It quickly becomes unreadable let alone maintainance. What would be the silver bullet to fix this crap?

Well, there is no silver bullet, but there is definitely a pill. _FSM_ with an attached to the entity _state_ and validated transitions would allow us to make sure that the entity, or a set of entities, is always in the consistent state (or in the middle of transition.) These transitions behave like database transactions, but on the application business logic level. Adding a comment would look like (in pseudocode) `Post.transition(:new_comment) && Comment.transition(:added)`. The example looks a bit contrived (and it surely is,) but it shows the technique _and_ is expandable to more complicated relationships. Once the `Comment` is in added state, we are sure it has been attached to the published `Post` (otherwise `Post.transition(:new_comment)` would have failed,) and this `Post` is aware of this `Comment`.

---

I tend to bring the _FSM_ to everywhere, it drastically simplifies the development process and maintainability of the resulting code. My effort resulted in [`Finitomata`](https://rocket-science.ru/hacking/2022/04/02/finitomata) library several months ago, but I still felt discontented because too much of a boilerplate was still to be produced and/or copy-pasted from project to project. That’s how [`Siblings`](https://hexdocs.pm/siblings) library was born. Built on top of `Finitomata`, it enforces all the business logic to be written in the dedicated handlers and callbacks. One cannot interfere the internal state of anything managed by the library in any way but initiating a _transition_ and doing stuff in the callback.

All the stateful processes are _FSM_ implementations underneath, supervised by a partitioned `DynamicSupervisor` and accessible by a fast `O(1)` lookup. To update the state, one should start a transition. _And_ even to create a new object, one should start a transition on the supervising entity. So yeah, everything is a transition within the context of this library.

---

That makes me think about exploring the idea further to introducing `TRANSITION` _HTTP_ verb. Well, let it be a `POST` with transition data in the body (`event`, `event_payload`.) The shape of the transition input would automatically validate the `event_payload`, making the validation _and_ even client code generation obvious and straightforward.

I’m currently in the very beginning of a long path to a complete specification, but I see a bright future for this particular feature and I’d be glad to hear opinions on the matter.

Happy transitioning!
