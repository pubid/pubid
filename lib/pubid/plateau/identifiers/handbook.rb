# frozen_string_literal: true

module Pubid
  module Plateau
    module Identifiers
      # PLATEAU Handbook
      # Format: PLATEAU Handbook #NN[-annex] [第X.Y版[ volume]]
      # Example: PLATEAU Handbook #00 第1.0版
      # Example: PLATEAU Handbook #00 第5.0版 本編＋付録
      class Handbook < Identifier
        attribute :edition, :string, default: -> {}
        # The volume label MLIT prints after the edition: "本編" (the main
        # volume alone) or "本編＋付録" (main volume and appendix, one PDF).
        attribute :volume, :string, default: -> {}

        # A nil `volume` means the publication has no volume label:
        # `#00 第5.0版` does not subsume `#00 第5.0版 本編＋付録`.
        subset_strict :volume

        def type_string
          "Handbook"
        end

        def formatted_edition
          "第#{edition}版"
        end

        def ==(other)
          return false unless other.is_a?(Handbook)

          super && edition == other.edition && volume == other.volume
        end
      end
    end
  end
end
