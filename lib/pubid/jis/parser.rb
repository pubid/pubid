# frozen_string_literal: true

require "parslet"

module Pubid
  module Jis
    class Parser < Parslet::Parser
      # Japanese character normalization
      rule(:jp_dash) { str("ｰ") } # Full-width dash
      rule(:jp_space) { str("　") }  # Full-width space
      rule(:jp_colon) { str("：") }  # Full-width colon
      rule(:jp_lparen) { str("（") }
      rule(:jp_rparen) { str("）") }

      # Normalized separators
      rule(:dash) { (str("-") | jp_dash).as(:dash) }
      rule(:space) { str(" ") | jp_space }
      rule(:colon) { str(":") | jp_colon }

      # Basic elements
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }
      rule(:letter) { match["A-Z"] }

      # JIS prefix (optional, handles both "JIS " and "JIS/")
      rule(:jis_prefix) { str("JIS") >> (space | str("/")).maybe }

      # Type prefix (TR or TS, can come with or without slash)
      rule(:type_prefix) do
        (str("TR") | str("TS")).as(:type) >> (space | str("/"))
      end

      # Series letter
      rule(:series) { letter.as(:series) }

      # Number (preserve as string to maintain leading zeros)
      rule(:number) { digits.as(:number) }

      # Parts (multi-level: -1, -2-1, -3-2-1, etc.)
      rule(:part) do
        dash >> digits.as(:part)
      end

      rule(:parts) { part.repeat(0).as(:parts) }

      # Year
      rule(:year) do
        colon >> digits.as(:year)
      end

      # Language code
      rule(:language) do
        (str("(") | jp_lparen) >>
          match["EJ"].as(:language) >>
          (str(")") | jp_rparen)
      end

      # All-parts notation (Japanese)
      rule(:all_parts) do
        ((jp_lparen >> str("規格群") >> jp_rparen) |
         (str("(") >> str("規格群") >> str(")"))).as(:all_parts)
      end

      # Amendment supplement
      rule(:amendment) do
        str("/") >>
          (str("AMENDMENT") | str("AMD")).as(:amd_type) >>
          space >>
          digits.as(:amd_number) >>
          colon >>
          digits.as(:amd_year)
      end

      # Explanation supplement
      rule(:explanation) do
        str("/") >>
          (str("EXPLANATION") | str("EXPL")).as(:expl_type) >>
          (space >> digits.as(:expl_number)).maybe
      end

      # Corrigendum supplement
      rule(:corrigendum) do
        str("/") >>
          (str("CORRIGENDUM") | str("CORR")).as(:corr_type) >>
          space >>
          digits.as(:corr_number) >>
          colon >>
          digits.as(:corr_year)
      end

      # Supplements (AMD, EXPL or CORRIGENDUM, only one for JIS)
      rule(:supplement) do
        amendment.as(:amendment) | explanation.as(:explanation) |
          corrigendum.as(:corrigendum)
      end

      # Main identifier
      rule(:identifier) do
        jis_prefix.maybe >>
          type_prefix.maybe >>
          space.maybe >>
          series >>
          space.maybe >>
          number >>
          parts >>
          year.maybe >>
          language.maybe >>
          all_parts.maybe >>
          supplement.maybe
      end

      rule(:root) { identifier }

      # Parse and normalize Japanese characters
      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
