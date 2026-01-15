# frozen_string_literal: true

require "lutaml/model"
require_relative "../supplement_identifier"
require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Ashrae
    module Identifiers
      # Errata identifier for ASHRAE standards and guidelines
      # Represents corrections/errata for a base standard
      # Examples:
      # - ASHRAE Guideline 0-2005 Errata (September 28, 2011)
      # - ANSI/ASHRAE Standard 62.1-2004 Errata (May 4, 2007)
      class Errata < SupplementIdentifier
        attribute :errata_date, :string

        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Errata"],
            type_code: "errata",
            stage_code: "published",
          ),
        ].freeze

        def self.type
          { key: :errata, title: "ASHRAE Errata", short: "Errata" }
        end

        def to_s
          return base_identifier.to_s unless base_identifier

          # Format: ASHRAE Guideline 0-2005 Errata (September 28, 2011)
          result = base_identifier.to_s
          result += " Errata"
          result += " (#{errata_date})" if errata_date
          result
        end
      end
    end
  end
end
