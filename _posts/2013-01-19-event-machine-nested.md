---
layout: post
title: "EventMachine :: Nested Calls"
description: "Yield ⇒ Choose one ⇒ Yield"
category: hacking
tags:
  - ruby
  - tricks
---
The easiest way to drop a brick is to use asynchronous threads. Few friends of mine, while proved themselves as a strong professional hackers, were literally surrendering to the multithreading. For starters I would tell my favorite parable of the deadlock (sorry for the dupe, but it is too nice to omit it here.) Ten years ago [Associated Press](http://ap.org/) told the world as, in the Swedish city airport Krisianstad, a pilot was trying to land a passenger plane, but none of air traffic controllers did respond to his requests. It turned out that the controller had not yet returned from his vacation. As a result, the plane circled the airport until an urgently summoned reserve air traffic controller landed the plane in half an hour. Debriefing revealed that the problem was caused by a delay of the airplane. The air traffic controller, who had to land an airplane, hurried to his workplace from a vacation on it’s board.

Well, when we bump into the asynchrony, we have to break the usual picture in the head: a subjective world around us is single threaded. If we had sent a letter and have got an answer past a week, everything happened in a single flow. We are not responsible for actions of our respondent and/or a postman. While our code is.

To make a life easier for the programmer, man can use the [Reactor](http://en.wikipedia.org/wiki/Reactor_pattern) pattern. I swear that the best its implementation for ruby is [EventMachine](https://github.com/eventmachine/eventmachine/wiki). But there is no perfect thing under the sun and there are some not obvious things with it. I plan to briefly tell about one of them.

### EventMachine

```bash
gem install eventmachine
```

An `EventMachine` class is more or less documented. Dealing with simple queries is straightforward. Usually the stuff looks somehow like below (here and after `EM` is an alias for `EventMachine`):

```ruby
begin
  EM.run do
  … # all the meaningful code, e. g. EM.connect (…)
  # we are to print a weird message infinitely
  EM.add_periodic_timer(1) { puts "on tick" } 
  end
ensure
  EM.stop # this could be omitted since the destructor nevertheless calls it
end
```

Reactor is well-hooked (e. g. `EventMachine.add_shutdown_hook { puts «Exiting…» }`.) Asynchronous connection surely may be served on the fly. A documentation is, again, presented. Sometimes it is even clearly.

But let’s cease humdrum.

###Reaping a harvest

While a task is limited to "request processing →  response," there is no problem. But what if we need to send the next query basing on the result of the previous one? Not to make a post too long, let us get right to the problem:

> __*look up jabber-server for a Discovery component and then communicate with it asynchronously*__

We are to send a request to Discovery, to get a list of components, to ask each component for its capabilities. If the list of features is ours, perform our job. Gracefully quit, if it is not.

Here’s how it looks like with `EventMachine` (I removed everything that has nothing to do with `EM` directly):

```ruby
@stream.write_with_handler(disco) do |result|
…
  # iterate thru disco results and wait until all collected
  EM::Iterator.new(result.items).map proc{ |c, it_disco|
…
    @stream.write_with_handler(info) do |reply|
…
      # iterate thru discoinfo results and wait until all collected,
      # then switch the parent’s iterator
      EM::Iterator.new(reply.features).map proc{ |f, it_info|
        it_info.return …
      }, proc{ |comps|
        # one more disco item was utilized
        it_disco.return …
      }
…             
    end
…
  }, proc{ |compss|
    # yielding
    # compss.init or smth like that
…
  }
end
```

Everything is done for us by iterators and their magic function [`map`](http://eventmachine.rubyforge.org/EventMachine/Iterator.html#map-instance_method). Lambda code under the last bracket (near the comment "yielding") will be executed if and only we have collected all the discoinfos for all components.

I apologize if someone does seem the snippet above obvious, but Google has suggested to me no quick solution, while romping through Fiber’s here turns into pure hell.

