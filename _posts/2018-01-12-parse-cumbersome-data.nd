---
layout: post
title: "Pattern matching on binaries is better than regular expressions"
description: "Cumbersome pattern matching might be way better than parsing strings with regexps"
category: hacking
tags: elixir, tricks, dwim
---

Last week I spent evenings tweaking
[`{:ok, 📍} LibLatLon`](https://github.com/amotion-city/lib_lat_lon),
the helper library for geocoding. Currently it supports both `OpenStreetMap` and
`GoogleMaps` providers (other might be easily added,) and provides fancy lookup
given _an image with gps coordinates included_ as an argument

```elixir
iex|1 ▶ LibLatLon.lookup "images/IMG_1.jpg"
#⇒ %LibLatLon.Info{
#     address: "Avinguda del Litoral, [...] España",
#     bounds: %LibLatLon.Bounds{
#     ...
```

OK, leading shameless ad is over; let’s turn back to the the theme of today's
talk. This library claims it can read a latitude and longitude information from
almost anything that is somehow looking like a thing, that includes coordinates.

It was easy for:

* `{lat, lon} when is_number()` tuples;
* `{[degree, minute, second], reference}` values;
* some weird combinations of the above, used here and there;
* images with _GPS_ geo information included (that was easy!).

One might check
[the diversity of types accepted](https://hexdocs.pm/lib_lat_lon/LibLatLon.Coords.html#borrow/1)
and the examples below. And everything was fun, unless I stepped into accepting
strings as an input. If you wonder, Google supports the nifty properly
typographed format:

* https://maps.google.com?search=41°22´33.612˝N,2°8´55.242˝E

Cool? Yes. I decided I need to support this format as well. In other words,
I was to parse the input like `"41°22´33.612˝N"` and produce a float out of
this. I love regular expressions. If I ever will launch my own programming
language, it’ll support none syntax but regular expressions.

The only drawback is productivity and inability to damn test all the corner
cases with a regular expression. One might go with something like:

    \d{1,2}°\d{1,2}´\d{1,2}(\.\d{1,})?˝[NWES]

or, even, be more precise and disallow degrees, greater than `89` and minutes
greater than `59` and all that. My goal was different: I wanted to use
Elixir binary pattern matching to accomplish the task. Because I love regular
expressions, but binary pattern matching is still way sexier.

The issue is one cannot pattern match binaries of undeternmined length
in the middle of the match. My first idea was strictly disallow malformed
input like `"42°0´6.57252˝N,3°8´28.13388˝E"`, but a friend of mine having
an address “17257 Fontanilles, Girona, Spain” would complain and grudge that
`{42, 3.14159265}` is accepted fine, while `"42°0´0˝N,3°14´15.9˝E"` is not.

But Elixir provides great opportunities for macro programming, would probably
yell here the astute reader, and yes, here we go. We are about to _generate_
all possible variants of the string above in a compile time.

Let’s do it for the single blahtitude:

```elixir
  for id <- 1..2,
      im <- 1..2,
      is <- 1..@decimal_precision do
    def parse(<<
          d::binary-size(unquote(id)), "°",
          m::binary-size(unquote(im)), "´",
          s::binary-size(unquote(is)), "˝",
          ss::binary-size(1)
        >>),
    do: Enum.map([d, m, s], fn v ->
          with {v, ""} <- Float.parse(v), do: v
        end)
```

Hey, it was simple! `@decimal_precision` is a parameter that is small in
developement environment and set to `12` in production. 12 gives 48 different
implementation only for the single blahtitude and it takes some noticable time
to compile.

The result would be nearly the same as we had copy-pasted
`def parse(<<.........>>), do: {}` 48 times and changed the details here
and there.

The implementation of the whole match does not differ much: another three
comprehension loops are added and the total number of generated functions
is raised drastically. That’s mostly it.

The same technique might be applied to parsing dates, times, floating point numbers
with a limited mantissa (with an unlimited one, it’s still possible with
a fallback to regular expression when the amount of digits is greater than `42`,)
you name it.

Sometimes plain old good regular expression looks at least way more sane.


