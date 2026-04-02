# frozen_string_literal: true

require_relative "../serializable"

require_relative "identifier"
require_relative "../components/typed_stage"
require_relative "components/publisher"
require_relative "../components/code"
require_relative "../components/date"
require_relative "../components/language"

module PubidNew
  module Jcgm
    class SingleIdentifier < Identifier
      include PubidNew::Serializable

      attribute :publisher, Jcgm::Components::Publisher
      attribute :typed_stage, PubidNew::Components::TypedStage
      attribute :number, PubidNew::Components::Code
      attribute :date, PubidNew::Components::Date
      attribute :languages, PubidNew::Components::Language, collection: true
      attribute :stage, PubidNew::Components::Stage
      attribute :type, PubidNew::Components::Type

      # Generate URN for this identifier
      #
      # @return [String] URN representation
      def to_urn
        require_relative "urn_generator"
        UrnGenerator.new(self).generate
      end

      def publisher_portion
        publisher.to_s
      end

      def number_portion
        parts = []
        parts << number.value if number
        parts << ":#{date.year}" if date
        parts.join("")
      end

      def language_portion
        return "" unless languages&.any?

        [
          "(",
          languages.map(&:original_code).join("/"),
          ")",
        ].join("")
      end

      def to_s
        parts = [publisher_portion]
        parts << number_portion unless number_portion.empty?
        result = parts.join(" ")
        result += language_portion
        result
      end
    end
  end
end
