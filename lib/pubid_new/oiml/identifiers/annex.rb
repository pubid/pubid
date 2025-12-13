# frozen_string_literal: true

module PubidNew
  module Oiml
    module Identifiers
      class Annex < SupplementIdentifier
        attribute :letter, :string  # For "Annex A", "Annex B", etc.
        
        def supplement_type
          letter ? "Annex #{letter}" : "Annexes"
        end
        
        def to_s
          # Annexes don't use "(year) to" format, they use different pattern
          # "OIML R 60 Annexes:2021 (E)" or "OIML R 60-Annex A Edition 2013 (E)"
          if letter
            # Specific annex: embed in base as part suffix
            result = base_identifier.to_s.sub(base_identifier.code.to_s, "#{base_identifier.code}-Annex #{letter}")
            result.sub(/:(\d{4})/, ' Edition \1')
          else
            # General annexes
            result = "#{base_identifier.publisher} #{base_identifier.type} #{base_identifier.code} Annexes"
            result += year ? ":#{year}" : (base_identifier.date ? " Edition #{base_identifier.date.year}" : "")
            result += " (#{language})" if language
            result
          end
        end
      end
    end
  end
end