require 'uri'
require 'domainatrix'


module Sherlock
  class Inspector
    include Sherlock::Utils::URL_Utils

    attr_accessor :url,:client
    attr_reader   :scheme,:fetched,:host,:domain,:path,:port,:params

    def initialize(url)
      setup_inspector(url)
    end

    def url=(url)
      setup_inspector(url)
    end

    #STATUS METHODS
    def exists?
      fetch_url_with_method('head')
      !@client.status.to_s.match(/^4[0-9]{2}/) ? true : false
    end

    def redirected?
      fetch_url_with_method('head')
      @client.status.to_s.match(/^3[0-9]{2}/) ? true : false
    end

    def success?
      fetch_url_with_method('head')
      @client.status.to_s.match(/^2[0-9]{2}/) ? true : false
    end

    #CURRENTLY ONLY SUPPORTING HTTP/HTTPS
    def fetchable?
      @scheme.downcase.to_s.match(/http/) ? true : false
    end

    def fetched?
      @client.fetched.eql?(true) ? true : false
    end

    def fetch
      @client.fetch
      @content = @client.content
      return self
    end

    private
    def fetch_url_with_method(request_method)
      if !fetched? && (@client.request_method != request_method)
        @client.request_method = request_method
      end
      return true
    end

    def setup_inspector(url)
      validate_url(url)
      @url       = sanitize_url(url)
      parsed_url = Domainatrix.parse(@url)
      @scheme    = parsed_url.scheme
      @host      = parsed_url.host
      @domain    = parsed_url.domain
      @path      = parsed_url.path
      @port      = parse_port(@url)
      @params    = parse_url_params(@url)
      @client    = Sherlock::Client.new(@url)
      @content   = @client.content
    end

    def method_missing(method_name, *args, &block)
      if @client.respond_to?(method_name)
        return @client.send(method_name, *args, &block)
      elsif @content.respond_to?(method_name)
        return @content.send(method_name, *args, &block)
      else
        return super
      end
    end
  end
end
