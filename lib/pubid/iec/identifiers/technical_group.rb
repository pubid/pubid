# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Technical Group identifier — identifies a committee rather than a
      # publication. Covers:
      #
      #   IEC TC 1             (Technical Committee)
      #   IEC PC 118           (Project Committee)
      #   ISO/IEC JTC 1        (Joint Technical Committee)
      #   ISO/IEC JPC 2        (Joint Project Committee)
      #   ISO/IEC JTC 1/SC 7   (Joint TC with Subcommittee)
      #   IEC SC 100A          (Subcommittee with letter suffix)
      #   CIS/A                (CISPR Subcommittee, bare form)
      #   CISPR                (CISPR Committee, bare form)
      class TechnicalGroup < Base
        attribute :technical_committee, :string
        attribute :subcommittee, :string

        TYPED_STAGES = [].freeze

        def self.type
          { key: :tg,
            web: :technical_group, title: "Technical Group", short: "TG" }
        end
      end
    end
  end
end
