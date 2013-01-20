---
layout: page
title: mudasobwa@github
tagline: continiously building the M³-model of life
---
{% include JB/setup %}

## Welcome

My name is Alexei “mudasobwa” Matyushkin. Below are the notes I do write when occasionally find smth interesting during hacking (and lamering.)

## Posts

<table class="table table-striped table-condensed table-bordered">
  {% for post in site.posts %}
    <tr><td>{{ post.date | date_to_string }}</td><td><a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></td></tr>
  {% endfor %}
</table>

