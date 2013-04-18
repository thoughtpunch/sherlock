Dir[File.dirname(__FILE__) + '/sherlock/utils/*'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/sherlock/schemes/*'].each {|file| require file }
require "sherlock/version"
require "sherlock/inspector"
require "sherlock/client"



module Sherlock
  class << self

    def inspect(uri=nil)
      uri ? (@inspector = Sherlock::Inspector.new(uri)) : self
    end

  end
end
