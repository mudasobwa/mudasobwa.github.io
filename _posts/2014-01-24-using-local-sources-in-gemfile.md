---
layout: post
title: "Using local sources in Gemfile"
description: "Comfort development of several gems simultaneously"
category: hacking
tags:
  - ruby
  - shell
---

{% include JB/setup %}

Let’s imagine we develop application, depending on a couple of our own gems.
Or, say, we decide to break a functionality into several gems. The main
application `Gemfile` thus contains references to our gems among all others.

{% highlight ruby %}
gem 'mycutegem'
{% endhighlight %}

The above uses the gem from [Ruby Gems](http://rubygems.org), which is quite
inconvenient in our case: we modify it simultaneously. There is option to
supply path to load the source locally:

{% highlight ruby %}
gem 'mycutegem', :path => '../mycutegem'
{% endhighlight %}

This is hardly acceptable because `Gemfile` became inconsistent with remote
repository. Unfortunately, we cannot specify rules for different groups
in the `Gemfile`, like:

{% highlight ruby %}
gem 'mycutegem', :path => '../mycutegem', :group => :development
gem 'mycutegem', '~> 0.9.3', :group => :production
{% endhighlight %}

{% highlight ruby %}
You cannot specify the same gem twice with different version requirements.
{% endhighlight %}

The solution is simple. There is an ability to inform bundler about
our _local_ copy of repository:

{% highlight ruby %}
$ bundle config local.mycutegem /home/am/Projects/mycutegem
{% endhighlight %}

The latter should be a path to _local **git** repository_. Now the
following code will use our local version of repository (with all the
hot changes,) while all others will use the public source (`:branch` is
mandatory):

{% highlight ruby %}
gem 'mycutegem',
    :git => 'git://github.com/mudasobwa/mycutegem',
    :branch => 'master'
{% endhighlight %}

