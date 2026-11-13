module Pubid
  module EtsiPfs
    module Identifiers
      # The synthesized Amendment wrapper (PFS supplements
      # declaration): the kind face "A" is the run's
      # dispatch token and the printed notation's face.
      class Amendment < Supplement
        FACE = "A".freeze

        def self.face
          FACE
        end

        def self.polymorphic_name
          "pubid:etsi:amendment"
        end
      end
    end
  end
end
