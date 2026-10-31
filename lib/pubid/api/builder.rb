# frozen_string_literal: true

module Pubid
  module Api
    class Builder < Pubid::Builder::Base
      TYPE_CLASS_MAP = {
        "BULL" => Identifiers::Bulletin,
        "MPMS" => Identifiers::Mpms,
        "RP" => Identifiers::RecommendedPractice,
        "SPEC" => Identifiers::Specification,
        "STD" => Identifiers::Standard,
        "TR" => Identifiers::TechnicalReport,
        "COS" => Identifiers::ContinuousOperationsStandard,
        "PUBL" => Identifiers::Publication,
      }.freeze

      # The bound grammar flattens the combined form's first/second
      # wrappers (the bindings cannot nest): the second identifier's
      # fields capture under second_* names. The tree backend folded
      # first and second into one hash in parse order, so the second
      # side's assignments came last and its number/part/year overwrite
      # the first's — and select_class saw no top-level :type, so a
      # combined form always built the typeless class. Reproduce both.
      SECOND_KEYS = %i[second_number second_part second_year second_type].freeze
      SECOND_OVERWRITES = { number: :second_number,
                            part: :second_part,
                            year: :second_year }.freeze

      def build(data)
        super(unflatten_combined(data))
      end

      private

      def unflatten_combined(data)
        return data unless SECOND_KEYS.any? { |k| data.key?(k) }

        data = data.dup
        data.delete(:type)
        SECOND_OVERWRITES.each do |target, source|
          data[target] = data.delete(source) if data.key?(source)
        end
        data
      end

      def default_identifier_class
        Identifiers::TypelessStandard
      end

      def select_class(data)
        TYPE_CLASS_MAP[data[:type]&.to_s] || default_identifier_class
      end

      def cast(key, value)
        case key
        # `:type` is consumed only by select_class for dispatch; it is not an
        # identifier attribute (the concrete class is pinned by `_type`). Drop it
        # so the raw Parslet::Slice never lands in the inherited :type attribute.
        # `:second_type` is the combined form's second type token, with
        # the same dispatch-only role (unflatten_combined has already
        # removed the first side's :type so the typeless class wins,
        # exactly as the tree backend's wrapper nesting did).
        when :type, :second_type then nil
        when :reaffirmation
          value.is_a?(Hash) ? (value[:year] || value).to_s : value.to_s
        # Every remaining key is a bare scalar. `:chapter` is a PARSE-TREE key
        # and keeps its name in the grammar; the ATTRIBUTE it feeds is `number`
        # (see handle_key below), which this branch retyped from
        # Components::Code to :string — so it now casts like the rest.
        when :number, :chapter, :part, :section, :subsection, :year
          value.to_s
        else
          super
        end
      end

      # Route the MPMS chapter into the `number` attribute. The shared
      # assign_attributes loop uses the parse-tree key as the setter name and
      # silently skips a key that is not an attribute, so without this the
      # chapter would simply vanish once `attribute :chapter` was removed.
      def handle_key(identifier, key, value)
        return super unless key.to_sym == :chapter

        identifier.number = value
        true
      end
    end
  end
end

Pubid::Api::Builder.prepend(Pubid::Builder::AllPartsWrap)
