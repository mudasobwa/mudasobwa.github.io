---
layout: post
title: "YADR for Dummies"
description: "Easy installation of YADR"
category: shell
tags:
  - tools
  - linux
---
I spend a half of my life in the terminal window (another half is being wasted even sillier.)
A couple of years ago I switched to `zsh`, then I met [`oh-my-zsh`](https://github.com/robbyrussell/oh-my-zsh),
I even wrote my own theme for it, with blackjack and [battery charge indicator]({% post_url 2013-01-20-zsh-weird-right-prompt %}).
From time to time I tuned the theme up, played with newly investigated vim tricks etc. I switched from `oh-my-zsh` to
[`prezto`](https://github.com/sorin-ionescu/prezto), but I anyway felt myself a little bit deprived.

Accidentally I stumbled upon [`YADR`](https://github.com/skwp/dotfiles). The project headline states
“YADR is the best vim, git, zsh plugins and the cleanest vimrc you've ever seen.” And you know what?—That’s true.
Try it youself and I swear you never decide to turn back to your crude homebred dotfiles.

An installation is as easy (you already have ruby installed, haven’t you?) as:

{% highlight bash %}
git clone https://github.com/skwp/dotfiles ~/.yadr
cd ~/.yadr && rake install
{% endhighlight %}

The only polish required (in my opinion) is the proper theme. So, here we go. I teached the pretty
[Agnoster](https://gist.github.com/agnoster/3712874) theme to show proper right prompt with current gemset,
current ruby version etc. If you are not as to Ruby as me, you’ll find a better application for it.

To install the theme you’ll need:

* install a [Powerline-patched font](https://gist.github.com/1595572) for the theme special symbols
to render correctly
* grab the [theme file](https://gist.github.com/mudasobwa/5308070) and put in into `~/.zsh.prompts/prompt_mudasobwa_setup`
* put the following three lines in the end of your `~/.zshrc` file:

{% highlight bash %}
  $ autoload -Uz promptinit
  $ promptinit
  $ prompt mudasobwa
{% endhighlight %}

* restart `zsh`

The screenshots below show only the visual effectiveness of the theme; the cymes is in details. Everyone
is to be exalted about it’s power and scared kinda “why didn’t I switched to it yesterday.”

**Inside git branch:**

![YADR prompt inside git branch](/img/yadr-mudasobwa-git-prompt.png)

**With background jobs (the blue gear on the left) and non-zero exit status from the previously run command:**

![YADR prompt with running process](/img/yadr-mudasobwa-full-prompt.png)

**VIM status line:**

![YADR prompt for VIM](/img/yadr-mudasobwa-vim-prompt.png)


