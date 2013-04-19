#Utility methods for parsing and processing HTTP request/response data
require 'time'
require 'json'
require 'hashie'
require 'faraday'

module Sherlock
  module Utils
    module HTTP_Utils

      #Parse the headers and return as Hashie::Mash for that sweet object-like sugar
      # EX: header.server = 'nginx'
      def headers_to_mash(headers)
        if headers && headers.is_a?(Faraday::Utils::Headers)
          sanitized_hash = headers.map{|k,v| {k.downcase.strip.gsub(/\W/,"_").gsub(/^\_|\_$/,"").to_sym => v.downcase}}
          header_mash = sanitized_hash.reduce Hashie::Mash.new, :merge
          return header_mash
        end
      end

      #Parse the cookie and return as Hashie::Mash
      def cookie_to_mash(headers)
        if headers && headers.is_a?(Faraday::Utils::Headers)
          cookie = headers_to_mash(headers).set_cookie
          sanitized_cookie = cookie.split(/\;/).map{|x|
            key,value = x.split("=");
            if 
            {key.strip.gsub(/\W/,"_").gsub(/^\_|\_$/,"").to_sym => value.to_s.downcase.strip}
          }
          return sanitized_cookie.reduce Hashie::Mash.new, :merge
        end
      end

      #Parse JSON responses and return as Hashie::Mash
      def json_response_to_mash(response)

      end

      #Parse XML responses and return as Hashie::Mash
      def xml_response_to_mash(response)

      end
    end
  end
end