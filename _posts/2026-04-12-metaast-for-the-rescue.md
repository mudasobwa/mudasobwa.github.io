---
layout: post
title: "A Score for an Invisible Orchestra"
description: "Every programming language stores its AST in its own idiosyncratic format. Writing a code-analysis tool means rewriting it from scratch for each new language. MetaAST—a meta-model sitting one level above any concrete AST—solves this by providing a single universal representation. One analyser, all languages, linear instead of quadratic growth. This is the score that every instrument in the orchestra can read."
category: hacking
tags:
  - elixir
  - programming
  - metaprogramming
---

Imagine a five-storey building with no lift, erected in the late fifties somewhere on the outskirts of Avtozavodskaya—or better still, in Kupchino. Every floor speaks its own language. Not figuratively but in the most literal sense: the ground floor communicates in Cyrillic, the second in Latin script, the third in ideograms, the fourth in cuneiform, and the fifth, in the manner of Wittgenstein, maintains a principled silence on the grounds that whereof one cannot speak, thereof one must be silent. The postman, delivering the correspondence, is obliged to carry five copies of one and the same letter, translated into each of these tongues, and to knock on the door every time, hoping the addressee has not moved to another floor.

That is precisely how the world of programming is arranged—if one looks at it from the wings rather than the stalls. Every language has its own internal representation of code. Python stores its AST the way a thrifty housewife stores dry goods: in tidy labelled containers—`BinOp`, `FunctionDef`, `Name`. Elixir, with characteristic self-assurance, uses triples `{atom, metadata, children}` and calls them _quoted expressions_, as though what we have before us is not a syntax tree but a collection of quotations from William Blake. Ruby stockpiles its S-expressions the way an antiquarian bookseller stockpiles yellowing volumes, and Erlang, faithful to tradition, converses in tuples and atoms intelligible only to Ericsson engineers and, by a curious coincidence, doctoral students at a handful of Swedish universities.

The problem is obvious to anyone who has ever attempted to build a code-analysis tool. Suppose you have written a superb cyclomatic-complexity analyser for Python. It is magnificent: it finds nested conditionals, counts branching points, draws control-flow graphs. Then a colleague comes along and asks, “Could you do one for Ruby?” And it transpires that all your work—all those tree walkers, all that pattern matching over Python’s AST—must be rewritten from scratch. From zero. For a different tree, with different nodes, different semantics, and different booby traps. And then a third colleague will turn up and request the same for Haskell.

Imagine a conductor forced to relearn musical notation every time a new instrument joins the orchestra. Violin—one system of writing. Cello—another. Oboe—a third, with reversed polarity, no less. The trumpet flatly refuses to acknowledge the existence of the staff and insists on a tablature of its own invention. Absurd, of course. In the real world every instrument reads the same score. Notes, rhythm, dynamics are universal. Only the technique of execution differs.

MetaAST is that score.

---

Before we turn to the details (and they deserve attention in the way a well-constructed detective plot deserves it), permit me a brief digression into theory. Fear not: no formulae, only an analogy. Though one formula will appear after all—but it is so elegant that failing to cite it would be a crime against aesthetics.

In the early two-thousands—when mobile telephones already existed but had not yet taken charge of our lives—the OMG consortium (Object Management Group, bearing no relation whatsoever to the divine or the exclamatory) released a standard called MOF: Meta-Object Facility. Its essence fits into four lines, yet it took the industry two decades to understand those four lines. MOF defines a four-level hierarchy of models:

**M⁰** is running code. There it goes, spitting out results, crashing with errors, consuming memory. This is reality.

**M¹** is a model of reality. For programs, it is the AST: the abstract syntax tree. Python’s `BinOp(op=Add(), left=Name('x'), right=Num(5))` is M¹. Elixir’s `{:+, [context: Elixir], [{:x, [], Elixir}, 5]}` is also M¹. Every language describes its own code in its own M¹, the way every painter paints an apple in their own way.

**M²** is the model of models. The meta-model. It defines what a node of _any_ AST _can be_. Not a concrete node of a concrete language, but the _concept_ of a node. A binary operation is neither Python’s `BinOp` nor Elixir’s `{:+, ...}`. A binary operation is the _idea_ that two operands are connected by an operator. UML lives at the M² level. And so does MetaAST.

**M³** is the meta-meta-model. That which defines what meta-models themselves can be. The type system, the rules of composition. MOF lives here. In the context of MetaAST, this role is played by Elixir’s type system—`@type` and `@spec`.

The fundamental difference between MetaAST and LLVM IR, Java bytecode, or any other intermediate representation lies precisely here: all of those are models (M¹). They describe concrete code in a concrete format. MetaAST is a meta-model (M²). It describes what descriptions of code _can be_. The difference is roughly the same as between a dictionary and a language: a dictionary catalogues words, whereas a language defines the rules by which those words are possible in the first place.

---

Metastatic is an Elixir library that implements this idea in code. The name, as befits a respectable technical project, is charged with a double meaning: **Met(a)-AST-atic**, that is, “pertaining to the meta-level of AST.” The medical connotations are the house’s treat.

The architecture is three-layered, and this is not caprice but a consequence of theory:

**M².1 — Core.** Concepts present in _every_ programming language on the planet. Literals, variables, binary operations, conditionals, function calls, assignments. Nothing exotic here. `x + 5` in Python, Elixir, Ruby, Erlang, and Haskell is one and the same thing. An identical MetaAST representation. Literally:

