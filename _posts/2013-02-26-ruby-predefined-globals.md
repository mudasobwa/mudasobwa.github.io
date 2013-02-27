---
layout: post
title: "Ruby Predefined Globals"
description: "List of predefined globals ($∀) in ruby with examples"
category: tips
tags: [ruby]
---
{% include JB/setup %}

## Below is the summary table for the predefined globals in ruby.

<table class="table table-bordered code">
<tbody>
<tr>
<td><a href="#bang" class="btn"><strong>$!</strong></a></td>
<td><a href="#plus" class="btn"><strong>$+</strong></a></td>
<td><a href="#minus-w" class="btn"><strong>$-W</strong></a></td>
<td><a href="#minus-v-small" class="btn"><strong>$-v</strong></a></td>
<td><a href="#digit" class="btn"><strong>$2</strong></a></td>
<td><a href="#digit" class="btn"><strong>$8</strong></a></td>
<td><a href="#greater" class="btn"><strong>$&gt;</strong></a></td>
</tr>
<tr>
<td><a href="#double-quotes" class="btn"><strong>$"</strong></a></td>
<td><a href="#comma" class="btn"><strong>$,</strong></a></td>
<td><a href="#minus-a-small" class="btn"><strong>$-a</strong></a></td>
<td><a href="#minus-w-small" class="btn"><strong>$-w</strong></a></td>
<td><a href="#digit" class="btn"><strong>$3</strong></a></td>
<td><a href="#digit" class="btn"><strong>$9</strong></a></td>
<td><a href="#qmark" class="btn"><strong>$?</strong></a></td>
</tr>
<tr>
<td><a href="#dollar" class="btn"><strong>$$</strong></a></td>
<td><a href="#minus-zero" class="btn"><strong>$-0</strong></a></td>
<td><a href="#minus-d-small" class="btn"><strong>$-d</strong></a></td>
<td><a href="#dot" class="btn"><strong>$.</strong></a></td>
<td><a href="#digit" class="btn"><strong>$4</strong></a></td>
<td><a href="#colon" class="btn"><strong>$:</strong></a></td>
<td><a href="#at" class="btn"><strong>$@</strong></a></td>
</tr>
<tr>
<td><a href="#ampersand" class="btn"><strong>$&amp;</strong></a></td>
<td><a href="#minus-f" class="btn"><strong>$-F</strong></a></td>
<td><a href="#minus-i-small" class="btn"><strong>$-i</strong></a></td>
<td><a href="#slash" class="btn"><strong>$/</strong></a></td>
<td><a href="#digit" class="btn"><strong>$5</strong></a></td>
<td><a href="#semicolon" class="btn"><strong>$;</strong></a></td>
<td><a href="#backslash" class="btn"><strong>$\</strong></a></td>
</tr>
<tr>
<td><a href="#end-quote" class="btn"><strong>$'</strong></a></td>
<td><a href="#minus-i" class="btn"><strong>$-I</strong></a></td>
<td><a href="#minus-l-small" class="btn"><strong>$-l</strong></a></td>
<td><a href="#digit" class="btn"><strong>$0</strong></a></td>
<td><a href="#digit" class="btn"><strong>$6</strong></a></td>
<td><a href="#less" class="btn"><strong>$&lt;</strong></a></td>
<td><a href="#underscore" class="btn"><strong>$_</strong></a></td>
</tr>
<tr>
<td><a href="#splat" class="btn"><strong>$*</strong></a></td>
<td><a href="#minus-k" class="btn"><strong>$-K</strong></a></td>
<td><a href="#minus-p-small" class="btn"><strong>$-p</strong></a></td>
<td><a href="#digit" class="btn"><strong>$1</strong></a></td>
<td><a href="#digit" class="btn"><strong>$7</strong></a></td>
<td><a href="#tilde" class="btn"><strong>$~</strong></a></td>
<td><a href="#backtick" class="btn"><strong>$`</strong></a></td>
</tr>
</tbody>
</table>


<div class="table-wrapper">
<table class="table">
<thead><tr><th>Variable</th><th>Description</th></tr></thead>
<tbody>
<tr>
  <td class="tooltipable">
      <a id="bang"></a>
      <code class="btn btn-large disabled"><strong>$!</strong></code>
      <span class="code">Exception === $! unless $!.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span> <span class="label label-info">thread-local</span>  <strong>The last exception, that was <em>thrown and rescued</em> in the current context.</strong><br>
    Locals to the <code>rescue</code> clause.</p>
{% highlight ruby %}
> 0 / 0 rescue $!
# ⇒ <ZeroDivisionError: divided by 0>

> begin
>   0 / 0
> rescue
>   $!
> end
# ⇒ <ZeroDivisionError: divided by 0>

> 0 / 0
# ZeroDivisionError: divided by 0
# from (pry):67:in `/'
> $!
# ⇒ nil
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="double-quotes"></a>
      <code class="btn btn-large disabled"><strong>$"</strong></code>
      <span class="code">Array === $"</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Array of strings,
        containing absolute paths to loaded files.</strong><br>
    Files, loaded within both <code>Kernel’s</code> <code>load</code>,
        <code>require</code>, <code>require_relative</code> directives <strong><em>and</em></strong> platform-specific
        <a href="http://www.ruby-doc.org/stdlib-1.9.3/libdoc/dl/rdoc/DL.html">DL</a>/<a href="http://www.ruby-doc.org/stdlib-1.9.3/libdoc/fiddle/rdoc/Fiddle.html">Fiddle</a>,
        are shown in the list.
    </p>
{% highlight ruby %}
> $"
# ⇒ [
#  [  0] "enumerator.so",
#  [  1] "/…/lib/ruby/2.0.0/x86_64-linux/enc/encdb.so",
#  [  2] "/…/lib/ruby/2.0.0/x86_64-linux/enc/trans/transdb.so",
#  [  3] "/…/lib/ruby/site_ruby/2.0.0/rubygems/defaults.rb",
#  [  4] "/…/lib/ruby/2.0.0/x86_64-linux/rbconfig.rb",
#  …
#  [227] "/…/lib/ruby/2.0.0/dl.rb"
# ]
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="dollar"></a>
      <code class="btn btn-large disabled"><strong>$$</strong></code>
      <span class="code">Fixnum === $$</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Current process ID.</strong><br></p>
{% highlight ruby %}
> $"
# ⇒ 8603

