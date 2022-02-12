---
layout: post
title: "Plugins in Elixir Applications"
description: "How to make your application to easily support plugins"
category: hacking
tags:
  - elixir
---

Each and every application has code duplication. Well, not yours, of course. All but yours.

Eventually, the similar functionality tends to suffer from discrepancies in the details. Parameters are slightly different, return values are discrepant, one might raise, another one should not. Commercial projects often have an optional features to be switched on only once the customer pays. Libraries want to support external modules to extend their basic abilities. All that comes to the question “how do we deal with the induced complexity?”

![Lizard](/img/plugins.jpg)

`C` uses header files to claim a demand. Erudite developers with a rich vocabulary yell “polymorphism.” OOP coaches whisper “interfaces.” Pattern adepts get probably already bored reading this because the “Command” pattern is the one. Dynamic languages vote for duck-typing. Erlang provides behaviours for the nearly same purpose. Elixir inherits behaviours and introduces a notion of protocols. RESTful notation has its own word. Even Facebook is now Meta (although I doubt it has anything with the real meaning of the beautiful Greek word.)

OK, jokes aside. We are talking about generic plugins here. Once plugged in, such a beast provides some rich additional functionality. If there is no suitable adapter in the house, nothing crashes, despite the significant part of the functionality is not available anymore. Sounds quite familiar. You cannot listen to the music on your not-so-smart-phone if you are using your grandma’s jack’ed earpods, but answering calls and playing snake is still an option.

Writing plugins in a well-designed plugin architecture is drastically easy. Designing the wellformed plugin architecture is …ahem… a bit harder. The good news is, it’s still not a rocket-science.

We need a duplex communication here. The main application should be able to identify a plugin and ask it to perform its duties when needed, the plugin itself must understand the input and provide a meaningful outcome.

I’d distinguish three different categories of plugins.

- side effect
- pure functions
- mix of both

### Side-effect

Plugins, providing side-effects only (like extendable `Save As…` functionality in the editor,) would be the easiest to implement. It should be able to introduce itself to the application and export a function to call by the application when needed. Somewhat like this would be great (in pseudo-ruby for the sake of brevity)

```ruby
class SaveAsPlugin
  class << self
    def name
      "CSV"
    end

    def call(data)
      raise unless data.is_a?(Hash)
      CSV.save(hash)
    end
  end
end
```

Upon start, the main application would scan the universe for available plugins, call `#name` function on found ones, list them somewhere in the menu and call `#save` when the menu item will be pressed by the user. Or like. That simple.

### Pure

Pure plugins are not quite harder. The code would nearly the same, save for `#call` function will now return the value to be used in the application.

```ruby
class Arithmetic::Minus
  class << self
    def name
      "-"
    end

    def call(lho, rho)
      lho - rho
    end
  end
end
```

That way we might extend the abilities of the `Calculator` application with void default implementation. FWIW, [`Plug`](https://hexdocs.pm/plug) in _Elixir_ are of that kind of plugin, which allows chaining them into [pipelines](https://hexdocs.pm/phoenix/Phoenix.Router.html#pipeline/2) for the further pleasure of developers

```elixir
pipeline :api do
  plug :token_authentication
  plug :dispatch # here we are authenticated
end
```

### Complex plugins

The complexity of this kind of plugins comes from the fact, that they might acually intervene the caller’s workflow in the unknown complicated manner. And the main challenge dealing with this kind of plugins would be to decompose unpredicted unpurity into a chain of predicted pure or side-effect-only calls. This decomposition usually results in a set of different _callbacks_.

Consider the example with the premium features on the regular _Phoenix_ website. What would such a premium feature provide? Well, a list of scopes, where to show a link to it, basically routes. Some contexts, templates and controllers. It must response to requests like `allowed?/1` where the parameter in a call would be the current auth. Something else, drastically specific to the application.

The number of callbacks should be tempting to a minimum, while it must still cover all the possible scenarios.

That sounds too generic, but in fact it’d be not so complicated to implement. There is absolutely no need to strive to produce a swiss-knife-like plugin behaviour. Tree structure works perfectly everywhere, and here it does as well. Just make a top-level behaviour to provide a name, scope _and_ features, where features are other behaviours implemented. Then the main application might perform a sequence of requests for the current scope and decide whether all, or some, or none plugins are suitable to allow in each particular case.

This writing already becames too long, so I’d postpone real-life examples, but the main idea of how to approach this should be _hopefully_ clear now.

---

Happy plugging in!
