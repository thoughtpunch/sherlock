#Utility methods for parsing and processing HTTP request/response data
require 'hashie'
require 'faraday'

module Sherlock
  module Utils
    module HTTP_Utils

      #Parse the headers and return as Hashie::Mash for that sweet object-like sugar
      # EX: header.server = 'nginx'
      def headers_to_mash(headers)
        if headers && headers.is_a?(Faraday::Utils::Headers)
          sanitized_hash = headers.map{|k,v| {k.downcase.strip.gsub(/\W/,"_") => v.downcase}}
          header_mash = sanitized_hash.reduce Hashie::Mash.new, :merge
          return header_mash
        end
      end

      def cookie_to_mash(headers)
        if headers && headers.is_a?(Faraday::Utils::Headers)
          cookie = headers_to_mash(headers).set_cookie
          sanitized_cookie = cookie.split(/\;/).map{|x|
            key,value = x.split("=");
            {key.strip.to_sym => value.to_s.downcase.strip}
          }
          return sanitized_cookie.reduce Hashie::Mash.new, :merge
        end
      end

      def response_to_mash(response)

      end

    end
  end
end