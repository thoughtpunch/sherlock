require 'domainatrix'
require 'nokogiri'
require 'ruby-readability'
include Sherlock::Utils::String_Utils
include Sherlock::Utils::Text_Utils
include Sherlock::Utils::URL_Utils

module Sherlock
  class HTML

    attr_reader :url, :host, :html, :params

    def initialize(url,html)
      @url = url #need for absolute link,img refs
      @host = Domainatrix.parse(url).host
      @html = html
      @title,@text,@images,@links,@author,@date = nil
      @params = parse_url_params(url)
    end

    #Returns an array of sanitized URL's from the content.
    # Note, this will not return internal anchors or null links
    def links
      return @links if (defined?(@links) && !@links.nil?)
      @links = Nokogiri::HTML.parse(@html).css('a')
      @links = @links.map {|link| link.attribute('href').to_s}
      @links = @links.delete_if{ |link| (link.nil? || link.to_s == '') }

      # remove non-HTTP links
      @links = @links.delete_if{|x| x if !x.match("http")}

      # handle HTTP redirect links
      # i.e. 'http://www.google.com/?=http://www.cats.com'
      @links = @links.map{|x| "http" + x.split("http").last}.compact

      # Remove URL params from links
      @links = @links.map{|x| x.split(/\?|\&/).first}.compact

      # Sanitize links
      @links = @links.map{|x| URI.decode(x).downcase.strip}.compact

      # Remove link proxies(i.e. from Google) & decode URI again
      if url.match(/google\.com/i)
        @links = @links.map{|x| x.split("%2b").first}.compact
        @links = @links.map{|x| URI.decode(x).downcase.strip}.compact
      end

      return @links.uniq
    end

    #Returns images from the content
    def images
      return @images if (defined?(@images) && !@images.nil?)
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
      @author ||= Readability::Document.new(@html).author
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
      @title ||= (Nokogiri::HTML.parse(@html).title).to_s.gsub(/\n|\t|\r/,"")
    end

    #Returns the text content from the HTML
    def text
      return @text if (defined?(@text) && !@text.nil?)
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

      filter_param = (self.params[:q] || self.params[:query] || self.params[:search])

      if filter_param
        @text = @text.split.map{|x| x.split(/(#{filter_param})/i).each_slice(2).map(&:join)}.flatten.join(" ")
      end

      return @text
    end

  end
end