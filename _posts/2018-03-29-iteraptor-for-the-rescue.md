---
layout: post
title: "Iteraptor :: Iterating Nested Terms Like I’m Five"
description: "The tiny library (200 LOC) to iterate/map/filter deeply nested structures in Ruby"
category: hacking
tags:
  - “…”
  - ruby
  - tricks
  - tools
---

Iterating both hashes and arrays in ruby is charming. One might chain iterators,
map, reduce, filter, select, reject, zip... Everybody having at least eight
hours of experience with ruby has definitely seen (and even maybe written)
something like this:

```ruby
%w[aleksei saverio].map do |name|
  name.capitalize
end.each do |capitalized_name|
  puts "Hello, #{capitalized_name}!"
end
```

That is really handy. The things gets cumbersome when it comes to deeply nested
structures, like a hash having nested hashes, arrays etc. The good example of
that would be any configuration file, loaded from YAML.

So, welcome the library that makes the iteration of any nested hash/array
combination almost as easy as the natural ruby `map` and `each`.

• [**Iteraptor**](https://github.com/am-kantox/iteraptor)

### Intro

Since the library monkeypatches core classes, it uses spanish names for
iteration methods. There is a plan to make it better memorizable, see more
about it in the end of this post.

### Features

* `cada` (_sp._ `each`) iterates through all the levels of the nested `Enumerable`,
yielding `parent, element` tuple; parent is returned as a delimiter-joined string
* `mapa` (_sp._ `map`) iterates all the elements, yielding `parent, (key, value)`;
the mapper should return either `[key, value]` array or `nil` to remove this
element;
  * _NB_ this method always maps to `Hash`, to map to `Array` use `plana_mapa`
  * _NB_ this method will raise if the returned value is neither `[key, value]` tuple nor `nil`
* `plana_mapa` iterates yielding `key, value`, maps to the yielded value,
whatever it is; `nil`s are not treated in some special way
* `aplanar` (_sp._ `flatten`) the analogue of `Array#flatten`, but flattens
the deep enumerable into `Hash` instance
* `recoger` (_sp._ `harvest`, `collect`) the opposite to `aplanar`, it builds
the nested structure out of flattened hash
* `segar` (_sp._ `yield`), alias `escoger` (_sp._ `select`) allows to filter
and collect elelements
* `rechazar` (_sp._ `reject`) allows to filter out and collect elelements.

### Words are cheap, show me the code

```ruby
▶ require 'iteraptor'
#⇒ true

▶ hash = {company: {name: "Me", currencies: ["A", "B", "C"],
▷         password: "12345678",
▷         details: {another_password: "QWERTYUI"}}}
#⇒ {:company=>{:name=>"Me", :currencies=>["A", "B", "C"],
#              :password=>"12345678",
#              :details=>{:another_password=>"QWERTYUI"}}}

▶ hash.segar(/password/i) { "*" * 8 }
#⇒ {"company"=>{"password"=>"********",
#   "details"=>{"another_password"=>"********"}}}

▶ hash.segar(/password/i) { |*args| puts args.inspect }
["company.password", "12345678"]
["company.details.another_password", "QWERTYUI"]
#⇒ {"company"=>{"password"=>nil, "details"=>{"another_password"=>nil}}}

▶ hash.rechazar(/password/)
#⇒ {"company"=>{"name"=>"Me", "currencies"=>["A", "B", "C"]}}

▶ hash.aplanar
#⇒ {"company.name"=>"Me",
#   "company.currencies.0"=>"A",
#   "company.currencies.1"=>"B",
#   "company.currencies.2"=>"C",
#   "company.password"=>"12345678",
#   "company.details.another_password"=>"QWERTYUI"}

▶ hash.aplanar.recoger
#⇒ {"company"=>{"name"=>"Me", "currencies"=>["A", "B", "C"],
#   "password"=>"12345678",
#   "details"=>{"another_password"=>"QWERTYUI"}}}

▶ hash.aplanar.recoger(symbolize_keys: true)
#⇒ {:company=>{:name=>"Me", :currencies=>["A", "B", "C"],
#   :password=>"12345678",
#   :details=>{:another_password=>"QWERTYUI"}}}
```

### In Details

#### Simple Iterating

**`Iteraptor#cada(**params, &λ)`** — iterates the nested structure, yielding
the keys (concatenated with `Iteraptor::DELIMITER` or whatever is passed
as `delimiter` keyword argument.) The returned from the block value is discarded.

_block arguments:_ **`key, value`**

_Example:_

```ruby
▶ {foo1: 42, foo2: %i[bar1 bar2], foo3: {foo4: {foo5: 3.14, foo6: :baz}}}.
▷   .cada { |key, value| puts [key, value].inspect }
# ["foo1", 42]
# ["foo2", [:bar1, :bar2]]
# ["foo2.0", :bar1]
# ["foo2.1", :bar2]
# ["foo3", {:foo4=>{:foo5=>3.14, :foo6=>:baz}}]
# ["foo3.foo4", {:foo5=>3.14, :foo6=>:baz}]
# ["foo3.foo4.foo5", 3.14]
# ["foo3.foo4.foo6", :baz]

#⇒ {:foo1=>42, :foo2=>[:bar1, :bar2], :foo3=>{:foo4=>{:foo5=>3.14, :foo6=>:baz}}}
```

#### Simple Mapping

**`Iteraptor#mapa(**params, &λ)`** — iterates the nested structure,
yielding the parent key, key and value. The value, returned from the block
should be a single value (while iterating through arrays, `value` block
argument is `nil`,) of either `[key, value]` tuple or `nil` while
iterating over hashes. In the latter case if `nil` is returned, the resulting
value is removed from the result (_NB:_ this behaviour might change.)

_block arguments:_ **`parent, (key, value)`**

_Example:_

```ruby
▶ {foo1: 42, foo2: %i[bar1 bar2], foo3: {foo4: {foo5: 3.14, foo6: :baz}}}.
▷   mapa { |parent, (k, v)| puts parent; v ? [k, "==#{v}=="] : k }
# foo1
# foo2.0
# foo2.1
# foo3.foo4.foo5
# foo3.foo4.foo6

#⇒ {:foo1=>"==42==", :foo2=>[:bar1, :bar2],
#   :foo3=>{:foo4=>{:foo5=>"==3.14==", :foo6=>"==baz=="}}}
```

#### Filtering

**`Iteraptor#escoger(*filters, **params, &λ)`** — filters the receiver
according to the set of filters given (filters use case-equality) and,
optionally, iterates the resulting structure if the block was given. Might
be treated an an extended analogue of `Enumerable#select`.

_alias:_ **`segar`**, _block arguments:_ **`key, value`**

_Example:_

```ruby
▶ {foo1: 42, foo2: %i[bar1 bar2], foo3: {foo4: {foo5: 3.14, foo6: :baz}}}.
▷   escoger(/foo4/)
#⇒ {"foo3"=>{"foo4"=>{"foo5"=>3.14, "foo6"=>:baz}}}
▷   escoger(->(k) { k == "foo3" })
#⇒ {"foo3"=>{"foo4"=>{"foo5"=>3.14, "foo6"=>:baz}}}


▶ {foo1: 42, foo2: %i[bar1 bar2], foo3: {foo4: {foo5: 3.14, foo6: :baz}}}.
▷   segar(/foo[16]/) { |key, value| 3.14 }
#⇒ {"foo1"=>3.14, "foo3"=>{"foo4"=>{"foo6"=>3.14}}}
```

**`Iteraptor#rechazar(*filters, **params, &λ)`** — the exactly opposite to
`Iteraptor#escoger`. Might be treated an an extended analogue of `Enumerable#select`.

_Example:_

```ruby
▶ {foo1: 42, foo2: %i[bar1 bar2], foo3: {foo4: {foo5: 3.14, foo6: :baz}}}.
▷   rechazar(/[15]/)
#⇒ {"foo2"=>[:bar1], "foo3"=>{"foo4"=>{"foo6"=>:baz}}}
```

#### Flattening

**`Iteraptor#aplanar(**params, &λ)`** — flattens the receiver, concatenating
keys with `Iteraptor::DELIMITER` or whatever is passed as `delimiter` keyword
argument. Might be treated an an extended analogue of `Enumerable#flatten`.
If block passed, `key, value` pair is yielded to it. The returned value
is discarded.

_block arguments:_ **`key, value`**

_Example:_

```ruby
▶ {foo1: 42, foo2: %i[bar1 bar2], foo3: {foo4: {foo5: 3.14, foo6: :baz}}}.
▷   aplanar(delimiter: "_")
#⇒ {"foo1"=>42, "foo2_0"=>:bar1, "foo2_1"=>:bar2,
#   "foo3_foo4_foo5"=>3.14, "foo3_foo4_foo6"=>:baz}
```

**`Iteraptor#recoger(**params)`** — de-flattens the receiver, building
the nested structure back. Knows now to deal with arrays.

_Example:_

```ruby
▶ {"foo1"=>42, "foo2_0"=>:bar1, "foo2_1"=>:bar2, "foo3_foo4_foo5"=>3.14,
▷  "foo3_foo4_foo6"=>:baz}.recoger(delimiter: "_", symbolize_keys: true)
#⇒ {:foo1=>42, :foo2=>[:bar1, :bar2], :foo3=>{:foo4=>{:foo5=>3.14, :foo6=>:baz}}}
```

---

The source code is linked above, the `gem` is available through rubygems.
