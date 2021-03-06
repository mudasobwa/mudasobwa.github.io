---
layout: post
title: "Multiple Match in Ruby"
description: "Matching all the occurences of a pattern returning MatchData"
category: hacking
tags:
  - ruby
  - tricks
---
When somebody needs to find all occerences of a pattern in a string, she usually
does either `scan` or repeatitive `match` calls. I was unable to google a quick solution
of getting all the `MatchData` instances. Even
[StackOverflow provides](http://stackoverflow.com/questions/6804557/how-do-i-get-the-match-data-for-all-occurrences-of-a-ruby-regular-expression-in)
a strange answers on a topic, like that one below:

```ruby
str.to_enum(:scan, /PATTERN/).map { Regexp.last_match }
```

Actually, the [owls are easier than they seem](http://en.wikipedia.org/wiki/Twin_Peaks). All we 
need is to use one of a cryptic `$` [ruby globals](http://jimneath.org/2010/01/04/cryptic-ruby-global-variables-and-their-meanings.html):

```ruby
input = "abc12def34ghijklmno567pqrs"
numbers = /\d+/
input.gsub(numbers) { |m| p $~ }
```

prints all the `MatchData`s:

```ruby
# ⇒ <MatchData "12">
# ⇒ <MatchData "34">
# ⇒ <MatchData "567">
```

Voilà.
