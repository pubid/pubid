# frozen_string_literal: true

require "parslet"

module Pubid
  module Iho
    # Parser class for IHO identifiers
    class Parser < Parslet::Parser
      rule(:space)  { str(" ") }
      rule(:dash)   { str("-") }
      rule(:dot)    { str(".") }
      rule(:digits) { match("[0-9]").repeat(1) }

      rule(:series) do
        (str("S") | str("P") | str("M") | str("B") | str("C")).as(:type)
      end

      rule(:number_suffix) do
        (str(":") >> digits) | (str("/") >> digits) | (dash >> digits) | match("[A-Z]")
      end

      rule(:code) do
        (digits >> number_suffix.maybe).as(:code)
      end

      rule(:appendix) do
        space >> str("Ap.") >> space >> (digits | match("[A-Z]")).as(:appendix)
      end

      rule(:part) do
        space >> str("Part") >> space >>
          (
            (digits >> match("[a-zA-Z]").repeat).as(:part) |
            match("[A-Z]").as(:part)
          )
      end

      rule(:version) do
        space >> (digits >> dot >> digits >> dot >> digits).as(:version)
      end

      rule(:identifier) do
        (str("IHO") >> space).maybe >>
          series >> dash >> code >>
          appendix.maybe >> part.maybe >> version.maybe
      end

      root :identifier

      def self.parse(string)
        new.parse(string.strip)
      end
    end
  end
end
