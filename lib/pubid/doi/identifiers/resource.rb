# frozen_string_literal: true

module Pubid
  module Doi
    module Identifiers
      # Concrete DOI identifier type.
      #
      # Examples:
      #   doi:10.1000/182
      #   10.6028/NIST.2022-04-15.001
      #   https://doi.org/10.1006/jmbi.1998.2354
      class Resource < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubdoi,
            stage_code: :published,
            type_code: :doi,
            abbr: ["DOI"],
            name: "DOI",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :doi, web: :doi, title: "DOI", short: "DOI" }
        end
      end
    end
  end
end
