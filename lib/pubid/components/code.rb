# frozen_string_literal: true

module Pubid
  module Components
    # Document code/number component.
    #
    # Holds the structured fields that recur across flavors: the main +value+
    # (always present), plus optional +prefix+ (series/type designator),
    # +part+, +subpart+, and free-form +parts+. Subclasses own their
    # composition rules — flavor-specific separators and orderings live in
    # the subclass #to_s / #render override.
    class Code < Lutaml::Model::Serializable
      attribute :value, :string
      attribute :prefix, :string
      attribute :part, :string
      attribute :subpart, :string
      attribute :parts, :string, collection: true

      def to_s
        value.to_s
      end

      # Format-aware render seam. Default returns the bare value; subclasses
      # override to compose flavor-specific shapes (e.g. ISO joins parts
      # with "-", NIST joins subpart with ".").
      def render(context: nil)
        value.to_s
      end

      def hash
        [value, prefix, part, subpart, parts].hash
      end

      # rubocop:disable Metrics/AbcSize
      def eql?(other)
        return false unless other.is_a?(self.class)

        value == other.value &&
          prefix == other.prefix &&
          part == other.part &&
          subpart == other.subpart &&
          parts == other.parts
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
