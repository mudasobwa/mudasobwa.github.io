---
layout: post
title: "mocks Are Your Friends, Not Your Servants"
description: "On treating mocks as protagonists of the testing narrative rather than disposable stand-ins hired to nod along"
category: hacking
tags:
  - elixir
  - erlang
  - otp
  - testing
  - mocks
---

There is a peculiar tradition in our industry: the moment someone says “mock,” half the room recoils as if you have just proposed replacing the database with a spreadsheet. The other half nods enthusiastically, having already replaced the database with a spreadsheet.

Both camps are wrong, and for the same reason: they think of “mock” as a verb.

## Mock Is a Noun

José Valim wrote a [splendid piece on the subject](https://dashbit.co/blog/mocks-and-explicit-contracts) some years ago, and yet the industry continues to collectively ignore its central thesis with the dedication of a cat ignoring an expensive toy. The key insight is disarmingly simple: **consider “mock” to be a noun, never a verb.** You do not “mock a module.” You create a mock—an entity, a collaborator, a contract participant—that implements a well-defined behaviour.

The difference is not cosmetic. When you “mock” a function (verb), you are lying to your test. You are saying: “pretend this hole in the wall is a door.” When you create a mock (noun), you are building an actual door—one that opens and closes according to the same interface contract as the production door, just perhaps into a smaller room.

## Stubs Are for Candles, Not for Software

The prevailing use of mocks in the wild amounts to: “I need this function to return 42 so my other function does not crash.” This is not testing. This is bribery. You have paid off a witness to give the testimony you wanted, and now you are surprised when the real trial goes sideways.

A mock that merely returns canned responses is a stub wearing a fake moustache. It tells you nothing about whether your code actually _interoperates_ with the expected behaviour. It only tells you that, given a universe where everything behaves exactly as you imagined, your code does not crash. Congratulations—that was never the hard part.

The hard part is the contract. Does your code send the right messages? Does it handle the responses defined by the behaviour? Does it _respect the protocol_, not just survive it? A proper mock enforces these questions. A stub sweeps them under the carpet and charges you for the cleaning.

## Promote Your Mocks to Lead Actors

Here is the heresy: mocks should not sit quietly in the corner of your test, responding when spoken to like well-trained waitstaff. They should be protagonists. They should _drive_ the testing narrative.

Consider a finite state machine. It transitions through states, fires callbacks, notifies listeners. In production, the listener might persist data, send emails, ring bells. In tests, you do not care about the bells. You care about: did the FSM reach state X with payload Y after event Z?

A mock-as-protagonist answers this question directly. It is not merely absorbing calls—it is _reporting back_ to the test, asserting that the system did what it promised. The mock becomes your embedded journalist, filing reports from inside the process under test.

This is a fundamentally different posture. The mock is no longer a shift worker you hire to stand in for the real employee. It is a first-class participant in the test, with its own responsibilities, its own assertions, its own voice.

## OTP, Race Conditions, and the Debugger You Deserve

Anyone who has tested concurrent OTP systems knows the special joy of a test that passes ninety-nine times and fails on the hundredth, always at random time, always on CI, never on your machine. The core problem is structural: you fire an asynchronous message and then try to assert about a state that may or may not have been reached yet. `Process.sleep(200)` is not a solution—it is a prayer in milliseconds.

Mocks offer something better. When a mock is registered as a listener, every state transition sends a message back to the test process. You can then use `assert_receive` to _wait_ for the transition, with a timeout, deterministically. No sleep. No prayer. No coin flip.

In effect, the mock becomes a breakpoint in a debugger you never had to open. It declares: “I expect to be called with _these_ arguments, in _this_ order,” and it sends a message to the test process confirming each call. You get both the expectation (`expect/3`) and the synchronization (`assert_receive/2`) in one mechanism. The mock is simultaneously the probe and the signal.

This is not theoretical. In OTP, where processes communicate via message passing and the scheduler is free to interleave execution in whatever order amuses it most, this pattern transforms flaky tests into deterministic ones. You are no longer guessing when the process reached the desired state. You are being _told_.

## Listeners, Visibility, and the Joy of Seeing What Happens

There is a secondary benefit that deserves its own paragraph: visibility.

When you plug a mock in as a listener—not as a replacement for an implementation, but as an _observer_ of one—the test code becomes radically more readable. Each assertion is a statement about what the system _did_, not about what you had to simulate. The reader does not need to mentally reconstruct the production flow from a pile of stubs. The flow is right there, reported by the mock, step by step.

Test code that reads like a narrative of actual system behaviour is test code that people trust. And test code that people trust is test code that people maintain. And test code that people maintain is test code that catches bugs. The chain of causation is longer than a Dickensian sentence, but every link holds.

## Finitomata: A Case Study in Mock-Driven Testing

All of this is not armchair philosophy. The [`Finitomata.ExUnit`](https://github.com/am-kantox/finitomata/blob/main/lib/finitomata/test/ex_unit.ex) module is a working testing framework built entirely on this premise. It uses `Mox` not as a crutch but as the foundation.

The setup declares a mock listener. The mock is `allow`-ed to the FSM process and given `expect`ations for `after_transition/3` callbacks. Each expectation sends `{:on_transition, id, state, payload}` back to the test process. The test then walks the FSM through its transitions and asserts each state deterministically via `assert_receive`.

The result looks like this:

```elixir
test_path "respectful passenger", %{passengers: initial_passengers} do
  :coin_in ->
    assert_state :opened do
      assert_payload do
        data.passengers ~> ^initial_passengers
      end
    end

  :walk_in ->
    assert_state :closed do
      assert_payload do
        data.passengers ~> one_more when one_more == 1 + data.passengers
      end
    end

  :switch_off ->
    assert_state :switched_off
    assert_state :*
end
```

No `Process.sleep`. No polling. No race conditions. Each transition is confirmed by the mock-listener before the test proceeds. And crucially: _intermediate_ states—including those triggered by automatic (bang!) transitions that the test never explicitly fires—are observable and assertable, because the mock reports every single one.

The mock here is not a stand-in. It is the entire testing infrastructure. Remove it, and you are back to `Process.sleep(200)` and crossed fingers.

## The Moral

Mocks have suffered from a branding problem. They were introduced to the mainstream as “a way to avoid calling the real thing,” which is roughly equivalent to introducing a violin as “a way to avoid silence.” Technically correct, but missing the point so thoroughly that it constitutes its own genre of wrongness.

A mock is a collaborator. A contract enforcer. A synchronisation primitive. A visibility layer. A debugger breakpoint. A protagonist.

Treat it accordingly, and your tests will repay you with the one thing no amount of `Process.sleep` can buy: confidence.
