require 'faraday'
require 'faraday_middleware'
require 'typhoeus/adapters/faraday'

module Sherlock

  class Client

    SUPPORTED_REQUEST_METHODS = ["get","head","options"]

    attr_accessor :uri,:request_method
    attr_reader :status,:content,:headers,:error,:request,:fetched

    def initialize(uri,request_method="get")
      @uri = uri
      @request_method = request_method
      @fetched = false
      @status,@content,@headers,@error,@request = nil
    end

    def uri=(uri)
      @uri = uri
      fetch
    end

    def request_method=(request_method)
      if SUPPORTED_REQUEST_METHODS.include?(request_method)
        @request_method = request_method
        fetch
      else
        raise "Only the following HTTP methods are supported: 'get','head','options'"
      end
    end

    def root_uri
      if @request
        return @request.env[:url].to_s
      end
    end

    def fetch
      connection = Faraday.new(@uri) do |conn|
        conn.use      FaradayMiddleware::FollowRedirects
        conn.adapter  :typhoeus
      end

      begin
        @request = connection.instance_eval(@request_method)
      rescue Exception => ex 
        @error = ex
        @request = connection.head
      end

      @status  = @request.status
      @content = @request.success? ? @request.body : nil
      @headers = @request.headers
      @fetched = true
      return self
    end

  end

end