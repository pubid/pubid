# frozen_string_literal: true

module Pubid
  module Components
    # Document code/number component
    #
    # Renders as its bare value regardless of format (human, URN, MR).
    # Subclasses (ISO, IEC, NIST) extend the model with prefixes or
    # subparts but inherit the rendering seam.
    class Code < Lutaml::Model::Serializable
      attribute :value, :string

      def to_s
        value.to_s
      end

      # Format-aware render seam. Same output for every format today;
      # components with format-specific shapes override this.
      def render(context: nil)
        value.to_s
      end

      def hash
        @hash ||= value.hash
      end

      def eql?(other)
        return false unless other.is_a?(self.class)

        value == other.value
      end
    end
  end
end
