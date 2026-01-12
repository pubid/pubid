require_relative "../identifier"
require_relative "identifier"

module PubidNew
  module Iso
    # Identifier that represents a bundled identifier with base document and supplements
    # E.g., "ISO/IEC DIR 1 + IEC SUP:2016-05" or "ISO/IEC DIR 1:2022 + IEC SUP:2022"
    class BundledIdentifier < Identifier
      attribute :base_document, Identifier, polymorphic: true
      attribute :supplements, ::PubidNew::Identifier, polymorphic: true,
                                                      collection: true
      attribute :type, :string, default: -> { "bundled_identifier" }

      def to_s(lang: :en, lang_single: false, with_edition: false, format: nil,
stage_format_long: nil, with_date: nil)
        parts = [base_document.to_s(lang: lang, lang_single: lang_single,
                                    with_edition: with_edition, format: format, stage_format_long: stage_format_long, with_date: with_date)]

        # Add each supplement with "+" separator
        supplements.each do |supplement|
          # Use special to_supplement_s method if available (for DirectivesSupplement)
          supplement_str = if supplement.respond_to?(:to_supplement_s)
                             supplement.to_supplement_s(lang: lang, lang_single: lang_single,
                                                        with_edition: with_edition, format: format, stage_format_long: stage_format_long, with_date: with_date)
                           else
                             supplement.to_s(lang: lang, lang_single: lang_single,
                                             with_edition: with_edition, format: format, stage_format_long: stage_format_long, with_date: with_date)
                           end
          parts << "+ #{supplement_str}"
        end

        parts.join(" ")
      end
    end
  end
end
