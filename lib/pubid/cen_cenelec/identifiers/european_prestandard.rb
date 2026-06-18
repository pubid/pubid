# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module CenCenelec
    module Identifiers
      class EuropeanPrestandard < SingleIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }
        attribute :adopted_identifier, Pubid::Identifier, polymorphic: true

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubenv,
            stage_code: :published,
            type_code: :env,
            abbr: ["ENV"],
            name: "European Prestandard",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :env,
            web: :european_prestandard, title: "European Prestandard", short: "ENV" }
        end

        def to_s(lang: :en, lang_single: false, **opts)
          render(format: :human, lang: lang, lang_single: lang_single, **opts)
        end
      end
    end
  end
end
