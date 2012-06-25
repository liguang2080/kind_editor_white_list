# -*- encoding : utf-8 -*-
require "set"
module WhiteListHelper
  extend self
  PROTOCOL_ATTRIBUTES = Set.new %w(src href)
  PROTOCOL_SEPARATOR  = /:|(&#0*58)|(&#x70)|(%|&#37;)3A/

  [:bad_tags, :tags, :attributes, :protocols].each do |attr|
    klass = class << self; self; end
    klass.send(:define_method, "#{attr}=") { |value| class_variable_set("@@#{attr}", Set.new(value)) }
    define_method("white_listed_#{attr}") { ::WhiteListHelper.send(attr) }
    mattr_reader attr
  end

  # This White Listing helper will html encode all tags and strip all attributes that aren't specifically allowed.  
  # It also strips href/src tags with invalid protocols, like javascript: especially.  It does its best to counter any
  # tricks that hackers may use, like throwing in unicode/ascii/hex values to get past the javascript: filters.  Check out
  # the extensive test suite.
  #
  #   <%= white_list @article.body %>
  # 
  # You can add or remove tags/attributes if you want to customize it a bit.
  # 
  # Add table tags
  #   
  #   WhiteListHelper.tags.merge %w(table td th)
  # 
  # Remove tags
  #   
  #   WhiteListHelper.tags.delete 'div'
  # 
  # Change allowed attributes
  # 
  #   WhiteListHelper.attributes.merge %w(id class style)
  # 
  # white_list accepts a block for custom tag escaping.  Shown below is the default block that white_list uses if none is given.
  # The block is called for all bad tags, and every text node.  node is an instance of HTML::Node (either HTML::Tag or HTML::Text).  
  # bad is nil for text nodes inside good tags, or is the tag name of the bad tag.  
  # 
  #   <%= white_list(@article.body) { |node, bad| white_listed_bad_tags.include?(bad) ? nil : node.to_s.gsub(/</, '&lt;') } %>
  #
  def white_list(html, options = {}, &block)
    return html if html.blank? || !html.include?('<')
    attrs   = Set.new(options[:attributes]).merge(white_listed_attributes)
    tags    = Set.new(options[:tags]      ).merge(white_listed_tags)
    block ||= lambda { |node, bad| white_listed_bad_tags.include?(bad) ? nil : node.to_s.gsub(/</, '&lt;') }
    [].tap do |new_text|
      tokenizer = HTML::Tokenizer.new(html)
      bad       = nil
      while token = tokenizer.next
        node = HTML::Node.parse(nil, 0, 0, token, false)
        new_text << case node
          when HTML::Tag
            unless tags.include?(node.name)
              bad = node.name
              block.call node, bad
            else
              bad = nil
              if node.closing != :close
                node.attributes.delete_if do |attr_name, value|
                  !attrs.include?(attr_name) || (PROTOCOL_ATTRIBUTES.include?(attr_name) && contains_bad_protocols?(value))
                end if attributes.any?
              end
              node
            end
          else
            block.call node, bad
        end
      end
    end.join
  end
  
  protected
    def contains_bad_protocols?(value)
      value =~ PROTOCOL_SEPARATOR && !white_listed_protocols.include?(value.split(PROTOCOL_SEPARATOR).first)
    end
end

WhiteListHelper.bad_tags   = %w(script)
WhiteListHelper.tags       = %w(h1 h2 h3 h4 h5 h6 table tr th td thead tbody tfoot a blockquote br caption cite code dl dt dd em i img li ol p pre q small strike strong b sub sup u ul span font div embed)
WhiteListHelper.attributes = %w(target name src type loop autostart quality allowscriptaccess alt title color size face class cellspacing cellpadding href title cite src alt width height align valign colspan rowspan bgcolor style border)
WhiteListHelper.protocols  = %w(ed2k ftp http https irc mailto news gopher nntp telnet webcal xmpp callto feed)
