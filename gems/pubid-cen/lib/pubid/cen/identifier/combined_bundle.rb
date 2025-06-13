require_relative "../renderer/combined_bundle"

module Pubid::Cen
  module Identifier
    class CombinedBundle < Base
      def_delegators 'Pubid::Cen::Identifier::CombinedBundle', :type

      attribute :base_document, :string
      attribute :amendments, :string, collection: true
      attribute :corrigendums, :string, collection: true

      def self.type
        { key: :combined, title: "Combined Bundle" }
      end

      def self.get_renderer_class
        Renderer::CombinedBundle
      end

      def to_s
        get_renderer_class.new(self).render
      end

      def <=>(other)
        return nil unless other.is_a?(CombinedBundle)

        base_comparison = base_document.to_s <=> other.base_document.to_s
        return base_comparison unless base_comparison.zero?

        amendments_comparison = amendments.map(&:to_s).sort <=> other.amendments.map(&:to_s).sort
        return amendments_comparison unless amendments_comparison.zero?

        corrigendums.map(&:to_s).sort <=> other.corrigendums.map(&:to_s).sort
      end
    end
  end
end
