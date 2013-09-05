---
layout: post
title: "Sequentional execution: example of Reactor pattern impl"
description: "Basic example of Reactor pattern implementation within two threads"
category: hacking
tags: [ruby, tricks]
---
{% include JB/setup %}

[Reactor pattern](http://en.wikipedia.org/wiki/Reactor_pattern) is an event handling pattern
for handling service requests delivered concurrently to a service handler by one or more inputs. All
the ready-to-use ruby implementations (like [EventMachine](http://rubyeventmachine.com/) and family,)
though are very smart built and quite helpful, hide all the details. I decided to write down a short
example of how the task may be accomplished in pure ruby.

Let’s say we are interested in running an echo-service-like application. We don’t need any servers,
just pure “wait-for-input ⇒ reply” app. The CLI wrapper might be a good example. All we want is to have
a running instance somewhere, which will accept internal calls like `@inst.cmd("ls")` and reply with
the result of the command run.

We decide to have two independent threads, which are to be synchronized in the following manner: just
after the `prior` function is executed, the `posterior` function wakes up, does something and sleeps
back until the next call to `prior`. Here we go:

{% highlight ruby %}
module SeqExec
  class Seqs
    attr_reader :init
    def synch_prior mx, cv
      Thread.new {
        mx.synchronize {
          @init[:prior] = true
          loop do
            cv.wait mx
            yield if block_given?
            cv.broadcast
          end
        }
      }
    end

    def synch_posterior mx, cv
      Thread.new {
        mx.synchronize {
          @init[:posterior] = true
          loop do
            cv.wait mx
            yield if block_given?
            cv.broadcast
          end
        }
      }
    end

    def synch λ1, λ2
      @init = {}

      mx = Mutex.new
      cv = ConditionVariable.new

      synch_prior(mx, cv, &λ1)     # prior function
      Thread.pass until {:prior=>true} == @init

      synch_posterior(mx, cv, &λ2) # posterior function
      Thread.pass until {:prior=>true,:posterior=>true} == @init

      cv.signal                    # we are ready to start
    end
  end
end
{% endhighlight %}

Here we produce two threads which are waiting one for another until the `yield` clause
(which may be blocking, if necessary) occurs to initiate the _ping-pong_ mechanism.

Let’s now add some syntactic sugar:

{% highlight ruby %}
module SeqExec
  Thread.abort_on_exception = true
  def pre &cb
    @prior = cb
  end
  def post &cb
    @posterior = cb
  end
  def run λ1 = nil, λ2 = nil
    pre &λ1 if λ1
    post &λ2 if λ2
    raise ArgumentError.new "Cannot run sequential execution, lambdas are not set" \
      unless (@prior && @posterior)
    Seqs.new.synch @prior, @posterior
  end
end
{% endhighlight %}

Now it’s time to play with:

{% highlight ruby %}
include SeqExec
@i=0
@stack = []
pre { sleep 0.3; print "-#{@i += 1}-"; @stack.push(@i) }
post { print "|#{@stack.pop}|" }
run

10.times { print "#"; sleep 0.1 }
sleep 3
{% endhighlight %}

The `prior` function pushes the incremented integer to the stack, the `posterior` reacts
by printing it to the terminal:

{% highlight ruby %}
# ⇒ ####-1-|1|###-2-|2|###-3-|3|-4-|4|-5-|5|-6-|6|-7-|7|-8-|8|-9-|9|-10-|10|-11-|11|-12-|12|-13-|13|
{% endhighlight %}

