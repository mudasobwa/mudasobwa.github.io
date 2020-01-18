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

Please note, that all the below is the humble opinion of not so smart human being. But it based on over 30 years of professional development career providing robust and fault-tolerant services. 

The typical argument of strong typing evangelists would be “let’s assume refactoring.” When during the process youone attempts to call `get_user_by_id` function passing a user instance instead of an integer identifier, the compiler would complain and the error would not lek into runtime. And that’s true! But you know what? I am writing code for several decades and I never expected anything to literally develop the whole application for me. I feel kinda responsible to avoid passing crap to function arguments. “But it would be great to minimize your effort on that?”—I literally hear the arguing. Well, yes and no.

Assigning the identifier to something that is intended to be used as an instance is surely not the hardest to debug error. Assigning the user instance to what is supposed to be a timestamp means one needs more focus, not stronger types. The issues that are really hard to catch and eliminate hide in other swamp. Let’s consired some examples (I would intentionally use pseudo language to avoid the inescapable fuss and fury of things religious.)

### Following the Wrong Path

Let’s imagine we have a function that handles _HTTP_ calls to the third party service. We are to refactor it to add more careful logging and cover more different response types. We had somewhat like below.

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

### Can You Stop Whining and Suggest Something

I could have been giving examples of code where strong typing would not help forever. But sure, I can instead propose the ready-to-go prescription. It probably won’t work for everyone, but it’s definitely more robust than the blind faith in _Strong Typing Savior_.

An external, not built into the compiler, tool for static checking and code analysis might help. Pattern matching whenever applicable in function clauses helps. Being ready to treat an invalid input (so called sink-all function clauses) might help.

The developer should think before producing any code. The main responsibility is still put onto us. And we will continue producing bugs in production. That’s life in a nutshell.

Being 100% fault-tolerant _and_ reporting all the issues immediately—helps. Strong typing... Well, in my experience it actually does not much. But of course your tastes might differ.

Happy faulttolerating!