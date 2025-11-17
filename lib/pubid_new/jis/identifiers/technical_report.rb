require "lutaml/model"
require_relative "../single_identifier"

module PubidNew
  module Jis
    module Identifiers
      class TechnicalReport < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :jis_tr,
            stage_code: :published,
            type_code: :tr,
            abbr: ["TR"],
            name: "Technical Report",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :tr, title: "Technical Report", short: "TR" }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []
          
          # Publisher (JIS)
          parts << publisher.body if publisher
          
          # Type (TR)
          parts << "TR"
          
          # Series and number
          if series && number
            parts << "#{series.value} #{number.value}"
          elsif number
            parts << number.value
          end
          
          result = parts.join(" ")
          
          # Part
          result += "-#{part.value}" if part
          
          # Date
          result += ":#{date.year}" if date
          
          # Language
          result += "(#{language.value})" if language
          
          result
        end
      end
    end
  end
end