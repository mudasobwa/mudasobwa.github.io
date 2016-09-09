---
layout: post
title: "Use Hooks in Riak to Create Views"
description: "Riak hooks are a good tool to simplify creation of views"
category: hacking
tags:
  - ruby
---

> [Riak KV](http://docs.basho.com/riak/kv/2.1.4/downloads/) is a distributed
NoSQL database designed to deliver maximum data availability by distributing
data across multiple servers. As long as your Riak KV client can reach one
Riak server, it should be able to write data.

Riak is written in Erlang, that’s why. Also, Riak supports
[hooks, written in Erlang](http://docs.basho.com/riak/kv/2.1.4/developing/usage/commit-hooks/).

I love hooks. When it comes to a voodoo magic, I am a big fun of
[domino effect](https://en.wikipedia.org/wiki/Domino_effect). One simply
inserts a value into the database, and complicated business logic processes
do their job transparently. All these schema transformations, history, logging,
versioning, emailing, coffeemaking, tequiladrinking... Sorry, was distracted.

So, in one of our projects we have a stream of changing data; think of
a temperature value in hundred of different cities. Updates come every second,
or even more often. I need to keep a history, but also I need a clean pure
view with last up-to-date values. Like:

|-|-|
|City|Temperature|
|-|-|
|Barcelona     |23°|
|London        |22°|
|Moscow        |-6°|
|New York      |0°|
|-|-|

---

So far so good. Riak handles inserts into “raw” data bucket perfectly,
but how would I keep my view up-to-date? Easy.

Let’s introduce a hook on Riak’s insert into “raw” data bucket.
Hooks are to be written in Erlang, so we’ll produce a simple module:

{% highlight erlang %}
-module(backend_hooks).
-export([update_current/1]).

%% When the `raw` value is changed, we are to update the `current`
%%  bucket, that collects all up-to-date values.
update_current(RiakObject) ->
  {_, Key} = riak_object:bucket(RiakObject),
  Bucket = {<<"current">>, <<"spot">>},
	MetaData = riak_object:get_metadata(RiakObject),

  case dict:find(<<"X-Riak-Deleted">>, MetaData) of
    {ok, _} ->
      % do nothing, this is a deletion
      io:fwrite("!! DELETED AN OBJECT FROM RAW: ~w~n", [RiakObject]);
    _ ->
      {struct, Json} = mochijson2:decode(riak_object:get_value(RiakObject)),
      {<<"value">>, Value} = lists:keyfind(<<"value">>, 1, Json)
      {ok, C} = riak:local_client(),
      case C:get(Bucket, Key) of
        {ok, Old} ->
          case riak_object:get_value(Old) of
            Value -> % Value has not changed, skipping update
              % io:fwrite("LEFT INSTACT: ~w~n", [{Key, Value}]);
              ok;
            _ ->
              % io:fwrite("UPDATED: ~w~n", [{Key, Value}]),
              C:put(riak_object:update_value(Old, Value))
            end;
        {error, notfound} ->
          % io:fwrite("CREATED: ~w~n", [{Key, Value}]),
          C:put(riak_object:new(Bucket, Key, Value))
        end
    end,
  RiakObject.
{% endhighlight %}

Cool. Now we have to install this hook. To do so, one should do three things.
Riak hooks might be attached directly to specific buckets, but I prefer to keep things
clear and introduce the `bucket-type` for it:

{% highlight bash %}
sudo riak-admin bucket-type create raw \
    '{"props":{"precommit":[{"mod":"backend_hooks","fun":"update_current"}]}}'
sudo riak-admin bucket-type activate raw

sudo riak-admin bucket-type create current
sudo riak-admin bucket-type activate current
{% endhighlight %}

To install a hook, one should compile the Erlang module and copy the resulting
`beam` into the directory, Riak is aknowledged of. First of all, let’s tell
Riak about our hook directory:

{% highlight bash %}
$ cat /etc/riak/advanced.config
[
  {riak_kv, [
    {add_paths, ["/usr/lib/riak/hooks"]}
  ]}
].
{% endhighlight %}

On the fresh installation, this file is empty/non-existent. Put the content
above into it. This will add `"/usr/lib/riak/hooks"` to the Riak paths.

Now, copy the `beam` into this directory:

{% highlight bash %}
$ sudo mkdir -p /usr/lib/riak/hooks
$ erlc backend_hooks.erl && \
    sudo cp backend_hooks.beam /usr/lib/riak/hooks
{% endhighlight %}

Restart Riak and we are all set. From now on every insert into `raw` bucket,
will result in Riak to gracefully update the “nested” up-to-date
`{current, spot}` bucket.

And all that was done with a dozen of lines of code. Cute, isn’t it?
