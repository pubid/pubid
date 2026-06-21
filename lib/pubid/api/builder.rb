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

      private

      def default_identifier_class
        Identifiers::TypelessStandard
      end

      def select_class(data)
        TYPE_CLASS_MAP[data[:type]&.to_s] || default_identifier_class
      end

      def cast(key, value)
        case key
        when :number then Components::Code.new(value: value.to_s)
        when :reaffirmation
          value.is_a?(Hash) ? (value[:year] || value).to_s : value.to_s
        when :part, :chapter, :section, :subsection, :year
          value.to_s
        else
          super
        end
      end
    end
  end
end
