require 'uri'
require 'domainatrix'
require 'sherlock/utils/uri_utils'

#This is the 'Client' class. It returns basic info about a given URI
# If it actually fetches the URI, it returns an 'Item' class
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

    #Raise an error unless a valid URI
    def validate_uri(uri)
      if uri !~ /\:/
        msg = "URI has no scheme (i.e. 'http', 'ftp', 'smtp')"
      elsif uri !~ /\/\//
        msg = "URI missing start of hierarchical segment '//'"
      elsif !(uri =~ URI::regexp)
        msg = "URI does not appear to be valid"
      end
      msg ? (raise URI::InvalidURIError, msg) : true
    end

    #Parse params from URI, return as hash
    def parse_uri_params(uri)
      parsed_params = {}

      possible_params = uri.split(/\?|\&/).delete_if{|x| !x.match(/\=/)}

      unless possible_params.nil? || possible_params.empty?
        possible_params.each do |prm|
          param = prm.split(/\=/)
          parsed_params[param[0].to_sym] = param[1]
        end
        return parsed_params
      end
    end

    #Parse port from the URI, otherwise nil
    def parse_port(uri)
      port = uri.scan(/\:[0-9]+/).first
      port ? port.gsub(":","").to_i : nil
    end

    def sanitize_uri(uri)
      URI.decode(uri.to_s).downcase.strip
    end

    def update_uri_on_redirect
      if status.redirected?
        #update @uri with the real uri
        p "REDIRECTED"
      end
    end
  end
end
