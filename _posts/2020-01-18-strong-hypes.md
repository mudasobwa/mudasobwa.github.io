---
layout: post
title: "Strong Types Should Have Been Named Strong Hypes"
description: "Arguably more robust way to write the good code compared to Strong Typing hype"
category: hacking
tags:
  - elixir
  - erlang
---

Nowadays there is a tendency all around the internets to enforce the goodness of strong typing. Most stubborn rhetoricians even come to the conclusions like “when you have types you don’t need tests.” I believe, this is simply not true. There are, obviouusly, some circumstances, when strong typing might help to catch human mistakes at early stages, but the boilerplate needed when strong typing is implied everywhere brings more hassle than help.

Please note, that all the below is the humble opinion of not so smart human being. But it based on over 30 years of professional development career providing robust and fault-tolerant services. Also, I welcome every strong typing evangelist to write a _markdown parser_ to see the whole field where Types literally suck.

The typical argument of strong typing evangelists would be “let’s assume refactoring.” When during the process youone attempts to call `get_user_by_id` function passing a user instance instead of an integer identifier, the compiler would complain and the error would not leak into runtime. And that’s true! But you know what? I am writing code for several decades and I never expected anything to literally develop the whole application for me. I feel kinda responsible to avoid passing crap to function arguments. “But it would be great to minimize your effort on that?”—I literally hear the arguing. Well, yes and no.

Assigning the identifier to something that is intended to be used as an instance is surely not the hardest to debug error. Assigning the user instance to what is supposed to be a timestamp means one needs more focus, not stronger types. The issues that are really hard to catch and eliminate hide in other swamp. Let’s consired some examples (I would intentionally use pseudo language to avoid the inescapable fuss and fury of things religious.)

### Following the Wrong Path

Let’s imagine we have a function that handles _HTTP_ calls to the third party service. We are to refactor it to add more careful logging and cover different response types. We had somewhat like below.

```js
function call_3rd_party(uri) {
  case call(uri) {
    200 => handle_success()
    else => handle_error()
  }
}
```

Now we want to log the falsey path. 

```js
function call_3rd_party(uri) {
  case call(uri) {
    200 => handle_success()
    500 => handle_error(UNAVAILABLE_SERVER_ERROR)
    503 => handle_error(INTERNAL_SERVER_ERROR)
    else => handle_error(UNKNOWN)
  }
}
```

Can you grasp the issue? Sure you can, we messed up error codes. Can any super sophisticated typing system do that for us? Unfortunately not.

### Getting to the Wrong Record

Let’s say we have a `users` database table we are to look up. We end up with the function that looks pretty clean.

```js
function get_user(name) {
  db_load_user_or_die(name)
}
```

Even having `name` above to be a hundred times strong typed as `string`, passing _surname_ instead of the _first name_ will make it crash.

### Dependent Types and Formal Proof

Yes, in [`Idris`](https://www.idris-lang.org/), [`Agda`](https://wiki.portal.chalmers.se/agda/pmwiki.php), and family one might build the proof on top of the [`Category theory`](https://en.m.wikipedia.org/wiki/Category_theory), that the outcome of the operation would be the _correct_ one. That sounds somewhat magical, but it’s true.

The above does not mean we yielded a silver bullet of development; we simply shifted the problem down the chain. Now instead of writing the correct code in language _Foonctional_, we are to make no mistake in language _Typoo_. Which is in many cases harder. The completeness, while is mandatory in axiomatics, might be a real show stopper in the productive development process. Consider the following code, showing the author name next to the blog post. 

```js
function show_author(name) {
  if get_user(name) {
    show(name)
  } else {
    log("Something wrong with " + user)
    show(ADMIN)
  }
}
```

It’s a representation of the user. If something has failed, we should not actually bother. We ar fine discarding the error here, all we need would be to show _the damn post_. Could not get the name of the author?—In many cases this is not critical. The main goal would be still to show the content; we are to do that at any cost. With strong types it would not even compile. And we will be put into a position to fix the database, to update all the empty authors, or to invent a new monadic type for the _maybe_ present author.

Yeah, the latter is _more robust_. Yeah, the example is rather contrived. But with my conditional approach it would be in prod in one minute. Ask business, what’s better?

### Panacea for Everything

One of the top reasonable arguments for using strong types is “I don’t need to read the code to understand what that function does, I can check types.” C’mon, it’s 2020. Good boys do write and support _the documentation_, with proper _doctests_. Schedule a meeting, invite all your mates and ask them to vote what they prefer to read: types, or documentation.

And yes, types in proper languages _are included_ into documentation. The reasoning that it might become obsolete is absurd. The code might also become obsolete. Just make documentation a first class citizen in your codebase, it’s absolutely not that hard. Reject CRs with anything left undocumented. Write docs for your own better understanding of what are you actually implementing. In plain English that is still better understood by human beings than cathegory theory.

### Can You Stop Whining and Suggest Something

I could have been giving examples of code where strong typing would not help forever. But sure, I can instead propose the ready-to-go prescription. It probably won’t work for everyone, but it’s definitely more robust than the blind faith in _Strong Typing Savior_.

An external, not built into the compiler, tool for static checking and code analysis might help. Pattern matching whenever applicable in function clauses helps. Being ready to treat an invalid input (so called sink-all function clauses) might help.

The developer should think before producing any code. The main responsibility is still put onto us. And we will continue producing bugs in production. That’s life in a nutshell.

Being 100% fault-tolerant _and_ reporting all the issues immediately—helps. Strong typing... Well, in my experience it actually does not much. But of course your tastes might differ.

Happy faulttolerating!