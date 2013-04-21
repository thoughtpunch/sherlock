require 'faraday'
require 'faraday_middleware'
require 'typhoeus/adapters/faraday'
include Sherlock::Utils::HTTP_Utils

module Sherlock
  class Client

    SUPPORTED_REQUEST_METHODS = ["get","head"]

    attr_accessor :url,:request_method
    attr_reader :status,:content,:headers,:error,:response,:fetched,:cookie

    def initialize(url,request_method="get")
      @url = url
      @request_method = request_method
      @fetched = false
      @status,@content,@headers,@error,@response = nil
    end

    def url=(url)
      @url = url
      fetch
    end

    def request_method=(request_method)
      if SUPPORTED_REQUEST_METHODS.include?(request_method)
        @request_method = request_method
        fetch
      else
        raise ArgumentError,"Only the following HTTP methods are supported: 'get','head'"
      end
    end

    #Return the last url in a redirect chain (i.e. after unpacking a shortened URL)
    def root_url
      @response.env[:url].to_s if @response
    end

    #Fetches the URL
    def fetch
      connection = Faraday.new(@url) do |conn|
        conn.use      FaradayMiddleware::FollowRedirects,:limit=>5
        conn.adapter  :typhoeus
      end

      begin
        @response = connection.instance_eval(@request_method)
      rescue Exception => ex 
        @error = ex
        @response = connection.head
      end

      @status  = @response.status
      @headers = headers_to_mash(@response.headers)
      @content = appropriate_content_for_type
      @cookie  = cookie_to_mash(@response.headers)
      @fetched = true
      return self
    end

    private
    def appropriate_content_for_type
      case @headers.content_type 
      when /html/i
        Sherlock::HTML.new(@url,@response.body)
      when /json/i
        Sherlock::JSON.new(@url,@response.body)
      else
        @response.body
      end
    end

  end

end