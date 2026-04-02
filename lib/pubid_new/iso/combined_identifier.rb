require_relative "../identifier"
# frozen_string_literal: true
require_relative "identifier"

module PubidNew
  module Iso
    # Identifier that represents a supplement to a base identifier.
    class CombinedIdentifier < Identifier
      attribute :base_identifier, Identifier, polymorphic: true
      attribute :additional_identifiers, ::PubidNew::Identifier,
                polymorphic: true, collection: true
      attribute :type, :string, default: -> { "combined_identifier" }

      def to_s(lang: :en, lang_single: false)
        [
          base_identifier.to_s(lang: lang, lang_single: lang_single),
          additional_identifiers.map do |id|
            id.to_s(lang: lang, lang_single: lang_single)
          end,
        ].flatten.join(" | ")
      end
    end
  end
end
