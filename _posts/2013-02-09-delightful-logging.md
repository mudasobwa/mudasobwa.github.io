---
layout: post
title: "Delightful Logging"
description: "Facilitation of dealing with Logger"
category: hacking
tags:
  - ruby
  - tricks
---
{% include JB/setup %}

Many ruby project scaffolders (like [bueller](https://github.com/dkastner/bueller) &Co.) produce a file tree
consisting of main `module` file (`MODULE_NAME.rb` needed to syntax-sugaring the project stuff requires,)
some additional garbage and a `lib/MODULE_NAME/version.rb` file. The latter looks like:

{% highlight ruby %}
# encoding: utf-8

module MyModule
  VERSION  = "0.0.1"
end
{% endhighlight %}

I get used to utilize this `version.rb` to define all the project-wide constants etc. If the project requires
config, there is a code to read `config.yml` placed, as well as other predefines.

Nowadays I rejoice in even better approach. There is mere usual but very effective way to make a `Logger` instance
(and others someone likely needs all over the project) accessible from anywhere around the code. To achieve 
that I simply create a `module Kernel` section inside the `version.rb` and put there all the stuff I might need
everywhere:

{% highlight ruby %}
# encoding: utf-8

module MyModule
  VERSION  = "0.0.1"
  LOGGER_STREAM, LOGGER_LEVEL = load_config || STDOUT, Logger::INFO
end

module Kernel
  @@logger = Logger.new(MyModule::LOGGER_STREAM)
  @@logger.level = MyModule::LOGGER_LEVEL
end
{% endhighlight %}

The trick is that `Kernel` module *is being included within `Object` class* and since all the classes have `Object` as
their superclass, all of them obtain an access to `@@logger` class variable transparently. Now anywhere within the project
scope we may write:

{% highlight ruby %}
@@logger.info "Hello, I’m logger"
{% endhighlight %}

yielding:

{% highlight ruby %}
# ⇒  I, [2013-02-09T18:44:18.208111 #27511]  INFO -- : Hello, I’m logger
{% endhighlight %}
