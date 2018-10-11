---
layout: post
title: "Protocols in Ruby → Allow Implicit Inheritance"
description: "Dry-behaviour ruby library implementing Elixir protocols for Ruby going towards 1.0 release"
category: hacking
tags:
  - elixir
  - ruby
  - tricks
  - tools
---

[**`dry-behaviour`**](https://github.com/am-kantox/dry-behaviour) is a ruby implementation of [_Elixir protocols_](http://elixir-lang.org/getting-started/protocols.html).

For those who sees this concept for the first time, here is a quick example.

```ruby
module ToString
  include Dry::Protocol

  defprotocol do
    defmethod :dump, :this

    defimpl target: User do
      def dump(this)
        "#{this.name} <#{this.email}>"
      end
    end

    defimpl target: Post do
      def dump(this)
        "#{this.title} <#{this.date}>"
      end
    end
  end
end

ToString.dump(User.last)
#⇒ Aleksei <am@mudasobwa.ru>
ToString.dump(Post.last)
#⇒ Allow Implicit Inheritance <2018-10-11>
```

Basically, this is another way to implement a polymorhism in ruby, isolated and allowing avoid monkeypatching at all.

---

In the last release we have significantly improved error handling, including, but not limited to:

- very descriptive, elixirish error messages that include possible causes, suggestions on how to resolve the issue, etc
- the whole stacktrace is carefully saved with `cause`
- the error object does now store all the environment where the exception occured
- internal exceptions related to wrong implementation do now point to the proper lines in the client code (internal trace lines are removed).

Here is the example of the error message:

![New error](/img/protocols/error-message.png)

---

`Protocols` implementation is very flexible. Besides direct implementation, it allows delegation of methods to the target object). Before this version we allowed the implicit delegation when the method was not implemented:

```ruby
module Namer
  include Dry::Protocol

  defprotocol do
    defmethod :email, :this

    defimpl target: User do
    end
  end
end

Namer.email(User.last)
#⇒ am@mudasobwa.ru
```

There are problems with implicitness. Always. Sooner or later you’ll get into very hard to understand and debug issue, induced by some indirect initialization. Yeah, the warning message about implicit delegation was printed during class loading, but who does read these messages.

In the latest version we’ve deprecated implicit delegation with the intent to remove it completely in `1.0` and raise if the implementation is incomplete.

![Deprecation warning](/img/protocols/deprecation-warning.png)

Instead we now allow implicit delegation to `super` (parent protocol implementation) provided the protocol definition is allowing this.

```diff
 module Namer
   include Dry::Protocol

-  defprotocol do
+  defprotocol implicit_inheritance: true do
     defmethod :email

     def email(this)
       this.email
     end

     defimpl target: User do
-      def email(this)
-        super(this)
-      end
     end
   end
 end
```

---

Also, the most complete environment is stored within the exception to simplify debug if there are some issues:

```ruby
Foo = Class.new
ex =
  begin
    Namer.email(Foo.new, true)
  rescue => e
    e
  end
#⇒ Protocol “Namer” is not implemented for “Foo”.>

ex.details
#⇒ {:method=>:email,
#   :receiver=>#<Foo:0x00560922447308>,
#   :args=>[true],
#   :self=>Namer,
#   :message=>"Protocol “Namer” is not implemented for “Foo”."}
```

---

As one might see, this minor release is mostly focused on polishing error handling, documentation, “explicit-over-implicit” and cosmetics. It brings only one new feature (implicit inheritance inside protocol ancestors tree,) and even that was induced by the necessity to removedeprecate the implicit delegation.

I perfectly understand now why José is constantly repeating “documentaion is the first class citizen.” The code is now way more pleasantly to use. Enjoy!

---

For those who is curious about how the library is implemented under the hood, there is more [technical introduction](http://rocket-science.ru/hacking/2016/12/19/dry-behaviour) _and_, of course, the [source is open](https://github.com/am-kantox/dry-behaviour).

Happy behaving!
