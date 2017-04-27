---
layout: post
title: "Progress Bar in Console for Rake Tasks"
description: "How to make long-running rake task execution fancy"
category: hacking
tags:
  - ruby
---

Yesterday I found myself writing a long-running migration rake task.

It was supposed to walk through one big database table and update records.
One by one. There was no way to write a clever SQL query: 3rd party service
was called for each record and the updated column value depended on
the result of the request. I do not like starring at the stale console screen
since 90s, when I had a 486 machine with 2MB of RAM. There is no typo above:
my working computer, I used heavily to earn money as freelancer had 2MB of ROM.
20 years ago. Anyway, there is no room for nostalgia now and I feel no
nostalgia at all for 14Kb modem connection, ROM counted in megabytes and
processors, doing less flops than my cat chasing a fly.

I decided I need a progress bar for this rake task to show—well—progress.
I went to [`DuckDuckGo`](https://duckduckgo.com) (which is by all means better
than Google for developers) and asked for a ruby gem providing console status
bar functionality. There are many. With all respect to their authors, they must
serve coffee and massage your back for this amount of code they contain.

Damn it, I decided. It would be faster to write the progress bar on my own,
than to download one of these gems and digdoc there interfaces. After all,
everything I need from a progress bar is to draw—well—progress bar.

Below is the source code of it. I put this file into my `lib/tasks` directory
and I `require_relative` it from tasks where I need to draw a meter. That simple.

```ruby
class ProgressBar
  RUNNING = %W{👆 👇 👈 👉 👊}.freeze

  attr_reader :count, :position

  def initialize caption, count, running = RUNNING
    @count = count
    @caption = " #{caption} "
    @running = running.cycle
    @position = 0
  end

  def tick
    @now = Time.now if @position.zero?

    @position += 1

    closing
    opening
    meter
  end

  ##########################################################

  def self.test caption = 'Hello', count = 1024
    ProgressBar.new(caption, count).tap do |pb|
      pb.count.times do
        sleep 0.01
        pb.tick
      end
    end
  end

  ##########################################################

  private

  def opening(sym = '|')
    print "\e[1G#{@caption}#{sym}"
  end

  def closing(sym = '|')
    print "\e[#{$stdin.winsize.first}G#{sym}"
  end

  def meter(sym = '=')
    space = $stdin.winsize.first - @caption.length - 2
    print sym * (@position.to_f * space / @count)
    if @position == @count
      puts
      # rubocop:disable Style/FormatString
      puts "It took %s min %s sec" % (Time.now - @now).ceil.divmod(60)
      # rubocop:enable Style/FormatString
    else
      print @running.next
    end
  end
end
```

This code is provided as is, take it, play with it, but don’t write me back
saying it could’ve been done better. It could have. But I needed to have it up
and running in half of an hour: now it’s running and I am writing this post,
keeping one of my eyes on fancy progress meter.
