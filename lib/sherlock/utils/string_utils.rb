#Utility methods manipulating strings
module Sherlock
  module Utils
    module String_Utils

      def remove_punctuation_from_string(string)
        if !(string.is_a? String)
          raise ArgumentError,"#{string} is not a valid instance of the String class"
        else
          return string.downcase.gsub(/\'|[0-9]/,"").gsub(/\W+/," ").strip
        end
      end

      def encode_utf8_with_extreme_prejudice(string)
        if !(string.is_a? String)
          raise ArgumentError,"#{string} is not a valid instance of the String class"
        else
          return string.encode('utf-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '')
        end
      end

    end
  end
end