# frozen_string_literal: true

module Pubid
  module Plateau
    # Human-readable renderer for PLATEAU identifiers.
    #
    # Produces strings like:
    #   "PLATEAU Technical Report #01"
    #   "PLATEAU Handbook #00 第1.0版"
    #   "PLATEAU Handbook #01-1 Annex A"
    #
    # The renderer is registered as the `:human` format in the PLATEAU format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **opts)
        id = @id

        case id
        when SupplementIdentifier
          render_supplement(id)
        when Identifiers::Handbook
          render_handbook(id)
        when Identifiers::TechnicalReport
          render_technical_report(id)
        else
          render_base(id)
        end
      end

      private

      def render_base(id)
        "#{id.publisher} #{id.type_string} #{id.formatted_number}#{id.formatted_annex}"
      end

      def render_technical_report(id)
        "#{id.publisher} #{id.type_string} #{id.formatted_number}#{id.formatted_annex}"
      end

      def render_handbook(id)
        result = "#{id.publisher} #{id.type_string} #{id.formatted_number}#{id.formatted_annex}"
        result += " #{id.formatted_edition}" if id.edition
        result
      end

      def render_supplement(id)
        "#{id.base_identifier} #{id.supplement_string}"
      end
    end
  end
end
