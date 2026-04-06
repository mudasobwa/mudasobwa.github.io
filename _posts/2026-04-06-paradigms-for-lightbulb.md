---
layout: post
title: "How Many Paradigms Does It Take to Screw In a Lightbulb?"
description: "If a developer claims the badge of mid-level-plus but doesn’t feel at ease in at least the five principal paradigms—they are a pompous fool, and you should show them the door."
category: hacking
tags:
  - elixir
  - erlang
  - programming
  - opinion
---

A developer who knows only one programming paradigm resembles a carpenter whose entire toolbox contains a single hammer. Naturally, a hammer will drive a nail with admirable precision. Or a screw, if sufficient enthusiasm is applied. But try to saw or plane a board with that hammer, and it becomes immediately clear—assuming you’ve encountered a saw or a plane at least once in your life—that the instrument has been chosen poorly. So it is with paradigms: knowledge of nothing but imperative programming, or nothing but object-oriented design, transforms a developer into a mechanical executor of tasks, incapable of seeing an elegant solution even when it lies on the surface, waiting to be noticed.

The narrowness of a programmer trapped in a single paradigm manifests in everything. They will erect loops where a single higher-order function would suffice. They will breed classes and inheritance where a pure function and composition would have been more than enough. They will attempt to verify the correctness of an algorithm with a debugger and tests instead of proving it formally at the type level. Such a developer resembles a tourist who knows exactly one word of the foreign language and is attempting, with its help, to explain a route across the entire city to a taxi driver. And it’s a small mercy if the word isn’t obscene.

Let us, for a start, walk through the principal paradigms and see what instruments each offers for solving problems. We’ll begin with the most ancient and familiar—the imperative paradigm.

**Imperative programming** is the world of instructions and mutable state. The programmer tells the machine: do this, then that, change this variable, repeat five times. A classical example in `C`:

```c
int sum = 0;
for (int i = 0; i < 10; i++) {  sum += i; }
```

Here we explicitly manage the state of the variable `sum`, accumulating the result step by step. This is natural for the machine, but tedious for the human. Every step must be spelled out, every mutation tracked. The imperative style serves well when the task reduces to a sequence of actions with side effects: write to a file, update a database, print to the screen. But as soon as the task grows in complexity, the code devolves into a tangle of interrelated variables and conditions.

**Procedural programming** is the imperative approach enriched with structures and functions. We group instructions into procedures to avoid repetition and improve readability. The same example:

```c
int calculate_sum(int n) {
    int sum = 0;
    for (int i = 0; i < n; i++) {
        sum += i;
    }
    return sum;
}
```

Now the logic is packaged into a function that can be reused. The procedural style dominated the era of Pascal and early `C`. It taught programmers to think in modules and structure their code, but it never freed them from the problems of mutable state and side effects.

**Object-oriented programming** (in Gosling’s understanding, not Kay’s) promised to solve all problems at once: encapsulation, inheritance, polymorphism—the three pillars upon which the entire world supposedly rests. Data and methods unite into objects, objects assemble into class hierarchies. It sounds splendid, until you begin to examine how the code actually works:

```java
class Counter {
    private int value = 0;
    public void increment() {
        value++;
    }
    public int getValue() {
        return value;
    }
}
```

State lives inside the object, convenient methods form the API, full encapsulation achieved. So it would seem, but the state hasn’t gone anywhere—it has merely relocated into a class field. And along with it relocated all the old afflictions: data races in multithreading, the difficulty of testing, the unpredictability of behavior. The object-oriented approach serves well for modeling a domain when you need to describe entities and their interactions. But it transforms into a nightmare when class hierarchies sprawl to dozens of inheritance levels, and half the methods exist solely to pass a call further down the chain.

**Functional programming** looks at the task from an entirely different angle. Here there is no mutable state, no loops, no side effects. There are only functions that receive data and return results. The same summation example in Haskell:

```haskell
sum = foldl (+) 0 [0..9]
```

One line instead of five. No loops, no intermediate variables. The function `foldl` takes (1) an addition operation, (2) an initial value, and (3) a list, returning the result. The code reads like a mathematical expression, not a sequence of commands. The functional style is particularly well suited for working with collections, for building data-processing pipelines, for parallel computation. When there is no mutable state, there is no need for locks and synchronization. Functions can be safely launched simultaneously on different processor cores. Though for the domain of _Accounting for a liquor store in the suburbs_—it’s a rather dubious ally.

