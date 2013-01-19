---
layout: page
title: Hello World!
tagline: Supporting tagline
---
{% include JB/setup %}

## Welcome

My name is Alexei Matyushkin. Below are the notes I do write when occasionally find smth interesting during hacking (and lamering.)

## Posts

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>

