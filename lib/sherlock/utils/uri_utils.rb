#Utility methods for parsing and processing URIs

module Sherlock
  module Utils
    module URI_Utils

      def validate_uri(uri)
        if uri !~ /\:/
          msg = "URI has no scheme (i.e. 'http', 'ftp', 'smtp')"
        elsif uri !~ /\/\//
          msg = "URI missing start of hierarchical segment '//'"
        elsif !(uri =~ URI::regexp)
          msg = "URI does not appear to be valid"
        end
        msg ? (raise URI::InvalidURIError, msg) : true
      end

      def parse_uri_params(uri)
        parsed_params = {}

        possible_params = uri.split(/\?|\&/).delete_if{|x| !x.match(/\=/)}

        unless possible_params.nil? || possible_params.empty?
          possible_params.each do |prm|
            param = prm.split(/\=/)
            parsed_params[param[0].to_sym] = param[1]
          end
          return parsed_params
        end
      end

      def parse_port(uri)
        port = uri.scan(/\:[0-9]+/).first
        port ? port.gsub(":","").to_i : nil
      end

      def sanitize_uri(uri)
        URI.decode(uri.to_s).downcase.strip
      end

      #A Decorator for displaying URI's when the title is unknown. Looks best with HTTP URI's
      def titleize_uri(uri)
        if uri.match(/http/)
          return uri.split(/\//).sort_by{|x| x.length}.last.titleize rescue ""
        end
      end

    end
  end
end
