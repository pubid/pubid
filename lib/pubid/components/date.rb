# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Components
    # Publication date component
    #
    # Human render: "YYYY" or "YYYY-MM" or "YYYY-MM-DD"; or "--" when the
    # date slot is present but explicitly undated (ISO/IEC undated-reference
    # convention, e.g. "ISO 16634:--"). URN render: year only (RFC 5141-bis
    # URN spec); flavors that drop the slot when undated gate that decision
    # at the URN-generator level, not here.
    class Date < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :month, :string
      attribute :day, :string
      attribute :undated, :boolean, default: false

      # True when the year is set to a non-empty value, OR the date is
      # explicitly marked undated. An undated date is a meaningful
      # publication-date slot (it is what renders as `:--` in ISO/IEC), so
      # callers that gate rendering on "is there a date at all?" should
      # treat undated as present.
      def present?
        return true if undated
        !year.nil? && !year.to_s.empty?
      end

      def undated?
        !!undated
      end

      def render(context: nil)
        return "--" if undated? && (year.nil? || year.to_s.empty?)
        return nil unless present?
        return year.to_s if context&.urn?
        return year.to_s unless month

        result = "#{year}-#{pad2(month)}"
        result += "-#{pad2(day)}" if day
        result
      end

      def to_s(_context: nil, _include_month: false)
        return "--" if undated? && (year.nil? || year.to_s.empty?)
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
        @hash ||= [year, month, day, undated].compact.map(&:hash).hash
      end

      def eql?(other)
        return false unless other.is_a?(self.class)

        year == other.year && month == other.month && day == other.day &&
          undated == other.undated
      end
    end
  end
end
