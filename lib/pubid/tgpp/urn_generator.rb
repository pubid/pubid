# frozen_string_literal: true

module Pubid
  module Tgpp
    # Emits `urn:3gpp:<type>:<code>:<release>:<version>`, e.g.
    # `urn:3gpp:ts:23.207:REL-4:2.0.0`. `<code>` is number+suffix+parts.
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        [
          "urn",
          "3gpp",
          identifier.type_prefix.downcase,
          identifier.code,
          identifier.release,
          identifier.version,
        ].join(":")
      end
    end
  end
end
