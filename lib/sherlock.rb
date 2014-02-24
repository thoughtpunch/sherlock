Dir[File.dirname(__FILE__) + '/sherlock/utils/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/sherlock/response_types/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/sherlock/*.rb'].each {|file| require file }


module Sherlock
  class << self

    def inspect(url=nil,fetch=false)
      if url
        @inspector = Sherlock::Inspector.new(url)
        if fetch
          @inspector.fetch
        end
      end
      return @inspector
    end

  end
end
