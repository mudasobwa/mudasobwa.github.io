---
layout: post
title: "Make Hash Element Access Painless"
description: "Provide a common mechanism to access deeply nested hash elements w/o annoying exception handling"
category: hacking
tags:
  - ruby
  - tricks
---
We often need to deal with a data from very unreliable sources. Over unreliable networks. Using unreliable foreign libraries.

Typically, parsing XML or JSON returns a hash, array, or combination of them. These hashes and/or arrays are likely to be
partially fulfilled or even broken. Parsing through an invalid array leads to curly handling of all sorts of `Error`s and 
unexpected nils. I like spaghetti if and only it’s paired with bolognese.

Actually, the behaviour I expect is quite straightforward: return value requsted if the key provided contains it, 
or smth, having `smth.empty? === true` otherwise.

For example, I have a ramified hash and want to look it up current user’s rights:

{% highlight ruby %}
myhash['users'][@current]['policy']['groups']['admin']
{% endhighlight %}

The user may not being exist, policies might be not set yet, it surely may participate in no groups and, finally, `admin`
privilege may be either set to `false` or completely unset. And guess what? I want to write:

{% highlight ruby %}
show_admin_menu \
  if myhash['users'][@current]['policy']['groups']['admin'] === 'granted'
{% endhighlight %}

Occasionally, there is a way to hack around. To be as accurate as possible, we will not interfere the standard classes
like `Hash` and `Array`. Instead of that we will produce a static function, that will inject the proper behaviour 
(return empty Hash/Array rather than throw an exception) in the instances. The complete code is shown below:

{% highlight ruby %}
def weaken_checks_for_brackets_accessor inst
  inst.instance_variable_set(:@original_get_element_method, inst.method(:[])) \
    unless inst.instance_variable_get(:@original_get_element_method)

  singleton_class = class << inst; self; end
  singleton_class.send(:define_method, :[]) do |*keys|
    begin
      res = (inst.instance_variable_get(:@original_get_element_method).call *keys)
    rescue
    end
    weaken_checks_for_brackets_accessor(res.nil? ? inst.class.new : res)
  end
  inst
end
{% endhighlight %}

Let’s dig up roots. Being called on the instance of Hash (Array is OK as all the other classes, having `#[]` defined),
this method stores the original `Hash#[]` method unless it is already substituted (that’s needed to prevent
stack overflow during multiple calls.) Then it injects the custom implementation of `#[]` method, returning empty
class instead of nil/exception. To use the safe value retrieval:

{% highlight ruby %}
a = { 'foo' => { 'bar' => [1, 2, 3] } }

p (weaken_checks_for_brackets_accessor a)['foo']['bar']
p "1 #{a['foo']}"
p "2 #{a['foo']['bar']}"
p "3 #{a['foo']['bar']['ghgh']}"
p "4 #{a['foo']['bar']['ghgh'][0]}"
p "5 #{a['foo']['bar']['ghgh'][0]['olala']}"
{% endhighlight %}

Yielding:

{% highlight ruby %}
 #⇒ [1, 2, 3]
 #⇒ "1 {\"bar\"=>[1, 2, 3]}"
 #⇒ "2 [1, 2, 3]"
 #⇒ "3 []"
 #⇒ "4 []"
 #⇒ "5 []"
{% endhighlight %}

Nice, isn’t it?
