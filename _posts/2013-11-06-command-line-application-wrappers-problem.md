---
layout: post
title: "Command line application wrappers problem"
description: "Problem with shell script wrappers in non-default I18N environment"
category: hacking
tags: 
  - ruby
  - tricks
---
Well, everybody knows, that there is no locale but `C`. That’s why all the wrappers
bar none use simple `Popen3::popen3` calls and then parse the output selfless. For
instance whether we are to count the total number of file system blocks, including indirect
blocks, used by the files in directory, we would write the following wrapper:

```ruby
  def get_dir_total dir
    stdin, stdout, stderr = Open3.popen3 "ls -la #{dir}"
    # log the errors or whatever
    stdout.read.split("\n").select { |line| line['total'] }.gsub(/\D/, '')
  end
```

And this code will pass all the tests. And we’ll put it in production, and for all
the colleagues it will work like a charm. Until some trainee from the adjacent
department has a bugreport filled. Damn europeans, will probably think we about,
reading an email from _Łukash Poręba_.

Aha. He has likely polished locale set on his laptop. As well as me, having the russian
one. Which forces `ls` to print `итого` instead of `total`, breaking so cute-promising code.

So, I have monkeypatched my `Popen3` with

```ruby
  …
  cmd.prepend "LC_ALL=C "
  original.popen3 cmd
  …
```

And I would like to ask wrapper-writers “Please, don’t rely on standard locale on target computers.”


