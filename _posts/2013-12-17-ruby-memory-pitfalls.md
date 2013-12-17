---
layout: post
title: "Ruby Memory Pitfalls"
description: "Ruby Memory Operation :: Pitfalls"
category: hacking
tags: [ruby]
---
{% include JB/setup %}

Ruby has an automatic memory management. In most cases this is good; sometimes it becomes sad.

Ruby memory management is both elegant and cumbersome. It stores objects (named `RVALUE`s)
in so-called heaps of size of approx 16KB. On a low level, `RVALUE` is a `c`-struct, containing
a union of different standard ruby object representations.

So, heaps store `RVALUE` objects, which size is not more than 40 bytes. For such
objects as `String`, `Array`, `Hash` etc. this means that small objects can fit in
the heap, but as soon as they reach a threshold, an extra memory outside of the
Ruby heaps will be allocated.

**This extra memory is flexible; is will be freed as soon as an object became GC’ed.
But the heaps themselves are not released to OS anymore.**

Let’s take a look at the simple example:

{% highlight ruby %}
  def report
    puts 'Memory ' + `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`
            .strip.split.map(&:to_i)[1].to_s + 'KB'
  end

  report
  big_var = " " * 10_000_000
  report
  big_var = nil
  report
  ObjectSpace.garbage_collect
  sleep 1
  report

  # ⇒ Memory 11788KB
  # ⇒ Memory 65188KB
  # ⇒ Memory 65188KB
  # ⇒ Memory 11788KB
{% endhighlight %}

Here we allocate the huge amount of memory, use it somehow and then release back to OS.
Everything seems to be fine. Let’s now slightly change the source code:

{% highlight ruby %}
-  big_var = " " * 10_000_000
+  big_var = 1_000_000.times.map(&:to_s)
{% endhighlight %}

That was a humdrum modification, wasn’t it? But wait:

{% highlight ruby %}
  # ⇒ Memory 11788KB
  # ⇒ Memory 65188KB
  # ⇒ Memory 65188KB
  # ⇒ Memory 57448KB
{% endhighlight %}

WTF? The memory is not released to OS anymore. That’s because each element
of the array we introduced _suits_ the `RVALUE` size and is stored in the _ruby heap_.

In most cases this is OK. There are more empty slots in ruby heap now; code
re-run will not eat any additional memory; `GC[:heap_used]` value is decreased
as expected every time we dispose `big_var` and a lot of empty heaps, ready
for operation are returned back to Ruby. To _Ruby_ that said, not to OS.

So, be careful with creating a lot of temporary variables suiting the 40 bytes:

{% highlight ruby %}
  big_var = " " * 10_000_000
  big_var.gsub(/\s/) { |c| '-' }
{% endhighlight %}

results in growth of memory guzzled by Ruby as well. And this memory will not
be returned back to OS during the whole long run:

{% highlight ruby %}
  # ⇒ Memory 10156KB
  # ⇒ Memory 13788KB
  # ⇒ Memory 13788KB
  # ⇒ Memory 12808KB
{% endhighlight %}

Not so crucial, but noteworthy enough.

