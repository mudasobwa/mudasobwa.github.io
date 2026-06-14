---
layout: post
title: "Your Orchestrator Is a Finite Automaton in Denial"
description: "On the lonely `status` column that quietly metastasised into a state machine, the boolean flags breeding in its shadow, and why a real finite automaton is not academic finery but the cheapest insurance you will ever decline to buy"
category: hacking
tags:
  - elixir
  - finitomata
  - fsm
  - architecture
  - opinion
---

Somewhere in your codebase there is a table with a column called `status`. It started life as the most innocent thing imaginable—a single string, `"pending"`, set once at insertion and forgotten. Then somebody needed to know whether the thing had been paid for, so a boolean joined the schema. Then somebody needed to know whether it had shipped, and another boolean arrived. By the time the quarter closed, your `status` column had accreted flags the way a ship’s hull accretes barnacles: quietly, asymmetrically, and always below the waterline where nobody looks until the thing stops steering.

This is _status-driven orchestration_, and it is the most popular way in the industry to build a finite-state machine while loudly insisting you are doing nothing of the sort. The denial is the interesting part. Everyone agrees that explicit state machines are good in the abstract—the way everyone agrees that flossing is good—and then goes home and writes another `cond/1` that branches on a string.

Let me try to talk you out of it.

## The Anatomy of the Thing You Built

Here is a perfectly representative specimen. An order goes through a fulfilment pipeline: it gets paid for, packed, shipped, delivered. It can be cancelled. It can be refunded. Nothing exotic. Let us model it the way it actually gets modelled in the wild, in an `Ecto` schema that has clearly survived three product managers:

```elixir
schema "orders" do
  field :status,     :string,  default: "pending"
  field :paid?,      :boolean, default: false
  field :packed?,    :boolean, default: false
  field :shipped?,   :boolean, default: false
  field :delivered?, :boolean, default: false
  field :cancelled?, :boolean, default: false
  field :refunded?,  :boolean, default: false
end
```

And here is the orchestrator that drives it—the beating heart of the system, the thing that gets paged at three in the morning:

```elixir
def advance(%Order{} = order) do
  cond do
    order.status == "pending" and order.paid? and not order.cancelled? ->
      update(order, status: "paid")

    order.status == "paid" and order.packed? and not order.refunded? ->
      update(order, status: "packed")

    order.status == "packed" and order.shipped? ->
      update(order, status: "shipped")

    order.status == "shipped" and order.delivered? ->
      update(order, status: "delivered")

    order.cancelled? ->
      update(order, status: "cancelled")

    true ->
      {:ok, order}
  end
end
```

It looks reasonable. It compiles. It passes the one test somebody wrote for the happy path. And it is, I regret to inform you, a catastrophe wearing the high-visibility vest of a solution.

## What Is Actually Wrong Here

### Illegal states are not merely possible, they are the majority

Count the representable states. The `status` string takes seven values; each of the six booleans doubles the space. That is `7 × 2⁶ = 448` distinct rows your database will cheerfully accept. Of those four hundred and forty-eight, perhaps seven correspond to an order that could exist in physical reality.

The other four hundred and forty-one are nonsense, and your schema treats them with exactly the same hospitality as the legal ones. Nothing—not a constraint, not a type, not a stern comment—prevents a row with `status: "delivered"`, `cancelled?: true`, `refunded?: true`, and `paid?: false`. That is an order that was never paid for, was cancelled, was refunded money it never received, and was nonetheless delivered. It sits in your database like a passenger holding a ticket for a train that was cancelled: still on the platform, still expecting to be taken somewhere, and now also somehow already at the destination.

The flags breed in the schema like adapters in a junk drawer—each one solved a real problem exactly once, and now you own six and can confidently explain three. Every new boolean does not _add_ a state; it _multiplies_ the space of states you have promised to reason about and silently declined to.

### The state machine exists; you simply refused to draw it

