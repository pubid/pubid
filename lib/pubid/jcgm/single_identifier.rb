# frozen_string_literal: true

module Pubid
  module Jcgm
    class SingleIdentifier < Identifier
      attribute :publisher, Jcgm::Components::Publisher,
                default: -> { self.class.default_publisher }
      attribute :typed_stage, Pubid::Components::TypedStage,
                default: -> { self.class.published_typed_stage }
      attribute :number, Pubid::Components::Code
      attribute :date, Pubid::Components::Date
      attribute :languages, Pubid::Components::Language, collection: true
      attribute :stage, Pubid::Components::Stage
      attribute :type, Pubid::Components::Type

      # Compact serialization: only per-instance information is mapped. The
      # publisher (always "JCGM") and the derived type / stage / typed_stage
      # (fully determined by the class, i.e. `_type`) are intentionally NOT
      # mapped — they are reconstructed from the class on load via the
      # attribute defaults above. Components collapse to bare scalars:
      # number -> "100" (not {value: "100"}); date -> year/month/day scalars.
      # Mirrors ISO (lib/pubid/iso/identifier.rb) and OIML.
      key_value do
        map "_type", to: :_type
        map "number", with: { to: :number_to_kv, from: :number_from_kv }
        map "year", with: { to: :year_to_kv, from: :year_from_kv }
        map "month", with: { to: :month_to_kv, from: :month_from_kv }
        map "day", with: { to: :day_to_kv, from: :day_from_kv }
        map "languages", to: :languages
      end

      # The publisher implied when none is serialized — always JCGM.
      def self.default_publisher
        Jcgm::Components::Publisher.new(publisher: Jcgm::PREFIXES.first)
      end

      # The class's published typed_stage (canonical surface form). Each JCGM
      # class registers exactly one, all :published; `_type` fixes the class,
      # so an omitted typed_stage reconstructs deterministically on from_hash.
      def self.published_typed_stage
        return nil unless const_defined?(:TYPED_STAGES)

        ts = self::TYPED_STAGES.find { |t| t.stage_code.to_s == "published" }
        return nil unless ts

        ts = ts.dup
        ts.original_abbr = ts.canonical_abbreviation
        ts
      end

      # type and stage are derived from typed_stage, never stored — so the
      # doctype (fixed by the class / _type) is not carried in the hash.
      def type
        typed_stage&.to_type
      end

      def stage
        typed_stage&.to_stage
      end

      # --- number (Code) flattened to a bare string ---
      def number_to_kv(model, doc) = emit_kv(doc, "number", model.number&.value)
      def number_from_kv(model, value) = model.number = build_code(value)

      def build_code(value)
        Pubid::Components::Code.new(value: value.to_s)
      end

      # --- date flattened to top-level year/month/day scalars ---
      def year_to_kv(model, doc) = emit_kv(doc, "year", model.date&.year)
      def month_to_kv(model, doc) = emit_kv(doc, "month", model.date&.month)
      def day_to_kv(model, doc) = emit_kv(doc, "day", model.date&.day)
      def year_from_kv(model, value) = date_for(model).year = value.to_s
      def month_from_kv(model, value) = date_for(model).month = value.to_s
      def day_from_kv(model, value) = date_for(model).day = value.to_s

      def emit_kv(doc, key, value)
        return if value.nil? || value.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new(key, value.to_s))
      end

      def date_for(model)
        model.date ||= Pubid::Components::Date.new
      end

      def publisher_portion
        publisher.to_s
      end

      def number_portion
        parts = []
        parts << number.value if number
        parts << ":#{date.year}" if date
        parts.join
      end

      def language_portion
        return "" unless languages&.any?

        [
          "(",
          languages.map(&:original_code).join("/"),
          ")",
        ].join
      end
    end
  end
end
