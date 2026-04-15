# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Standard identifier for IEEE standards
      #
      # Represents published IEEE standards with the standard format:
      # "IEEE Std XXX-YYYY"
      #
      # @example Standard IEEE identifier
      #   std = Pubid::Ieee.parse("IEEE Std 802.3-2018")
      #   std.code.to_s  # => "802.3"
      #   std.year       # => "2018"
      #
      # @example With co-publisher
      #   std = Pubid::Ieee.parse("ANSI/IEEE Std 500-1984")
      #   std.publisher        # => "IEEE"
      #   std.copublisher     # => ["ANSI"]
      class Standard < Base
        # TYPED_STAGES for published IEEE standards
        # Standards use "Std" abbreviation for published state
        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Std"],
            type_code: "standard",
            stage_code: "published",
          ),
        ].freeze

        def self.type
          { key: :std, title: "Standard", short: "Std" }
        end

        # Render standard IEEE format
        #
        # @return [String] IEEE Std XXX-YYYY format
      end
    end
  end
end
