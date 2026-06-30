# frozen_string_literal: true

module Pubid
  module Oiml
    class SingleIdentifier < Identifier
      # Base class for OIML single identifiers (non-supplements)
      attribute :publisher, :string
      attribute :code, Oiml::Components::Code
      attribute :date, Pubid::Components::Date
      attribute :edition, :string
      attribute :stage, :string
      attribute :iteration, :string
      attribute :language, :string
      attribute :parsed_format, :string, default: -> {
        "short"
      } # Track parsed format

      # Serialization delta on top of Oiml::Identifier's shared block. The
      # `code` (number/part/subpart/suffix) and `date` (year) components are
      # flattened to top-level keys rather than nested hashes, mirroring ISO
      # (lib/pubid/iso/identifier.rb). `type` is intentionally omitted
      # (recomputed from the class on load).
      key_value do
        map "publisher", to: :publisher
        map "number", with: { to: :number_to_kv, from: :number_from_kv }
        map "part", with: { to: :part_to_kv, from: :part_from_kv }
        map "subpart", with: { to: :subpart_to_kv, from: :subpart_from_kv }
        map "suffix", with: { to: :suffix_to_kv, from: :suffix_from_kv }
        map "space_suffix",
            with: { to: :space_suffix_to_kv, from: :space_suffix_from_kv }
        map "year", with: { to: :year_to_kv, from: :year_from_kv }
        map "edition", to: :edition
        map "stage", to: :stage
        map "iteration", to: :iteration
      end

      # --- code components flattened to top-level keys ---
      def number_to_kv(model, doc) = emit_kv(doc, "number", model.code&.number)
      def number_from_kv(model, value) = code_for(model).number = value.to_s
      def part_to_kv(model, doc) = emit_kv(doc, "part", model.code&.part)
      def part_from_kv(model, value) = code_for(model).part = value.to_s
      def subpart_to_kv(model, doc) = emit_kv(doc, "subpart", model.code&.subpart)
      def subpart_from_kv(model, value) = code_for(model).subpart = value.to_s
      def suffix_to_kv(model, doc) = emit_kv(doc, "suffix", model.code&.suffix)
      def suffix_from_kv(model, value) = code_for(model).suffix = value.to_s

      def space_suffix_to_kv(model, doc)
        return unless model.code&.space_suffix

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new("space_suffix", true),
        )
      end

      def space_suffix_from_kv(model, value)
        code_for(model).space_suffix = value
      end

      # --- date flattened to a top-level year ---
      def year_to_kv(model, doc) = emit_kv(doc, "year", model.date&.year)

      def year_from_kv(model, value)
        (model.date ||= Pubid::Components::Date.new).year = value.to_s
      end

      def emit_kv(doc, key, value)
        return if value.nil? || value.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new(key, value.to_s))
      end

      def code_for(model)
        model.code ||= Components::Code.new
      end

      attr_reader :requested_format

      # Type is determined by the subclass
      def type
        type_string
      end

      def to_s(format: nil, **opts)
        # Store requested format so the renderer can access it
        @requested_format = format
        render(format: :human, **opts)
      end

      def edition_portion
        # Deprecated - kept for compatibility
        # Use to_s(format: :long) instead
        if edition && date
          "#{edition} Edition #{date.year}"
        elsif date
          "Edition #{date.year}"
        else
          edition
        end
      end

      # Subclasses override this
      def type_string
        raise NotImplementedError, "Subclasses must implement type_string"
      end

      # Subclasses override this
    end
  end
end
