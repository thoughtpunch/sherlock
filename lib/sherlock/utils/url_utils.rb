#Utility methods for parsing and processing urls

module Sherlock
  module Utils
    module URL_Utils

      EXTERNAL_URLS  = %r(\.(co(op|m|\.uk)?|(in(t|fo)?)|net|org|edu||mil|name|gov|arpa|biz|aero|name|pro|museum|uk|me)$)
      FILES       = /(avi|css|doc|exe|gif|html|htm|jpg|jpeg|js|midi|mp3|mov|mpg|mpeg|pdf|png|rar|tiff|txt|wav|zip)$/i
      META_PAGES  = %r(\/(page[s]?|about|contact|bio|tag[s]?|keywords[s]?|
                        staff|people|member[s]?|course[s]?|cart|item[s]|
                        marketplace|manifesto|privacy|team|platform|
                        categor[y|ies]|author[s]?)(\/|$))

      def shortened_url?
        #TODO: Find a regex for this
        #@url.match(/\.ly)
      end

      def meta_page?
        @url.match(META_PAGES) ? true : false
      end

      def external_url?
        @url.match(EXTERNAL_URLS) ? true : false
      end

      def file_url?
        @url.match(FILES) ? true : false
      end

      def validate_url(url)
        if url !~ /\:/
          msg = "url has no scheme (i.e. 'http', 'ftp', 'smtp')"
        elsif url !~ /\/\//
          msg = "url missing start of hierarchical segment '//'"
        elsif !(url =~ URI::regexp)
          msg = "url does not appear to be valid"
        end
        msg ? (raise url::InvalidurlError, msg) : true
      end

      def parse_url_params(url)
        parsed_params = {}

        possible_params = url.split(/\?|\&/).delete_if{|x| !x.match(/\=/)}

        unless possible_params.nil? || possible_params.empty?
          possible_params.each do |prm|
            param = prm.split(/\=/)
            parsed_params[param[0].to_sym] = param[1]
          end
          return parsed_params
        end
      end

      def parse_url_date
        #try to get the date from the url
        if %r{([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})}.match(@url)
          return %r{([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})}.match(@url).captures.join.to_date
        elsif %r{([A-Za-z]+)(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([A-Za-z]+)}.match(@url)
          return (%r{([A-Za-z]+)(\/|\-)([0-9]{2,})(\/|\-)([0-9]{2,})(\/|\-)([A-Za-z]+)}.match(@url).captures.join.gsub(/[A-Za-z]/,"") + "01").to_date
        end
      end

      def parse_port(url)
        port = url.scan(/\:[0-9]+/).first
        port ? port.gsub(":","").to_i : nil
      end

      def sanitize_url(url)
        URI.decode(url.to_s).downcase.strip
      end
    end
  end
end
