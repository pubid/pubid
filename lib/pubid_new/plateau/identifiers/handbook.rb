# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Plateau
    module Identifiers
      # PLATEAU Handbook
      # Format: PLATEAU Handbook #NN[-annex] [第X.Y版]
      # Example: PLATEAU Handbook #00 第1.0版
      class Handbook < Base
        attribute :edition, :string, default: -> { nil }

        def type_string
          "Handbook"
        end

        def to_s
          result = "#{publisher} #{type_string} #{formatted_number}#{formatted_annex}"
          result += " #{formatted_edition}" if edition
          result
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
