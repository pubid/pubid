require_relative "identifier"

module PubidNew
  # Identifier that represents a combined bundle of documents using the + operator.
  # Examples:
  #   EN 10077-1:2006+AC:2009+AC2:2009
  #   ISO/IEC DIR 1 + IEC SUP:2016-05
  #   ISO 8601:2019+Amd 1:2024+Cor 1:2025
  #
  # Semantic: Base document combined with amendments/corrigenda that are applied together
  # This is different from:
  #   / operator (SupplementIdentifier) - supplement of a document
  #   | operator (CombinedIdentifier) - dual-published by multiple organizations
  class BundledIdentifier < Identifier
    attribute :base_document, Identifier, polymorphic: true
    attribute :supplements, Identifier, polymorphic: true, collection: true
    attribute :type, :string, default: -> { 'bundled_identifier' }

    # Delegate common attributes to base_document for easier access
    def publisher
      base_document&.publisher
    end

    def copublishers
      base_document&.copublishers
    end

    def number
      base_document&.number
    end

    def date
      base_document&.date
    end

    def type
      base_document&.type
    end

    def stage
      base_document&.stage
    end

    def typed_stage
      base_document&.typed_stage
    end

    def to_s(lang: :en, lang_single: false)
      result = base_document.to_s(lang: lang, lang_single: lang_single)

      supplements.each do |supplement|
        # ISO DirectivesSupplement always uses " + " (space before)
        # CEN-style supplements (AC, A) without base_identifier use "+" (no space before)
        # Other ISO supplements with base_identifier use " + " (space before)
        if supplement.class.name&.include?("DirectivesSupplement") ||
           (supplement.respond_to?(:base_identifier) && !supplement.base_identifier.nil?)
          result += " + #{supplement.to_s(lang: lang, lang_single: lang_single)}"
        else
          result += "+#{supplement.to_s(lang: lang, lang_single: lang_single)}"
        end
      end

      result
    end

    # Support comparison for sorting
    def <=>(other)
      return nil unless other.is_a?(BundledIdentifier)

      base_comparison = base_document.to_s <=> other.base_document.to_s
      return base_comparison unless base_comparison.zero?

      supplements.map(&:to_s).sort <=> other.supplements.map(&:to_s).sort
    end
  end
end