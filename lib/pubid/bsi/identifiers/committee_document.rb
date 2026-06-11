# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # CommitteeDocument represents BSI committee draft documents
      # Format: YY/NNNNNNNN DC (2-digit year, 8-digit number, DC suffix)
      #
      # Examples:
      #   14/30300822 DC
      #   21/30445138 DC
      #   24/30300822 DC
      class CommitteeDocument < SingleIdentifier
        attribute :document_number, :string # The 8-digit document number

        # TYPED_STAGES for committee documents (draft by default)
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :draft_committee,
            stage_code: :draft,
            type_code: :committee_document,
            abbr: ["DC"],
            name: "Draft Committee Document",
            harmonized_stages: %w[30.00 30.20 30.60 40.00 40.20 40.60],
          ),
        ].freeze

        def self.type
          { key: :committee_document, title: "Committee Document", short: "DC" }
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
