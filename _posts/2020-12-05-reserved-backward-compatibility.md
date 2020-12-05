---
layout: post
title: "Reserved Backward Compatibility"
description: "One small step towards backward compatibility, one giant leap for mankind"
category: hacking
tags:
  - elixir
  - erlang
---

I am fiercely loyal to backward compatibility at any cost. There is no single line of code I wrote in the past decade that breaks backward compatibility. Including but not limited to my experimental libraries dying at version `v0.5` and downloaded by strangers exactly zero times, because I never bothered to publish them into a public space.

I would rather sacrifice clarity, succinctness, and ease of use, than backward compatibility. Even if a parameter is never used anymore and gets immediately discarded in recent versions of the library, the external API would still accept it without compromises. That pattern allows me to recommend library users to always upgrade my library once the new version is released. Semantic versioning in my understanding means _no breaking changes_ in the first place. Numbers just hint how much new goodness one’ll get with an update: none for patch, some for minor and kinda pack (read: LTS) for major. I don’t care what Proper Semantic Versioning Church Evangelists write in their books, I don’t read books. I use a common sense instead.

There is no way one might be put in a situation when introducing breaking changes would be a must. No damn way. Succinctness of the interface in the new version is a perfect dildo to tickle author’s ego and nothing else. No single user of the library cares about the existence of default function parameters or existence of the legacy function that does almost the same but slightly worse.

Deprecate it, freeze it’s development, but **never ever remove it** nor modify its signature.

---

There is a fancy (unfortunately implausible) tale revealing Leonardo da Vinci used the same model for both _Christ_ and _Judas_ in ‘Last Supper.’

> It’s said that Leonardo da Vinci took over ten years to paint the masterpiece ‘Last Supper’ because he was so picky about the models he used for each character. Each model had to have a face that was da Vinci’s vision of the person that he would represent. Needless to say, it became a tedious task to find them. One Sunday, just after da Vinci had begun the painting, he spotted a young man in the choir that he felt would be the perfect Jesus Christ. The lad radiated love, innocence, tenderness, compassion and kindness. The young man, Pietri Bandinelli, agreed to be the model.
> 
> Ten years went by, and the painting remained incomplete. Leonardo could not find just the right face for Judas. He was allowed to search the prison, and there he found the perfect character to portray the man who betrayed Christ. Near the completion of the painting, the model asked if he was allowed to have a look. As he stared at the painting, tears began to flow down his face. When da Vinci asked what was wrong, the model told him that he was Pietri Bandinelli, the same man who had modeled for Christ ten years earlier. He went on to confess that after modelling he began to sin, and soon he turned away from God altogether, resulting in a life of crime, anger, sadness and grief that ended with him being sent to prison for life.
> 
> — [source](https://www.northernstar-online.com/true-or-false-da-vinci-last-supper/)

Imagine for the sake of example that indeed happened. Should Leonardo have the visage of _Christ_ deprecated once he knew the truth? Spend another ten years looking for the new model? I doubt. The same comes for legacy interfaces. Don’t kill them, please. Every time you kill one, God tortures the kitten.

---

When I need to come up with an example of brilliant backward compatibility, I always mention Win95API on that matter.

![RegQueryValueExA](/img/RegQueryValueExA.png)

I do recall using this function back in 1996, when tweaking windows registry was kinda semi-hacking experience, required reverse engineering skills, as well as both bravery and despair. It worked 25 years ago, it works today. Everything around has changed, but this function. That’s what I admit and adore _WinAPI_. It is fully backward compatible.

What exactly am I to blame for that?—Well, this `lpReserved` field. Whenever MS engineeers needed kinda new functionality related to the new data attached to this function, they have a room to pass it through. Without changing interfaces. That’s crucial.

---

Nowadays the interfaces are rather data interchange formats rather than pure functions accessible from the outside code via direct linkage. But the latter are still there when it comes to external libraries encapsulating some data.

My advise would be to always create and empty field named `meta`, or `payload`, or `crap` if you are excentric enough, that woul hold the empty collection from scratch.

`State` is _Elixir_ might look like:

```elixir
defstruct State,
  id: :integer,
  foo: nil,
  bar: %{},
  __meta__: %{}
```

`Message` in JSON:

```json
{"id":1,"foo":null,"bar":{},"__payload__":{}}
```

---

Future you will inevitably praise you present for letting literally any data of any shape to be attached to these `State` and `Message` without breaking anything. Just as an example, let’s see how this `state` might receive a new functionality without the necessity to _upgrade major version_ in all the consumers. Imagine, we are after user-defined validation within this structure. And we already have some internal intergity validation, like:

```elixir
def valid?(%State{} = state) do
  is_integer(state.id) and state.id > 0
end
```

Custom validation?—Easy. Simply whisper to your users “meta supports validation now” and add literally one line to your checker:

```elixir
def valid?(%State{} = state) do
  Map.get(state.__meta__, :checker, fn _ -> true end).(state) and
    is_integer(state.id) and state.id > 0
end
```

Voilà. The rest of the code requires zero modifications, because nothing has changed in the data structure, nor in data handling. Your users would simply change

```diff
- %State{id: 42}
+ %State{id: 42, __meta__: %{checker: fn state -> not is_nil(state.foo) end}}
```

and they are all set. All the old code would not have a chance to notice any difference. That simple.

The same evidently applies to message exchanging, protocols etc. Create a reserved field and it’ll pay back next time you need to introduce somewhat new without frustrating everyone using your code and/or external messaging API.

---

Happy reserving!