```elixir
{:binary_op, [category: :arithmetic, operator: :+],
  [{:variable, [], "x"}, {:literal, [subtype: :integer], 5}]}
```

Five languages. One tree. One analysis tool. A score legible to any instrument in the orchestra.

**M².2 — Extended.** Constructs that exist in _most_ languages but not all. Loops, lambdas, collection operations, pattern matching, exception handling. Haskell knows nothing of imperative loops—so be it: it has recursion at the M².1 level. Ruby knows nothing of guards—no matter: the adapter’s metadata will preserve the context.

**M².3 — Native.** The emergency exit for constructs that resist generalisation. Rust’s lifetimes, Haskell’s type classes, Elixir’s metaprogramming. They are wrapped in `{:language_specific, :rust, ...}`—like fragile porcelain in bubble wrap—and travel through the system without losing their identity, yet without claiming universality either.

---

Every MetaAST node is a triple: type, metadata, children (or value). The format is deliberately borrowed from Elixir’s quoted expressions, because if you already know how to write macros in Elixir, you already know how to work with MetaAST. The difference is semantic: where Elixir uses `:+` (the operator itself), MetaAST uses `:binary_op` (the _concept_ of a binary operation) and tucks the operator into metadata. Where Elixir inlines literals, MetaAST wraps them in `{:literal, [subtype: :integer], 42}`, ensuring structural uniformity.

Language adapters form the bridge between M¹ and M². The Python adapter takes Python’s AST (obtained via subprocess) and _abstracts_ it up to MetaAST. The Elixir adapter takes quoted expressions and does the same. The Ruby adapter—likewise. The inverse operation—_reification_—turns MetaAST back into the native AST of the target language. This pair of operations, abstraction and reification, constitutes what mathematicians call a Galois connection:

```
Adapter_L = (alpha_L, rho_L)

alpha_L: AS_L -> MetaAST x Metadata    (abstraction: M¹ -> M²)
rho_L:   MetaAST x Metadata -> AS_L    (reification: M² -> M¹)
```

What does this mean in practice? Here is a scenario. You have written a function-purity analyser. It operates on MetaAST: traverses the tree, looks for side effects (I/O, state mutation, calls to random-number generators), and renders its verdict. This analyser was written once. Once. And it works with Python, Elixir, Ruby, Erlang, and Haskell. Because it analyses not the Python or Elixir AST but the _meta-level_. You write:

```elixir
{:ok, doc} = Metastatic.Adapter.abstract(Python, "print('hello')", :python)
{:ok, result} = Metastatic.Analysis.Purity.analyze(doc)
result.pure?    # => false — side effect: I/O
result.effects  # => [:io]
```

And precisely the same code, unchanged, works if you replace Python with Ruby and `print('hello')` with `puts 'hello'`. Because both calls are `{:function_call, [name: "print"], [{:literal, [subtype: :string], "hello"}]}` at the M² level.

---

Let us return to MOF and the four-level hierarchy. Why is any of this necessary? Why erect meta-models when one could simply write a converter from one AST to another?

The answer is simple and brutal, like the truth of life. A converter works pairwise. For five languages you need twenty converters (5 × 4). For ten—ninety. For twenty—three hundred and eighty. A meta-model works through a hub: each language connects once, via its own adapter. Five languages—five adapters. Ten—ten. Twenty—twenty. Linear growth instead of quadratic. A mathematician who had spent half his life as a reporter would appreciate the irony.

But it is not only a matter of combinatorics. A meta-model provides _standardisation_. Every tool written for MetaAST is guaranteed to work with any language for which an adapter exists. This is not “Python support” and “Ruby support” as separate features. It is one feature: MetaAST support. Everything else follows as a consequence.

OMG understood this in 2002 when it released MOF. The entire UML industry is built on the same principle: the meta-model defines what models _can be_, and concrete diagrams are merely instances of that meta-model. MDA (Model-Driven Architecture) took the idea further: transformations between models are defined at the meta-level and applied automatically to any instances.

Metastatic does the same, but not for class diagrams—for the syntax trees of programs. It is not an IR, not a compiler, not a transpiler. It is the foundation upon which all of the above can be built—once, and for every language at once.

---

There is an old story about a farmer, I’ve heard from a stranger on a train. A man spends his entire life breeding different eggplant varieties. In decades, when the farmer is already old and blind, his fields have produced an unprecedented harvest. He calls for each and every agronomist in the world, they come, and the most famous one says, “These aubergines are adorable!” The farmer dies of frustration. The man does not know what _aubergines_ are but he’s certain the great eggplant nobody would have called ‘aubergine.’ He considers his life wasted.

The ASTs of different languages are the eggplants. MetaAST is the knowledge that they all grow on the same field. The difference between them is terminological, not semantic. Python’s `BinOp(op=Add())`, Elixir’s `{:+, [], [...]}`, and Ruby’s `s(:send, ..., :+, ...)` are different names for one and the same thing: `{:binary_op, [category: :arithmetic, operator: :+], [left, right]}`.

One could, of course, spend an entire life rewriting tools for every new language. One could relearn musical notation each time, bow before every new instrument in the orchestra, translate letters into five tongues for five floors of one and the same building. But why, when one can ascend a single level of abstraction—to the place where eggplants and aubergines are indistinguishable, and the score is one for all?

