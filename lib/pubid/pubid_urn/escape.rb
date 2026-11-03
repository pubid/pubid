# frozen_string_literal: true

module Pubid
  module PubidUrn
    # The value escape of the pubid-scheme URN.
    #
    # The URN is also an HTTP path slug (relaton/relaton#441), so it cannot
    # use "%": servers and proxies decode "%2F" before they route, or they
    # refuse it. "~XX" (uppercase hex of one UTF-8 byte) has no meaning in a
    # path, and "~" is an RFC 3986 unreserved character. Every byte outside
    # SAFE is escaped, so ":" "," "(" ")" "~" never occur raw in a value and
    # stay free for the structure of the URN.
    module Escape
      SAFE = /[A-Za-z0-9._-]/
      RAW_TOKEN = /\A(?:[A-Za-z0-9._-]|~[0-9A-F]{2})*\z/

      module_function

      # @param value [String]
      # @return [String]
      def encode(value)
        value.to_s.each_char.map { |char| encode_char(char) }.join
      end

      # Escape every character of +char+, safe or not. The codec uses it on
      # the first character of a core value that would otherwise read as
      # structure ("amd" -> "~61md").
      #
      # @param char [String] one character
      # @return [String]
      def force(char)
        char.b.each_byte.map { |byte| format("~%02X", byte) }.join
      end

      # @param token [String]
      # @return [String]
      # @raise [Pubid::Errors::UrnParseError] for a raw character outside the
      #   safe set, or a malformed or lower-case escape
      def decode(token)
        unless RAW_TOKEN.match?(token)
          raise Pubid::Errors::UrnParseError,
                "bad character or escape in pubid URN value #{token.inspect}"
        end

        bytes = token.b.gsub(/~([0-9A-F]{2})/n) { Regexp.last_match(1).hex.chr }
        decoded = bytes.force_encoding(Encoding::UTF_8)
        unless decoded.valid_encoding?
          raise Pubid::Errors::UrnParseError,
                "escape in pubid URN value #{token.inspect} is not UTF-8"
        end

        decoded
      end

      def encode_char(char)
        SAFE.match?(char) ? char : force(char)
      end
    end
  end
end
