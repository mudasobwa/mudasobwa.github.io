---
layout: post
title: "Raise For The Rescue"
description: "When in any incomprehensible situation—raise! Do not let the uncertainty propagate through."
category: hacking
tags:
  - elixir
  - ruby
  - tricks
---

### Exceptional Behaviour

> There are only two hard things in Computer Science: cache invalidation and naming things.
> _— Phil Karlton_

Actually, there are three. I would put making a decision on whether to raise or gracefully handle exceptions in that row.

There is the famous Erlang philosophy “let-it-crash,” which roughly means the process should not lie about it’s ability to deal with everything, rather it should simply refuse to handle unexpected data. 

> [...] a clean separation of issues. We write code that solves problems and code that fixes problems, but the two are not intertwined.
> _— Joe Armstrong, “[Programming Erlang](https://pragprog.com/book/jaerlang2/programming-erlang)”_

That said, the code that _solves_ problem should not ever try to _fix_ problems. There is a rule of thumb.

**Code handling a data must not make an assumptions. If the code does not understand the data, it should raise an exception. Period.**

Imagine we have a function that processes the use input (say, currency conversion rate.) We usually tend to write something like this:

```ruby
params[:inverse] ? amount / params[:rate] : amount * params[:rate]
```

But we are smart and we notice, that when the user passes zero, the code above will blow up, so we defend our application:

```ruby
if params[:inverse]
  unless params[:rate].zero?
    amount / params[:rate]
  else
    # WHAT WOULD WE PUT HERE?
  end
else
  amount * params[:rate]
end
```

In the first place, the code already looks like a spaghetti monster (for two years already I reject any PRs having a nested `if` and I am going to start rejecting PRs having `if` at all as a sign of the architectural illness.) Besides that, there is no clean understanding of what should we do when the rate passed is zero. This code knows nothing about how to deal with the weird rate and it’s none of its business according to [SRP](https://en.wikipedia.org/wiki/Single_responsibility_principle). That means, that the explicit check for the `rate` value in the code above is a code smell. The former snippet is _correct_, the latter is a bloated piece of unrelated garbage.

The **behaviour of this code when the rate is zero is _exceptional_** and unless we clearly know how to deal with it (e. g. if we are processing a view and might show `N/A` without any side effect), it **should not interfere the control flow**.

### Let it crash

> The real world actually has independent things communicating through messages. I’m an ex-physicist — we perceive the world by receiving messages. Packets of light and sound carry information. All that we know about the world is what we’ve learned by receiving messages. We don’t have shared memory. I have my memory, you have yours, and I don’t know what you think about anything. If I want to know what you think about something, then I have to ask you a question and wait for you to reply.
> _— Joe Armstrong, “[Programming Erlang](https://pragprog.com/book/jaerlang2/programming-erlang)”_

I have seen (and honestly produced) a lot of code that is as defensive as possible. The `case` conditional statement should have `else` clause, that is to process unexpected income, they say. But... wait. Let’s take a step back and look up the meaning of “unexpected” in Merriam-Webster. It says “unexpected” is a synonym of “unforeseen” and to my best knowledge the latter means one cannot predict it. I am also an ex-physicist and I am pretty sure we cannot cook the ready-to-use answer if we don’t know what the question was. They also call it _“causation”_.

That means, the code should not make silly attempts to cover all the cases. This leads to hidden, hard-to-hunt, arisen from nowhere bugs. Don’t screw future you up! Leave it not handled, or raise directly from there. That is one of rare cases when it’s better to receive `NullPointerException` right there than some incorrect value assigned to the unrelated variable ten thousands LOCs away.

And since you have the application-wide error handler (in erlang world we call it “ErlangVM”,) you are safe to propagate exception until some piece of code knows what to do with it. **Don’t rescue** if you are uncertain, what exactly should happen on error. Don’t rescue if many different things might happen, depending on the outside world state. In general, this advice (although it has some exceptions raised) should be read as “don’t rescue.”

Rescued excepions lead to hidden induced issues in the code that _was indeed exectuted afterwards, despite the data is known to be corrupted_.

### Graceful feedback

Let me restate it again: do not return results of partially processed input, do not input “a meaningful value” when the input is incorrect, do not attempt to assume anything. Wrong means wrong. Let the calling process rethink and reenter the data even if the calling process is a beloved client. Do not fool your code users mimicking robust solid response when you don’t have one. They will definitely grumble in dissatisfaction, but they won’t stalk you to kill as in the case of “almost correct response.”

Instead of returning the half-proven response, put all the effort in the maintaining as descriptive and affable error message as possible. Tell them, whoever they are—function in the neighbour module, external API, or a human being living in Toledo, OH—what went wrong and how to fix an issue. Raise an exception with as many local information put in, as possible. And expose this data to the caller.

Do not hide skeletons in the closet, and nightmares will shun you away.

Happy raising!