There is a finite-state machine in that `advance/1` function. It is real, it has transitions, it has rules about what may follow what. The only problem is that it has no single, inspectable existence. It is smeared across the `cond`, the changeset validations, three controller actions, a background job, and the part of the senior engineer’s memory that he is planning to take with him when he leaves. The transition table lives nowhere and everywhere at once, like a signature forged by committee.

Ask the system a simple question—_what states can follow `paid`?_—and there is no honest way to answer it except to read the entire codebase and hope you found every site that writes to `status`. Spoiler: you did not. There is one in a Rake-equivalent task from 2023 that sets `status = "shipped"` directly, bypassing `advance/1` entirely, because someone needed to fix a stuck order once and never removed the scaffolding.

### Nothing stops a transition that should be unthinkable

Because `status` is just a field, _any_ code that can reach the struct can write _any_ value to it. There is no notion of a transition being illegal—there is only the notion of you having remembered to write an `if` that forbids it, everywhere, forever, without exception. Going from `delivered` back to `pending` is not prevented by the design; it is prevented by your vigilance, which is a renewable resource right up until the on-call rotation hits someone new.

### Concurrency turns the whole thing into a knife fight in a lift

Two requests arrive at once. Both read the order in state `pending`. Both evaluate the `cond`. Both decide the next state. Both write. What follows is less a race condition than a knife fight in a lift: cramped, badly lit, and with exactly one party walking out. Last writer wins, the first update evaporates, and the customer is charged twice because the “already paid?” check read a value that was true a microsecond ago and is now a lie.

You can paper over this with row locks and `SELECT ... FOR UPDATE` and optimistic-concurrency version columns, and now you are hand-rolling the serialisation guarantees that a process-based state machine hands you for nothing.

### Failure is an afterthought wearing a `rescue`

Where, in the specimen above, does failure live? It does not. When the payment processor times out, the code raises, something up the stack catches it, sets `status: "failed"`—an eighth string value nobody added to the schema’s mental model—and the order joins the population of rows that no longer match any branch of the `cond` and will sit there, inert, until a human notices the revenue gap.

### You overwrote your own audit trail

Every `update(order, status: "paid")` destroys the evidence of where the order was a moment ago. The history of the process—the single most valuable thing you have when debugging why an order is stuck—is overwritten in place. Reconstructing it later is archaeology conducted with a teaspoon and a head-torch, cross-referencing log lines against `updated_at` timestamps and praying nobody ran a backfill.

## Now Do It With an Actual Finite Automaton