> Process.pid
# ⇒ 8603
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="ampersand"></a>
      <code class="btn btn-large disabled"><strong>$&amp;</strong></code>
      <span class="code">String === $&amp; unless $&amp;.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span> <span class="label label-info">thread-local</span>  <strong>The matched string from the previous successful pattern match.</strong><br>
    Locals to the pattern match scope.</p>
{% highlight ruby %}
> "foo bar baz".match /foo|bar|baz/
# ⇒ <MatchData "foo">
> $&
# ⇒ "foo"

> "foo bar baz".gsub /foo|bar|baz/, "ggg"
# ⇒ "ggg ggg ggg"
> $&
# ⇒ "baz"

> "foo bar baz".match /foobarbaz/
# ⇒ nil
> $&
# ⇒ nil
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="end-quote"></a>
      <code class="btn btn-large disabled"><strong>$'</strong></code>
      <span class="code">String === $' unless $'.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span> <span class="label label-info">thread-local</span>  <strong>The rest of the string <em>after the matched</em> substring in the previous successful pattern match.</strong><br>
    Locals to the pattern match scope.</p>
{% highlight ruby %}
> "foo bar baz".match /foo|bar|baz/
# ⇒ <MatchData "foo">
> $'
# ⇒ " bar baz"

> "foo bar baz".gsub /foo|bar|baz/, 'ggg'
# ⇒ "ggg ggg ggg"
> $'
# ⇒ ""

> "foo bar baz".match /foobarbaz/
# ⇒ nil
> $'
# ⇒ nil
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="splat"></a>
      <code class="btn btn-large disabled"><strong>$*</strong></code>
      <span class="code">Array === $*</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>The command line arguments passed to the currently executed ruby script.</strong><br>
    An alias for <code>ARGV</code>.</p>
{% highlight ruby %}
~ pry --simple-prompt
> $*
# ⇒ [
#  [0] "--simple-prompt"
# ]
> ARGV
# ⇒ [
#  [0] "--simple-prompt"
# ]
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="plus"></a>
      <code class="btn btn-large disabled"><strong>$+</strong></code>
      <span class="code">String === $+ unless $+.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span> <span class="label label-info">thread-local</span>  <strong>The last <em>captured</em> match from the previous successful pattern match.</strong><br>
    Locals to the pattern match scope. Contains <code>nil</code> if there was no capture (even while match was successful.)</p>
{% highlight ruby %}
> "foo bar baz".match /(foo) (bar) baz/
# ⇒ <MatchData "foo bar baz" 1:"foo" 2:"bar">
> $+
# ⇒ "bar"

