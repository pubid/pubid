# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Expert Commentary Identifier
      # Wraps a base identifier with ExComm suffix
      class ExpertCommentary < Base
        attribute :base_identifier, Base, polymorphic: true

        def to_s
          "#{base_identifier.to_s} ExComm"
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