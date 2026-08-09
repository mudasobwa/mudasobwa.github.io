---
layout: post
title: "Anti-Antipatterns in Elixir Library Guidelines"
description: "Deconstructing the dogmatic anti-patterns section of the official Elixir library guidelines and demonstrating when every single one of them is actually needed."
category: hacking
tags:
  - elixir
  - erlang
  - architecture
  - anti-patterns
---

Only a lazy person never blogged about library should not use application configuration. Even the official propaganda says so in the [Elixir Library Guidelines](https://elixir.hexdocs.pm/1.12.3/library-guidelines.html#avoid-application-configuration).

As all the sharp rules, this one is rotten. There are usecases when the library configuration must prevail over local parameters.

In fact, the entire “Anti-patterns” section of the official library guidelines reads like a list of commandments handed down from Mount Sinai, written for developers who cannot be trusted with sharp tools. But software engineering is not about blindly following rigid rules; it is about choosing the right trade-offs.

Let’s walk through all nine anti-patterns declared in the official guidelines and show why—and when—each so-called “anti-pattern” is not just permissible, but absolutely necessary.

---

## 1. Avoid Application Configuration

The guidelines state that libraries must never rely on `Application.get_env/2` because global state makes it impossible for two dependencies to use the library in different ways. Instead, we are told to pass explicit keyword options down every function call.

Consider an application dealing with markdown here and there. Its dependencies parse markdown too. Core parses markdown, web parses markdown, several helpers under umbrella do parse markdown.

How do I add the new plugin everywhere? Easy, if there is an application configuration. And …ehrm… there is a way to patch dependencies.

If you enforce passing `opts` explicitly through forty layers of call stacks across fifteen sub-applications in an umbrella project, you guarantee that every intermediate module becomes a glorified passthrough for configuration keys it doesn’t care about. Application configuration allows the system operator to define system-wide defaults once—in `config/config.exs`—while still allowing individual calls to override them when necessary. Global defaults are a feature, not a bug, when your application needs uniform behavior by default.

---

## 2. Avoid Compile-Time Application Configuration

We are warned against reading the application environment in module attributes, such as `@http_client Application.fetch_env!(...)`, because it burns values into the compiled binary at compile time rather than reading them at runtime.

This advice conveniently ignores two crucial requirements: **zero-cost abstractions** and **compile-time code generation**.

When building high-throughput data pipelines, parsers, or logging frameworks, invoking `Application.get_env/3` inside a hot loop running millions of times per second introduces unnecessary dictionary lookups. Statically baking configured modules or constants into module attributes yields zero-overhead dispatch.

Furthermore, if your library uses macros to generate pattern-matching clauses or AST structures based on configuration (e.g., compiling custom sigils or state machine transitions dynamically), runtime lookup is literally impossible. The AST must be constructed at compile time. Compile-time configuration is the bridge between user configuration and macro expansion.

---

## 3. Avoid Using Exceptions for Control-Flow

“Use `{:ok, result}` and `{:error, reason}` tuples everywhere,” says the guide. “Never use exceptions or `raise`/`throw` for control flow.”

This sounds clean in trivial examples, but consider a deeply nested AST traversal or a recursive tree parser fifteen levels deep. If an invalid node is encountered on level 14, propagating `{:error, reason}` back up through 14 stack frames requires wrapping every single recursive step in a `with` block or manual tuple matching. The core algorithm becomes buried under an avalanche of error-plumbing boilerplate.

In complex recursive operations, using `throw/1` and `catch` (or raising a dedicated structural exception rescued at the top-level boundary) acts as a clean, non-local exit. It unwinds the stack immediately back to the public API boundary, leaving the internal recursive code concise, readable, and fast. The caller still receives a clean `{:error, reason}` tuple at the boundary, but the internal code doesn’t suffer from tuple-wrapping tax.

Even `for` comprehension might take advantage from throwing in the middle if something went south.

---

## 4. Avoid Working with Invalid Data

The guideline advises validating all data immediately at the entry boundary using pattern matching and guards, refusing to operate on anything that doesn’t strictly match expected types.

This principle breaks down when dealing with **streaming data ingestion**, **resilient ETL pipelines**, and **progressive parsing of semi-structured data**.

Suppose you are building a log processor or IoT event consumer that ingests gigabytes of heterogeneous payloads. If you strictly validate the entire schema at the entry boundary, a single malformed key or unexpected field type forces you to drop the whole batch or crash the pipeline.

Instead, accepting loose structures at the boundary and deferring validation to downstream processing stages allows your system to handle partial data, quarantine bad sub-fields, and log warnings without discarding valid payload portions. Late validation and resilient boundary accepting are fundamental to building fault-tolerant data pipelines.

---

## 5. Avoid Defining Modules Outside Your Namespace

The rules demand that every module in a library be prefixed with the library’s top-level module name (e.g., `MyLib.Foo`), warning that defining top-level modules or extending another library’s namespace causes collisions on the Erlang VM.

Yet, this rule completely ignores **drop-in polyfills**, **standard protocol implementations**, and **seamless stdlib integration**.

If you are writing a drop-in replacement library or a compatibility layer (for instance, a library providing backwards compatibility for a deprecated OTP module or patching telemetry integration like `Telemetria`), placing your modules in the expected target namespace is the entire point. It allows existing applications to use your library without modifying hundreds of call sites across an entire codebase.

Similarly, when implementing protocol consolidations or global dispatchers that third-party plugins hook into, adhering strictly to arbitrary prefixing can make macro-based registration unwieldy. When done intentionally, target-namespaced modules are a legitimate pattern for drop-in interoperability.

---

## 6. Avoid `use` When an `import` Is Enough

“Do not provide `use MyLib` if all it does is `import MyLib`,” reads the guide. “Prefer `alias`, then `import`, and use `use` only as a last resort.”

This is classic short-term thinking that ruins library API evolution.

Suppose version 1.0 of your library only needs to import helper functions into the target module. You instruct users to put `import MyLib` in their code. Six months later, in version 2.0, your library needs to register module attributes, inject a `@before_compile` hook, or set up telemetry callbacks.

Because you chose `import MyLib` to satisfy a dogmatic guideline, every single user of your library must now go through their codebase and replace `import MyLib` with `use MyLib`. 

By offering `use MyLib` from day one—even if its initial `__using__/1` implementation is just an `import`—you establish an extensible contract. You reserve the right to add compile-time hooks, behaviours, and setup logic in future releases without breaking a single line of client code.

---

## 7. Avoid Macros

“Macros are harder to write... clear code is better than concise code... macros should only be used as a last resort.”

If the Elixir core team took this rule seriously, we wouldn’t have Ecto schemas, Phoenix routers, ExUnit tests. If I did, we wouldn’t have my libraries at all. If [`Finitomata`](https://hexdocs.pm/finitomata) can be probably rewritten in non-macro approach, [`Telemetría`](https://hexdocs.pm/telemetria) has zero chance to ever exist without all the spectre of macros, from `use` to `__before_compile__` hooks and whatnot.

Trying to define complex domain logic using raw functions, maps, and anonymous function passing results in an unreadable wall of syntactical noise. Macros allow us to build expressive, declarative Domain-Specific Languages (DSLs). They perform compile-time validation, optimize data structures before execution, and turn complex domain semantics into intuitive code.

Without macros, Elixir would just be Erlang with different syntax. Embracing macros responsibly is what makes Elixir libraries powerful.

---

## 8. Avoid Using Processes for Code Organization

The guidelines argue that processes must only model runtime properties (state, concurrency, fault tolerance) and never code organization, using the classic strawman of putting a basic calculator behind a `GenServer`.

While putting arithmetic in a `GenServer` is obviously silly, using processes as **fault-isolation boundaries** for computation is a battle-tested OTP pattern.

Consider a library executing third-party NIFs, parsing untrusted image files, or running heavy memory-intensive computations. If you run that code directly inside the caller’s process and it triggers an out-of-memory error, segfaults, or enters an infinite loop, it takes down the caller.

Wrapping that “pure computation” inside a dedicated worker process isolates the failure. If the computation crashes, only the worker process dies; the caller receives an error tuple and survives. Processes are not just for state—they are hard memory and fault-containment zones.

---

## 9. Avoid Spawning Unsupervised Processes

Finally, the guidelines insist that every process must live inside a supervision tree, warning against raw `spawn/1` or unsupervised tasks.

This ignores **fire-and-forget side-effects** where coupling the task lifetime to the caller or supervisor is undesirable.

Take non-critical background operations: sending an asynchronous telemetry event, flushing an audit log, or dispatching a best-effort metric. If you start these tasks under the main caller’s supervision tree, a failure in the telemetry reporter can crash the supervisor or block the shutdown sequence of the primary application.

Spawning an unlinked, unsupervised task (or using a detached process) guarantees that the background side-effect runs independently on a best-effort basis without ever delaying, blocking, or crashing the primary business logic.

---

## Summary

The official Elixir library guidelines are a useful set of defaults for beginners, but defaults are not universal laws.

Every single “anti-pattern” in the guidelines exists because someone, at some point, needed to solve a real engineering problem that the “clean” abstraction couldn’t handle. Understanding *why* a rule exists gives you the authority to break it when the trade-offs demand it.

Don’t let dogma dictate your architecture. Use application configuration when you need global defaults, use macros when you need expressive DSLs, use processes when you need fault isolation, and use the full power of the Erlang VM when your application calls for it.
