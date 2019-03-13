---
layout: page
title: mudasobwa@github
tagline: continiously building the M³-model of life
---
{% include JB/setup %}

---

## My ¢2

My name is Alexei Matyushkin. I was born on October 0, 1973, in Saint-Petersburg, Russia. Nowadays I got used to a nickname “mudasobwa,” proudly granted by rwandian linguists:

<blockquote><p>Kinyarwanda, the language spoken by most Rwandans, has no words for many basic technical and computing terms, including the very word “computer,” explained Steve Murphy, organizer of the project. After debating whether to borrow English or French terms or come up with their own native word, the group settled on “mudasobwa,” which roughly translates to “something or someone that does not make mistakes.”</p>
<small><a href="http://news.com.com/2100-7344_3-5159179.html?part=rss&amp;tag=feed&amp;subj=news">Se habla open source?</a></small></blockquote>

----

[My OSS / CC BY-SA Contributions](/pages/projects.html)

----

## In One Fell Swoop

I have an experience in C/C++ pointing, Ruby railing, SQL querying, Java threads woodoo magic (and woodoo pleasure since 6.0), Perl crypting, Javascript handling, AJAX inplacing, Python tabbing, LISP bracketing. I have been working with so many unix variants (HP-UX, Solaris, Minix, Linux) that I finally learned the proper plural form ‘unices’. I have managed the jabber client-server apps in Yandex, led warehouse management apps for US customers, developed the metamodelling tool in Berlin and created the medical apps in Saint-Petersburg.

----
<div class="row">
  <div class="col s12 m6">
  <h4 class="smallcaps">decalogue</h4>
  <ol type="i">
  <li>Go drunk solitary. In fine fettle call friends to drink.</li>
  <li>Flirt with everyone. Sleep alone.</li>
  <li>Know there is somebody around. Forget who.</li>
  <li>Do all things in time. Set the deadlines yourself.</li>
  <li>Once realized—do approx. Once approxed—forgive.</li>
  <li>Got things done?—Dismiss. Fail?—Dare.</li>
  <li>Accept the past. Fix a future.</li>
  <li>Don’t be afraid of a hate. Fear the indifference.</li>
  <li>Believe feelings. Trust in reason.</li>
  <li><b>Bear in mind</b>: you are wiser, hence you are guilty.</li>
  <li><em>P.S.</em>Don’t dodge to supplement.</li></ol>
  </div>
  <div class="col s12 m6" style="font-size: 80%;">
  <h4 class="smallcaps">binaries</h4>
  <ul class="disc">
  <li>I don’t dread to appear: smart, stupid, arrogant, humble, a womanizer, a misogynist, a chatterbox, a taciturn, a teetotaler, an alcoholic, a dictator, a democrat, reliable, unreliable, white, black and purple.</li>
  <li>I am affraid to show myself: a bore.</li></ul>
  <h4 class="smallcaps">sins (and coss)</h4>
  <ul class="disc">
  <li>indifference</li>
  <li>partiality</li>
  <li>intellectual laziness</li>
  <li>envy</li></ul>
  </div>
</div>

----
Below are the notes I do write when occasionally find smth interesting during hacking (and lamering.)

## Posts

<table class="striped highlight border" style="line-height: 100%;">
  {% for post in site.posts %}
    <tr><td>{{ post.date | date_to_string }}</td><td><a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></td></tr>
  {% endfor %}
</table>
