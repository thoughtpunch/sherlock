require 'json'
require 'hashie'

module Sherlock
  class JSON

    attr_reader :json

    def initialize(url,json)
      @url = url
      @json = JSON.parse(json)
    end

  end
end