**Logic programming** overturns one’s very notion of how to write code. Instead of explaining *how* to solve a task, the programmer describes *what* they want to obtain. The system finds the solution on its own. `Prolog` is the classical representative of this paradigm:

```erlang
parent(tom, bob).
parent(tom, liz).
parent(bob, ann).

grandparent(X, Z) :- parent(X, Y), parent(Y, Z).
```

We described kinship relations and a rule for determining grandparents. Now we can pose the question: `grandparent(tom, ann)`?—and the system will answer “yes,” having found the path through the facts. Logic programming is indispensable in certain corners of artificial intelligence, expert systems, and task planning. I even [dragged it into](https://habr.com/ru/articles/885668/) the consistency validation of finite automata in one of [my libraries](https://hexdocs.pm/finitomata). But an attempt to write a web server in `Prolog` would look rather like an attempt to hammer a mole with a microscope.

**Declarative programming** is a general term for approaches where the programmer describes the desired result rather than the sequence of steps. SQL is the textbook example:

```sql
SELECT name FROM users WHERE age > 18 ORDER BY name;
```

We don’t explain how to traverse the table, how to check the condition, how to sort the result. We simply declare: I want the names of users over eighteen, sorted alphabetically. The database will figure out how to do this efficiently on its own. The declarative style dominates in HTML, CSS (for now—I suspect someone will drag recursion into it before long), and configuration files. It allows one to separate the *what* from the *how*.

**Concatenative programming** is built on the idea of function composition via a stack. `Forth` is its most vivid representative:

```
: square dup * ;
5 square .
```

The function `square` duplicates the top element of the stack and multiplies it by itself. The number 5 is placed on the stack, the function `square` is applied, the result is printed. The code reads right to left, like reverse Polish notation. Concatenative languages are compact and efficient, but they demand a particular cast of mind. They remain popular in embedded systems and wherever code size and execution speed are critical.

**Reactive programming** focuses on data streams and the propagation of changes. When a data source changes, all dependent computations update automatically. An example in `RxJS`:

```javascript
const clicks = fromEvent(document, 'click');
const positions = clicks.pipe(map(event => event.clientX));
positions.subscribe(x => console.log(x));
```

We create a stream of click events, transform it into a stream of coordinates, and subscribe to changes. Each click automatically produces the coordinate in the output. The reactive style is ideal for interfaces, event handling, and working with asynchronous data sources. It liberates you from callback hell and makes the data flow explicit.

**Aspect-oriented programming** addresses the problem of cross-cutting concerns—logging, caching, access control. Instead of smearing these aspects across the entire codebase, they can be described separately:

```java
@Transactional
@Logged
public void updateUser(User user) {
    repository.save(user);
}
```

The annotations `@Transactional` and `@Logged` are aspects. They will be automatically “applied” to the method, wrapping it in a transaction and adding logging. The core code remains clean and comprehensible. The aspect-oriented approach is popular in enterprise development, where cross-cutting concerns permeate the entire system.

**Metaprogramming** is the programming of programs that write programs. Macros in LISP allow code to be generated at compile time:

```lisp
(defmacro when (condition &rest body)
 `(if ,condition (progn ,@body)))
```

The macro `when` expands into an `if` construct with a `progn` block. Metaprogramming grants extraordinary flexibility, enabling the creation of domain-specific languages right inside the host language. But with great power comes great responsibility: poorly written macros turn code into an unreadable mess. If you want to see what metaprogramming looks like when practiced by a sane person—take any of my libraries, or write your own in *Elixir*. I know of no other language where macros have been done properly.

**Dependently-typed programming** elevates the type system to a new plane. Types can depend on values, allowing complex invariants to be expressed at the type level.

```haskell
data Vec (A : Set) : Nat -> Set where
    []  : Vec A zero
    _::_ : {n : Nat} -> A -> Vec A n -> Vec A (suc n)

append : {A : Set} {m n : Nat} -> Vec A m -> Vec A n -> Vec A (m + n)
```

The type `Vec A n` is a vector of elements of type `A` with length `n`. The function `append` takes two vectors of lengths `m` and `n` and returns a vector of length `m + n`. The compiler verifies correctness at the type level. It is impossible to write a function that violates the length invariant. Dependent types are used for the formal verification of critical systems, where an error costs far too much.

**Theorem-proving** as a paradigm is the proof of program correctness by mathematical methods. *Lean* and *Coq* allow one to write not merely code, but proofs that the code does precisely what was intended:

```haskell
theorem add_comm (n m : Nat) : n + m = m + n := by
  induction n with
  | zero => simp [Nat.zero_add, Nat.add_zero]
  | succ n ih => simp [Nat.succ_add, Nat.add_succ, ih]
