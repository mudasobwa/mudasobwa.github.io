---
layout: post
title: "YAGNIN, but YAGNIL"
description: "Part three of ‘four key developer skills’: why YAGNI is the laziness excuse of the decade, what the correct formulation actually is, and how dependency injection lets you be ready for tomorrow without writing a single superfluous line today."
category: hacking
tags:
  - elixir
  - erlang
  - programming
  - architecture
---

_Part three of [four key developer skills](/hacking/2023/11/03/software-development-in-2023)._

> Ability to design software such that the first version contains not a single line "in anticipation of future changes," while future changes don’t touch existing code in any way.

---

One of the most repulsive “principles” of development to emerge in the last decade can safely be identified as [YAGNI](https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it). Despite growing out of Donald Knuth’s coquettish but not entirely thoughtless “premature optimization is the root of all evil”—stated nearly 60 years ago—the modern interpretation hands idlers, under-qualified practitioners, and outright scoundrels enormous latitude to dodge solving problems correctly.

The correct formulation is right there in the title of this post: “You aren’t gonna need it _now_, but you are gonna need it _later_.” If that were not so—if “architecting for future requirements / applications turns out net-positive” (in John Carmack’s words) really were needed only rarely—we would never encounter the reaction “this code is easier to rewrite from scratch than to change.” The situation “we’ll need to refactor three modules deep” would never arise when adding a new parameter to a function call. People would never break backward compatibility—since Ron’s quote yanked from context (available at the link above) promises us simple addition of new things as needed.

Unfortunately, none of the above works. At least not out of the box, in the form in which the programming extremists try to sell it to us.

On the other hand, Knuth, Jeffries, and Carmack are respectable people who have each written heaps of code tested by decades—and most likely wouldn’t talk complete nonsense.

As always, it’s all in the nuances. Immediately implementing every potential feature that might someday pop into the head of a deranged client is obviously a thankless task. You shouldn’t do that, and you can’t guess all those potential ideas right now anyway. But you must be _prepared_ for them.

What does that mean?—Let me try to explain with an example.

Suppose the task at hand is writing a Mastodon text publisher. A command-line utility, literally. Here—a text file, there—a toot. Called with something like `$ post file.txt`.

The first thing to settle: will anyone else be using this? Because if we’re talking about a single-user program that runs once every five years on my machine—you don’t even need to handle errors. It crashes with an exception?—I’ll tweak it and restart, no big deal.

But if we’re talking about a project for actual people—whether a paying client or open-source freebie-hunters—things become somewhat more complex. And it’s not even about bugs: loyal users will forgive bugs, and they’re easy enough to fix. The point is that if the project is going to grow, you need to prepare for that a little. Because rewriting everything from scratch with every new requirement is fun, but inefficient.

So where might it grow?

- a new publishing service gets added;
- a new text format gets added;
- batch processing gets added;
- something else, probably—but that’ll do for now.

It’s time to utter the two magic words: _dependency injection_. Everywhere you expect requirements to scale outward, you can give yourself insurance without writing a single superfluous line. Instead of hardcoding it like this:

```elixir
@spec publish(String.t()) :: :ok
def publish(text) do
  text
  |> Markdown.format()
  |> Mastodon.publish()
end
```

you can inject dependencies, with a sensible default:

```elixir
@spec publish(String.t() | [String.t()], Formatter.t(), Publisher.t()) :: :ok
def publish(texts, formatter \\ Markdown, publisher \\ Mastodon) do
  texts
  |> List.wrap() # accept a single string as well
  |> Enum.each(fn text ->
    text
    |> formatter.format()
    |> publisher.publish()
  end)
end
```

Done. This code is now ready to accept multiple texts at once (as well as a single one), format with anything, and publish anywhere. We’ve covered all three of the potential future requirements that came to mind, without writing a single superfluous line of code (well, about 60 characters were added—apologies).

Of course, we cannot anticipate all of tomorrow’s needs. But some are so obviously staring you in the face that you can handle them without even getting up from your chair. Everyone knows that magic constants are bad. So people do this:

```elixir
@pi 3.14159265

def pi, do: @pi
```

There’s no need to do it this way, for two reasons: if it’s π, it will never change, and no one will confuse it with the CEO’s full name. But if it’s something that might change tomorrow—say, the maximum number of characters for a repost—`@max_symbols 140` won’t help much: you’ll still have to find it and change it directly in the code. This, on the other hand, is good:

```elixir
@max_symbols Application.compile_env(:my_app, :max_symbols, 140)

def truncate(text, symbols \\ @max_symbols),
  do: String.slice(0..symbols-1)
```

Need to change the default value?—Welcome to the config. Need the ability to truncate at different lengths?—Here’s a parameter, hello.

In fact, this example scales easily to any “grey zone” of architectural change. The architecture should not change, in principle: the _parts_ should change. The business is young and there are only five clients so far?—Then the function for sending a New Year’s greeting by email (forgive the example) should be ready to parallelize. It’s a `MailSender` that exports a single function `send/2`, which for now accepts a text and a list of email addresses _and simply iterates over them sequentially_. When the hundredth client arrives—we’ll rewrite it to use multiple threads, without touching the rest of the code—and that’s it.

---

Strive to ensure that every operation in your code is handled by a separately taken, extremely simple, isolated, and tested module. After all, one can spend a lifetime preparing for the day the toilet in one’s bathroom gets clogged, and achieve mastery in the art of unblocking it. Or, when the hour comes, one can simply call a plumber who does only that—but does it well. That is _dependency injection_.
