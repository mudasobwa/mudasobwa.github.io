---
layout: post
title: "Clarity Over Verbosity Everywhere"
description: "A response to “Clarity over brevity in variable and method names” by DHH"
category: culture
---

Last day my colleague has shared [the post by DHH](https://signalvnoise.com/posts/3250-clarity-over-brevity-in-variable-and-method-names),
written back in 2012 and called “Clarity over brevity in variable and method names.”

David advocates long variable and method names there. The example from the
_Basecamp_ code base illustrates the idea. I beg your pardon if you do read
this from the smartphone and/or tablet:

```ruby
def make_person_an_outside_subscriber_if_all_accesses_revoked
  person.update_attribute(:outside_subscriber, true) if person.reload.accesses.blank?
end
```

The point is (if I got it properly): _the method name is clear because of it’s
verbosity_. This is bullshit.

When two persons are having a conversation in Spanish, the phrase in Russian,
even being very clear, verbose and syllabically flawless, won’t help to
describe the topic better. Development is being done with so-called
programming languages, that differ from human languages. And there is a
good reason for that.

Abstraction.

While coding, I don’t give a piece of cake whether this entity is a person,
a cat or even a forest troll. The literal meaning of “subscriber” is of no value
at all. It is just an association. It could be _the hair color_ as well.
Or, say, _monthly income_. The good developer should not care about
implementation details. Good abstraction level is 80% of the success in
producing maintainable, flexible and reliable codebase. Not long names.

`if_all_accesses_revoked`. What? Who damn cares? Make it generic and benefit
from having an abstraction, that serves access rights. _Any possible_ access
rights, both existing and those to be created in the next year.

I am positive, that while one’s reading the method name shown above, good
developer will produce the whole implementation of the _access rights_ abstraction.
Programming languages differ from human languages. They extract
the essense to decrease a possibility of the ambiguity and make the code less
error-prone. All that is impossible when we start to talk (and therefore think)
on such a microlevel as “outside subscribers in a case when all accesses are
revoked.” This granularity breaks the whole picture, makes the codebase bloated
and in general introduces unmaintainable code, since every single update
in _accesses_ would typically introduce hundreds of new methods.

We are developers and we are supposed to know the syntax of the language
we work with. It should not be a quest to understand what the code does.

Long names say nothing about meaningful things, like: control flow, side effects,
current state, etc. All that is valuable. And “outside subscriber” is not.
Call it “chapuza,” or “stuff,” or “хня,” the programming language speaks for
itself. BTW, COBOL is the most readable language that was ever invented,
that’s why I proposed to call Rails COBOL². The whole attempt of Rails’
so-called readability was invented by
[Grace Hopper](https://en.wikipedia.org/wiki/Grace_Hopper) 60 yrs ago.

And my advice for those having problems understanding oneliners would be:
train yourself in the programming language. Solve quizes. Help on Stack Overflow.
Write more code.

Introducing long method names would just bury you disability to write and read
clean code deeper in the ground. I [have been writing](http://rocket-science.ru/hacking/2016/04/22/stack-overflow-achievements) about
that already. Nothing has changed. Good code is granular, dense and strong.
Long sentenses are good in medieval literature, not in the development.



