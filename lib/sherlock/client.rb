require 'typhoeus'
require 'faraday'
require 'faraday_middleware'

module Sherlock

  #this should only fetch the item and return the result + status
  class Client

    def self.fetch(uri)
      connection = Faraday.new(uri) do |conn|
        conn.use      FaradayMiddleware::FollowRedirects
        conn.adapter  :typhoeus
      end

      begin
        @request = connection.get
      rescue Exception => ex 
        @error = ex
        @request = connection.head
      end

      @status  = @request.try(:status)
      @html    = @request.success? ? @request.body : nil
      @headers = @request.headers

    end

  end

end