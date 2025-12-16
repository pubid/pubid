# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Api
    module Identifiers
      class Mpms < Base
        attribute :chapter, :string
        attribute :section, :string
        attribute :subsection, :string

        def type_string
          "MPMS"
        end

        def to_s
          parts = ["API", "MPMS"]
          
          # Add chapter
          parts << "CH #{chapter}" if chapter
          
          # Add section/subsection
          if section
            parts << ".#{section}"
            parts << ".#{subsection}" if subsection
          end
          
          # Add year
          parts << "-#{year}" if year
          
          parts.join(" ").gsub(" .", ".")
        end

        private

        def code_portion
          # Override - MPMS doesn't use code_portion
          nil
        end
      end
    end
  end
end