# frozen_string_literal: true

require "parslet"
require_relative "../errors"

module Pubid
  module Parser
    # The superclass of every flavor grammar.
    #
    # Its only job is to keep parslet out of pubid's public contract. Every
    # grammar failure originates in `Parslet::Atoms::Base#parse`, which
    # `Parslet::Parser` does not override, so one override here covers all 46
    # grammars, both public entry points of every flavor, and the cross-flavor
    # delegation routes (`Pubid::Iso.parse("ITU-T G.711")` runs ITU's grammar)
    # — without touching the 131 `parse` methods.
    #
    # The name is `Grammar`, not `Base`, because {Pubid::Parsers::Base} already
    # exists and means something unrelated (the MR-string parser).
    #
    # Known limit: a rule atom parsed directly, `Parser.new.<rule>.parse(str)`,
    # bypasses this and raises a bare `Parslet::ParseFailed`. Nothing in the
    # gem does that.
    class Grammar < ::Parslet::Parser
      # @param io [String, IO]
      # @param options [Hash] passed through to parslet
      # @raise [Pubid::Errors::ParseError]
      def parse(io, options = {})
        super
      rescue ::Pubid::Errors::ParseError
        # A nested grammar already wrapped it. Keep the inner flavor and input.
        raise
      rescue ::Parslet::ParseFailed => e
        raise wrap_parse_failure(e, io)
      end

      private

      # @param error [Parslet::ParseFailed]
      # @param io [String, IO] what was handed to {#parse}
      # @return [Pubid::Errors::ParseError]
      def wrap_parse_failure(error, io)
        ::Pubid::Errors::ParseError.new(
          error.message,
          error.parse_failure_cause,
          input: io.is_a?(String) ? io : nil,
          flavor: pubid_flavor_name,
        )
      end

      # "Pubid::Iso::Parser" -> "iso"; "Pubid::Ieee::Aiee::Parser" -> "ieee".
      #
      # Resolved through {Pubid::Registry} rather than taken from the module
      # name, because the two disagree: `Pubid::Tgpp` registers as `"3gpp"`,
      # and `Pubid::CenCenelec` registers twice (`"cen_cenelec"` first, then
      # the `"cen"` alias). Reporting the registered name is what lets a caller
      # feed `error.flavor` straight back to `Pubid::Registry.get`.
      # @return [String, nil]
      def pubid_flavor_name
        parts = self.class.name.to_s.split("::")
        return nil unless parts[0] == "Pubid" && parts.length > 1

        registered_flavor_name(parts[1]) || parts[1].downcase
      end

      # @param module_name [String] e.g. "Tgpp"
      # @return [String, nil] the registered name, nil if not registered
      def registered_flavor_name(module_name)
        ::Pubid::Registry.canonical_name(::Pubid.const_get(module_name))
      rescue ::NameError
        nil
      end
    end
  end
end
