---
layout: post
title: "Ruby Logger :: Temporary Enable Debug for One Class"
description: "How to enable debug for a couple of classes only"
category: hacking
tags: [ruby, tricks]
---
{% include JB/setup %}

In our application we may occasionally have a heavy usage of `logger.debug` calls. It appears
to be helpful to examine the fails, especially in multithreading environment. That’s why we
do not want to get rid of these calls. We set the `logger.level = Logger::INFO` in production instead.

But what if we need to print debug messages for only one or two of over 9000 files? There is no elegant
solution on hand, as far as I know. Let me show an ugly hack to provide such a functionality.

First of all, let’s prepare the function to retrieve the caller’s filename and/or method. This would
be a static function somewhere in top-level of our module:
{% highlight ruby %}
module MyModule
  def parse_caller
    # magic number 7 below is the amount of calls 
    #   on stack to unwind to get your caller
    if /^(?<file>.+?):(?<line>\d+)(?::in `(?<method>.*)')?/ =~ caller(7).first
      file      = Regexp.last_match[:file]
      line      = Regexp.last_match[:line].to_i
      method    = Regexp.last_match[:method]
      [file, line, method]
    end
  end
end
{% endhighlight %}
The magic number “7” there states for an amount of subcalls between our call and resulting
`Logger#add`. We will examine the original caller of `logger.debug` method and reject all 
calls except of interesting ones.

The other thing we need is to override the formatter of our logger:
{% highlight ruby %}
# put this after logger initialization
logger.level = Logger::DEBUG
logger.formatter = lambda do |sev, dt, prog, msg|
  f,l,m = parse_caller
  #↓↓↓↓↓↓↓↓↓↓↓↓ here goes the check ↓↓↓↓↓↓↓↓↓↓↓↓↓
  if (f =~ /newclass/i) && (m =~ /failed_method/)
    original_formatter.call(sev, dt, prog, msg) 
  end
end
{% endhighlight %}
I know it looks a weird hack, but it works fine. As soon as we don’t need debug logging at all, simply
turn back to `INFO` level (and don’t forget to switch back to regular `Logger#formatter`):
{% highlight ruby %}
logger.level = Logger::INFO
logger.formatter = Logger::Formatter.new
{% endhighlight %}

