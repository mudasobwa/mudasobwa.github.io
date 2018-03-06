---
layout: post
title: "Why immutability rules"
description: "A list of some less evident advantages of immutability"
category: hacking
tags:
 - elixir
 - ruby
---

The arguing on pros and cons of mutability is aging it’s Diamond jubilee.
As far as I can tell, nowadays people tend to blame mutability for hardly
manageable code and “floating” errors that are nearly impossible to catch.
Also, I’ve heard that immutability is great because it leaves no room
to make a silly mistake for the developer.

While that is true, that is _very_ perfunctory view on the difference.
I have an experience in writing code in both assembly language and C and I
am positive that programming differs from visiting spa facilities: it’s
still up to the developer to take care about, you know, code quality. Any coder,
having the IQ that slightly exceeds the IQ of my vacuum cleaner, must be able
to deal with the mutability. That’s not a rocket science.

What really matters is a performance. Code efficiency and viability. The human
being should be responsible to understand any cumbersome code, while it brings
a gain in the user experience. One of the most valuable metrics of UX is
a response time. Not the developer comfort. I believe there is an epitaph
graved in stone in the programmer’s hell, saying **“Thou shalt have no
boon before UX.”**

I got distracted, though.

Immutability grants _a compiler_ with a great opportunity for free: there is
no need to copy data. Everything might be passed by reference. For free.
Because the data is guaranteed to remain unchanged forever.

I accidentally realized that there are some people all around who didn’t think
about that particular aspect of immutability, so please let me repeat it in bold.

**Data is nearly never copied, no matter what. It is passed by reference. Always.**

That said, if one wants to return, for instance, a complicated structure from
a function, there is no need to declare a constant upfront. In the code below,
the only instance of this map will be allocated. All subsequent calls will
reference the previously allocated memory.

```elixir
def my_data do
  %{
    address: "Carrer de la Marina, 16, 08005 Barcelona",
    poi: "Torre Mapfre",
    weird_numbers: [42, 3.14159265],
    inner_map: %{i: :was, not: :able, to: :invent, better: :example}
  }
end
```

Please note, that the same function called in e. g. _ruby_ 50 times would
allocate the memory _50 times_.

That is very significant. If you still think it is not, let me restate:
_immutability grants caching of everything for free._ This is an immortal
cache that does not require invalidation for the application lifetime.

---

Plus, of course, it saves our asses from passing a list/array to a function
in a loop and wondering why the heck it gets truncated when the loop exits.
I am also able to value the amenity for developers, even despite I care for
compiler much more.
