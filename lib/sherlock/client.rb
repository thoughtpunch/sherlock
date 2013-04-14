require 'faraday'
require 'faraday_middleware'
require 'typhoeus/adapters/faraday'

module Sherlock

  class Client

    SUPPORTED_REQUEST_METHODS = ['GET','HEAD','TRACE','OPTIONS']

    attr_accessor :uri,:request_method
    attr_reader :status,:content,:headers,:error,:request,:fetched

    def initialize uri,request_method='get'
      @uri = uri
      @request_method = request_method
      @status,@content,@headers,@error,@request,@fetched = nil
    end

    def uri=(uri)
      @uri = uri
      fetch
    end

    def request_method=(request_method)
      @request_method = request_method
      fetch
    end

    def fetch
      connection = Faraday.new(@uri) do |conn|
        conn.use      FaradayMiddleware::FollowRedirects
        conn.adapter  :typhoeus
      end

      begin
        @request = connection.get
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

    # def update_uri_on_redirect
    #   if status.redirected?
    #     #update @uri with the real uri
    #     p "REDIRECTED"
    #   end
    # end

  end

end