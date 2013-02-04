# encoding: utf-8

module RocketScience
  module Liquid
    class QuoteTag < ::Liquid::Tag
      def initialize(tag_name, quote, title, href, tokens)
        @quote = quote.strip
        @title = title.strip
        @href  = href.strip
        super
      end
      
      def render(context)

        <<MARKUP.strip
<blockquote>
<p>#{@quote}</p>
<small><a href='#{@href}'>#{@title}</a></small>
</blockquote>
MARKUP
      end
    end
  end
end

Liquid::Template.register_tag('quote', RocketScience::Liquid::QuoteTag)


