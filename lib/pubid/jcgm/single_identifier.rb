# frozen_string_literal: true

module Pubid
  module Jcgm
    class SingleIdentifier < Identifier
      attribute :publisher, Jcgm::Components::Publisher
      attribute :typed_stage, Pubid::Components::TypedStage
      attribute :number, Pubid::Components::Code
      attribute :date, Pubid::Components::Date
      attribute :languages, Pubid::Components::Language, collection: true
      attribute :stage, Pubid::Components::Stage
      attribute :type, Pubid::Components::Type

      # Generate URN for this identifier
      #
      # @return [String] URN representation

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

      def to_s
        render(format: :human)
      end
    end
  end
end
