---
layout: post
title: "Myths of Backward Compatibility"
description: "Most fears about backward compatibility are precisely that—myths, nourished by laziness, ignorance, or a banal unwillingness to think the problem through. Just ensure backward compatibility. Leave the choice between SemVer, CalVer and assorted ShitVer to the angels-on-a-pinhead crowd."
category: hacking
tags:
  - programming
  - opinion
---

In any discussion of versioning, the hottest debates tend to revolve around a contrived problem: “How can we, through the correct application of version numbers, compensate for the carelessness and low competence of our employees, who are incapable of producing backward-compatible code?”

This is a disgrace.

Yes, backward compatibility—like that insufferable pedant from the Department of Applied Casuistry—transforms any technical discussion into a philosophical treatise on the nature of time and the inevitability of death. The moment someone proposes breaking an API, a person with blazing eyes materializes, prepared to spend an hour explaining why this is impossible, how it will destroy the ecosystem and annihilate every kitten within a kilometre radius. But the truth is that most fears about backward compatibility are precisely that—myths, nourished by laziness, ignorance, or a banal unwillingness to think the problem through.

So then.

### Myth No. 1: Backward Compatibility Requires Preserving All Old Code Forever

No. Backward compatibility is not a mausoleum where every line of code is embalmed and put on public display. It is the art of creating transition periods, during which old and new coexist in parallel long enough for users to migrate. Nobody demands that you prop up crutches for decades—it suffices to give people six months or a year, announce the _deprecation_ clearly, provide migration tools, and then calmly remove the obsolete code. Or don’t remove it—rest assured, somewhere in Los Ybanez, TX there is a design bureau whose engineers are still using version `0.1.0` of your API; simply delete the documentation and dump warnings straight into their snouts—I mean, terminals.[^1]

The problem is not backward compatibility as such, but the absence of a versioning policy and of trust in your users.

### Myth No. 2: Supporting Old Versions Makes Code Unreadable

Bad code makes code unreadable. Backward compatibility merely makes it slightly more verbose. If your function transforms into Frankenstein’s monster solely because you added an optional parameter with a default value, the problem is not backward compatibility but architecture. A well-designed interface can be extended without turning into a rubbish tip. Yes, you will need to write a couple of adapter functions; yes, you will need to keep the contract in your head. But this is neither sorcery nor quantum physics—it is ordinary engineering work, performed by millions of programmers every day.

Besides, abstractions in the form of adapters are needed regardless—unless, of course, you are scraping the internet in Perl.

### Myth No. 3: One Cannot Fix Old Bugs Without Breaking Compatibility

Oh, for heaven’s sake. Of course you can. Moreover, it is done constantly. Add a new function with the corrected behaviour, mark the old one as _deprecated_, give people time to switch. Or use compatibility flags that allow them to opt in to the new behaviour explicitly. Or version your API so that v2 lives alongside v1, without disturbing its peaceful decay. The only thing you truly cannot do is fix a bug in such a way that nobody notices. But that is not necessary either: users are not idiots—they understand that bugs happen, provided you are not attempting to pass off bugs as features.

There is no such thing as a bug caused by accepting the wrong parameters in a function that needs different ones to work properly. There can be too few parameters, or too many—but neither situation requires breaking anything.

### Myth No. 4: Backward Compatibility Stifles Innovation

Ha. Innovation is stifled by the inability to think. Backward compatibility is simply one of the constraints you must work with, like performance or security. Yes, it imposes certain boundaries, but those boundaries do not prohibit doing something new—they require doing it carefully. History is replete with systems that evolved over decades while remaining backward-compatible: from HTTP to the Linux kernel. Erlang is backward-compatible all the way to its first public release in the 1980s.

If Google can add new features to Chrome without breaking half the internet, you can manage your JSON-processing API.

### Myth No. 5: Users Are to Blame If They Rely on Undocumented Behaviour

Yes, but no. From a technical standpoint—yes. From a human one—no. If your code does something definite, people will depend on it, whether you documented it or not. This is called [Hyrum's Law](https://www.hyrumslaw.com/): all observable behaviour of your system will be relied upon by someone. Even within a single team. You can write in the README in capital letters, “THIS IS AN INTERNAL IMPLEMENTATION DETAIL, DO NOT TOUCH,” but if it works and it solves someone’s problem, it will be used.[^2] Blaming users for this is rather like leaving a manhole open in the middle of the road and then expressing astonishment that someone fell in. You must either define your contracts and their boundaries precisely, or resign yourself to the fact that people will drag into their code everything that is not nailed down.

---

So the choice between all your `SemVer`, `CalVer`, and assorted `ShitVer` is a debate about how many devils can fit on the point of a knife. Just ensure backward compatibility. Leave the option of calling the first version of the API, even if the major has long since passed twenty.

This is precisely what I do—which is why not once in my adult career have I had to waste precious time, calories, and nerve cells pondering how to version code correctly.

---

[^1]: Here is how deprecation works in one of my most esoteric [Ruby libraries](https://github.com/am-kantox/dry-behaviour):

![Sooner or later, users will grow tired of seeing this at every launch—and they will do as I ask](/img/dry-protocols-warning.png)

Sooner or later, users will grow tired of seeing this at every launch—and they will do as I ask.

[^2]: _A case from life:_ in one of my libraries I needed to parse simple PlantUML/Mermaid diagrams. For such a thing I do not drag monstrous dependencies into my projects, so I quickly knocked together my own [`parsec`](https://github.com/dashbitco/nimble_parsec) in a private namespace and forgot about it. Roughly a year later, I received an issue complaining that my parser could not handle—I no longer recall the exact details—something like nested comments in states. In other words, a fellow developer had found my library for working correctly with finite automata (!) and was using its undocumented helper functions to parse complex PlantUML.
