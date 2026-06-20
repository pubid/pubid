# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Addendum Document Identifier
      # Contains a base identifier plus addendum parameters
      # Supports various formats:
      # "BS 1501-2 Addendum No. 1:1973"
      # "BS 1902-2.3:Addendum No. 1:1976"
      # "BS 2000-0:Addendum 1:1983"
      # "BS 6034:1981:Addendum No. 1:1986"
      class AddendumDocument < SingleIdentifier
        attribute :base_identifier, ::Pubid::Identifier, polymorphic: true
        attribute :addendum_number, :string
        attribute :addendum_year, :integer
        attribute :addendum_type, :string, default: -> {
          "No."
        } # "No." or empty for "Addendum N"
        attribute :separator, :string, default: -> {
          ":"
        } # Separator before Addendum (":" or " ")

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end

        def publisher
          base_identifier&.publisher
        end
      end
    end
  end
end
