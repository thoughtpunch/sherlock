require 'domainatrix'
require 'nokogiri'
require 'ruby-readability'
include Sherlock::Utils::String_Utils

module Sherlock
  class HTML

    def initialize(url,html)
      @url = url #need for absolute link,img refs
      @html = html
      @title,@text,@images,@links,@author,@date = nil
    end

    #Returns an array of sanitized URL's from the content.
    # Note, this will not return internal anchors or null links
    def links
      links = Nokogiri::HTML.parse(@html).css('a')
      hrefs = links.map {|link| link.attribute('href').to_s}

      # remove non-HTTP links
      hrefs = hrefs.delete_if{|x| x if !x.match("http")}

      # handle HTTP redirect links
      # i.e. 'http://www.google.com/?=http://www.cats.com'
      hrefs = hrefs.map{|x| "http" + x.split("http").last}.compact
      
      # Remove URL params from links
      hrefs = hrefs.map{|x| x.split(/\?|\&/).first}.compact

      # Sanitize links
      hrefs = hrefs.map{|x| URI.decode(x).downcase.strip}.compact
      
      return hrefs.uniq
    end

    #Returns images from the content
    def images
      @images = []
      imgs = Nokogiri::HTML.parse(@html).css("img")
      imgs.each do |img|
        if img.attributes["src"] && (!img.attributes["src"].value.match("data:image"))
          if !img.attributes["src"].value.match(/http/)
            @images << URI.encode("#{@url}#{img.attributes["src"].value}")
          else
            @images << URI.encode("#{img.attributes["src"].value}").gsub(/^.+http/,"http")
          end
        end
      end
      return @images
    end
    
    #Returns the likely author of the content
    def author
      Readability::Document.new(@html).author
    end

    #Returns the first explicit date in the content. Usually, but not always
    # this is the publish/creation/post date of the content
    def content_date
      #trying to find date from webpage
      #   parsed_html = Nokogiri::HTML.parse(@html).text.encode!('utf-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '').gsub(/\&\w+\;|\<\S+|\s\>|\"|\\n|\/|\\r|\u0093|\u0094/, " ").gsub(/\s+/, " ").downcase
      #   regex = %r{(([0-9|\s]*)(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*[0-9|\s|\,]{2,})}
      #   possible_match = parsed_html.scan(regex).first
      #   if possible_match
      #     possible_match.delete_if{|x| x.empty? || x.scan(/[0-9]/).empty?}.compact
      #     return possible_match
      #   end
    end

    #Returns the HTML title
    def title
      @title = (Nokogiri::HTML.parse(@html).title).to_s.gsub(/\n|\t|\r/,"")
    end

    #Returns the text content from the HTML
    def text
      content = Readability::Document.new(@html).content #segfaults be damned

      if content.nil? || content.empty?
        #this is reaalll dirty...but it mostly works
        @text = encode_utf8_with_extreme_prejudice(@html).
                   gsub(/\&\w+\;|\<\S+|\s\>|\"|\\n|\/|\\r|\u0093|\u0094|\n|\r|\t/, " "). #remove HTML tags and wierd Unicode charecters
                   scan(/([\w+\s+\:\-\(\)\?\.\,\"\'\/\`\$\u2013\u2019\u201C\u201D\!\\xC2\\xA0]{300,})/).join. #scan for blocks of text with punctuation 300+ chars
                   gsub(/\xC2\xA0/, " ").gsub(/\?/, "? ").gsub(/\s\?/, "?").gsub(/\!/, "! ").gsub(/\./, ". "). #fix broken punctuation
                   gsub(/\:/, ": ").gsub(/[A-Z]\w/, ' \0').gsub(/\s{2,}/, " ").gsub(/[A-Za-z0-9]{30,}/,"") #fix even more punctuation, remove extraneous data
      else
        #even the Readability text has HTML in it. Remove it.
        @text = (Nokogiri::HTML(content).text).gsub(/\n|\t|\r/,"").gsub(/\?/, "? ").gsub(/\s\?/, "?").
                  gsub(/\!/, "! ").gsub(/\:/, ": ").gsub(/\s{2,}/, " ")
      end
      return @text
    end

    # Returns the HTML content text without punctuation or special charectoers.
    # - Useful for searching against search indexes, text analyzers, etc
    def search_text
      remove_punctuation_from_string(@text)
    end

  end
end