# frozen_string_literal: true

module Pubid
  module Ansi
    # Parser for ANSI (American National Standards Institute) identifiers
    # Examples: ANSI X3.4-1986, ANSI C63.4-2014, ANSI/ISO 9899:1990
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules
      include ::Pubid::Parser::CommonParseMethods

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

      # Optional "Std" keyword
      rule(:std_keyword) do
        (str("Std") >> space).maybe
      end

      # Number with optional parts and subparts
      # Examples:
      # - X3.4-1986 (letter prefix, one dot, year)
      # - C63.4-2014 (letter prefix, one dot, year)
      # - C37.06.1-2000 (letter prefix, two dots, year)
      # - C57.12.10-1988 (letter prefix, three dots, year)
      # - N323A-1997 (letter prefix, number, letter suffix, year)
      # - N42.49A-2011 (letter prefix, dot, number, letter suffix, year)
      # - 9899 (just digits)
      # - 802.3-2012 (digits with dot and year)
      # - 802.1b-1995 (digits, dot, digits, letter, year)
      rule(:number_with_part) do
        (
          # Letter prefix with multiple dots and optional letter suffix
          # C37.06.1, C57.12.10, C63.25.1, N323A, N42.49A
          (match["A-Z"].repeat(1) >>
           digits >>
           (str(".") >> digits).repeat(0, 3) >> # Allow up to 3 additional dot-separated parts
           match["A-Z"].maybe >>                  # Optional letter suffix (A, B, etc.)
           (str("-") >> digits).maybe) |          # Optional dash-year part
          # Just digits with optional dots and letter suffix: 9899, 802.3-2012, 802.1b-1995
          (digits >>
           (str(".") >> digits >> match["a-z"].maybe).repeat(0, 2) >> # Dots with optional lowercase letter
           (str("-") >> digits).maybe)
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
      # ANSI/ISO 9899:1990, ANSI/IEEE Std 1-1986
      rule(:identifier_with_copublishers) do
        publisher >> copublishers >>
          space >> std_keyword >>
          number_with_part >>
          date.maybe >> language.maybe
      end

      # Main identifier for ANSI alone
      # ANSI X3.4-1986, ANSI Std C63.4-1991
      rule(:identifier_sole) do
        publisher >> space >>
          std_keyword >>
          number_with_part >>
          date.maybe >> language.maybe
      end

      rule(:identifier) do
        identifier_with_copublishers | identifier_sole
      end
    end
  end
end
