---
layout: post
title: "Pry :: breakpoint or ARGF?"
description: "Hwo to make binding.pry work when $stdin is given"
category: hacking
tags:
  - ruby
---

[`Pry`](https://github.com/pry/pry) is fantastic. If you are still tumbling in IRB,
go get Pry a chance and you’ll never roll back.

Besides all it’s buns and cookies, pry provides an ability to debug your ruby code.
Just put `binding.pry` whereever in your code and voilà, you are done. Run it and
see an execution stopped on this line of code:

{% highlight ruby %}
     5: (1..42).each do |i|
     6:   puts "Iteration ##{i}."
     7:   puts "This code does nothing useful."
  => 8:   binding.pry
     9: end
{% endhighlight %}

Everything works like a charm until one tries to make a script accepting
standard input. Unix way, you know.

{% highlight ruby %}
  ps -Ao pid,command | grep proc_of_interest | awk '{ print $1 }' | my_script
{% endhighlight %}

In `my_script` one would utilize `ARGF` power:

{% highlight ruby %}
input = ARGF.read
# binding.pry
do_stuff input
{% endhighlight %}

Have you noticed `binding.pry`? Well, it was not commented out, since I met
a problem with my data and wanted to examine them in debugger session.

Unfortunately, `pry` just _won’t stop here_. It will silently ignore this
breakpoint. WTF?

Well, there is no bug in pry and no magic around. As soon as you get input piped
to your script, ruby internals `$stdin` and `STDIN` are not `tty` anymore. That
said, `$stdin` is assigned to the standard input we just passed to it through
pipe. And yes, pry is clever enough to check for `$stdin.tty?` and switch to
non-interactive mode, since no interaction is possible. It’s silly to wait for
user input when there is neither user no input available, right? So pry does.

How could one overcome this? Pretty easy. Let’s cheat `pry`:

{% highlight ruby %}
pry_stdin = IO.new(IO.sysopen('/dev/tty'), 'r')
# load pry and cheat it with our stdio
require 'pry'
Pry.config.input = pry_stdin

# ...
binding.pry
{% endhighlight %}

We just opened a `tty` device for reading from and passed it as input stream to
`pry`. All internal `pry` checks are now happy and we yield good old breakpoint.
