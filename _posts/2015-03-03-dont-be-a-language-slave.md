---
layout: post
title: "Don’t be a language slave"
description: "Another matter why PHP is damaging brains"
category: hacking
tags:
  - ruby
  - shell
---
Last week I had an intriguing discussion with some Python guru (he got a nickname “[reticulatus](https://en.wikipedia.org/wiki/Python_reticulatus)” a long ago.) I complained to him that the last year I was oblidged to code in PHP and now I am anxious about my IQ being decreased significally. That language virtually forces one to write an enormously nasty code. On the other hand, I finally feigned that PHP code might be written in functional manner as well. My friend archly grinned and suggested me to run benchmarks on functional-ity.

Well, I did.

The result is embarassing. I can’t even surmise how much scorn is to be felt to produce the interpreter that acts in the following way. Let’s take a look at the benchmarks. NB I wrote [the tiny wrapper](https://github.com/mudasobwa/screwdrivers/blob/master/src/Mudasobwa/Screwdrivers/YardStick.php) for calls to `microtime`. It does nothing but calculates times and memory usage between subsequent calls. Consider it a handy transparent utility.

{% highlight php %}
$count = 1000000; // an amount of iterations

// test input, it will be mapped and reduced
$array = array();
for ($i = 0; $i < $count; $i++) {
  $array[] = rand(1, $count);
}

// the wrapper to benchmark easily
$ys = new \Mudasobwa\Screwdrivers\YardStick(true);
{% endhighlight %}

{% highlight php %}
// Mapping
$ys->milestone('MAP#Start');
$countew_array1 = array();
foreach ($array as $a) { $countew_array1[] = $a / 2; }
$ys->milestone('MAP#FOREACH');
$countew_array2 = array();
for ($i = 0; $i < $count; $i++) { $countew_array2[] = $array[$i] / 2; }
$ys->milestone('MAP#FOR');
$countew_array3 = array_map(function($a) { return $a / 2; }, $array);
$ys->milestone('MAP#ARRAY_MAP');
$ys->report('MAP.+'); // report measures for milestones `MAP*`
{% endhighlight %}

{% highlight php %}
// Reducing
$ys->milestone('REDUCE#Start');
$average1 = 0;
foreach ($array as $a) { $average1 += $a / $count; }
$ys->milestone('REDUCE#FOREACH');
$average2 = 0;
for ($i = 0; $i < $count; $i++) { $average2 += $array[$i] / $count; }
$ys->milestone('REDUCE#FOR');
$average3 = array_reduce($array, function($memo, $a) use($count) {
  return $memo + $a / $count;
}, 0);
$ys->milestone('REDUCE#ARRAY_REDUCE');
$ys->report('REDUCE.+'); // report measures for milestones `REDUCE*`
{% endhighlight %}

The results are shown below:

{% highlight bash %}
==== Diff for tags: [MAP#Start :: MAP#FOREACH]
--   ⌚ Time:    ⇒ 0.223850 sec
--   ⌛ Memory:  ⇒ 141,009.3 KB
==== Diff for tags: [MAP#FOREACH :: MAP#FOR]
--   ⌚ Time:    ⇒ 0.240624 sec
--   ⌛ Memory:  ⇒ 141,009.2 KB
==== Diff for tags: [MAP#FOR :: MAP#ARRAY_MAP]
--   ⌚ Time:    ⇒ 0.374310 sec
--   ⌛ Memory:  ⇒ 141,009.2 KB
——————————————————————————————————————
==== Diff for tags: [REDUCE#Start :: REDUCE#FOREACH]
--   ⌚ Time:    ⇒ 0.072303 sec
--   ⌛ Memory:  ⇒ 4.6 KB
==== Diff for tags: [REDUCE#FOREACH :: REDUCE#FOR]
--   ⌚ Time:    ⇒ 0.086437 sec
--   ⌛ Memory:  ⇒ 4.6 KB
==== Diff for tags: [REDUCE#FOR :: REDUCE#ARRAY_REDUCE]
--   ⌚ Time:    ⇒ 0.276434 sec
--   ⌛ Memory:  ⇒ 4.6 KB
{% endhighlight %}

Memory consumption is the same, but `array_map` execution time is almost twice as much as `foreach`, and `array_reduce` is almost four times slower! WUT? Let’s turn back to ruby (I’m not as reptile as my friend, I like jewels more than snakes.)

{% highlight ruby %}
require 'benchmark'

n = 1_000_000
prng = Random.new
array = 1.upto(n).map { |_| 1.0 * (prng.rand n) }
array_new1 = []
array_new2 = []
array_new3 = []

Benchmark.bm do |x|
  x.report { for i in 1...n; array_new1 << array[i] / 2; end }
  x.report { array.each { |a| array_new2 << a / 2 } }
  x.report { array_new3 = array.map { |a| a / 2 } }
end

reduce1 = reduce2 = reduce3 = 0
Benchmark.bm do |x|
  x.report { for i in 1...n; reduce1 += array[i] / n; end }
  x.report { array.each { |a| reduce2 += a / n } }
  x.report { reduce3 = array.reduce(&:+) / n }
end
{% endhighlight %}

{% highlight bash %}
       user     system      total        real
   0.130000   0.000000   0.130000 (  0.130952)
   0.110000   0.000000   0.110000 (  0.104156)
   0.090000   0.010000   0.100000 (  0.097225)
       user     system      total        real
   0.120000   0.000000   0.120000 (  0.115846)
   0.150000   0.000000   0.150000 (  0.155771)
   0.090000   0.000000   0.090000 (  0.090643)
{% endhighlight %}

Ooh! Here we got what we expected from the modern language: mapping and reducing might be optimized comparing to dumb iteration and they occasionally were optimized. Both `map` and `reduce` are predictably _faster_ than iterations. QED.

The difference in ruby is not significant, but the language is likely nudging us to use functional approach. Besides this code is a way more readable, it is just _faster_. While PHP... Well, thanks God my PHP diving season is over.
