#Utility methods manipulating strings
module Sherlock
  module Utils
    module Text_Utils

      DICTIONARIES ||= Dir["./lib/sherlock/dictionaries/*"]

      # Returns the HTML content text without punctuation or special charectoers.
      # - Useful for searching against search indexes, text analyzers, etc
      def search_text(text=nil)
        text ||= self.text
        @search_text ||= remove_punctuation_from_string(text)
      end

      def keywords
        dictionary = self.dictionary
        source = self.search_text.split.map{|x| x.downcase.gsub(/\W|\_|\-/," ").strip }
        source = source.delete_if{|word| word.length < 4 || word.length > 20 }
        source = source.delete_if{|word| word.match(/www|http|html|upc|gtin/i) || dictionary.include?(word)}
        @keywords = {}
        source.map{|x| @keywords[x] += 1 rescue (@keywords[x] = 1)}
        return @keywords.sort_by{|k,v| v}.reverse
      end

      def dictionary(language="english")
        dict = DICTIONARIES.select{|x| x.match(/#{language}/i)}.first
        words = File.open(dict,"rt").map{|l| l.downcase.strip }.sort if dict
        return words
      end

    end
  end
end