> "foo bar baz".scan (/a(\S)/) { |m| puts m }
# r
# z
# ⇒ "foo bar baz"
> $+
# ⇒ "z"

> "foo bar baz".match /foo bar baz/
# ⇒ <MatchData "foo bar baz">
> $+
# ⇒ nil
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="comma"></a>
      <code class="btn btn-large disabled"><strong>$,</strong></code>
      <span class="code">String === $, unless $,.nil?</span>
  </td>
  <td>
    <p><span class="label label-success">read-write</span>  <strong>Separator for both
    <code>Kernel#print</code> and <code>Array#join</code>.</strong><br>
    Defaults to nil.</p>
{% highlight ruby %}
> print "foo", "bar", "baz"
# foobarbaz⇒ nil
> %w[foo bar baz].join
# ⇒ "foobarbaz"

> $,='%'
# ⇒ "%"

> print "foo", "bar", "baz"
# foo%bar%baz⇒ nil
> %w[foo bar baz].join
# ⇒ "foo%bar%baz"
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-zero"></a>
      <code class="btn btn-large disabled"><strong>$-0</strong></code><br><br>
      <a id="slash"></a>
      <code class="btn btn-large disabled"><strong>$/</strong></code>
      <span class="code">String === $-0 unless $-0.nil?<br>String === $/ unless $/.nil?</span>
  </td>
  <td>
    <p><span class="label label-success">read-write</span>  <strong>Input record separator.</strong><br>
    Defaults to <code>\n</code>. May be set with the <code>-0</code> command line parameter (as octal value.)</p>
{% highlight ruby %}
> $-0='%'
# ⇒ "%"
> gets
f
o
o
%
# ⇒ "f\no\no\n%"

~ ruby -045 /…/bin/pry
> gets
f
o
o
%
# ⇒ "f\no\no\n%"
> 
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-f"></a>
      <code class="btn btn-large disabled"><strong>$-F</strong></code><br><br>
      <a id="semicolon"></a>
      <code class="btn btn-large disabled"><strong>$;</strong></code>
      <span class="code">String === $-F unless $-F.nil?<br>String === $: unless $:.nil?</span>
  </td>
  <td>
    <p><span class="label label-success">read-write</span>  <strong>Default field separator for <code>String#split</code>.</strong><br>
    Defaults to <code>nil</code>. May be set with the <code>-F</code> command line parameter.</p>
{% highlight ruby %}
> $-F
# ⇒ nil
> "foo bar baz".split
# ⇒ [
#  [0] "foo",
#  [1] "bar",
#  [2] "baz"
# ]

> $-F='%'
# ⇒ "%"
> "foo bar baz".split
# ⇒ [
#  [0] "foo bar baz"
# ]
> "foo%bar%baz".split
# ⇒ [
#  [0] "foo",
#  [1] "bar",
#  [2] "baz"
# ]

> $-F == $;
# ⇒ true
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-i"></a>
      <code class="btn btn-large disabled"><strong>$-I</strong></code><br><br>
      <a id="colon"></a>
      <code class="btn btn-large disabled"><strong>$:</strong></code>
      <span class="code">Array === $-I<br>Array === $:</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Array of include paths.</strong><br>
    Absolute paths to be searched by <code>Kernel.load</code> and/or <code>Kernel.require</code>.</p>
{% highlight ruby %}
> $-I
# ⇒ [
#  [ 0] "/…/gems/rubygems-bundler-1.1.0/lib",
#  [ 1] "/…/gems/bundler-1.2.3/lib",
#  [ 2] "/…/gems/coderay-1.0.8/lib",
#  [ 3] "/…/gems/slop-3.4.3/lib",
#  …
#  [14] "/…/lib/ruby/2.0.0/x86_64-linux"
# ]

> $-I == $:
# ⇒ true
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-k"></a>
      <code class="btn btn-large disabled"><strong>$-K</strong></code>
      <span class="code">String === $-K unless $-K.nil?</span>
  </td>
  <td>
    <p><span class="label label-inverse">obsolete</span> <span class="label label-success">read-write</span>  <strong>Determined the encoding to use to parse <code>.rb</code> files.</strong><br>
    One should avoid using that variable since <code>ruby-1.9</code>.</p>
{% highlight ruby %}
> $-K
# (pry):13: warning: variable $KCODE is no longer effective
# ⇒ nil
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-w"></a>
      <code class="btn btn-large disabled"><strong>$-W</strong></code>
      <span class="code">Fixnum === $-W</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Current verbosity level.</strong><br>
    Defaults to <code>1</code>. May be set to <code>0</code> with the <code>-W0</code> command line arg
      and to <code>2</code> with one of <code>-w</code>, <code>-v</code>, or <code>--verbose</code> switches.</p>
{% highlight ruby %}
> $-W
# ⇒ 1
> exit

