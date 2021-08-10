---
layout: post
title: "Why Am I Not To IDE"
description: "A rant on why I do not use IDE (and think that IDE hinders the good developers more than helps)"
category: hacking
tags:
  - dwim
---

When I started my professional career as a software developer, I was mostly on small warehousing applications written with _Delphi32_. It had excellent _RAD_ environment, allowing people with next to zero knowledge of the computer science produce semi-robust applications with several mouse clicks. One created a form, placed some controls on it and assigned handlers, writing a little amount of code. The naming was not an issue at all, because _RAD_ produced perfect unique names for everything, including forms, controls and handlers, like `TForm1.Button1.onClick`. Projects were small, sold as-is and this approach worked well.

![Night in Montgat](/img/montgat-hill-night.jpg)

Then I got my first office job. The project was an explosive mixture of server-side `COBOL`, client GUI in `VisualBasic3` and a middleware written in pure `C`. We used _Visual SourceSafe_ as version control and I was happy to mostly avoid both `COBOL` and `VB`, focusing on `C`. _Visual Studio_, providing helpful hints, showing help from _MSDN_ and shining its newly introduced _IntelliSense_ feature was of a great help. It was even more friendly than a famous _Dr. Paperclip_ from _MSOffice_.

Three years later I switched to Java RAD development myself. We were building the tool allowing people to construct their own modelling languages based on [_MOF_](https://www.omg.org/spec/MOF/) and visually build applications, bidirectionally converting diagrams to code back and forth. I was building the GUI part on top of _NetBeans_ (it has been called _Forte_ back then.) Code generation part was on _Haskell_, fwiw.

Then I got into custom search engine development with _C++_, web shenanigans with _PHP_, and later _Ruby_. I was diving into learning new languages by installing _IDE_ that literally led my study. _IDE_ was my substitute for mentors, guides, documentation, and everything else. I was navigating through an alien code, understanding it and learning from it. I created my own projects using wild guessing based totally on code completion instead of documentation, and I somewhat succeeded in becoming a relatively good software engineer.

In hindsight, I am ready to proclaim: _IDE_ is the enemy of any good developer. It helps invaluably while learning stage, but once you feel comfortable with a language, _IDE_ hinders your effort. Here is why.

### Code Completion and Hints

Using _IDE_ code completion feature is like using subway when navigating through the city. You’ll definitely get to the destination faster compared to walking, but you’ll know nothing about the path. It’s like teleport, the best you might discover about the relative coordinates between two points on the map, would be one of them is northeast of the other. Walking seems harder and slower, but you’ll inevitably know the whole path. When tomorrow you’ll need to go somewhere in between, you’d already know where to be heading and how much time it takes approximately. You learn by example and in some time you’ll _know the city_. You’ll be able to guide people through this city. You’ll be able to finger to where this or that building is located. By using metro you’ll be able to nail where all the metro stations are, at best.

Once the whole picture becomes more or less complete, you are able to reason about what is the best approach here and there. It might take only five minutes to walk to the destination, but the professional metro-user would take a round-trip with three transfers because it’s how sparse station graph with rare edges works. The learning curve would be way steeper, but it’s definitely worth it on the long run.

### Code Generation

Well, _IDE_ is great in code generation. Two mouse clicks might produce 100 LoCs in a nanosecond. But is it even an advantage unless you get paid for LoCs? I had been always finding myself in a need to genuinely cleanup all the generated mess, which requires nearly the same time as typing the proper code from scratch. I type fast, and this is mostly because I type more than click mouse buttons. Otherwise I’d probably be fast in button clicking, but this skill is not something I am after.

And I spend more time thinking than typing in the first place. Well-thought approach would not require too much code to type. So yeah, since I refused to use _IDE_, there were several occasions when I wished I had a code generation feature, but I always was able to redesign the architecture to make the code shorter and hence more readable. Would I ever bother about this aspect of architecture if I had a button to generate all that crap? I doubt.

### Refactoring

This is my favorite one. Here is my hot take on the topic.

**If your _IDE_ is able to perform code refactoring for you, it is not a refactoring by any mean.**

Rearranging functions between different modules is not a refactoring. It’s reshaping, reforming, re-something you name it. Refactoring is all about changing interfaces, boundaries, and even paradigms. This is something the smartest _IDE_ around cannot do yet. Moving codepieces between files might sound reasonable and feel satisfactory, but it’s not needed in 99% of cases. The yesterday’s you found that was better, today’s you decided this would be better. What about tomorrow’s you and, more important, all the people who will read this code? Are you as sure your new code split between files would be easier to understand? Well, maybe. But even in such a case, `grep`, `sed`, and `awk` would do.

When one does a proper refactoring, it’s important to have more time to review it than a modern _CPU_ requires to rename the variable everywhere. During manual refactoring you’ll inevitably see whether you are doing it right or not. Maybe some better ideas will come to your mind. You’ll feel it like you feel the city when you walk through it and you feel the sound of wheels when you reach the destination point by metro.

Don’t regret to waste time on manual crafting your code. Artists still produce more exciting pieces than machines.

---

Happy idenying.
