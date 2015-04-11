---
layout: post
title: "Log with pleasure"
description: "A couple of tricks to make your logging experience pleasing"
category: hacking
tags:
  - ruby
---
One half of my working time I spend staring like a stuck pig at my logs. (In case
anybody’s wondering: another half I gaze on pry’s debugger stack; in pauses I
keep my eyes fixed on code itself.) Logs are great. You may run an application,
go drink a couple ristrettos, get back to your table and reflectively read what
that huge clumsy sluggish piece of code, having words ‘innovative’ and
‘revolutionary’ in it‘s name had spitted out to console.

The main problem is that log is like dormitory. Unfortunately, my colleagues
get used to utilize the same working routine; rails and other plugged in engines
seem to feel themselves lonely without communication as well. The log looks like
a trash can. Grokking logs is a hard task, requiring from the brave log explorer
such skills like “Mouse Wheel Scrolling Master,” “Eye Scanner Level 80” and
“Winner of World Gotcha Championship.”

I want to share a couple of tricks helping me to utilize the log in cosy manner.

#### Intercepting standard Rails log

First of all, to tune the log we have to gain an access to it. Let’s do it.

{% hightlight ruby %}
@logdevice = const_defined? 'Rails' ?
              ::Rails.logger
                     .instance_variable_get(:@logger)
                     .instance_variable_get(:@log) :
              Logger.new($stdout)
@tty = @logdevice.instance_variable_get(:@logdev).instance_variable_get(:@dev).tty? ||
              const_defined?('Rails') && ::Rails.env.development?
{% endhightlight %}

The latter condition in `@tty` check is required to force `@tty` be set to `true`
in _Rails_ development environment, where logs are going through `development.log`
file, yet most purpose is to review them on the fly in the console.

Now we should not forget about our colleagues, who probably would not admit
the accidental log format change as long-awaited Christmas gift.

{% hightlight ruby %}
@keep_out = Kernel.const_defined?('Rails') && ::Rails.env.production? ||
            ENV['RAILS_PRETTY_LOG'] != '42'
{% endhightlight %}

OK, my log modifications would never affect neither production env, nor alien
environments not having `RAILS_PRETTY_LOG` environment variable set to `42`.
Fine. Let’s hack a log a bit. First of all, let’s add colors.

{% hightlight ruby %}
SEV_COLORS = {
  'INFO'    => ['01;38;05;21', '00;38;05;152'],
  'WARN'    => ['01;38;05;226', '00;38;05;222'],
  'ERROR'   => ['01;38;05;196', '01;38;05;174'],
  'DEBUG'   => ['01;38;05;242', '00;38;05;246'],
  'ANY'     => ['01;38;05;222;48;05;238', '01;38;05;253;48;05;238']
}
def self.clrz txt, clr
  return txt unless @tty

  "\e[#{clr}m#{txt.gsub(/«(.*?)»/, "\e[01;38;05;51m\\1\e[#{clr}m")}\e[0m"
end
{% endhightlight %}

We will colorize different types of messages (red errors, blue infos, darkgrayed
debugs, all that stuff.) Whether the message contains text in guillemets, it
will be automatically highlighted.

Fine. Now let’s introduce the stopwords.

{% hightlight ruby %}
@stopwords = []
def logger_stopwords file
  @stopwords += File.read(file).split($/).map { |l| Regexp.new l } rescue nil
end
{% endhightlight %}

Once the text file, having list of regexps one by line, is loaded with
aforementioned `logger_stopwords` function, matching messages would be removed
from log. This is quite useful for filtering `ActiveRecords`’s debug littered
with infinite SQL statements.

It sounds like everything is ready. Let’s implement our own
[formatter](http://ruby-doc.org/stdlib-2.1.5/libdoc/logger/rdoc/Logger/Formatter.html).

{% hightlight ruby %}
SEV_SYMBOLS = {
  'INFO'    => '✔',
  'WARN'    => '✗',
  'ERROR'   => '✘',
  'DEBUG'   => '✓',
  'ANY'     => '▷'
}
unless @keep_out
  @logdevice.formatter = proc { |severity, datetime, progname, message|
    message.strip!                      # strip
    message.gsub! "\n", "\n#{' ' * 31}" # align new lines pretty
    if message.empty? || @stopwords.any? { |sw| sw =~ message }
      nil                               # skip stopwords
    else
    '' << clrz(clrz("#{SEV_SYMBOLS[severity]} ", SEV_COLORS[severity].first)   \
       << clrz(severity[0..2], SEV_COLORS[severity].first)                     \
       << ' | '                                                                \
       << clrz(datetime.strftime('%Y%m%d-%H%M%S.%3N'), '01;38;05;238')         \
       << ' | '                                                                \
       << clrz(message, SEV_COLORS[severity].last)                             \
       << "\n"
    end
  }
end
{% endhightlight %}

The above will filter everything matching stopwords, format multiline strings
in more human-readable manner and colorize output when printing on console.
Nifty symbols will be prepended to every message, making it even easier to
navigate eyes through bundles of lines on the screen.

The only thing left to mention is `ANY` severity: it will be spitted out despite
current log level. This is useful, e.g., to print out some values quite
temporarily, not switching the context.

Well, we are to define wrappers:

{% hightlight ruby %}
%i(warn info error debug).each do |m|
  class_eval "
    def #{m} message
      logger.#{m}(message)
    end
    module_function :#{m}
  "
end
{% endhightlight %}

Let’s run it and go take another ristretto.
