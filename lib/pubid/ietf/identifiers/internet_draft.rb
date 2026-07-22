# frozen_string_literal: true

module Pubid
  module Ietf
    module Identifiers
      # An Internet-Draft, e.g. "draft-giuliano-treedn-02" (versioned) or
      # "draft-giuliano-treedn" (the unversioned "latest" sibling). The full
      # slug (including the leading "draft-") is stored in `name`; the optional
      # trailing two-digit version in `version`.
      class InternetDraft < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :internet_draft,
            stage_code: :draft,
            type_code: :internet_draft,
            abbr: ["I-D", "Internet-Draft"],
            name: "Internet-Draft",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :internet_draft, web: :internet_draft,
            title: "Internet-Draft", short: "I-D" }
        end
      end
    end
  end
end
