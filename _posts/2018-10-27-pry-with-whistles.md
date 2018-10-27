---
layout: post
title: "Better pry for Ruby REPL"
description: "Ruby REPL “pry” is way more powerful than “irb” and might be even better tuned"
category: hacking
tags:
  - ruby
  - tricks
  - tools
---

![Pry Logo](/img/pry_logo.png)

## REPL

_REPL_ in CS stands for [Real Eval Print Loop](https://www.allacronyms.com/REPL).

Ruby, like many other languages, comes with it’s own _REPL_ implementation called `irb`. While it likely does it’s primitive job, there is a way better alternative for it: [`pry`](http://pryrepl.org/).

The excerpt from `pry`’s official site claims

> Pry is a **powerful** alternative to the standard IRB shell for Ruby. It features **syntax highlighting**, a **flexible plugin architecture**, **runtime invocation** and **source and documentation browsing**.

And all the above is indeed true. I am going to show how to install and configure `pry` for user’s better experience. I would assume you already have Ruby up and running on the target machine.

## Preparation step

Go the to console and execute:

```
$ gem install pry pry-theme awesome_print coderay
```

Now you should be all set. Try to run `pry` and see no difference against `irb`. Frustrating enough.

Let’s teach `pry` to be smarter.

## Configuration matters

There is a config file `.pryrc` located in your home directory, that tells `pry` how it should look and behave like. If there is none, execute `cd && touch .pryrc` to create it.

## Tweaking `.pryrc`

I am going to reveal pry features step by step. For those impatient:

**TL;DR:** [gist with my `.pryrc`](https://gist.github.com/am-kantox/5ebb68916ccde06736e8d95026693742)

- [`pry` guides](https://github.com/pry/pry/wiki): there is a ton of useful information for post-graduated pryests,
- [`pry` themes](https://github.com/kyrylo/pry-theme/wiki): use, create, howtos, wtfs.

### Editor

```ruby
Pry.editor = 'vi' # 'code', 'subl'
```

### Prompt

```ruby
Pry.config.prompt =
  [
    ->(_obj, _nest_level, _) { "✎ " },
    ->(*) { "  " }
  ]
```

One might dump the current object name, or maintain different propmts based on the level of nesting or whatever. Since `.pryrc` is a plain ruby file, this procs might execute any code you want or even mine bitcoins while you are waiting for the next prompt to appear.

I do use minimalistic setting to make copy-paste easy (not requiring any cleanup before pasting.)

### Colors

This is driven by `pry-theme` gem. I switch coloring on (unless started as `PRY_BW=true pry`) and set the predefined theme that does not hurt eyes much. For folders under _Rails_ supervision (read: for _Rails_ projects) that might show something even fancier. I hate _Rails_, that’s why I’d never seen it and I cannot tell what exactly happens there.

```ruby
unless ENV['PRY_BW']
  Pry.color = true
  Pry.config.theme = "railscasts"
  Pry.config.prompt = PryRails::RAILS_PROMPT if defined?(PryRails::RAILS_PROMPT)
  Pry.config.prompt ||= Pry.prompt
end
```

### History

This is a godsend. While in debugger mode, or whether the command (not an evaluation) was executed right before, press <kbd>⏎</kbd> and it’ll be repeated. Extremely helpful for stepping into code in debugger (unless you spot all the bugs with your glance and never ever enter debugging sessions, like me.)

```ruby
Pry.config.history.should_save = true
Pry::Commands.command /^$/, "repeat last command" do
  _pry_.run_command Pry.history.to_a.last
end
```

### Commands

Debugger. Don’t trust much this config, I just borrowed it from my teammate who is spending his whole life debugging stuff.

```ruby
Pry.commands.alias_command 'c', 'continue' rescue nil
Pry.commands.alias_command 's', 'step' rescue nil
Pry.commands.alias_command 'n', 'next' rescue nil
Pry.commands.alias_command 'f', 'finish' rescue nil
Pry.commands.alias_command 'l', 'whereami' rescue nil
```

### Listing config

```ruby
Pry.config.ls.separator = "\n" # new lines between methods
Pry.config.ls.heading_color = :magenta
Pry.config.ls.public_method_color = :green
Pry.config.ls.protected_method_color = :yellow
Pry.config.ls.private_method_color = :bright_black
```

This should be self-explanatory.

# Plugins

The below is just a sample of configuring _some_ (read: _awesome_) plugin. I am positive you dislike bloated configs and tend to maintain them ~~line by line~~ pixel by pixel for decades. The snippet below is provided just for the sake of an example. Also comments in the code speak for themselves.

```ruby
# `awesome_print` gem is a great syntax colorized printing
# look at `~/.aprc` for more settings for awesome_print
begin
  require 'awesome_print'
  # The following line enables awesome_print for all pry output,
  # and it also enables paging
  Pry.config.print = proc {|output, value| Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output)}

  # If you want awesome_print without automatic pagination, use the line below
  module AwesomePrint
    Formatter.prepend(Module.new do
      def awesome_self(object, type)
        return super(object, type) unless type == :string
        return super(object, type) unless @options[:string_limit]
        return super(object, type) unless object.inspect.to_s.length > @options[:string_limit]

        colorize(object.inspect.to_s[0..@options[:string_limit]] + "...", type)
      end
    end)
  end

  AwesomePrint.defaults = {
    :string_limit => 80,
    :indent => 2,
    :multiline => true
  }
  AwesomePrint.pry!
rescue LoadError => err
  puts "gem install awesome_print  # <-- highly recommended"
end
```

### Custom commands

Did I say that `pry` is very powerful? You can even define your own set of commands to be used within `pry`. The example below shows how to create `sql` command to execute raw SQL from the console (provided you have a working AR connection there) with a minimum of keystrokes.

```ruby
default_command_set = Pry::CommandSet.new do
  command "sql", "Send sql over AR." do |query|
    if ENV['RAILS_ENV'] || defined?(Rails)
      pp ActiveRecord::Base.connection.select_all(query)
    else
      pp "No rails env defined"
    end
  end
end

Pry.config.commands.import default_command_set
```

### Monkeypatches and globals

Yeah, you might tweak any Ruby code with your own monkeypatches, that are available in `pry` sessions only. The following is very handy for playing with arrays and hashes.

```pry
class Array
  def self.sample(count = 10, &block)
    Array.new(count, &(block || :succ))
  end
end

Hash.singleton_class.prepend(Module.new
  def sample(count = 10)
    (?a...count.times.reduce(?a) { |o| o.succ }).
      map(&:to_sym).zip(0...count).to_h
  end
end)
```

_Sidenote:_ if you think the snippet above is overcomplicated with `Integer#succ`, you surely never dealt with long hashes having more than 26 keys :)

### Color customization

Everything below is for customizing colors, using `coderay` gem. The result would be worth it. Symbols are red and numbers are blue, all that stuff.

```ruby
CodeRay.scan("example", :ruby).term # just to load necessary files
$LOAD_PATH << File.dirname(File.realpath(__FILE__))
require "escaped_colors"

module CodeRay
  module Encoders
    class Terminal < Encoder
      TERM_TOKEN_COLORS.each_pair do |key, value|
        TOKEN_COLORS[key] = value
      end
    end
  end
end
```

## That’s pretty much it

I hope I gave you the first impression on what `pry` is and how is it better than `irb`. I did not cover debugging experiences, mostly because I do not debug, I write the correct code from the scratch. But I hope I could interest you and—please—don’t hesitate to sink into and reconfigure everything to your own taste.

Happy prying!