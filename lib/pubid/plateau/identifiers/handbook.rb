# frozen_string_literal: true

module Pubid
  module Plateau
    module Identifiers
      # PLATEAU Handbook
      # Format: PLATEAU Handbook #NN[-annex] [第X.Y版]
      # Example: PLATEAU Handbook #00 第1.0版
      class Handbook < Base
        attribute :edition, :string, default: -> {}

        def type_string
          "Handbook"
        end

        def formatted_edition
          "第#{edition}版"
        end

        def ==(other)
          return false unless other.is_a?(Handbook)

          super && edition == other.edition
        end
      end
    end
  end
end
