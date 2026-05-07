# frozen_string_literal: true

module Pubid
  module Astm
    class SingleIdentifier < Pubid::Identifier
      # Generate URN for this identifier
      #
      # @return [String] URN representation
      attribute :publisher, :string, default: -> { "ASTM" }
      attribute :code, Components::Code
      attribute :year, :string
      attribute :format_suffix, :string # -EB for eBook

      def to_s
        parts = []
        parts << publisher if publisher
        parts << prefix if self.class.attributes.key?(:prefix) && prefix
        parts << code.to_s if code
        parts << "-#{year}" if year
        parts << format_suffix if format_suffix
        parts.join(" ")
      end
    end
  end
end
