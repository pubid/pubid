require "parslet"
require_relative "../parser/common_parse_rules"
require_relative "../parser/common_parse_methods"

module PubidNew
  module Ansi
    # Parser for ANSI (American National Standards Institute) identifiers
    # Examples: ANSI X3.4-1986, ANSI C63.4-2014, ANSI/ISO 9899:1990
    class Parser < Parslet::Parser
      include ::PubidNew::Parser::CommonParseRules
      include ::PubidNew::Parser::CommonParseMethods

      root :identifier

      # ANSI as sole publisher
      rule(:publisher) do
        str("ANSI").as(:publisher)
      end

      # Copublishers: ISO, IEEE, IEC, etc.
      ORGANIZATIONS = %w[ISO IEC IEEE SAE ASME ASTM].freeze
      rule(:copublishers) do
        (str("/") >> space? >> array_to_str(ORGANIZATIONS).as(:copublisher)).repeat(1).as(:copublishers)
      end

      # Number with optional parts
      # X3.4-1986, C63.4-2014, 9899, 802.3-2012
      rule(:number_with_part) do
        (
          # Letter prefix with number and optional part: X3.4, C63.4-2014
          (match['A-Z'].repeat(1) >> digits >> (str(".") >> digits).maybe >> (str("-") >> digits).maybe) |
          # Just digits with optional parts: 9899, 802.3-2012
          (digits >> (str(".") >> digits).maybe >> (str("-") >> digits).maybe)
        ).as(:number_with_part)
      end

      # Date - year only
      rule(:date) do
        str(":") >> year_digits.as(:date)
      end

      # Language codes
      rule(:language) do
        str("(") >>
          (match["a-z"].repeat(2) >> str(",").maybe).repeat.as(:languages) >>
          str(")")
      end

      # Main identifier for ANSI with copublishers
      # ANSI/ISO 9899:1990
      rule(:identifier_with_copublishers) do
        publisher >> copublishers >>
          space? >> number_with_part >>
          date.maybe >> language.maybe
      end

      # Main identifier for ANSI alone
      # ANSI X3.4-1986
      rule(:identifier_sole) do
        publisher >> space >>
          number_with_part >>
          date.maybe >> language.maybe
      end

      rule(:identifier) do
        identifier_with_copublishers | identifier_sole
      end
    end
  end
end