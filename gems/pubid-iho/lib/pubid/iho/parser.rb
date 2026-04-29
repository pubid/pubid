module Pubid::Iho
  class Parser < Pubid::Core::Parser
    rule(:series) do
      array_to_str(%w[S P M B C]).as(:type)
    end

    rule(:number_suffix) do
      (str(":") >> digits) | (str("/") >> digits) | (dash >> digits) | match("[A-Z]")
    end

    rule(:number) do
      (digits >> number_suffix.maybe).as(:number)
    end

    rule(:appendix) do
      space >> (str("Appendix") | str("Ap.")) >> space >>
        (
          (match("[A-Z]") >> dash >> digits) |
          digits |
          match("[A-Z]")
        ).as(:appendix)
    end

    rule(:part) do
      space >> str("Part") >> space >>
        (
          (digits >> match("[a-zA-Z]").repeat).as(:part) |
          match("[A-Z]").as(:part)
        )
    end

    rule(:annex) do
      space >> str("Annex") >> space >> match("[A-Z]").as(:annex)
    end

    rule(:supplement) do
      space >> str("Suppl") >> space >> digits.as(:supplement)
    end

    rule(:version) do
      space >> (digits >> dot >> digits >> dot >> digits).as(:version)
    end

    rule(:identifier) do
      (str("IHO") >> space).maybe >> series >> dash >> number >>
        appendix.maybe >> part.maybe >> annex.maybe >> supplement.maybe >> version.maybe
    end

    rule(:root) { identifier }
  end
end
