---
layout: post
title: "YAML Parser Tuning"
description: "An example on how to tune a JSON parser"
category: hacking
tags:
  - ruby
---

YAML files are good. They are [likely] human readable, the syntax in more or
less minimalistic and they are nearly a standard for configuration files in
ruby world. One day, though, everybody faces up a necessity to read YAML in
some unusual, often weird manner.

Yesterday I was participating in answering a
[question on StackOverflow](http://stackoverflow.com/questions/29462856/loading-yaml-with-line-number-for-each-key/29595013).
The YAML file was to be parsed as usual, but with a tiny improvement: instead
of leaves values there should be placed hashes like:

```ruby
{ value: value, line: line }
```

where line is a line in original YAML file this leaf was met. The technique
below actually is not stuck with this particular case; it demonstrates the
common approach on how to parse YAML in a non-standard way.

The default parser in Ruby is `Psych`. It is a good old AST builder. To improve
(read: change) it’s behaviour, one needs to bring three things on the table.

#### Node

Patching the node is pretty straightforward. We would store a line, so here we go:

```ruby
class Psych::Nodes::Node
  attr_accessor :line
end
```

#### TreeBuilder

`TreeBuilder` uses visitor pattern to build a syntax tree. In general, it has
the only method of interest, `TreeBuilder#scalar`, which is invoked on every
node. Lets’s deal with it a bit.

```ruby
class EnchancedBuilder < Psych::TreeBuilder
  # Line numbers are available to parser, not to builder; we need a backreference
  attr_accessor :parser

  # Main handler in TreeBuilder
  # @param value [String] the value met
  # @style [Integer] the type of entity met (scalar/int/array/etc)
  def scalar value, anchor, tag, plain, quoted, style
    s = super
    # using the mark from a previous hit to handle multilined values
    s.line = @line || 1
    @line = parser.mark.line + 1 # marks are zero-based
    s
  end
end
```

Here we set the prepared `Node.line` attribute and store the current value
of line of current entity.

#### ToRuby

The only thing left is to spit the newly introduced `line` attribute to
generated ruby properly.

```ruby
class Psych::Visitors::ToRuby
  # There may be problems with Yaml mappings that have tags.
  # @author @matt
  def revive_hash hash, o
    o.children.each_slice(2) { |k,v|
      key = accept(k)
      val = accept(v)

      # This is the important bit. If the value is a scalar,
      # we replace it with the desired hash.
      if v.is_a? ::Psych::Nodes::Scalar
        val = { "value" => val, "line" => v.line }
      end

      # Code dealing with << (for merging hashes) omitted.
      # If you need this you will probably need to copy it
      # in here. See the method:
      # https://github.com/tenderlove/psych/blob/v2.0.13/lib/psych/visitors/to_ruby.rb#L333-L365

      hash[key] = val
    }
    hash
  end
end
```

That’s it. Now we are able to produce hashes as shown below from YAML.

```yaml
key1: value1
key2:
  - value21
  - value22
```

would become

```yaml
hash = {
  'key1' => { 'value' => 'value1', 'line' => 1 },
  'key2' => [
    'value' => 'value21', 'line' => 3,
    'value' => 'value22', 'line' => 4
  ]
}
```
