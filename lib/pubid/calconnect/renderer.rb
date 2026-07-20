# frozen_string_literal: true

module Pubid
  module Calconnect
    # Human-readable renderer for CalConnect identifiers.
    #
    # Produces the canonical printed form, e.g.:
    #   "CC 18011:2018"
    #   "CC/DIR 10006:2019"
    #   "CC/WD 51017:2024-07-23"
    #   "DIR 10006:2019"          (only when with_publisher: false)
    #
    # Registered as the `:human` format in the CalConnect format registry and
    # invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      PUBLISHER = "CC"

      def render(**_opts)
        id = @id
        prefix = if with_publisher?(id)
                   id.series ? "#{PUBLISHER}/#{id.series} " : "#{PUBLISHER} "
                 else
                   id.series ? "#{id.series} " : ""
                 end
        date = id.date_string
        "#{prefix}#{id.number}#{":#{date}" if date}"
      end

      private

      def with_publisher?(id)
        id.respond_to?(:with_publisher) && id.with_publisher != false
      end
    end
  end
end
