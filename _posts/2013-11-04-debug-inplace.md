---
layout: post
title: "Debug inplace"
description: "Example of using PRY for inplace debugging in ruby"
category: hacking
tags:
  - ruby
  - tricks
---
{% include JB/setup %}

Most valuable feature of Ruby is, <abbr title="‘Meiner demütig Meinung nach’ is the german equivalent for ‘IMHO’">MDMN</abbr>,
the ability to overwrite virtually all the default behaviour. The swiss knife of hacking is [pry](http://pryrepl.org) which is,
according to official site, “a **powerful** alternative to the standard IRB shell for Ruby. It features **syntax highlighting**,
a flexible **plugin architecture**, **runtime invocation** and **source and documentation browsing**.”

Though `pry` is better than the standard IRB console in all the aspects around, I personally am totally amused with
it’s “runtime invocation” feature. It works in the following way: anywhere within your code scope you simply drop the line

{% highlight ruby %}
binding.pry
{% endhighlight %}

and—voilá—the execution flow is stopped here, putting you in `pry` session with the context specified. Let’s say we have
the code:

{% highlight ruby %}
#!/usr/bin/env ruby

require 'pry'

def iterate
  40.times { |i|
  # ⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓  HERE GOES MAGIC
    binding.pry or break if rand(40-i).zero?
    print '='
  }
  puts
end

iterate
{% endhighlight %}

We’ll yield an amount of equal signs in the output, following by accidental zero in `rand` call, leading us
to the `pry` instance within current context:

{% highlight ruby %}
〉ruby pry.rb
===============
From: /tmp/pry.rb @ line 7 Object#iterate:

     5: def iterate
     6:   40.times { |i|
 =>  7:     binding.pry or break if rand(40-i).zero?
     8:     print '='
     9:   }
    10:   puts
    11: end

2.1.0 (main):0 >
{% endhighlight %}

Here goes the whole stuff in action (thanks to brilliant [showterm.io](http://showterm.io) service):

<iframe src="http://showterm.io/d542cd31224acaa84549f" width="640" height="480"> </iframe>


