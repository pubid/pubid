module Pubid
  module CenPfs
    module Identifiers
      # The synthesized Corrigendum wrapper (PFS supplements
      # declaration, issue #121 feature 3): the kind face
      # "AC" is the run's dispatch token and the
      # printed notation's face.
      class Corrigendum < Supplement
        FACE = "AC".freeze

        def self.face
          FACE
        end

        def self.polymorphic_name
          "pubid:cencenelec:corrigendum"
        end
                            
                            # The MR slug's supplement suffix: the shared MrString
                            # recurses into base and appends this.
                            def mr_supplement_suffix
                              mr_join_segments("cor", number, supplement_date)
                            end
      end
    end
  end
end
