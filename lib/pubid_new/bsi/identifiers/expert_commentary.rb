# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Expert Commentary Identifier
      # Wraps a base identifier with Expert Commentary suffix
      # Three formats:
      # 1. "Expert Commentary" (full form)
      # 2. "ExComm" (abbreviated form)
      # 3. "ExComm (Fire)" (with optional topic suffix)
      class ExpertCommentary < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :format, :string  # "full", "abbr", "abbr_with_topic"
        attribute :topic, :string  # e.g., "Fire"

        def to_s
          base_str = base_identifier.to_s
          # Ensure suffix appears only once at the end
          base_str = base_str.sub(/ (Expert Commentary|ExComm(\s*\(.*\))?)$/, "")

          case format
          when "full"
            "#{base_str} Expert Commentary"
          when "abbr_with_topic"
            "#{base_str} ExComm (#{topic})"
          else  # "abbr" (default)
            "#{base_str} ExComm"
          end
        end

        def publisher
          base_identifier&.publisher
        end

        def number
          base_identifier&.number
        end

        def year
          base_identifier&.year
        end
      end
    end
  end
end