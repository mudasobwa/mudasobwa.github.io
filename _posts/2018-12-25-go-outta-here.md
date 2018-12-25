---
layout: post
title: "Go Outta Here"
description: "The step-by-step explanation of why Go language is not good at all"
category: hacking
tags:
  - elixir
  - go
  - tools
---

> They’re [Googlers] not capable of understanding a brilliant language but we want to use them to build good software. So, the language that we give them has to be easy for them to understand and easy to adopt. – [Rob Pike](https://channel9.msdn.com/Events/Lang-NEXT/Lang-NEXT-2014/From-Parallel-to-Concurrent)

I made several attempts to play with [_Go_](https://golang.org). After all, it is the language created by famous [Rob Pike](http://herpolhode.com/rob/) who previously engineered such successful and widely-used software as [Plan9](https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs) and [Inferno](https://en.wikipedia.org/wiki/Inferno_(operating_system)) operating systems and [Limbo](https://en.wikipedia.org/wiki/Limbo_programming_language) programming language. _Go_ is supported by _Google_, and they won’t fail, right?

Nope.

_Go_ is the hugest scam of the XXI century in CS so far. For some reason people do still trust _Google_ to some extent, despite of abandoned “Don’t be evil” motto, despite of a full load of violence evidence, despite of firing people for having and sharing the opinion.

_Go_ was made by _Google_ and _Google_ cannot fail, they say. Bullshit.

_Go_ is a fraud in a company of _modern_ languages and I am going to explain why.

---

I am going to walk through the official [_Golang Book_](https://www.golang-book.com/books/intro/2#section1) and show what is wrong (in terms of design flaws) with nearly every statement there.

### Your first program

The tutorial starts with the explanation of the program structure.

> The first line says this:
>
    package main

OK, everybody calls it _module_, we’d call it _package_, because we are special. OK.

> Then we see this:
>
    import "fmt"

`import "fmt"`? You gotta be kidding me; it is completely redundant in a compiled language. Good compiler might easily resolve all the calls to `fmt.foo` and do whatever imports are needed for. The only reason the explicit _import_ might be helpful is to literally _import_ functions into the ~~module~~ package. That’s not the case here, one still should bother with FQ-names.

### Types

That is my fave! 

> Go is a statically typed programming language. This means that variables **always** have a specific type and that type cannot change.

That is the lie. (Emphasis is mine.) Statically typed (I prefer the wording “fully typed”) languages with rich types, like Haskell, require an enormous boilerplate to accomplish very simple tasks and _Go_ was announced as _easy-come-easy-go_. That’s why it is in fact **statically typed unless otherwise**. We’ll come back to _void interfaces_ later.

> Go's integer types are: `uint8`, `uint16`, `uint32`, `uint64`, `int8`, `int16`, `int32` and `int64`.

The above makes me cry. In the second decade of XXI century we enforce the developer to distinguish between `int32` and `int64` in _compiled “statically typed” language_. Really?

### Variables

> Since creating a new variable with a starting value is so common Go also supports a shorter statement:
>
    x := "Hello World"

What could go wrong with a plain old good equal sign? We’d lose the pride for _Go_ being _statically typed_ if it would not remind us about that by redundant syntax quirks?

> 
    package main
    import "fmt"
    var x string = "Hello World"
    func main() {
      fmt.Println(x)
    }
>
> Notice that we moved the variable outside of the main function. This means that other functions can access this variable.

This is found in _scopes_ chapter. OK, it looks like an instance variable in Ruby. Or as a module attribute in Elixir. What is indeed the scope and the lifetime of this variable? Can I return it from the functions declared in this module? There is no answer in the tutorial, also I understand that probably after stepping onto a couple of rakes any _Gopher_ would burn the knowledge into memory.

### Control structures

The first control _structure_ (?) introduces is a `for` loop. Iterating, mapping, reducing?—No, we’ve never heard about. Declare an outermost variable and loop with `for`. I am discreetly checking the current date against my calendar. It’s still 2018.

The second one is obviously `if`. _“Give me `for` and `if` to stand on, and I will move the Earth,”_ as Archimedes used to say instead of the evening pray. BTW, the third _control structure_ would be `switch`.

And that’s it! The language must be as simple as possible. 

### Arrays, Slices and Maps

Arrays have predefined length. Slices are arrays of not fixed length. Maps are key-values. Maps are to be both declared and initialized, otherwise a runtime error raises (if this is not a shallow copy of the one billion dollar mistake, I don’t know what is.)

```go
var x map[string]int = make(map[string]int)
```

The above looks like a bullet proof evidence of the fact that the goal to create the easy readable language was successfully achieved.

Below is how one does accesses elements in the map.

```go
if name, ok := elements["Un"]; ok {
  fmt.Println(name, ok)
}
```

No comment. Those who are to object that it’s safe and all that, I hear you. This is exactly what’s called _Stockholm syndrome_.

I could not even imagine what level of potential developers is expected to produce such a defence from an idiot. Maybe it’d be easier to simply not hire them?

### Functions

Functions can return multiple values (what’s wrong with returning _arrays_ btw?) and functions could be _variadic_ (accepting an unknown upfront number of arguments of the same type.) So far, so good.

The last condition though, all the _splatted_ arguments should be of the same type gave a born to the feature that basically proves _Go_ to be a fraud in the family of modern mature serious languages.

Interfaces. Sounds scary?—That’s not all. Void Interfaces.

```go
func Println(a ...interface{}) (n int, err error)
```

Statically typed? Safe? ROFL.

The road to hell is paved with good intentions. I believe they were to create a safe statically typed language for dummies (although the idea in a nutshell sounds a bit insane.) But the real world is severe, harsh and rough. Dummies were not ready to produce huge boilerplates on every single occasion. And—voilà—we let the whimsical child to get some sweets instead of a healthy soup.

---

Here my dive into this _great language_ has ended. I understand, that the good code is made by developers, not by computer languages. There are tons of great code on weird poor-designed languages and tons of awful code in great languages. Personally, I do not care much about what language I need to accomplish a task.

But please stop call _Go_ safe, easy to read-and-write and statically typed. Thank you.

---

For the sake of entropy constancy, I would provide an example of how _proper safe typing_ might be achieved in very dynamic language _Elixir_. With pattern matching and guards.

```elixir
@spec foo(nil | map() | list() | non_neg_integer()) ::
                    {:error, any()} | {:ok, atom()} 

def foo(nil), do: {:error, :empty}
def foo(%{} = map) when map_size(map) == 0,
  do: {:error, :empty}
def foo([]), do: {:error, :empty}

def foo(%{} = map), do: {:ok, :map}
def foo(num) when is_integer(num) and num > 0,
  do: {:ok, :positive_integer}

# def foo(_), do: {:error, :unknown}
```

The code above will warn on compilation stage if the attempt to call it with an improper argument is detected. This code will raise in the runtime on dynamic passing of the invalid argument as near to the issue as possible. And this code might be statically validated with a static code analisys tool, if as needed.

I don’t know about everyone, but this is more than good for me to avoid any kind of typing errors possible.

Happy going!
