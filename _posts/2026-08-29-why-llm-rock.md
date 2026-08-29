---
layout: post
title: "Why LLMs Rock (or: BooLLMean Logic for the Uninitiated)"
description: "A truth table for human-LLM cooperation, why the comment section immediately accused me of supporting both Trump and Putin, and a sarcastic, joyful breakdown of garbage-in vs. wise-out."
category: hacking
tags:
  - llm
  - programming
  - opinion
  - culture
---

Every now and then, in a fleeting moment of unwarranted optimism, I attempt to summarize a fundamental law of software engineering in a single tweet. It is a foolish habit, akin to throwing a pearl into a crowded pigpen and expecting a thoughtful discussion on marine biology.

![Here is how I think about human and language model interaction, expressed in pristine formal notation—a system I like to call BooLLMean Logic](/img/boolmean-logic.png)

or, in plain text:

> **Truth Table for Human/LLM cooperation. BooLLMean Logic.**
>
> **Conjunction**  
>   ▸ Dull ∧ LLM = Dull  
>   ▸ Wise ∧ LLM = Wise²  
>   ▸ Dull ∧ Wise = Dull  
>
> **Disjunction**  
>   ▸ Dull ∨ LLM = Dull²  
>   ▸ Wise ∨ LLM = Dull  
>   ▸ Dull ∨ Wise = Wise  

Simple, elegant, self-contained. Or so the modest author might think.

Naturally, the Gaussian median of the internet reading public reacted with its customary grace. Within twenty minutes, the replies had degraded into a masterclass of logical leapfrogging. I was called a moron by people whose own code consists of copy-pasting StackOverflow snippets from 2014. Two commenters deduced that because I refused to brand LLMs as either absolute evil or divine savior, I must—by some mysterious geopolitical transitive property—be a clandestine supporter of both Donald Trump and Vladimir Putin.

I am sick and tired of chewing out elementary truths to people whose reading comprehension caps out at three words per paragraph. So, instead of wasting my afternoon arguing with anonymous handles on X, I turned to my trusty, soulless assistant and said: *“Listen, please expand this truth table for the dulls out there. Make it sarcastic, make it joyful, and pack it with real-life examples of garbage-in—garbage-out versus wise amplification.”*

And here it comes.

---

### Part I: Conjunction (`∧`) — Working Hand-in-Hand

In mathematical logic, conjunction implies that two elements operate together in a single pipeline. When human cognition and an LLM are joined by `∧`, the machine acts strictly as a multiplier.

#### 1. Dull ∧ LLM = Dull
*Garbage-In, Garbage-Out, but now delivered at 120 tokens per second.*

If an author brings zero domain understanding, zero taste, and zero structural clarity to the table, the LLM will gladly assist in producing pure, unadulterated mediocrity. 

**Real-life example:** Imagine a junior developer who doesn’t understand concurrency or relational integrity. He prompts the model: *“Write code to sync 10 microservices by polling a REST API every 100 milliseconds and retrying on failure.”* The LLM, eager to please and incapable of feeling shame, generates 600 lines of nested `async/await` loops with exponential backoff and no mutexes. The code runs, eats 100% CPU, deadlocks twice a day, and corrupts the database on Fridays. The developer posts on LinkedIn about his “AI-native microservice architecture.” The input was dull; the output remains dull.

#### 2. Wise ∧ LLM = Wise²
*The Force Multiplier.*

When a seasoned engineer who possesses deep architectural vision uses an LLM, the model ceases to be a crutch and becomes an exoskeleton.

**Real-life example:** An architect designing a fault-tolerant state machine in Elixir knows precisely what invariant properties must hold across every transition. Instead of spending four tedious hours manually typing property-based test generators in `StreamData`, she gives the LLM the exact algebraic specification and asks: *“Generate 50 edge-case property tests covering non-deterministic payload drops.”* The model generates the boilerplate in twelve seconds. She audits the output, catches one subtle boundary error, corrects it, and ships a bulletproof test suite before lunch. Wisdom multiplied by execution speed equals Wisdom squared.

#### 3. Dull ∧ Wise = Dull
*The Human Bottleneck.*

Lest anyone forget the human baseline: if a brilliant engineer (`Wise`) is paired in a team with a micromanagement-happy bureaucrat (`Dull`) who insists on approving every variable name via committee, the result collapses into Dullness. No model in the world can save a project where human incompetence holds the veto power.

---

### Part II: Disjunction (`∨`) — Substitution & Delegation

Disjunction (`∨`) represents replacement—choosing one over the other. What happens when you substitute human thought entirely with machine output?

#### 1. Dull ∨ LLM = Dull²
*Compounded Ignorance.*

This is the domain of the “vibe coder”—someone who doesn’t merely consult an LLM, but abdicates all thinking to it. 

**Real-life example:** A founder with no technical background decides to build a crypto-trading platform using pure LLM generation. He inputs *“Make me a Web3 exchange like Binance.”* The model spits out thousands of lines of hallucinatory JavaScript. The founder doesn’t read a single line, deploys it directly to AWS, and advertises it on X. Three days later, an automated bot drains all user wallets through an unauthenticated endpoint that the LLM left as a placeholder. The dullness of blind reliance does not merely add up—it squares itself.

#### 2. Wise ∨ LLM = Dull
*The Abdication of Mastery.*

What happens when a wise person gets lazy and substitutes raw LLM output for their own judgment?

**Real-life example:** A world-class essayist or senior developer lazily asks an LLM: *“Write an article explaining garbage collection / Write the architecture overview for our core service.”* Instead of applying their sharp style, original metaphors, and deep domain insights, they copy-paste the model’s generic output directly into the publication. The result? A bland, sterile summary composed entirely of bullet points and passive voice. The wisdom has been successfully downgraded to the median noise of the internet: pure Dullness.

#### 3. Dull ∨ Wise = Wise
*The Classic Remedy.*

When a dull practitioner admits their limitations and allows a wise mentor to step in and replace the design, wisdom prevails. The tool is irrelevant here—what matters is the presence of actual human intelligence.

---

### Epilogue: Why LLMs Rock

The takeaway is so simple that even my comment section ought to grasp it (though I hold no illusions): **Large Language Models are cognitive mirrors.**

They do not think, they do not feel, and they do not hold political opinions regarding elections or foreign policy. They are high-speed statistical amplifiers. If you feed them clarity, discipline, and architectural rigor, they will return extraordinary leverage. If you feed them laziness, confusion, and slop, they will return an avalanche of sludge.

So the next time someone accuses you of supporting authoritarian regimes because you pointed out a truth table for autocomplete tools, just send them this post. Or better yet—ask your LLM to translate it into simple sentences for them.

Exactly as I did for that tweet and this post.