~ ruby -v /…/bin/pry
# ruby 2.0.0dev (2012-12-01 trunk 38126) [x86_64-linux]
# /…/gems/method_source-0.8.1/lib/method_source/code_helpers.rb:38: warning: assigned but unused variable - e2
# …
# /…/gems/pry-0.9.11.4/lib/pry/pry_class.rb:446: warning: instance variable @critical_section not initialized
> $-W
# /…/gems/awesome_print-1.1.0/lib/awesome_print/inspector.rb:114: warning: instance variable @force_colors not initialized
# ⇒ 2
> exit

~ ruby -W0 /…/bin/pry
> $-W
# ⇒ 0
>
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-a-small"></a>
      <code class="btn btn-large disabled"><strong>$-a</strong></code>
      <span class="code">∈ [true, false]</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Denotes whether the auto-split mode was enabled with <code>-a</code> command line argument.</strong><br>
    <code>-a</code> switch makes sense when used together with either <a href="#minus-p-small"><code>-p</code></a>
    or <a href="#minus-n-small"><code>-n</code></a> args.
    In auto-split mode, Ruby executes	<code>$F = <a href="#underscore">$_</a>.split</code> at beginning of each loop.</p>
{% highlight ruby %}
~ cat > test-a-switch.rb <<EOF
# heredoc> # encoding: utf-8
# heredoc> puts "LINE=[#{\$_.strip}]"
# heredoc> puts "\$F=#{\$F}"
# heredoc> EOF

~ ruby -a -n test-a-switch.rb test-a-switch.rb
# LINE=[# encoding: utf-8]
# $F=["#", "encoding:", "utf-8"]
# LINE=[puts "LINE=#{$_.strip}"]
# $F=["puts", "\"LINE=\#{$_.strip},"]
# LINE=[puts "$F=#{$F}"]
# $F=["puts", "$F=\#{$F}\""]

~ ruby -n test-a-switch.rb test-a-switch.rb
# LINE=# encoding: utf-8
# $F=
# LINE=puts "LINE=#{$_.strip}"
# $F=
# LINE=puts "$F=#{$F}"
# $F=
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-d-small"></a>
      <code class="btn btn-large disabled"><strong>$-d</strong></code>
      <span class="code">∈ [true, false]</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Denotes whether the debug mode was enabled with <code>-d</code> switch.</strong><br></p>
{% highlight ruby %}
~ cat > test-d-switch.rb <<EOF
# heredoc> puts "DEBUG MODE: #{\$-d}"
# heredoc> EOF

~ ruby -d test-d-switch.rb
# Exception `LoadError' at /…/lib/ruby/site_ruby/2.0.0/rubygems.rb:1264 - cannot load such file -- rubygems/defaults/operating_system
# Exception `LoadError' at /…/lib/ruby/site_ruby/2.0.0/rubygems.rb:1273 - cannot load such file -- rubygems/defaults/ruby
# DEBUG MODE: true
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-i-small"></a>
      <code class="btn btn-large disabled"><strong>$-i</strong></code>
      <span class="code">∈ [true, false]</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Value of the <code>-i</code> command line argument, if given.</strong><br>
    Defaults to <code>nil</code>. When provided, this argument enables inplace-edit mode; the parameter specifies an extension of
    backup file to be created.</p>
{% highlight ruby %}
~ cat > test-i-switch.rb << EOF
\$_.upcase!
puts "i-switch: #{\$-i}"
EOF

~ ruby -p -i.bak test-i-switch.rb test-i-switch.rb

