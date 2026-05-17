---
layout: post
title: "Make Friends With Your AI Assistant"
description: "Several rules from my experience which would make your cooperation with AI assistants a charm"
category: hacking
tags:
  - elixir
  - erlang
  - ai
---

## Typography

AI assistants do apparently love clean markers. I use ⓪ –⑳  markers for numbering, ▸/▹ markers for itemizing, typographically correct quotes (“”/‘’,) and m-dashes. Compose key makes entering that stuff easier, alternative layout makes it a charm. No tips for poor MacOS/Win users, sorry.

## Workflows

I have system-wide workflows for my assistant. They all look like “START_WORD → WORKFLOW_RULES → STOP_WORD.”

Here is an example:

> Let's define the workflow you must follow every time we work on a new task, named NEW_TASK. The rules are following:
>
> ① The statement "New task <TASK_NAME>!" typed by me starts new NEW_TASK workflow  
> ② Upon starting new workflow you must pull the main branch from github and create a new branch named "<TASK_NAME>"  
> ③ At this point you have to wait for me to enter the problem statement  
> ④ You have to analyze the problem statement and immediately ask all the questions regarding it where you might have had any uncertancy and/or lack of clarity  
> ⑤ After everythig is clarified, you must come up with the plan of implementation and ask for its amendment and/or approval  
> ⑥ Upon approval, you should start implementing it, asking all the questions you might have appeared  
> ⑦ Once done, you must create a comprehensive tests for the new functionality, documentation in both the source code as standalone (markdown), changelog entry, and a brief what-has-been-done note in markdown  
> ⑧ After I accept everything by saying "Task done!", you should commit everything with a descriptive comprehensive commit message, push it to remote, and create a pull request in github.

The key insight here is the **stop-words**. Without them the assistant will cheerfully barrel through all eight steps in one breath, commit untested code to `main`, and open a pull request titled "feat: everything." Stop-words are the leash. Love the leash.

## Context Is King (And Your Assistant Has Amnesia)

Every new session your assistant is a freshly hatched duckling. It will imprint on whatever you show it first. Feed it your codebase conventions, your style preferences, your testing philosophy—and do it _persistently_, through rules and system prompts, not through hopeful repetition in every chat.

The difference between a rule that says “always use `:json` instead of `:jason`” and manually correcting the same dependency in every generated `mix.exs` is the difference between engineering and penance.

Persistent rules are not optional. They are the civilizational layer between you and the primordial chaos of a context window that has never heard of your project. Each workflow (see above) might have different persistent rules attached.

## Atomic Tasks, or: Stop Writing Novels

The temptation to say “implement the entire authentication system” is roughly as productive as asking an intern to “make the app work.” Break it down. Then break it down again. If your task description exceeds one screenful, you have written a novel, not a task. If within the task there are forks in the road possible, the assistant will inevitable choose the wrong path.

The assistant will cheerfully _attempt_ your novel and _wild guess_ the direction on each fork. It will produce something that compiles, passes zero tests, and makes you question your career choices. Whereas “add the `verify_token/2` function that pattern-matches on `{:ok, claims}` and `{:error, reason}`”—that it can do in its sleep. If models slept.

The rule of thumb: **if there is more than one correct architectural path, the task is too large.** Decide the architecture yourself; delegate the typing.

## Feed It Good Code, Get Good Code

This is not mysticism, it is pattern matching. If you feed your assistant examples of clean, idiomatic code, it will produce clean, idiomatic code. If you feed it your legacy spaghetti written at 3 AM during a production outage, you will get more spaghetti—but with AI-generated parmesan on top.

I keep a curated set of “golden” modules that I attached as context ages ago. The assistant does not need to be told “you are a senior Elixir architect with 300 years of experience.” It needs to _see_ what good Elixir looks like. Show, don't pep-talk.

## Trust, But Verify (Especially the Tests)

The cruelest irony of AI-assisted development: the assistant generates tests that pass. “Green across the board!” you exclaim, and deploy. Three hours later you discover the tests were testing that the function returns _something_, not that it returns the _right_ something.

**Read the generated tests more carefully than the implementation.** The implementation at least looks suspicious when it is wrong. A bad test looks _exactly_ like a good test, except it asserts nothing useful. Pattern-match on the actual values; `assert result` is not a test, it is a prayer.

## The Art of Saying “No, Try Again”

Your assistant is not your therapist. It does not need encouragement. “This is wrong” followed by silence teaches it nothing. “This is wrong because the recursive clause does not handle the empty-list base case, see `List.foldl/3` for the pattern I expect”—now you are getting somewhere. Keep your paw right above `Ctrl`+`C` combination and press it every time you see the assistant’s thinking process drives bonkers.

You always liked interrupting people in person, feel free to interrupt your deputy.

## Know When to Kill the Session

If you have been going back and forth for more than three iterations on the same function, close the session. Start fresh. The context window is polluted with failed attempts, corrections, and mutual disappointment—a couples therapy transcript, essentially.

A new session with a clean description of what you _actually_ want will outperform the seventh round of “no, I meant the _other_ thing” every single time. Sunk cost fallacy applies to token budgets too.

Please aware, that the necessity to close a session vividly implies your original prompt sucked in the first place. Rewrite it from scratch. Make sure it has no freedom for the assistant to choose paths. They are good at walking the straight roads.

## The Checklist

Distilled to a grocery list for the impatient:

▸ Use persistent rules, not per-session rituals  
▸ Define workflows with explicit start/stop words  
▸ One architectural decision per task, maximum  
▸ Attach good code as examples, skip the motivational preamble  
▸ Run the full validation pipeline (`format`, `credo`, `dialyzer`, `test`) after every step, not at the end  
▸ Read generated tests as if they were written by someone who wants to trick you (they were not, but the effect is the same)  
▸ Three failed iterations = kill the session, rethink the task  
▸ Never let the assistant commit without your explicit say-so  
▸ If you could not solve the problem yourself, the assistant cannot solve it _for_ you—it can only type faster

The last point deserves a tattoo. An AI assistant is a force multiplier, not a force. Multiply zero by anything you like.

Happy prompting.

