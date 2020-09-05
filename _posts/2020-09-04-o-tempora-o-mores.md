---
layout: post
title: "O tempora, o mores!"
description: "Tempus is a library to deal with time slots, like doctor appointments and/or room reservations"
category: hacking
tags:
  - elixir
  - erlang
---

The title is gracefully stolen from _Oratio in Catilinam Prima in Senatu Habita_ by Marcus Tullius Cicero.

![Cicero Denounces Catiline, fresco by Cesare Maccari, 1882–1888](/img/ciceron_denuncia_a_catilina.jpg)

---

In real life we often deal with time slots. Dentist appointments, hotel room reservations, even daily lunch break: scheduling all these is a task of fitting a time slot in a series of other time slots.

Consider a dentist appointment. I know I need 1 hour for the yearly routine inspection. I can visit a doctor during my lunch time, or after my working hours. The doctor has other patients. Here my busy hours are shown in purple, the doctor’s ones in red, non-working hours in gray, and the happily found slot when we both are free in green.

![Timelines of my busy hours and the dentist’s busy hours](/img/tempus-1.png)

A cursory glance at this chart is enough to spot the appointment time to be scheduled. Tomorrow, lunch time. Easy, huh?

Unfortunately, none of languages I am familiar with provides the functionality to determine this programatically. Last several years I am married to _Elixir_, hence I decided to write the library solving this particular problem.

Welcome [`Tempus`](https://hexdocs.pm/tempus/getting-started.html)!

### Implementation details

The unit this library is built around is `Slot`. It represents the time slot in a most natural and simple way: struct, having `from` and `to` fields, both of type `DateTime`. The series of slots are organized in `Slots`. Under the hood it’s implemented as [`AVLTree`](https://en.wikipedia.org/wiki/AVL_tree). This choice was made to keep the underlying list of slots consistent (ordered and not overlapped) for lowest cost to optimize read-access. The common use-case would be to fill the tree and store it somewhere for querying later.

[`Slots.add/2`](https://hexdocs.pm/tempus/Tempus.Slots.html#add/2) function would add the slots list with the new slot, _joining slots as needed_. That makes it possible to simply insert new slots into the structure without bothering of the order _and_ of the overlapping. Also, the helper function [`Slots.merge/2`](https://hexdocs.pm/tempus/Tempus.Slots.html#merge/2) is provided to merge two slot series. The latter is explicitly handy when one needs e. g. to find the _empty_ slot in both series, as in the example with dentist appointment above.

One might also test any input against the slot with functions in [`Slot`](https://hexdocs.pm/tempus/Tempus.Slot.html#content) module: whether the slot covers the `DateTime` instance given, whether slots are disjoint or not, etc.

### `Tempus` module

The main module exports functions to work with slots as with an intermittent timeline. One might add any arbitrary time interval to the origin, taking the slots into consideration; check whether the origin is _free_, or already taken by slots, get next free, or next busy slot, inverse slots, and more.

Here is the simple example from tests:

```elixir
slots =
  [
    Tempus.Slot.wrap(~D|2020-08-07|), # whole day
    %Tempus.Slot{
      from: ~U|2020-08-08 01:01:00Z|, # one minute
      to: ~U|2020-08-08 01:02:00Z|
    },
    %Tempus.Slot{
      from: ~U|2020-08-08 01:03:00Z|, # one minute
      to: ~U|2020-08-08 01:04:00Z|
    }
  ]
  |> Enum.into(%Tempus.Slots{})
```

Now adding `0` seconds to the occupied by slot time would return the first free time after this slot.

```elixir
Tempus.add(slots, ~U|2020-08-08 01:01:30Z|, 0, :second)
#⇒ ~U[2020-08-08 01:02:00Z]
```

Adding 70 seconds five seconds before the first occupied minute `~U[2020-08-08 01:00:55Z]` would return the time five seconds after the second occupied minute

```elixir
Tempus.add(slots, ~U|2020-08-08 01:00:55Z|, 70, :second)
#⇒ ~U[2020-08-08 01:04:05Z]
```

And so on. Negative values are surely allowed as well.

### Merging slot series

`Slots.merge/2` accepts a stream as the second argument. At the moment the library does not support merging and using _stream_ of slots as is, but merging the stream into existing time slots is possible. This might be useful when one has the short list of, say, holidays, and wants to merge some reoccuring slots, like weekends.

All the functions returning `Slots` and/or `Slot` return valid objects (meaning `Slot` would be normalized and `Slots` would be ordered and joined as necessary.)

### Future development

Current implementation covers our internal needs only, so I would be happy to hear about what this library lacks and what should be added to it.

---

Happy timeslotting!
