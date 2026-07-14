# frozen_string_literal: true

module Pubid
  module Gost
    # Human-readable renderer for GOST identifiers.
    #
    # Produces canonical Latin-script citations:
    #   "GOST 14946-82"
    #   "GOST R 34.12-2015"
    #   "GOST ISO 9692-1"
    #   "GOST R ISO/IEC ISP 10609-9-95"
    #   "GOST R 58904-2020/ISO/TR 25901-1:2016"
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        return render_identical_adoption(id) if id.is_a?(Identifiers::IdenticalAdoption)
        return render_standard(id)

        raise ArgumentError, "Unknown GOST identifier class: #{id.class}"
      end

      private

      def render_standard(id)
        rendered = +"GOST"
        rendered << " R" if id.is_a?(Identifiers::NationalStandard)
        rendered << " #{id.copublisher}" if id.copublisher
        rendered << " #{id.subtype}" if id.subtype
        rendered << " #{id.number}"
        rendered << "-#{id.year}" if id.year
        rendered
      end

      def render_identical_adoption(id)
        "#{id.base.to_s}/#{id.adopted.to_s}"
      end
    end
  end
end
