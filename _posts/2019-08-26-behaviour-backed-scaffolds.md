---
layout: post
title: "Scaffolds Backed Up By Behaviours"
description: "Minimizing the boilerplate across your in-house library / applications is easy"
category: hacking
tags:
  - elixir
  - erlang
---

![Behaviour Backed Up By Scaffold](/img/beach-filipines.jpg)

### Repeated Code aka Copypasta

If you are like me, you probably try to make the ~~life~~ developing and testing easier by moving all the _generic_ code into well-tested self-contained packages. This is barely necessary if the waterfall development process in the company is shaped to feed the ancient behemoth, affectionately called by all teammates “Monolitty,” but first three microservices happened to appear in the repo eventually make everybody to think about how to share common code between them.

Sometimes it might be done by extracting the common code into the package used by all microservices. Unfortunately, the code to be shared is usually not _the same_, but _quite alike_. _Custom Logger_, or _Slack Notifier_, or _RabbitMQ Subscriber_ look very similar in the area of establishing and keeping a connection, managing crashes and disconnections, etc, but they differ in the business logic specific parts. And the decision _how do we shape the common part so that the pieces to be written by clients of this interface are both kept small but best maintainable_ remains the one of most important.

There are several different approaches. Here I am going to show one of them. I spotted it in [`Broadway`](https://hexdocs.pm/broadway). As by documentation,

> `Broadway` is a concurrent, multi-stage tool for building data ingestion and data processing pipelines.
>
> It allows developers to consume data efficiently from different sources, such as Amazon SQS, RabbitMQ and others.

In a nutshell, `Broadway` takes care about keeping the connection and providing a back pressure against the external source, providing the handy interface for _clients_ of the library to concentrate on the business logic only. Basically, one does `use Broadway` and all they need to plug in their business logic would be to implement `Broadway.handle_message/3` callback which will be called on new incoming messages received from the external source. All the connection low-level handling stuff is kept under the hood and `use Broadway` just makes it implemented automagically. I oversimplified the things, but without loss of generality.

### Deal With It!

So, the approach I advertise and advocate would be

> **Implement the common logic in your external package and use callbacks anywhere the business logic is required / affected.**

This works incredibly smooth. As an example, unrelated to dealing with connections, I might mention [`DynamicManager`](https://hexdocs.pm/tarearbol/dynamic_workers_management.html#content) included in the last release of [`Tarearbol`](https://hexdocs.pm/tarearbol). This is a helper around [`DynamicSupervisor`](https://hexdocs.pm/elixir/master/DynamicSupervisor.html) taking care about the boilerplate needed to handle and supervise many different processes, behaving _more-or-less_ alike.

Imagine we have an auction implementation, with several different types of items. Each item is managed by its own process and the processes have slightly different _Finite Automata_ driving the business logic. Once the item is put up for auction, the process is started; once it gets sold, the process exits. If there was no user interaction, the price gets lowered by 1% automatically. Something like that. To distinguish the business logic and concentrate on what actually matters, one might use `DynamicManager` scaffold in the following way.

```elixir
module Auction do
  use Tarearbol.DynamicManager

  def children_specs,
    do: for au <- Repo.all(AuctionItem), into: %{}, do: {ai.id, [payload: ai]}

  def perform(aid, ai) do
    aid
    |> check_bids()
    |> case do
        {:ok, price} ->
          Repo.update(ai, price: price, status: :sold)
          :halt
        :pass ->
          Repo.update(ai, price: price * 0.99, status: :trading)
          :ok
      end
  end
```

That’s all needed. The process will reschedule itself every 1 second (default,) check for the bids (this function implementation is out of scope of this post,) and mark the item as sold and instruct the supervisor to kill itself or downgrade the price and wait for new bids.

The example is contrieved and oversimplified, but it perfectly shows how all the non-business-related logic might be encapsulated into the library and reused, when the real application only needs to implement several callbacks to make all the machinery work.

Happy encapsulating!
