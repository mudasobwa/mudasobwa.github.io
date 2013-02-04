# encoding: utf-8

require 'cgi'

module RocketScience
  module Liquid
    class QuoteTag < ::Liquid::Tag
      def initialize(tag_name, quote, tokens)
        @quote, @title, @href = CGI.escapeHTML(quote).split('×')
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


