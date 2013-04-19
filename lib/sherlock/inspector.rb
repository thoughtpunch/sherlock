require 'uri'
require 'domainatrix'
include Sherlock::Utils::URI_Utils

module Sherlock
  class Inspector

    EXTERNAL    = %r(\.(co(op|m|\.uk)?|(in(t|fo)?)|net|org|edu||mil|name|gov|arpa|biz|aero|name|pro|museum|uk|me)$)
    FILES       = /(avi|css|doc|exe|gif|html|htm|jpg|jpeg|js|midi|mp3|mov|mpg|mpeg|pdf|png|rar|tiff|txt|wav|zip)$/i
    META_PAGES  = %r(\/(page[s]?|about|contact|bio|tag[s]?|keywords[s]?|
                        staff|people|member[s]?|course[s]?|cart|item[s]|
                        marketplace|manifesto|privacy|team|platform|
                        categor[y|ies]|author[s]?)(\/|$))

    attr_reader :uri,:status,:scheme,:fetched,:host,:domain,:path,
                :port,:params,:client

    def initialize(uri)
      #validate uri and raise errors if needed
      validate_uri(uri)

      @uri       = sanitize_uri(uri)
      parsed_uri = Domainatrix.parse(@uri)
      @scheme  ||= parsed_uri.scheme
      @host    ||= parsed_uri.host
      @domain  ||= parsed_uri.domain
      @path    ||= parsed_uri.path
      @port    ||= parse_port(@uri)
      @params  ||= parse_uri_params(@uri)
      @client  ||= Sherlock::Client.new(@uri)
      @content ||= nil
    end

    #STATUS METHODS
    def exists?
      if @client.status
        !@client.status.to_s.match(/^4[0-9]{2}/) ? true : false
      end
    end

    def redirected?
      if @client.status
        @client.status.to_s.match(/^3[0-9]{2}/) ? true : false
      end
    end

    def success?
      if @client.status
        @client.status.to_s.match(/^2[0-9]{2}/) ? true : false
      end
    end

    #CURRENTLY ONLY SUPPORTING HTTP/HTTPS
    def fetchable?
      @scheme.downcase.to_s.match(/http/) ? true : false
    end

    def fetched?
      @client.fetched.eql?(true) ? true : false
    end

    #SELF INSPECTING METHODS
    def meta_page?
      @uri.match(META_PAGES) ? true : false
    end 

    def external_url?
      @uri.match(EXTERNAL_URLS) ? true : false
    end

    def file_url?
      @uri.match(FILES) ? true : false
    end

  end
end
