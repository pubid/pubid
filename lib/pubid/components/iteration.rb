# frozen_string_literal: true

module Pubid
  module Components
    # Stage iteration component — the numeric suffix on a stage (e.g., "WD.2").
    #
    # Renders as the bare number; the caller decides the separator (".")
    # because URN, MR, and human formats position iteration differently
    # relative to the stage abbreviation.
    class Iteration < Lutaml::Model::Serializable
      attribute :number, :string

      def to_s
        number.to_s
      end

      def render(context: nil)
        number.to_s
      end

      def hash
        @hash ||= number.hash
      end

      def eql?(other)
        return false unless other.is_a?(self.class)

        number == other.number
      end
    end
  end
end
