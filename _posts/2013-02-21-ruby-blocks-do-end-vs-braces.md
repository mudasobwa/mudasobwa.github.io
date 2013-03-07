---
layout: post
title: "Ruby Blocks: Do-end vs. Braces"
description: "What to use for ruby blocks?"
category: tips
tags: [ruby]
---
{% include JB/setup %}

Ruby tries to add a spoon of sugar to each damn line of your code any time she thinks it to be possible. That’s nice.
Sometimes she became meddlesome. That used to drive me bonkers. A newbie is to be that rara avis, to understand that
there is actually a huge difference between braces and `do-end` constructs to define a block.

Well, everybody may spend a life successfully writing tons lines of ruby code and never get stuck in weird exceptions,
coming from 3rd party libs, which in case were induced by negligent mess between `{}` and `do-end` in domestic code.
Let’s digress from our dramatic story and take a look at the following snippet. Somebody was set bringing benchmarks
to an application running at a snail's pace. Well, the task looks straightforward. Install `benchmark` gem, read the
[documentation](http://ruby-doc.org/stdlib-1.9.3/libdoc/benchmark/rdoc/Benchmark.html), try an example:

{% highlight ruby %}
require 'benchmark'
puts Benchmark.measure { "a"*1_000_000 }
{% endhighlight %}

Works fine! Let’s try smth more complicated:

{% highlight ruby %}
require 'benchmark'
puts Benchmark.measure do
  while true
    print 'a'
    break if Random.rand(100) === 1
  end
end
{% endhighlight %}

Ooooups…

{% highlight ruby %}
irb:010 >
# LocalJumpError: no block given (yield)
#     from IRRELEVANT_PATH_TO_RVM/lib/ruby/2.0.0/benchmark.rb:281:in `measure'
#     from (irb):9`
{% endhighlight %}

WTF? That’s the syntax sugar, ruby mixed into your tea. That’s a time to take a look at an operator precedence table.
`{}` binds tighter than `do-end`. Furthermore, `do-end` clause has lowest precedence at all. In other words, the latter
codepiece is similar to:

{% highlight ruby %}
require 'benchmark'
(puts Benchmark.measure) do
  # irrelevant code
end
{% endhighlight %}

Surely, the aforementioned hitch never befuddled a guru, but there is a style guideline which may get rid of the
possibility even to stuck with this. Use braces `{}` when a block returnes a value. Use `do-end` clause otherwise.
