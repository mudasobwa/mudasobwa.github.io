---
layout: post
title: "Open Graph Protocol …and Her Friends"
description: "the how-to on making links to your site beautifully expanded in facebook, twitter and family"
category: hacking
tags:
  - “…”
  - ruby
  - elixir
  - web.-components
---

When one copy-pastes a link to _twitter_ and/or _facebook_, it might either become
a nifty image with a fancy title and description, or remain an orphan lonely link.

![Afisha Open Graph / Twitter](/img/afisha.png)

The tweet above happened to be built by twitter itself. The tweet author just
copy-pasted the link to their webpage from her browser’s address. This wow-tech
is named “Twitter Cards”; it is [described in details here](https://dev.twitter.com/cards/overview).

That said, as soon as any link is posted to twitter, it’s engine crawls the content,
parses it for some specific `meta`s and renders the pretty preview as shown above.
The very basic example of the site providing tweet rendering layout would be
[GitHub](https://github.com):

```html
<meta name="twitter:card"        content="summary" />
<meta name="twitter:image:src"   content="https://avatars2..." />
<meta name="twitter:site"        content="@github" />
<meta name="twitter:title"       content="TITLE" />
<meta name="twitter:description" content="DESCRIPTION" />
```

The layout type would be `"summary"` [out of four possible](https://dev.twitter.com/cards/types):

> **Card Types**
>
* _Summary Card:_ Title, description, thumbnail, and Twitter account attribution.
* _Summary Card with_ Large Image: Similar to a Summary Card, but with a prominently featured image.
* _App Card:_ A Card to detail a mobile app with direct download.
* _Player Card:_ A Card to provide video/audio/media.

So far, so good. What about facebook? Well, these guys came up with their own
solution. Welcome [The Open Graph Protocol](http://opengraphprotocol.org/).
As stated in the very first para of Introduction to it:

> The Open Graph protocol enables any web page to become a rich object in a social graph.
For instance, this is used on Facebook to allow any web page to have the same
functionality as any other object on Facebook.

> While many different technologies and schemas exist and could be combined together, there isn't a single technology which provides enough information to richly represent any web page within the social graph. The Open Graph protocol builds on these existing technologies and gives developers one thing to implement. Developer simplicity is a key goal of the Open Graph protocol which has informed many of the technical design decisions.

It sounds like a galaxy conquest, but at the very moment is basically used to
embed trendy rendered links into facebook feed. GitHub surely has OGP implemented
as well:

```html
<meta property="og:type"         content="object" />
<meta property="og:image"        content="https://avatars2...." />
<meta property="og:site_name"    content="GitHub" />
<meta property="og:title"        content="TITLE" />
<meta property="og:description"  content="DESCRIPTION" />
<meta property="og:url"          content="https://github.com/..." />
```

Also, OGP appreciates the respective namespaces to be explicitly specified in the `<html>`
tag:

```html
<html prefix="og: http://ogp.me/ns#">
```

GitHub bothers about in it’s own way (note `head` tag):

```html
<head prefix="og: http://ogp.me/ns#
              fb: http://ogp.me/ns/fb#
              object: http://ogp.me/ns/object#
              article: http://ogp.me/ns/article#
              profile: http://ogp.me/ns/profile#">
```

In any case, it’s safe to omit these: consumers will _parse_, not _build XML tree_.

---

The profit of it would be: one might add a great-looking “share” buttons to her site
without any significant effort. Just combine these tags (see, 5 of them have same `content`
value) and get the fancy mentions in social networks, supporting OGP.

```html
<meta name="twitter:card"        content="summary" />
<meta property="og:type"         content="object" />

<meta name="twitter:image:src"   property="og:image"       content="https://avatars2..." />
<meta name="twitter:site"        property="og:site_name"   content="@github" />
<meta name="twitter:title"       property="og:title"       content="TITLE" />
<meta name="twitter:description" property="og:description" content="DESCRIPTION" />

```

We are done. Happy embedding!