Here is the same pipeline as a real FSM, using my [`Finitomata`](https://hexdocs.pm/finitomata) library. The entire state machine—every state, every legal transition, every event that triggers it—is declared once, in plain text, in a format that is simultaneously the code, the documentation, and a diagram your product manager can read:

```elixir
defmodule Order.FSM do
  @fsm """
  pending --> |pay| paid
  pending --> |cancel| cancelled
  pending --> |expire| cancelled
  paid --> |pack| packed
  paid --> |refund?| refunded
  packed --> |ship| shipped
  shipped --> |deliver| delivered
  """

  use Finitomata, fsm: @fsm, auto_terminate: true, timer: 15 * 60_000
end
```

That is not pseudocode and it is not a comment. That `@fsm` string is parsed, validated, and compiled into a `GenServer` with all the transition machinery generated for you. The diagram _is_ the source of truth, because there is no other source for it to disagree with.

Then you implement the business logic, and _only_ the business logic, in callbacks that pattern-match on exactly the state-and-event pairs you care about:

```elixir
@impl Finitomata
def on_transition(:pending, :pay, %{amount: amount}, payload) do
  case Payments.charge(payload.customer, amount) do
    {:ok, receipt} -> {:ok, :paid, Map.put(payload, :receipt, receipt)}
    {:error, _reason} -> {:error, :payment_declined}
  end
end

def on_transition(:paid, :pack, _event_payload, payload),
  do: {:ok, :packed, payload}
```

A successful charge moves the machine to `:paid` and stashes the receipt in the payload. A declined charge returns an error, the machine _stays exactly where it was_, and control flows to `on_failure/3`—a first-class, named place for things going wrong, rather than a `rescue` clause hoping for the best:

```elixir
@impl Finitomata
def on_failure(:pay, _event_payload, %Finitomata.State{} = state) do
  Logger.warning("payment failed for #{Finitomata.fsm_name(state)}")
  Notifications.payment_retry(state.payload)
  :ok
end
```

Time itself becomes a transition rather than a shadow orchestrator. The `timer: 15 * 60_000` option calls `on_timer/2` on a schedule, so an unpaid order expires on its own, without a cron job somewhere running `WHERE status = 'pending' AND inserted_at < ...` and mutating rows behind the FSM’s back:

```elixir
@impl Finitomata
def on_timer(:pending, %Finitomata.State{payload: payload}) do
  if Payments.overdue?(payload),
    do: {:transition, :expire, payload},
    else: :ok
end

def on_timer(_state, _state_struct), do: :ok
```

And driving it from the outside is unceremonious:

```elixir
{:ok, _pid} = Finitomata.start_link()

Finitomata.start_fsm(Order.FSM, "order:42", %{customer: cust, amount: 9_900})
Finitomata.transition("order:42", {:pay, %{amount: 9_900}})

Finitomata.state("order:42")
#⇒ %Finitomata.State{current: :paid, history: [:pending], payload: %{…}}
```

Notice the `history` field. The machine remembers where it has been, for free, without you overwriting anything.

## Point by Point, Why This One Wins

### Illegal states stop being representable

The current state is a single atom drawn from a closed set the compiler knows about. There is no `status` string _and_ a constellation of booleans to fall out of sync; there is the state, and there is the payload, and they are different things with different jobs. The four hundred and forty-one nonsense rows simply have nowhere to live. You cannot be `delivered` and `cancelled` simultaneously for the same brutally simple reason you cannot be in two rooms at once: the model does not have a word for it.

### The transition table is validated before your code ever runs

This is the part that ought to close the argument by itself. The `:finitomata` compiler reads your `@fsm` declaration and refuses to proceed unless it is a _consistent_ machine: exactly one initial state, at least one final state, and no orphans—no state you can enter and never leave, no state you declared and can never reach. It refuses to compile an incoherent machine the way a good editor refuses a sentence that parses but lies.

Better still, if you add a transition to the diagram and forget to handle an ambiguous case in `on_transition/4`, the compiler _tells you_, at compile time, with a warning that names the gap. Compare this to the status-driven approach, where a forgotten branch is discovered by a customer, on a Saturday, via Twitter.

### Transitions are guarded by construction, not by your memory

A transition that is not in the diagram does not happen. Sending `{:deliver, …}` to an order in state `pending` is not a bug you must remember to prevent with an `if`; it is structurally impossible, ignored by the machine the way a vending machine ignores a button for a slot that does not exist. The set of legal moves is data, declared once, enforced everywhere, rather than folklore re-implemented at each call site.

### Concurrency is solved because each machine is a process

Every `Finitomata` instance is its own `GenServer`, which means transition requests for a single order are serialised through a single mailbox and processed one at a time, in order. The knife-fight-in-a-lift disappears, not because you were careful, but because the architecture made the fight impossible to start. No row locks, no version columns, no optimistic-concurrency retries—just the actor model doing the one thing it has always been excellent at.

### Failure, timeouts, and retries are vocabulary, not accidents

The library has named, first-class places for the things status-driven code handles by flailing: `on_failure/3` for transitions that did not complete, `on_timer/2` for the passage of time, the `ensure_entry:` option to retry a transition until it sticks, and the last error preserved in the state for when you need to know _why_. A transition that ends with a `?`—like `paid --> |refund?| refunded`—is declared as one that is _expected_ to sometimes fail, so it does so quietly, without crying wolf in your logs. A transition that ends with a `!` is _determined_ and fires the instant it becomes the only way forward. These are not features bolted on; they are the grammar of the thing.

### History and observability come included

The state carries its own history. When an order is stuck, you ask the machine where it has been and it tells you, instead of you reconstructing the past from the sediment of `updated_at`. Pair it with the [`telemetria`](https://hexdocs.pm/finitomata) integration and every transition is an event you can measure, rather than a mutation you have to infer.

### Testing stops being string-equality theatre

Because the machine is explicit, you can test the machine. [`Finitomata.ExUnit`](https://hexdocs.pm/finitomata/Finitomata.ExUnit.html) lets you walk a path through the states and assert on each transition and the resulting payload, with a syntax that reads like the thing it verifies:

```elixir
assert_transition ctx, {:pay, %{amount: 9_900}} do
  :paid ->
    assert_payload do
      receipt ~> %Receipt{}
    end
    assert_receive {:charged, 9_900}
end
```

The status-driven equivalent is mocking the database and asserting that a string equals another string, which tests your typing accuracy and very little else.

### Distribution is a one-line upgrade

When one node is no longer enough, swap `Finitomata` for [`Infinitomata`](https://hexdocs.pm/finitomata/Infinitomata.html) and your machines run transparently across the cluster on top of `:pg`, with no change to the business logic. Scaling becomes a matter of adding nodes, not of rewriting your orchestrator around a distributed lock you will get subtly wrong.

## The Objections, and Why They Fold

**“This is over-engineering. It’s just a status field.”** It is not just a status field, and the proof is the six booleans standing next to it. You did not avoid building a state machine; you built one and declined to name it, which is the single option strictly worse than both alternatives—you pay the full cost of the complexity and receive none of the guarantees. Naming the tumour does not create it. It lets you operate.

**“FSMs are academic, textbook stuff.”** So is binary search, which you use without flinching, and the hash table underneath every dictionary you have ever instantiated. “Academic” is what we call the ideas that turned out to be so correct they became invisible. The finite automaton is one of the oldest, most thoroughly understood objects in computer science. Refusing to use it because it has a formal name is like refusing to use a bridge because an engineer was involved.

**“We already use a workflow engine for this.”** A workflow engine is, in the cases that matter, a finite-state machine that hired a sales team and learned to bill by the seat. If you want the semantics, you can have them in a hundred and fifty lines of your own language, in your own repository, without the YAML, the vendor console, and the per-execution pricing. Sometimes the heavy engine is the right call. Usually it is a sledgehammer rented monthly to drive a thumbtack.

**“Our orchestrator works fine.”** So does a car with insulating tape over the check-engine light. “Works fine” is a statement about the inputs you have happened to receive so far, not about the four hundred and forty-one illegal states patiently waiting for the input that produces them.

## The Point

You are going to build a state machine. That decision was made the moment your process had more than one step. The only choice left to you is whether it will be an _explicit_ state machine—declared in one place, validated by the compiler, guarded by construction, serialised by the runtime, and testable as a unit—or an _implicit_ one, scattered across your codebase like cutlery after an earthquake, held together by a `status` string, a fistful of booleans, and the fervent hope that nobody writes to the field from somewhere you forgot about.

The implicit machine is not simpler. It is the same machine with the guarantees filed off and the documentation set on fire. Name it. Draw it. Let the compiler check it. Your three-in-the-morning self, squinting at a row that claims to be delivered and refunded and never paid for, will thank you with a sincerity your waking self is not capable of.

Happy—and finite—automating.

---

Previously, on the subject of refusing to lose your mind over state:

- [Finitomata FTW](/hacking/2024/03/03/finitomata-for-the-win)
- [Make Your Library Test-Friendly](/hacking/2024/05/24/finitomata-exunit)
- [Documentation](https://hexdocs.pm/finitomata)
