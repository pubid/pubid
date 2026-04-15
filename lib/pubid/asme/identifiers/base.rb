# frozen_string_literal: true

module Pubid
  module Asme
    module Identifiers
      class Base < SingleIdentifier
        def to_s
          # Handle joint published identifiers
          parts = []
          if first_publisher && first_code
            # CSA B44.10/ASME A17.10 or API 579-2/ASME PTB-14 format
            parts << first_publisher
            parts << first_code
            parts << "/#{second_publisher}" if second_publisher
            parts << code.to_s if code && code.to_s != ""

          elsif joint_publisher
            # ISO/ASME or ASME/ANS format
            parts << joint_publisher
            parts << code.to_s if code && code.to_s != ""

          else
            # Standard ASME format
            parts << publisher if publisher
            parts << code.to_s if code

          end
          result = parts.join(" ")

          # PTC suffix (space-separated)
          if ptc_suffix
            result += " #{ptc_suffix}"
          end

          # CSA dual-published (for ASME/CSA format)
          if csa_number
            result += "/CSA #{csa_number}"
          end

          # Handbook keyword
          if handbook
            result += " Handbook"
          end

          # Year
          if draft_year
            result += "-#{draft_year}"
          elsif year
            result += "-#{year}"
          end

          # Parenthetical revision (comes after year)
          result += " #{parenthetical_revision}" if parenthetical_revision

          # Language (can appear in rendered output)
          result += " (#{language})" if language

          # Reaffirmation
          result += " (#{reaffirmation})" if reaffirmation

          # Revision note
          result += " #{revision_note}" if revision_note

          # Normalize all em-dashes (–, —) and en-dashes to regular dash (-)
          result.gsub(/[–—]/, "-")
        end
      end
    end
  end
end
