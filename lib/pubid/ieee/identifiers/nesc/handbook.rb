# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      module Nesc
        # NESC Handbook identifier
        #
        # Represents NESC Handbook publications which provide comprehensive
        # guidance and interpretation of the National Electrical Safety Code.
        #
        # @example Basic handbook
        #   nesc = Pubid::Ieee.parse("2012 NESC Handbook")
        #   nesc.to_s  # => "2012 NESC Handbook"
        #
        # @example With edition
        #   nesc = Pubid::Ieee.parse("2017 NESC Handbook, Premier Edition")
        #   nesc.to_s  # => "2017 NESC Handbook, Premier Edition"
        class Handbook < Base
          # Render handbook identifier
          #
          # @return [String] YYYY NESC Handbook format with optional edition
          def to_s
            parts = ["#{year.year} NESC Handbook"]
            parts << ", #{edition}" if edition
            parts.join
          end
        end
      end
    end
  end
end
