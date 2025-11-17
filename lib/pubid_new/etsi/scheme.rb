require "lutaml/model"

module PubidNew
  module Etsi
    class Scheme < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :number, :string
      attribute :part, :string, collection: true, default: -> { [] }
      attribute :version, :string, default: -> { nil }
      attribute :edition, :string, default: -> { nil }
      attribute :date, :string
      attribute :amendment, :string, default: -> { nil }
      attribute :corrigendum, :string, default: -> { nil }

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
        
        # Add date
        result += " (#{date})"
        
        result
      end
    end
  end
end