require 'uri'
require 'domainatrix'
require 'nokogiri'
require 'ruby-readability'
include Sherlock::Utils::HTTP_Utils
include Sherlock::Utils::String_Utils

module Sherlock
  class HTTP
    EXTERNAL    = %r(\.(com|edu|gov|net|biz|org)$)
    FILES       = %r(\.(jpg|pdf|gif|mpg|png))
    META_PAGES  = %r(\/(page[s]?|about|contact|bio|tag[s]?|keywords[s]?|
                        staff|people|member[s]?|course[s]?|cart|item[s]|
                        marketplace|manifesto|privacy|team|platform|
                        categor[y|ies]|author[s]?)(\/|$))

    def initialize(url,html)
      @url  = url
      @html = html
      @title,@text,@images,@links,@author,@date = nil
    end

    #SELF INSPECTING METHODS
    def meta_page?
      @url.match(META_PAGES) ? true : false
    end 

    def external_url?
      @url.match(EXTERNAL_URLS) ? true : false
    end

    def file_url?
      @url.match(FILES) ? true : false
    end

    #SCRAPE/CONTENT RETRIEVAL METHODS
    def links
      links = Nokogiri::HTML.parse(@html).css('a')
      hrefs = links.map {|link| link.attribute('href').to_s}

      # remove non-HTTP links
      hrefs = hrefs.delete_if{|x| x if !x.match("http")}

      # handle HTTP redirect links
      # i.e. 'http://www.google.com/?=http://www.cats.com'
      hrefs = hrefs.map{|x| "http" + x.split("http").last}.compact
      
      # Remove URL params from links
      hrefs = hrefs.map{|x| x.split(/\+|\?|\&|\=/).first}.compact

      # Sanitize links
      hrefs = hrefs.map{|x| URI.decode(x).downcase.strip}.compact
      
      # Remove URL params from links again
      hrefs = hrefs.map{|x| x.split(/\+|\?|\&|\=/).first}.compact.uniq
      return hrefs
    end

    def images
      @images = []
      imgs = Nokogiri::HTML.parse(@html).css("img")
      imgs.each do |img|
        if img.attributes["src"] && (!img.attributes["src"].value.match("data:image"))
          @images << URI.encode("#{host}#{img.attributes["src"].value}").gsub(/^.+http/,"http")
        end
      end
      return @images
    end
    
    def author
      Readability::Document.new(@html).author
    end

    def url_date
      #try to get the date from the url
      if %r{([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})}.match(@url)
        return %r{([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})}.match(@url).captures.join.to_date
      elsif %r{([A-Za-z]+)(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([A-Za-z]+)}.match(@url)
        return (%r{([A-Za-z]+)(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([A-Za-z]+)}.match(@url).captures.join.gsub(/[A-Za-z]/,"") + "01").to_date
      end
    end

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

    def title
      @title = (Nokogiri::HTML.parse(@html).title).to_s.gsub(/\n|\t|\r/,"")
    end

    def text
      content = Readability::Document.new(@html).content #segfaults be damned

      if content && !content.empty?
        #this is reaalll dirty...but it mostly works
        @text = encode_utf8_with_extreme_prejudice(@html).
                   gsub(/\&\w+\;|\<\S+|\s\>|\"|\\n|\/|\\r|\u0093|\u0094/, " "). #remove HTML tags and wierd Unicode charecters
                   scan(/([\w+\s+\:\-\(\)\?\.\,\"\'\/\`\$\u2013\u2019\u201C\u201D\!\\xC2\\xA0]{300,})/).join. #scan for blocks of text with punctuation 300+ chars
                   gsub(/\xC2\xA0/, " ").gsub(/\?/, "? ").gsub(/\s\?/, "?").gsub(/\!/, "! ").gsub(/\./, ". "). #fix broken punctuation
                   gsub(/\:/, ": ").gsub(/[A-Z]\w/, ' \0').gsub(/\s{2,}/, " ").gsub(/[A-Za-z0-9]{30,}/,"") #fix even more punctuation, remove extraneous data
      else
        #even the Readability text has HTML in it. Remove it.
        @text = encode_utf8_with_extreme_prejudice(Nokogiri::HTML(url_text).text).
                  gsub(/\xC2\xA0/, " ").gsub(/\?/, "? ").gsub(/\s\?/, "?").
                  gsub(/\!/, "! ").gsub(/\:/, ": ").gsub(/[A-Z]\w/, ' \0').
                  gsub(/\s{2,}/, " ")
      end
      return @text
    end

    def search_text
      remove_punctuation_from_string(@text)
    end

    private
    def titleize_uri
      if @url.match(/http/)
        return @uri.split(/\//).sort_by{|x| x.length}.last.titleize rescue ""
      end
    end

  end
end