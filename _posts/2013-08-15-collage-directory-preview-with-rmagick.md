---
layout: post
title: "Collage directory preview with RMagick"
description: "Monkeypatch for RMagick to produce collages"
category: hacking
tags: [ruby, tricks]
---
{% include JB/setup %}

Just before my last trip I have finally decided to issue daily reports. Not to forget the impressions
as well as to share my experiences with friends. The scenario I foresaw was: all the day I make photos,
then reach a hotel with Wifi internet, pick out a dozen of best views and publish.

It’s worth to mention that I have chosen a jekyll successor, the [ruhoh](http://ruhoh.com) publishing
system. I only needed a handy script to quickly produce a new blog entry by the directory with today photos.
Plus I wanted a collage to be put as a post preview.

There is an [ImageMagick](http://imagemagick.org) wrapper for Ruby: [RMagick](http://rmagick.rubyforge.org).
The only problem remained: I still needed to produce the collage by hands. So, I decided to monkeypatch the library.
Below goes the code of the patch:

{% highlight ruby %}
require 'RMagick'

module Magick
  class ImageList
    def self.preview files, options={}
      options = {
        :columns       => 5,              # number of columns in collage
        :scale_range   => 0.1,            # ± to the thumb width
        :thumb_width   => 120,            # the width of thumbnail
        :rotate_angle  => 20,             # maximal rotate angle
        :background    => 'white',        # background of the collage
        :border        => 'gray20'        # border color
      }.merge(options)
      # Produce collage from all the files in directory
      files = "#{files}/*" if File.directory?(files)
      imgs = ImageList.new
      # The placeholder for collage borders
      imgnull = Image.new(options[:thumb_width],options[:thumb_width]) {
        self.background_color = 'transparent'
      }
      # Top row
      (options[:columns]+2).times { imgs << imgnull.dup }
      Dir.glob("#{files}") { |f|
        Image::read(f).each { |i| 
          scale = (1.0 + options[:scale_range]*Random::rand(-1.0..1.0))*options[:thumb_width]/[i.columns, i.rows].max
          # Placeholder if that’s the first column
          imgs << imgnull.dup if (imgs.size % (options[:columns]+2)).zero?
          imgs << i.auto_orient.thumbnail(scale).polaroid(
            Random::rand(-options[:rotate_angle]..options[:rotate_angle])
          )
          # Placeholder if that’s the last columns
          imgs << imgnull.dup if (imgs.size % (options[:columns]+2)) == options[:columns]+1
        } rescue puts "Skipping error: #{$!}"  # simply skip non-image files
      }
      # Fill the last row
      (2*options[:columns]+4-(imgs.size % (options[:columns]+2))).times { imgs << imgnull.dup }
      imgs.montage { 
        self.tile             = Magick::Geometry.new(options[:columns]+2) 
        self.geometry         = "-#{options[:thumb_width]/5}-#{options[:thumb_width]/4}"
        self.background_color = options[:background]
      }.trim(true).border(10,10,options[:background]).border(1,1,options[:border])
    end
  end
end
{% endhighlight %}

The only noticable piece of code here is the stuff with `imgnull`. Since I rotate the thumbnails, I need to
preserve a sufficient place around the resulting montaged image. The function may be called with:

{% highlight ruby %}
Magick::ImageList::preview(IMGS_DIR, :thumb_width=>200).write COLLAGE.jpg
{% endhighlight %}

Resulting in smth like:

![Collage](/img/collage.jpg)
