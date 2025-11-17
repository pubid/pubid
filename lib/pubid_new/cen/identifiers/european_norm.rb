require "lutaml/model"
require_relative "../single_identifier"

module PubidNew
  module Cen
    module Identifiers
      class EuropeanNorm < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          # Published European Norm
          Components::TypedStage.new(
            code: :puben,
            stage_code: :published,
            type_code: :en,
            abbr: ["EN"],
            name: "European Norm",
            harmonized_stages: %w[60.00 60.60],
          ),
          # Proposal stage
          Components::TypedStage.new(
            code: :pren,
            stage_code: :proposal,
            type_code: :en,
            abbr: ["prEN"],
            name: "Proposal European Norm",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
          ),
          # Final proposal stage
          Components::TypedStage.new(
            code: :fpren,
            stage_code: :final_proposal,
            type_code: :en,
            abbr: ["FprEN"],
            name: "Final Proposal European Norm",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.98 40.99],
          ),
        ].freeze

        def self.type
          { key: :en, title: "European Norm", short: "EN" }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []
          
          # Stage prefix (prEN, FprEN)
          if typed_stage && typed_stage.abbr.first != "EN"
            parts << typed_stage.abbr.first
          else
            parts << publisher.body if publisher
          end
          
          # Copublishers
          if copublishers && copublishers.any?
            parts << copublishers.map(&:body).join("/")
          end
          
          # Number with part/subpart
          number_str = number.value
          number_str += "-#{part.value}" if part
          number_str += "-#{subpart.value}" if subpart
          parts << number_str
          
          result = parts.join(" ")
          
          # Date
          result += ":#{date.year}" if date
          
          result
        end
      end
    end
  end
end