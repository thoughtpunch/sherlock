require 'uri'
require 'domainatrix'
include Sherlock::Utils::URI_Utils

module Sherlock
  class Inspector

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
    end

    #STATUS METHODS
    def exists?
      
    end

    def redirected?
      @client.status && @client.status.to_s.match(/^3[0-9]{2}/)
    end

    def success?
      @client.status && @client.status.to_s.match(/^2[0-9]{2}/)
    end

    def fetched?
      @client.fetched
    end

  end
end
