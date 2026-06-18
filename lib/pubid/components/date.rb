# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Components
    # Publication date component
    #
    # Human render: "YYYY" or "YYYY-MM" or "YYYY-MM-DD".
    # URN render: year only (RFC 5141-bis URN spec).
    class Date < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :month, :string
      attribute :day, :string

      # True when the year is set to a non-empty value.
      def present?
        !year.nil? && !year.to_s.empty?
      end

      def render(context: nil)
        return nil unless present?
        return year.to_s if context&.urn?
        return year.to_s unless month

        result = "#{year}-#{pad2(month)}"
        result += "-#{pad2(day)}" if day
        result
      end

      def to_s(_context: nil, _include_month: false)
        return year.to_s unless month

        result = "#{year}-#{pad2(month)}"
        result += "-#{pad2(day)}" if day
        result
      end

      private

      def pad2(value)
        value.to_s.rjust(2, "0")
      end

      def hash
        @hash ||= [year, month, day].compact.map(&:hash).hash
      end

      def eql?(other)
        return false unless other.is_a?(self.class)

        year == other.year && month == other.month && day == other.day
      end
    end
  end
end