~ cat test-i-switch.rb
# i-switch: .bak
# $_.UPCASE!
# i-switch: .bak
# PUTS "I-SWITCH: #{$-I}"
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-l-small"></a>
      <code class="btn btn-large disabled"><strong>$-l</strong></code>
      <span class="code">∈ [true, false]</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Denotes whether the automatic line-ending processing mode was enabled with <code>-l</code> switch.</strong><br>
    Automatic line-endings sets <a href="#backslash"><code>$\</code></a> to
      the value of <a href="#slash"><code>$/</code></a>, and (when used with either <a href="#minus-p-small"><code>-p</code></a>
      or <a href="#minus-n-small"><code>-n</code></a> args) chops every line read using <code>chop!</code>.</p>
{% highlight ruby %}
# Could not invent a meaningful example :-(
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-p-small"></a>
      <a id="minus-n-small"></a>
      <code class="btn btn-large disabled"><strong>$-p</strong></code>
      <span class="code">∈ [true, false]</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Denotes whether the “gets loop around” mode was enabled with <code>-p</code> switch.</strong><br>
    <code>-p</code> switch acts mostly like <code>-n</code> sibling with one exception: it prints the value
      of variable <code>$_</code> at the each end of the loop.<br>For some unknown reason there is no internal global
      to get aknowledged whether the <code>-n</code> command line switch was given. When it was, Ruby is to assume
      the following loop around your script, which provides an iteration over filename arguments somewhat like
      <code>sed -n</code> and <code>awk</code> do.</p>
{% highlight ruby %}
while gets
 …
end
{% endhighlight %}
<p>An example of usage follows:</p>
{% highlight ruby %}
~ echo "foo bar baz" | ruby -p -e '$_.tr! "o-z", "O-Z"'
# ⇒ fOO baR baZ
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="minus-v-small"></a>
      <code class="btn btn-large disabled"><strong>$-v</strong></code><br><br>
      <a id="minus-w-small"></a>
      <code class="btn btn-large disabled"><strong>$-w</strong></code>
      <span class="code">∈ [true, false]</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Denotes whether the verbose mode
      was enabled with either <code>-v</code> or <code>-w</code> switch.</strong><br></p>
{% highlight ruby %}
~ cat > test-v-switch.rb <<EOF
# heredoc> puts "VERBOSE MODE: #{\$-v}"
# heredoc> EOF

~ ruby -v test-v-switch.rb
# ruby 2.0.0dev (2012-12-01 trunk 38126) [x86_64-linux]
# VERBOSE MODE: true
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="dot"></a>
      <code class="btn btn-large disabled"><strong>$.</strong></code>
      <span class="code">Fixnum === $.</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Number of the last line read from the current input file <a href="#less"><code>ARGF</code></a>.</strong><br>
    <a href="http://www.ruby-doc.org/core-2.0/ARGF.html">ARGF</a> is a stream designed for use in scripts that process files given as command-line arguments or passed in via <code>STDIN</code>.</p>
{% highlight ruby %}
ARGV.replace ["file1"] # file1 ≡ 'a\nb\nc\nd'
ARGF.readlines # Returns the contents of file1 as an Array
$.
# ⇒ 4
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="digit"></a>
      <code class="btn btn-large disabled"><strong>$0…$9</strong></code>
      <span class="code">String === $0 unless $0.nil?<br>
      String === $1 unless $1.nil?<br>
      String === $2 unless $2.nil?<br>
      String === $3 unless $3.nil?<br>
      String === $4 unless $4.nil?<br>
      String === $5 unless $5.nil?<br>
      String === $6 unless $6.nil?<br>
      String === $7 unless $7.nil?<br>
      String === $8 unless $8.nil?<br>
      String === $9 unless $9.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>The <code>N-th</code> capture of the previous successful pattern match.</strong><br>
    Defaults to <code>nil</code> if the match failed or if <code>N</code> is greater than an amount of captured groups.</p>
{% highlight ruby %}
> "foo bar baz".match(/(foo) (bar)/) 
# ⇒ <MatchData:0x18cb9f4>
> $1
# ⇒ "foo"
> $2
# ⇒ "bar"
> $3
# ⇒ nil
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="less"></a>
      <code class="btn btn-large disabled"><strong>$&lt;</strong></code>
      <span class="code">ARGF === $&lt;</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Read‐only alias for ARGF.</strong><br></p>
{% highlight ruby %}
> $<.class
# ⇒ ARGF.class < Object
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="equals"></a>
      <code class="btn btn-large disabled"><strong>$=</strong></code>
      <span class="code">∈ [true, false]</span>
  </td>
  <td>
    <p><span class="label label-inverse">obsolete</span>  <br></p>
{% highlight ruby %}
> $=
# (pry):23: warning: variable $= is no longer effective
# ⇒ false
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="greater"></a>
      <code class="btn btn-large disabled"><strong>$&gt;</strong></code>
      <span class="code">IO === $&gt;</span>
  </td>
  <td>
    <p><span class="label label-success">read-write</span>  <strong>Standard output stream.</strong><br></p>
{% highlight ruby %}
> $> = File.new('/tmp/foo', 'w')
# ⇒ <File:/tmp/foo>
# -rw-r--r-- 1 am users 0 Feb 27 12:41 /tmp/foo

