require 'faraday'
require 'faraday_middleware'
require 'typhoeus/adapters/faraday'

module Sherlock

  #this should only fetch the item and return the result + status
  class Client

    attr_accessor :uri
    attr_reader :status,:content,:headers,:error,:request,:fetched

    def initialize uri
      @uri = uri
      @status,@content,@headers,@error,@request,@fetched = nil
    end

    def uri=(uri)
      @uri = uri
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

  end

end