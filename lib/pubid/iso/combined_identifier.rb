# frozen_string_literal: true

module Pubid
  module Iso
    # Identifier that represents a supplement to a base identifier.
    class CombinedIdentifier < Identifier
      attribute :base, Identifier, polymorphic: true
      attribute :additional_identifiers, ::Pubid::Identifier,
                polymorphic: true, collection: true
      attribute :type, :string, default: -> { "combined_identifier" }

      # `**opts` carries render flags this list does not name (`annotated:`),
      # which the closed signature used to reject outright.
      def to_s(lang: :en, lang_single: false, **opts)
        [
          base.to_s(lang: lang, lang_single: lang_single, **opts),
          additional_identifiers.map do |id|
            id.to_s(lang: lang, lang_single: lang_single, **opts)
          end,
        ].flatten.join(" | ")
      end
    end
  end
end
