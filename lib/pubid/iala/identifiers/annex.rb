# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Annex to a base publication. Two surface forms appear in the
      # corpus, both wrapping a Guideline:
      #
      #   "G1045 Annex Ed 1"           — bare Annex, no letter
      #   "G1128 ANNEX A Ed 1.6"        — uppercase + letter (A/B/C/D)
      #
      # The case of the marker is preserved (Annex vs ANNEX) for round-trip
      # fidelity. Edition and language apply to the Annex itself, not the base.
      class Annex < Base
        # The publication this annex supplements. Always present; carries the
        # type letter and number (e.g. G1045).
        attribute :base_identifier, ::Pubid::Iala::Identifier, polymorphic: true
        # "Annex" or "ANNEX" — preserved verbatim for exact round-trip.
        attribute :annex_form, :string
        # "A", "B", "C", "D", or nil for the bare form.
        attribute :letter, :string

        key_value do
          map "base_identifier",
              with: { to: :base_identifier_to_kv, 
                      from: :base_identifier_from_kv }
          map "annex_form", to: :annex_form
          map "letter",     to: :letter
        end

        def self.type
          { key: :annex, title: "Annex", short: nil }
        end

        # Public because lutaml-model invokes the `to:` / `from:` mapping
        # methods via public_send during (de)serialization — a `private`
        # section here raises NoMethodError on to_hash (matches the public
        # visibility of Oiml::SupplementIdentifier's identical helpers).
        def base_identifier_to_kv(model, doc)
          base = model.base_identifier
          return unless base

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new("base_identifier",
                                                     base.to_hash),
          )
        end

        def base_identifier_from_kv(model, value)
          return unless value

          model.base_identifier = ::Pubid::Iala::Identifier.from_hash(value)
        end
      end
    end
  end
end
