module Pubid
  module EtsiPfs
    module Identifiers
      # The synthesized Corrigendum wrapper (PFS supplements
      # declaration): the kind face "C" is the run's
      # dispatch token and the printed notation's face.
      class Corrigendum < Supplement
        FACE = "C".freeze

        def self.face
          FACE
        end

        def self.polymorphic_name
          "pubid:etsi:corrigendum"
        end
      end
    end
  end
end
