# frozen_string_literal: true

module Pubid
  module Arxiv
    # Human-readable renderer for arXiv ids.
    #
    # Prints the canonical colon form `arXiv:<id>` whatever prefix the input
    # used, and the bare id for `with_publisher: false` — the form the arXiv
    # API takes in `id_list`.
    class Renderer < ::Pubid::Renderers::Base
      def render(with_publisher: nil, **_opts)
        bare = "#{body}#{version}"
        with_publisher == false ? bare : "#{Identifier::PUBLISHER}:#{bare}"
      end

      private

      def body
        return "#{@id.yymm}.#{@id.number}" unless @id.old_style?

        archive = [@id.archive, @id.subject_class].compact.join(".")
        "#{archive}/#{@id.yymm}#{@id.number}"
      end

      def version
        @id.version ? "v#{@id.version}" : ""
      end
    end
  end
end
