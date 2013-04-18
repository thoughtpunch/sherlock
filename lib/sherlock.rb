require "sherlock/version"
require 'sherlock/utils/uri_utils'
require 'sherlock/utils/http_utils'
require 'sherlock/utils/string_utils'
require "sherlock/inspector"
require "sherlock/item"
require "sherlock/client"


module Sherlock
  class << self

    def inspect(uri=nil)
      uri ? (@inspector = Sherlock::Inspector.new(uri)) : self
    end

  end
end
