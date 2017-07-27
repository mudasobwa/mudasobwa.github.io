---
layout: post
title: "Workflow as FSM: lost transitions"
description: "building a robust FSM for a workflow"
category: hacking
tags:
  - tricks
  - ruby
---

## Workflow as FSM

> A **finite-state machine** (**FSM**) or **finite-state automaton** (**FSA**,
plural: _automata_), **finite automaton**, or simply **a state machine**,
is a mathematical model of computation. It is an abstract machine that can be
in exactly one of a finite number of states at any given time.  
The FSM can change from one state to another in response to some external inputs;
the change from one state to another is called a transition.  
An FSM is defined by a list of its states, its initial state,
and the conditions for each transition.  
<small>[Wikipedia](https://en.wikipedia.org/wiki/Finite-state_machine)</small>

_Wikipedia_ provides a coin-operated turnstile as an example of state machine:

![State diagram for a turnstile](https://upload.wikimedia.org/wikipedia/commons/9/9e/Turnstile_state_machine_colored.svg)

Even from this example it’s clear that the definition above is not accurate.
To be precise, the statement “the change from one state to another is called
a transition” is actually incomplete. Check the `push` transition when the state
is `locked` and `coin` transition when the state is `unlocked`. Both _do not change
the state_.

This terminology inaccuracy leads to misunderstanding of how FSM should be built
to become a friend of a developer, not an enemy to fight against.

## Bonus program tracking (naïve approach)

Let’s imagine we have a bonus program to be developed for our clients. Each
client receives a fixed number of bonus points for each subsequent action,
and, as soon as the total amount reaches some value, the customer is awarded
with something fruitful. We want to implement bonus as a model, evidently
having three states: `:initial`, `:collecting` and `:bonus`. The naïve FSM
would look like:

![Naïve FSM](/img/fsm_bonus_naive.png)

Each subsequent bonus point moves us towards `:bonus` state. The code, supporting
this workflow could look somewhat like below (I am using
[`workflow`](https://github.com/geekq/workflow) gem here, but it really does not
matter.)

```ruby
workflow do
  state :initial do
    event :gain, transitions_to: :collecting
  end
  state :collecting do
    event :bonus_reached, transitions_to: :bonus
  end
  state :bonus do
    event :restart, transitions_to: :initial
  end
end

def coins_gained!(amount)
  @coins = @coins.to_i + amount
  if @coins >= 100
    bonus_reached!
    @coins -= 100
    restart!
  end
end
```

Right?—Unfortunately, no. This is not a robust workflow. It shifts too much of
it’s duties elsewhere. It does not control intermediate state (`:collecting`)
properly. Imagine, two days after launch we were asked by our marketing department
to email customers when their points amount reaches 20 and 50 points. What would
we do?—Yes, we would blow our `coins_gained!` method up:

```ruby
def coins_gained!(amount)
  old_amount = @coins.to_i
  new_amount = old_amount + amount

  if old_amount < 20 && new_amount >= 20 ||
     old_amount < 50 && new_amount >= 50
    send_email_to_customer
  end

  @coins = new_amount
  if @coins >= 100
    bonus_reached!
    @coins -= 100
    restart!
  end
end
```

Yeah, yeah, I know that the whole checking and sending email might be extracted
to it’s own method, as we always do in Rails making our models finally
to contain a dozillion of private helpers calling other private helpers
to satisfy rubocop with her 10-LOC-per-method-body limit.

## Better approach

The real issue is: our workflow is not robust. There is a transition we
missed: noop from `:collecting` to `:collecting` state:

![Proper FSM](/img/fsm_bonus_correct.png)

The workflow transitions are now named properly in the first place.

```ruby
workflow do
  state :initial do
    event :gain, transitions_to: :collecting
  end
  state :collecting do
    event :gain, transitions_to: :collecting
    event :bonus_reached, transitions_to: :bonus
  end
  state :bonus do
    event :restart, transitions_to: :initial
  end
end
```

Better?—Yes, but still not perfect:

```ruby
def gain(amount)
  @coins = @coins.to_i + amount
  bonus_reached! if @coins >= 100
end

def bonus_reached
  @coins -= 100
  restart!
end

def on_transition(amount)
  send_email_to_customer if need_email? # encapsulated check
end
```

The code is now clean, no explicit `if` on checking what state to be next exists,
the email will be sent despite the target state. What could be improved?—Well,
sending email is _also a state_.

## Overdesigned approach

Should not we also introduce a particular state for “sending an email”?

![Overdesigned FSM](/img/fsm_bonus_overdesigned.png)

The answer is: no, we probably shouldn’t. It will just make things cumbersome,
it will implicitly require more unnecessary checks, it will make the transitions
less explicit:

```ruby
def gain(amount)
  ...
  emailing! if need_email?
  # what if bonus is reached?
  ...
end

def emailing
  send_email_to_customer
  email_sent!
  # back to collecting ⇒ void transition implies
  #                      potential glitches when
  #                      handlers are implemented
end
```

## Conslusion

When some action is taken place from outside, it should be covered with
transition. Even if it’s same-state transition.

When the action is completely internal, it does not deserve it’s state.
