module Pubid
  module Nist
    module Parsers
      class Ncstar < Default
        rule(:number_suffix) { match("[abcdefghijA-Z]") }
      end
    end
  end
end
