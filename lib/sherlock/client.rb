require 'faraday'
require 'faraday_middleware'
require 'typhoeus/adapters/faraday'
include Sherlock::Utils::HTTP_Utils

module Sherlock
  class Client

    SUPPORTED_REQUEST_METHODS = ["get","head","options"]

    attr_accessor :uri,:request_method
    attr_reader :status,:content,:headers,:error,:response,:fetched,:cookie

    def initialize(uri,request_method="get")
      @uri = uri
      @request_method = request_method
      @fetched = false
      @status,@content,@headers,@error,@response = nil
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
      @response.env[:url].to_s if @response
    end

    def fetch
      connection = Faraday.new(@uri) do |conn|
        conn.use      FaradayMiddleware::FollowRedirects
        conn.adapter  :typhoeus
      end

      begin
        @response = connection.instance_eval(@request_method)
      rescue Exception => ex 
        @error = ex
        @response = connection.head
      end

      @status  = @response.status
      @content = @response.success? ? @response.body : nil
      @headers = header_to_mash(@response.headers)
      @cookie  = cookie_to_mash(@response.headers)
      @fetched = true
      return self
    end

  end

end