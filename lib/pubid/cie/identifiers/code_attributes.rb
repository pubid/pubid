# frozen_string_literal: true

module Pubid
  module Cie
    module Identifiers
      # Shared document-code attributes + rendering for the CIE identifier
      # types that carry a code (Standard, Identical, JointPublished,
      # DualPublished).
      #
      # The code fields live *flat* on the identifier (no nested
      # Components::Code), so the serialized hash stays compact:
      #   {style:, year:, ..., number: "018", iteration: "2"}
      # rather than nesting them under a code: {number:, iteration:, style:}.
      #
      # +code.style+ is intentionally gone: it always equalled the identifier's
      # own +style+ (the builder set both from one value), so #code_string reads
      # the identifier's +style+ directly for the part-separator fallback.
      module CodeAttributes
        def self.included(base)
          base.class_eval do
            attribute :number, :string        # "018", "170", "11664"
            attribute :part, :string          # "1", "2", "4"
            attribute :iteration, :string     # "2" in "018.2"
            attribute :part_separator, :string # "slash" | "dash" (original sep)
          end
        end

        # Render the code portion: "018.2", "170-1", "19/2.1", "11664-1".
        # Uses +part_separator+ when set, otherwise falls back to the
        # identifier's +style+ (legacy -> "/", current -> "-").
        def code_string
          return nil unless number

          result = number.dup
          if part && iteration
            result += "/#{part}.#{iteration}"
          elsif iteration
            result += ".#{iteration}"
          elsif part
            separator = case part_separator
                        when "slash" then "/"
                        when "dash" then "-"
                        else style == "current" ? "-" : "/"
                        end
            result += "#{separator}#{part}"
          end
          result
        end
      end
    end
  end
end
