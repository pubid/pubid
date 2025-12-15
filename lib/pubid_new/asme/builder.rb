# frozen_string_literal: true

module PubidNew
  module Asme
    class Builder
      def build(parsed_hash)
        identifier = Identifiers::Standard.new

        # Build code component
        if parsed_hash[:designator]
          identifier.code = build_code(parsed_hash)
        end

        # Set publisher
        identifier.publisher = "ASME"

        # Set year
        if parsed_hash[:year]
          identifier.year = parsed_hash[:year].to_s
        end

        # Set draft year
        if parsed_hash[:draft_year]
          identifier.draft_year = parsed_hash[:draft_year].to_s
        end

        # Set reaffirmation
        if parsed_hash[:reaffirmation]
          identifier.reaffirmation = "R#{parsed_hash[:reaffirmation]}"
        end

        # Set language
        if parsed_hash[:language]
          identifier.language = parsed_hash[:language].to_s
        end

        # Set CSA number
        if parsed_hash[:csa_number]
          identifier.csa_number = parsed_hash[:csa_number].to_s
        end

        # Set revision note
        if parsed_hash[:revision_note]
          identifier.revision_note = "[#{parsed_hash[:revision_note]}]"
        end

        identifier
      end

      private

      def build_code(parsed_hash)
        code = Components::Code.new
        code.designator = parsed_hash[:designator].to_s
        code.number = parsed_hash[:number].to_s if parsed_hash[:number]
        code
      end
    end
  end
end
