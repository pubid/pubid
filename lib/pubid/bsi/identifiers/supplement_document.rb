# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Supplement Document Identifier
      # Contains a base identifier plus supplement parameters
      # Supports both forward and reverse formats:
      # Forward: "BS 1000:Supplement No. 1:1972", "BS 1722-1 Supplement No. 1:1974"
      # Reverse: "Supplement No. 1 (1970) to BS 1831:1969"
      class SupplementDocument < SingleIdentifier
        attribute :base, ::Pubid::Identifier, polymorphic: true
        attribute :supplement_number, :string
        attribute :supplement_year, :integer
        attribute :supplement_type, :string, default: -> {
          "No."
        } # "No." or empty for "Supplement N"
        attribute :reverse_format, :boolean, default: false # true for "Supplement No. N (YEAR) to BS..."
        attribute :separator, :string, default: -> {
          ":"
        } # Separator before Supplement (":" or " ")

        def publisher
          base&.publisher
        end
      end
    end
  end
end
