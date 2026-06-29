# frozen_string_literal: true

module Pubid
  module Oiml
    class Identifier < Pubid::Identifier
      # Maps each concrete identifier's polymorphic_name => class name, so
      # key_value (de)serialization can re-instantiate the correct subclass
      # from the `_type` discriminator. Kept in sync with the Identifiers
      # namespace by a spec assertion (see spec/pubid/oiml/to_hash_spec.rb).
      OIML_TYPE_MAP = {
        "pubid:oiml:recommendation" => "Pubid::Oiml::Identifiers::Recommendation",
        "pubid:oiml:basic-publication" => "Pubid::Oiml::Identifiers::BasicPublication",
        "pubid:oiml:document" => "Pubid::Oiml::Identifiers::Document",
        "pubid:oiml:guide" => "Pubid::Oiml::Identifiers::Guide",
        "pubid:oiml:vocabulary" => "Pubid::Oiml::Identifiers::Vocabulary",
        "pubid:oiml:expert-report" => "Pubid::Oiml::Identifiers::ExpertReport",
        "pubid:oiml:seminar-report" => "Pubid::Oiml::Identifiers::SeminarReport",
        "pubid:oiml:amendment" => "Pubid::Oiml::Identifiers::Amendment",
        "pubid:oiml:errata" => "Pubid::Oiml::Identifiers::Errata",
        "pubid:oiml:annex" => "Pubid::Oiml::Identifiers::Annex",
      }.freeze

      # The base Pubid::Identifier no longer auto-maps attributes, so OIML must
      # declare its own key_value mapping. SingleIdentifier and
      # SupplementIdentifier (siblings) add their disjoint attribute deltas on
      # top of this shared block. `type` is deliberately NOT mapped: OIML's
      # `type` is a String-returning method (e.g. "R"), incompatible with the
      # inherited Components::Type attribute — and the `_type` discriminator
      # already pins the concrete subclass (and thus the type letter).
      key_value do
        map "_type", to: :_type, polymorphic_map: OIML_TYPE_MAP
        map "language", to: :language
        map "parsed_format", to: :parsed_format
      end

      # lutaml's polymorphic_map only validates `_type` on deserialization; it
      # does not re-instantiate the concrete subclass. Route by `_type` so
      # `Pubid::Oiml::Identifier.from_hash(h)` returns the right class (and its
      # nested base_identifier), mirroring Pubid::Iso::Identifier.from_hash.
      def self.from_hash(data, options = {})
        type = data["_type"] || data[:_type]
        klass_name = OIML_TYPE_MAP[type]
        if klass_name
          klass = Object.const_get(klass_name)
          return klass.from_hash(data, options) unless klass == self
        end
        super
      end

      def to_urn
        UrnGenerator.new(self).generate
      end
    end
  end
end
