---
layout: post
title: "Two ways to write ruby code"
description: "Make you code to be appreciated by the offspring"
category: hacking
tags:
  - ruby
  - dwim
---

> vi editor has two modes: one to beep whenever you hit a key and one to delete all the work you’ve done

There are mainly two modes to write rails (and, well, any ruby) code.

In Mode I, everything has clean, thought-out interfaces, each method performs
a well-defined, human understandable task (nowadays it’s fashionable to call
those _mutations_) and ...inside the methods, between those `def` and `end`
there is a hell load of gibberish.

In Mode II, every damn line of code is clean and understandable. Besides that,
nothing might be comprehended. Neither interfaces in general, nor methods
themselves seem to be of any good.

Nah, I know, there are gurus (somewhere in the land of pink fairies and unicorns,)
who produce clean readable rails code in real projects 24×7. Unfortunately, I live
in the parallel galaxy. With deadlines “yesterday,” with hotfixes, with business
rules changing on the fly and all that shit, always accompanying the bleeding
edge of commercial development. If I were refactoring every shitty piece of
our code, I’d be doing it till now, unpaid and probably unemployed. Business
sometimes is growing faster than the development department. And it, after all, dictates.

Turning back to our modes, I would reveal a couple of examples. I do not want to
have little force. I’m going to bring everything out clearly.

### Mode I. Bond. James Bond.

{% highlight ruby %}
SPECIAL_CASING_FIELDS.each { |method|
  define_method("filter_#{method}") { |cp, filters = []|
      hash[ncp = __to_code_point(cp)].nil? ? \
        nil : [*hash[ncp]].select { |h|
                filters.inject(true) { |memo, f|
                  memo &&= h[method.to_sym].match f
                }
              } ||
              [*hash[ncp]].select { |h| h[method.to_sym].vacant? }
  }
}
{% endhighlight %}

This is a piece from my [Unicode lightweight library](https://github.com/mudasobwa/forkforge).
It produces six helper methods for filtering and selecting different unicode
entities from the consortium description file (like _code_point_,
_lowercase_mapping_, _condition_list_ etc.) It is absolutely unreadable, but
once thoroughly tested it is known to do it’s job perfectly. I do not envy anybody
who will be obliged to read this code, though.

### Mode II. Mary Poppins.

{% highlight ruby %}
def check_validity_for_supplier supplier, additional: false
  if !supplier return false
  if !supplier.valid? return false
  if additional && !supplier.additional return false
  true
end
{% endhighlight %}

Everything here is clear. But in terms of the whole picture this method is
a fiction. Even being declared as `private`, it populates the screen area,
padding out the code clarity. Yeah, I know, they say “methods should not be
longer than 10 lines” and “use helpers.” Sometimes it is a good advise.
Sometimes it is not.

There is nothing wrong with the method, that has 50 lines of code, if it was
thoroughly tested and corked up. Pass integer to it, and it will return it’s square
(plus all these input checks gives exactly 50 lines.) Who ever cares what this method has inside?
Ugly code? Well, maybe. Take a look at spline interpolation. After all,
we use all these `inject` and even `permutation` without any fear that they
contain unreadable code inside.

Using the advise to split everything into tiny methods, it’s equally easy to
make the code either more readable, or the best tasted spaghetti ever. Method
declarations are _goto_ s, at least for future readers. This must be admitted.

I do not propose to write ugly unreadable code, of course. But the idealists are
usually mistaken. In the real life, sometimes, with a dozen of reserves, blah-blah,
you know, it’s better to write one well-tested, complicated helper and lock it
in the chest, than to engender twenty one-liner noodles. After all, your code
does not have pesto to dress these methods with.