> puts "bar baz"
# ⇒ nil
> exit

~ cat /tmp/foo
# bar baz
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="qmark"></a>
      <code class="btn btn-large disabled"><strong>$?</strong></code>
      <span class="code">Process::Status === $? unless $?.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span>  <strong>Exit status of the last terminated process within current context.</strong><br></p>
{% highlight ruby %}
> `ls FooBarBaz`
# ls: невозможно получить доступ к FooBarBaz: Нет такого файла или каталога
# ⇒ ""

> $?
# ⇒ <Process::Status: pid 31718 exit 2>
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="at"></a>
      <code class="btn btn-large disabled"><strong>$@</strong></code>
      <span class="code">Array === $@ unless $@.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span> <span class="label label-info">thread-local</span>  <strong>Shorthand to <code>$!.backtrace</code></strong><br>
    Locals to the <code>rescue</code> clause.</p>
{% highlight ruby %}
> 0 / 0 rescue $!
# ⇒ [
#  [ 0] "(pry):7:in `/'",
#  [ 1] "(pry):7:in `__pry__'",
#  …
#  [23] "/…/bin/ruby_noexec_wrapper:14:in `<main>'"
# ]
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="backslash"></a>
      <code class="btn btn-large disabled"><strong>$\</strong></code>
      <span class="code">String === $\ unless $\.nil?</span>
  </td>
  <td>
    <p><span class="label label-success">read-write</span>  <strong>Appended to <code>Kernel.print</code> output.</strong><br>
    Defaults to <code>nil</code>, or to <a href="#slash"><code>$/</code></a> if the <code>-l</code> switch was given.</p>
{% highlight ruby %}
> $\='%'
# ⇒ "%"
> print 'foo', 'bar', 'baz'
# ⇒ %foobarbaz%=> nil
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="underscore"></a>
      <code class="btn btn-large disabled"><strong>$_</strong></code>
      <span class="code">String === $_ unless $_.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span> <span class="label label-info">thread-local</span>  <strong>Last <code>String</code> read from <code>IO</code>
     by one of <code>Kernel.gets</code>, <code>Kernel.readline</code> or siblings.</strong><br>
    Widely used with <a href="#minus-p-small"><code>-p</code></a> and <a href="#minus-n-small"><code>-n</code></a> switches.</p>
{% highlight ruby %}
> gets
foo
# ⇒ "foo\n"

> $_
# ⇒ "foo\n"
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="backtick"></a>
      <code class="btn btn-large disabled"><strong>$`</strong></code>
      <span class="code">String === $` unless $`.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span> <span class="label label-info">thread-local</span>  <strong>The
      rest of the string <em>before</em> the matched substring in the previous successful pattern match.</strong><br>
    Locals to the pattern match scope.</p>
{% highlight ruby %}
> "foo bar baz".match /bar|baz/
# ⇒ <MatchData "bar">
> $`
# ⇒ "foo "

> "foo bar baz".gsub /foo|bar|baz/, 'ggg'
# ⇒ "ggg ggg ggg"
> $`
# ⇒ "foo bar "

> "foo bar baz".match /foobarbaz/
# ⇒ nil
> $`
# ⇒ nil
{% endhighlight %}
</td>
</tr>
<tr>
  <td class="tooltipable">
      <a id="tilde"></a>
      <code class="btn btn-large disabled"><strong>$~</strong></code>
      <span class="code">MatchData === $~ unless $~.nil?</span>
  </td>
  <td>
    <p><span class="label label-important">read-only</span> <span class="label label-info">thread-local</span>  <strong>The
      <code>MatchData</code> from the previous successful pattern match.</strong><br></p>
{% highlight ruby %}
> "abc12def34ghijklmno567pqrs".gsub (/\d+/) { |m| p $~ }
# ⇒ <MatchData "12">
# ⇒ <MatchData "34">
# ⇒ <MatchData "567">
{% endhighlight %}
</td>
</tr>
</tbody>
</table>
</div>

Credits to [Jim Neath](http://jimneath.org/2010/01/04/cryptic-ruby-global-variables-and-their-meanings.html) and
[runpaint](http://ruby.runpaint.org/globals), some examples came from these posts.
