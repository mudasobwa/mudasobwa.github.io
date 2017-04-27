---
layout: post
title: "Quotation Marks in XXI Century"
description: "How to escape quotation marks safely, or typography is coming"
category: hacking
tags:
  - ruby
  - dwim
---

There is a common problem we inherited from `VT-100` terminal times: there is
insufficient amount of buttons on a keyboard. While
[Latin alphabet](https://en.wikipedia.org/wiki/Latin_alphabet) contains 23 letters,
modern variation has 26 letters (`J`, `U` and `W` instilled,) and some languages
using it have added “diacriticsized” letters (like umlauts `Ö` in German and Swedish,
“island” `Ø` and “ångström” `Å` in Danish and Norwegian, etc.)

On Cyrillic keyboards (33 letters in the alphabet,) we have made a sacrifice of
square brackets and backtick, to admit additional letters into the house. I am
afraid to imagine how Archaic Egyptian keyboard should look like.

Due to the lack of place on our laptops and cellulars, we get accustomed to use
neutral straight dumbs instead of singular, double quotes, and even instead of
an apostrophe. Especially in programming languages.

Whoever cares about a typography rules in error messages, formatted as

> err: there is no such entity in container (#42)

---

Well, first of all since one has a localized application, she probably does not
want to scare these
[touchy Finns](http://arstechnica.com/information-technology/2013/07/linus-torvalds-defends-his-right-to-shame-linux-kernel-developers/)
with wrong typography. And, you know, different languages have different
[typography rules](https://en.wikipedia.org/wiki/Quotation_mark).

In fact, using proper typography quotes (well, hang the Finns, even simple
English quotation marks,) one yields a ton of profit. Typographically correct
quotation marks are:

* idempotent, left and right differ;
* easy to grep in the huge codebase;
* do not need any escaping anywhere in the code.

**The latter is the silver bullet.** Matz even invented `%Q{}` literal to
simplify the dealing with strings, containing both single and double quotation
marks, but what this string is converted to json? passed to remote service?
encoded and decoded?

Bah.

There is just no problem with strings, containing typographically correct
quotation marks. Not. At. All.

Pass them everywhere (I doubt about COBOL, but any other language in 2015 would
gracefully understand the unicode,) convert it back and forth, escape them,
unescape them, you’ll always have the correct result.

```ruby
     str = 'And God said “We’ll call it ‘typography’,” and there was light'
```

Actually, I came to this conclusion after a couple of hours of hard debug
session, where quoted string was passed into javascript from ruby with a
superfluous escaping, ruining json content, but still providing the well-formed
json.
