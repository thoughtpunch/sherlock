require 'uri'
require 'domainatrix'
require 'nokogiri'
require 'ruby-readability'
include Sherlock::Utils::HTTP_Utils

module Sherlock
  class HTTP
    EXTERNAL    = %r(\.(com|edu|gov|net|biz|org)$)
    FILES       = %r(\.(jpg|pdf|gif|mpg|png))
    META_PAGES  = %r(\/(page[s]?|about|contact|bio|tag[s]?|keywords[s]?|
                        staff|people|member[s]?|course[s]?|cart|item[s]|
                        marketplace|manifesto|privacy|team|platform|
                        categor[y|ies]|author[s]?)(\/|$))

    def initialize url
      @url = url
    end

    #SELF INSPECTING METHODS
    def meta_page?
      @url.match(META_PAGES) ? true : false
    end 

    def external_url?
      self.url.match(EXTERNAL_URLS) ? true : false
    end

    def file_url?
      self.url.match(FILES) ? true : false
    end

    #SCRAPE/CONTENT RETRIEVAL METHODS
    def links
      fetch
      if success?
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
    end

    def images
      fetch
      if success?
        @images = []
        imgs = Nokogiri::HTML.parse(@html).css("img")
        imgs.each do |img|
          if img.attributes["src"] && (!img.attributes["src"].value.match("data:image"))
            @images << URI.encode("#{host}#{img.attributes["src"].value}").gsub(/^.+http/,"http")
          end
        end
        return @images
      end
    end
    
    def author
      fetch
      (@html && !@html.blank?) ? Readability::Document.new(@html).author : "unknown"
    end

    def date
      #try to get the date from the url
      if %r{([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})}.match(@url)
        return %r{([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})}.match(@url).captures.join.to_date
      elsif %r{([A-Za-z]+)(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([A-Za-z]+)}.match(@url)
        return (%r{([A-Za-z]+)(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([A-Za-z]+)}.match(@url).captures.join.gsub(/[A-Za-z]/,"") + "01").to_date
      # else #trying to find date from webpage
      #   parsed_html = Nokogiri::HTML.parse(@html).text.encode!('utf-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '').gsub(/\&\w+\;|\<\S+|\s\>|\"|\\n|\/|\\r|\u0093|\u0094/, " ").gsub(/\s+/, " ").downcase
      #   regex = %r{(([0-9|\s]*)(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*[0-9|\s|\,]{2,})}
      #   possible_match = parsed_html.scan(regex).first
      #   if possible_match
      #     possible_match.delete_if{|x| x.empty? || x.scan(/[0-9]/).empty?}.compact
      #     return possible_match
      #   end
      end
    end

    def title
      fetch
      if success?
        @title = (Nokogiri::HTML.parse(@html).title).to_s.gsub(/\n|\t|\r/,"")
        if @title && !@title.blank? && (@title.length > 5)
          return @title
        else
          return URI.decode(@path).gsub(/\/$/,"").scan(/\/[^\/]+$/).first.downcase.gsub(/[^a-z]/," ").strip.gsub(/\s{1,}/," ").titleize
        end
      end
    end

    def text
      return @text unless @text.nil?
      begin
        fetch
        if success? && !(@url.include?(".pdf"))

          url_text = Readability::Document.new(@html).content #segfaults be damned

          if url_text.blank?
            sub = @html.encode!('utf-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '').gsub(/\&\w+\;|\<\S+|\s\>|\"|\\n|\/|\\r|\u0093|\u0094/, " ").gsub(/\s+/, " ")
            matches = sub.scan(/([\w+\s+\:\-\(\)\?\.\,\"\'\/\`\$\u2013\u2019\u201C\u201D\!\\xC2\\xA0]{300,})/)
            joined = matches.join.encode!('utf-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '')
            @text = joined.gsub(/\xC2\xA0/, " ").gsub(/\?/, "? ").gsub(/\s\?/, "?").gsub(/\!/, "! ").gsub(/\./, ". ").gsub(/\:/, ": ").gsub(/[A-Z]\w/, ' \0').gsub(/\s{2,}/, " ").gsub(/[A-Za-z0-9]{30,}/,"")
          else
            text = Nokogiri::HTML(url_text).text.encode!('utf-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '')
            @text = text.gsub(/\xC2\xA0/, " ").gsub(/\?/, "? ").gsub(/\s\?/, "?").gsub(/\!/, "! ").gsub(/\:/, ": ").gsub(/[A-Z]\w/, ' \0').gsub(/\s{2,}/, " ")
          end
          return @text
        end
      rescue
        nil
      end
    end

    def search_text
      fetch
      if success? && !text.blank?
        remove_punctuation = Proc.new{|text| text.downcase.gsub(/\'|[0-9]/,"").gsub(/\W+/," ").strip}
        (@text.blank? || @text.nil?) ? remove_punctuation.call(text) : remove_punctuation.call(@text)
      end
    end

  end

end