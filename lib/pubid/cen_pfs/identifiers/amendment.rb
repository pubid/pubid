module Pubid
  module CenPfs
    module Identifiers
      # The synthesized Amendment wrapper (PFS supplements
      # declaration, issue #121 feature 3): the kind face
      # "A" is the run's dispatch token and the
      # printed notation's face.
      class Amendment < Supplement
        FACE = "A".freeze

        def self.face
          FACE
        end

        def self.polymorphic_name
          "pubid:cencenelec:amendment"
        end
                            
                            # The MR slug's supplement suffix: the shared MrString
                            # recurses into base and appends this.
                            def mr_supplement_suffix
                              mr_join_segments("amd", number, year)
                            end
      end
    end
  end
end
