---
layout: post
title: "Ruby 2.0 Refinements: Totally Useless Crap"
description: "Are refinements in Ruby 2.0 totally useless?— Yes they are."
category: hacking
tags:
  - ruby
---
There were so-called refinements introduced in Ruby 2.0. I was playing with them and now I’m totally cajoled.
Let me explain, what’s wrong with ’em and why I consider nobody actually wants to use them.

#### The main declared advantage of refines is that they are not global scoped. Bah.

{% highlight ruby %}
module MyModule
  class ::String
    def my_locally_needed_func
      # do smth 
    end
  end
end

# here I need it
require 'mymodule'
"".my_locally_needed_func
{% endhighlight %}

is isolated not worse.

#### Refinements do not support class methods. Bah.

Of course they do through a hack (remember, everything is an object:)

{% highlight ruby %}
module VoidRefinements
  refine String do
    def self.singleton_method_for_string_class
      puts "inside singleton_method_for_string_class"
    end 
  end 
end

module VoidRefinementsOK
  refine Class do
    def singleton_method_for_string_class
      err_msg = "NoMethodError: undefined method" + \
                "‘#{__method__}’ for ‘#{self}:#{self.class}’"
      raise NoMethodError.new(err_msg) unless String == self
      puts "inside proper singleton_method_for_string_class"
    end 
  end 
end

using VoidRefinements
String.singleton_method_for_string_class rescue puts $!
# ⇒ undefined method `singleton_method_for_string_class' for String:Class

using VoidRefinementsOK
String.singleton_method_for_string_class rescue puts $!
# ⇒ inside proper singleton_method_for_string_class
{% endhighlight %}

The latter is not even resulting in performance penalties, since nobody would call `Fixnum.substr` on purpose.

#### Refinements are executed through eval.

`refine` is not a keyword. Bah. (well, “bah!” again.)

Plus I have had some weird unpredicted errors with non-ascii method names in refinements. But that does actually
make already no sense after all.

Am I missing smth or everyone sees no advantages in the newly introduced feature?

