# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # CSA dual published identifier
      # Represents IEEE/CSA dual published standards
      # Example: IEEE Std 844.1-2017/CSA C22.2 No. 293.1-17
      class CsaDualPublished < Base
        attribute :ieee_identifier, Base
        # CSA identifier is stored as-is (not a Lutaml model type)
        attr_accessor :csa_identifier

        # Delegate common attributes to ieee_identifier
        def publisher
          ieee_identifier.publisher
        end

        def copublisher
          ieee_identifier.copublisher
        end

        def code
          ieee_identifier.code
        end

        def year
          ieee_identifier.year
        end

        def typed_stage
          ieee_identifier.typed_stage
        end

        def to_s
          # Format: IEEE_IDENTIFIER/CSA CSA_IDENTIFIER
          # The CSA identifier should render with "CSA" prefix
          csa_str = csa_identifier.to_s
          # Ensure CSA prefix is present
          csa_str = "CSA #{csa_str}" unless csa_str.start_with?("CSA", "CAN/")

          "#{ieee_identifier}/#{csa_str}"
        end

        def self.parse(string)
          Base.parse(string)
        end
      end
    end
  end
end
