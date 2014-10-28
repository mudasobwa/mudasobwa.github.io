---
layout: post
title: "Developer Omniboxes for Chrome"
description: "A collection of omnibox search extensions for Google Chrome™, for searching API reference documentation for a number of different languages and libraries."
category: hacking
tags:
  - tools
---
A couple of months ago I finally switched from Firefox to Chromium. As I mentioned before, I’m a keyboard addict. I mostly use the browser
to find some information over the internet. That’s not click-through pattern. I know what am I interested in and I know where am I to find it.
So, half of the time I was wasting on opening new browser tabs and entering the respective search engine. Firefox gave me an opportunity
to use the small search box on the right of the usual one (sorry for not naming it properly, I likely do not bother how it’s called.)
Chromium, on the other hand, has no such ability (or I was not able to find it at a glance.)

Past a week I found myself searching for a “developing chrome extension extended search.” That was how I came to
[Omnibox](http://developer.chrome.com/extensions/omnibox.html) how-tos. It has actually an already existing and growing bundle of
[search tools for developers](https://code.google.com/p/developer-omniboxes-for-chrome/), including handy documentation lookup for
virtually speaking all the programming languages. E. g. to find a documentation on Ruby’s `Array` one does simply type in the
address bar: `rb Arr` and scrolls down the most suitable suggestion:

![Search against Ruby documentation](/img/omnibox-ruby.png)

The omnibox extension is so simple, that I immediately decided to have my own written. I chose `»` as the “keyword” for omnibox.
Depending on the input language, it suggests search against either different common engines (like youtube, wikipedia and bing,) or
against russian analogues (yandex, russian wiki, lingvo translation service.) For `» текст` it suggests the following engines:

![Search against Russian engines](/img/omnibox-lingvo.png)

The source code is rather simple and may be found at [github](https://github.com/mudasobwa/searchisk) as usual.