```

This is not simply an addition function—it is a proof that addition is commutative. The compiler doesn’t merely check types; it checks the mathematical proof. This approach is employed in cryptography, compilers, and operating systems—domains where the price of an error is measured not in irritated users, but in human lives or millions of dollars in losses.

**The actor model** views a program as a collection of independent actors that exchange messages. Each actor has its own `mailbox`, processes messages sequentially, and can create new actors. *Erlang* was built upon this idea:

```erlang
-module(counter).
-export([start/0, loop/1]).

start() -> spawn(fun() -> loop(0) end).

loop(N) ->
    receive
        {increment, Pid} ->
            Pid ! {value, N+1},
            loop(N+1);
        {get, Pid} ->
            Pid ! {value, N},
            loop(N)
    end.
```

The actor `counter` receives `increment` and `get` messages, modifies its state, and replies. No shared data, no locks. Actors scale horizontally, failures are isolated. This model is ideal for distributed systems, where failures are the norm rather than the exception.

**Dataflow programming** describes computation as a graph of data streams. The nodes of the graph are operations, the edges are data flows between them. A change in one node propagates automatically through the graph. *LabVIEW* uses visual dataflow programming for hardware control. The approach is intuitive for engineers accustomed to thinking in schematics and diagrams.

**Constraint programming** describes a task as a set of constraints that must be satisfied. The system searches for a solution by enumerating possibilities and pruning the impossible. *MiniZinc* is a language for constraint programming:

```
var 1..9: x;
var 1..9: y;
constraint x + y = 10;
constraint x * y = 21;
```

Two variables, two constraints. The system will find `x = 3, y = 7` or `x = 7, y = 3`. Constraint programming is applied in planning, scheduling, and resource optimization—wherever a task is formulated as finding a solution under constraints.

Phew.

Now let us pose the question: why does any of this matter to an ordinary developer? The answer is simple and simultaneously non-obvious. **Each paradigm is a way of thinking, an approach to solving problems.** A programmer who knows only imperative programming will solve every task with loops and conditionals. They will see a list-processing task and write a `for` loop with intermediate variables. A programmer acquainted with the functional paradigm will write `map` or `fold`—elegantly, concisely, free of side effects. One who has mastered reactive programming will construct an event-processing pipeline where each stage is explicitly described and easily testable.

Knowledge of different paradigms expands one’s arsenal of tools. You won’t write a web server in *Prolog* or prove theorems in *JavaScript*. But an understanding of logic programming will help you formulate conditions more precisely and build database queries. Familiarity with dependent types will teach you to think in invariants and express constraints at the type-system level. Experience with actors will show you how to build scalable distributed systems without the headaches of synchronization.

In truth, in the modern world all mature languages have long since become multi-paradigm. *Scala* combines object-oriented and functional approaches. *Rust* adds a powerful ownership and borrowing system to the imperative style. *Python* allows one to write procedurally, in an object-oriented fashion, and functionally. *F#* unites functional programming with the *.NET* ecosystem. *Swift* attempts to incorporate elements of all major paradigms at once. A programmer who understands when an aspect is needed (yes, in any language—for instance, I [dragged aspects into](https://hexdocs.pm/telemetria) *Elixir*) uses the language to its full power. One who knows only a single paradigm writes in any syntax as though it were PHP.

Paradigms are not a religion where you must choose one true faith and wage war on the heretics. They are tools, and a good craftsman knows when to reach for the hammer, when for the saw, and when for the plane. Need to parse something? Take the functional approach with `map` and `fold`. Build a system with thousands of simultaneous connections? Actors are your choice. Formally prove an algorithm’s correctness? Welcome to *Lean* or *Agda*. Developing an interface with many interactive elements? Reactive programming will make the code comprehensible.

A programmer trapped in a single paradigm is condemned to solve problems inefficiently. They will drag familiar patterns behind them even when those patterns don’t fit. They will write a class where a function would suffice. They will create mutable state where it could be avoided entirely. They will erect a complex hierarchy where composition would have been enough. They resemble a person who knows only one route from home to work and stubbornly waits at the bus stop every day, even though the road has been torn up for a month and the bus now runs on the next street over.

**If a developer claims the badge of mid-level-plus but doesn’t feel at ease in at least the five principal paradigms—they are a pompous fool, and you should show them the door.**
