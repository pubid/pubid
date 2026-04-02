require "lutaml/model"
# frozen_string_literal: true

module PubidNew
  module Etsi
    class Scheme < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :number, :string
      attribute :part, :string, collection: true, default: -> { [] }
      attribute :version, :string, default: -> {}
      attribute :edition, :string, default: -> {}
      attribute :date, :string
      attribute :amendment, :string, default: -> {}
      attribute :corrigendum, :string, default: -> {}

      def to_s
        result = "ETSI #{type} #{number}"

        # Add parts
        part.each do |p|
          result += "-#{p}"
        end

        # Add amendment or corrigendum
        result += "/A#{amendment}" if amendment
        result += "/C#{corrigendum}" if corrigendum

        # Add version or edition
        if version
          result += " V#{version}"
        elsif edition
          result += " ed.#{edition}"
        end

        # Add date (only if present)
        result += " (#{date})" if date

        result
      end
    end
  end
end
