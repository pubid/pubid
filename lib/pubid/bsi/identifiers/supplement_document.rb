# frozen_string_literal: true


module Pubid
  module Bsi
    module Identifiers
      # Supplement Document Identifier
      # Contains a base identifier plus supplement parameters
      # Supports both forward and reverse formats:
      # Forward: "BS 1000:Supplement No. 1:1972", "BS 1722-1 Supplement No. 1:1974"
      # Reverse: "Supplement No. 1 (1970) to BS 1831:1969"
      class SupplementDocument < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :supplement_number, :string
        attribute :supplement_year, :integer
        attribute :supplement_type, :string, default: -> {
          "No."
        } # "No." or empty for "Supplement N"
        attribute :reverse_format, :boolean, default: false # true for "Supplement No. N (YEAR) to BS..."
        attribute :separator, :string, default: -> {
          ":"
        } # Separator before Supplement (":" or " ")

        def to_s
          base_str = base_identifier.to_s

          if reverse_format
            # Reverse format: "Supplement No. 1 (1970) to BS 1831:1969"
            supplement_str = if supplement_type == "No."
                               "Supplement No. #{supplement_number} (#{supplement_year})"
                             else
                               "Supplement #{supplement_number} (#{supplement_year})"
                             end
            "#{supplement_str} to #{base_str}"
          else
            # Forward format: "BS 1000:Supplement No. 1:1972" or "BS 1722-1 Supplement No. 1:1974"
            supplement_str = if supplement_type == "No."
                               "#{separator}Supplement No. #{supplement_number}:#{supplement_year}"
                             else
                               "#{separator}Supplement #{supplement_number}:#{supplement_year}"
                             end
            "#{base_str}#{supplement_str}"
          end
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end
