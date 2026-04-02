require "lutaml/model"
# frozen_string_literal: true

module Pubid
  module Plateau
    class Scheme < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :number, :integer
      attribute :annex, :integer, default: -> {}
      attribute :edition, :string, default: -> {}

      def to_s
        result = "PLATEAU #{type_string} #{formatted_number}"
        result += formatted_annex if annex
        result += " #{formatted_edition}" if edition
        result
      end

      private

      def type_string
        case type
        when "Handbook"
          "Handbook"
        when "Technical Report"
          "Technical Report"
        else
          type
        end
      end

      def formatted_number
        "#%02d" % number
      end

      def formatted_annex
        "-#{annex}"
      end

      def formatted_edition
        "第#{edition}版"
      end
    end
  end
end
