---
layout: post
title: "Standing on the Shoulders of Giants"
description: "How I implicitly helped Joe Armstrong a while ago"
category: culture
tags:
  - elixir
  - erlang
---

![EXIF for Joe Armstrong](/img/on-giants-shoulders.jpg)

Today I was grepping the internets for something irrelevant and came across [this blog post](https://joearms.github.io/#2017-12-18%20Calling%20Elixir%20from%20Erlang) by Joe Armstrong. Long story short, he was stumbled upon extraction from the photos _“things like the latitude and longitude of the place where the image was taken and the time when the image was taken”_.

Basically it was about extracting [Exif](https://en.wikipedia.org/wiki/Exif) data from the photos. Joe discovered Dave Thomas’ [_Elixir_ library](https://github.com/pragdave/exexif) that deals with _Exifs_ and finally succeeded with his fleeting task.

What I am proud now, the code that made Joe happy was indeed _mine_. I got into the same issue a couple of years ago and _GPS_ data support in that library is [fully implemented by me](https://github.com/pragdave/exexif/tree/master/lib/exexif/data).

That said, Joe Armstrong used my code and it made him slightly happier at the moment. There is nothing to be proud of, in terms of code: it is trivial and all the hard work in regard to parsing _Exif_ was already done by Dave. It’s not about being proud and it’s not the stuff one puts into résumé.

I am just happy Joe used my code and it helped him at the moment. Joe is one of the smartest people I was lucky to know personally, I envy his sense of humor and it is just making me smile joyfully: I helped him with code.
