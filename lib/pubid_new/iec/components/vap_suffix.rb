require "lutaml/model"
# frozen_string_literal: true

module PubidNew
  module Iec
    module Components
      # VAP (Validation Assessment Programme) suffix codes
      # Single Responsibility: Represents VAP validation status suffixes
      class VapSuffix < Lutaml::Model::Serializable
        # VAP suffix codes as defined by IEC
        CODES = {
          "CMV" => "Common Modifications and Variations",
          "RLV" => "Relevant",
          "SER" => "Serial",
        }.freeze

        attribute :code, :string

        def validate!
          unless CODES.key?(code)
            raise ArgumentError,
                  "Unknown VAP suffix code: #{code}. Valid codes: #{CODES.keys.join(', ')}"
          end
        end

        def to_s
          code
        end

        def full_name
          CODES[code]
        end

        # VAP suffix appears after the main identifier with a space
        def render_with_space
          " #{code}"
        end
      end
    end
  end
end
