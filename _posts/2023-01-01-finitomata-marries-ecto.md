---
layout: post
title: "Finitomata Marries Ecto"
description: "The proper way to use FSM to control data consistency (opinionated approach)"
category: hacking
tags:
  - elixir
  - ideas
---

When people around me talk about metrics, the most used words are service reliability, latency, throughput, load capacity and their siblings. All that is indeed extremely important until it gets to the data. In the data world, where we deal with customer’s private information, business nuances, and, after all, money, the _data consistency_ is what we should take care of in the first place. I even [wrote a rant about it a while ago](https://rocket-science.ru/hacking/2022/08/14/fsm-driven-development).

![Roses Are Red](/img/roses-are-red.jpg)

Data consistency is harder than rumors say. Data consistency, contrary to popular misconception, cannot be preserved by _RDBMS_ itself. It cannot be represented as a diagram, let alone graph of relations. And, after all, when people talk about consistency, they too often use a wrong vocabulary. There is even the brand new wording invented by people who had most likely never been to the university. [Saga](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/saga/saga), if one would squeeze out all the water from the paper, is a poor-man FSM. OK, rich-man FSM, it’s coming from Microsoft after all.

I blindly used mocks for decades until I read José Valim’s ‘[I always consider “mock” to be a noun, never a verb.](https://dashbit.co/blog/mocks-and-explicit-contracts)’ and it clicked. Not that I had no clue what mocks are, but I surely was abusing the clean concept with somewhat nasty implementation.

Data consistency has not clicked for me for a while too. I felt there should be a clean way to ensure it in general, but I missed the details. I knew it should most likely rely on [finite automata](https://en.wikipedia.org/wiki/Finite-state_machine) and I tended to vote for it to be [non-deterministic](https://en.wikipedia.org/wiki/Nondeterministic_finite_automaton) because the absense of side effects would ruin any business (including but not limited to programming languages relying on pure functions only.)

I worked a lot with a handy [`workflow`](https://github.com/geekq/workflow) gem in ruby, and it did what I wanted to some extent, but it has two glitches that cannot be circumvented. The state is attached to an entity (to the data object directly,) and there is no restriction to modify entity state with transitions only. One can easily update the amount of order manually, bypassing a transition, which obviously ruins the whole math behind finite automata. It miserably becomes an _infinite state machine_.

That said, while attaching _FSM_ to data entities might ensure their consistency alone, it cannot validate relationships between them. Which are usually called **business processes**. Also, business processes is something what runs the business, might be spoken about with non-tech deps, and, the last but not the least, they are easily described with goddamn diagrams. Which are barely differ from a ready-to-use _FSM_ definition.

---

Consider [actor model](https://en.wikipedia.org/wiki/Actor_model) applied to data. Business processes are processes. Events provoking transitions are messages. Data is nothing but an internal state of a business process. Don’t you feel the smell of fault tolerance through business processes supervision trees yet?

---

In simple systems, the business process might be attached to the data entity, but still it would be better be a separate beast. When I started to work on _FSM_ application to data consistency, I wrote an [example application](https://github.com/am-kantox/finitomata/tree/main/examples/ecto_intergation) managing a `Post` in a wild. The most impressive feature of [_Elixir_](https://elixir-lang.org/) as of language is it literally yells at you when you are trying to implement things in a wrong way. The code starts to look ugly, whispering “Hey, you are likely missing a better approach here.”

Despite that I managed the example to work and even look not so ugly, I discovered the whole idea was crucially misconcepted. The `Post` itself should not keep track of its changes. This is not scalable, not extandable, and not supportable. Adding a comment would lead the approach to disintegrating like a house of cards. There must be a separated business process, like `PostLifecycle`, which would take care of a `Post` ...ahem... lifecycle. And—which is extremely important—the `Post` itself should not allow any modifications outside of the transitions in this process.

Here we get to the intriguing and cost-free side effect. Storing transitions alone would give us a perfectly valid event log. It would not be re-playable in general, due to non-pure transitions (consider the post which embeds an [`opg`](https://ogp.me/), which is to be downloaded from some external source with not idempotent responses,) but despite that, the event log would be fully plausible.

---

This approach works well with web applications. Instead of random requests, modifying the internal data of the application directly (as every single protocol known to me allows in a nutshell,) the endpoints in the web application should expose transition handlers only. The outmost world should not be allowed (and therefore even have an access) to _modify_ data directly. It should be permitted to initiate transitions only. As by Joe Armstrong’s analogy, the computer interoperation should mimic the human communication; we cannot read minds, we can only send messages, like saying words or waving our hands, and the interlocutor might or might not decide to change their mind or even share some of it with us.

The described approach is extremely easy to reason about, which is also true for most of other approaches broadly accepted in computer science. Its uniqueness is it drastically simplifies the project vision exchange with the people of business. Transitions are exactly what they think of, and everything else magically becomes _actual_ implementation details.

---

I am to come up with another example, demostrating the power of `Finitomata` in a concord with business processes automation, mapped to data internally, but in the meanwhile I wanted to share this agenda as a pure idea.

Happy business process driven development!