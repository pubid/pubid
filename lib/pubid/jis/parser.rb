# frozen_string_literal: true

module Pubid
  module Jis
    # The JIS grammar is the vendored artifact data/parg/jis.json. This class
    # holds only the Ruby ingestion in front of it.
    class Parser
      # A WES type token or a language before the year. Full-width forms
      # are accepted, as in the grammar.
      WES_SHIM = /
        \A(?<root>WES[ 　])
        (?:(?<type>TR|TS)[ 　])?
        (?<number>\d+(?:[-ｰ]\d+)*)
        (?:[(（](?<lang>[EJ])[)）](?=[:：]))?
      /x

      # The vendored grammar (pubid-grammar artifacts/jis.json) reads neither
      # "WES TR 2032" nor "WES 1112(E):2022". Until it does, cut those tokens
      # from the input and bind them as `wes_type` and `wes_language`, the
      # captures the grammar is to bind (hand-off
      # pubid__pubid-grammar__jis-wes-language-tr-ts). Other input passes
      # unchanged.
      # @param input [String]
      # @return [Array(String, Hash)] the input for the grammar, the bindings
      #   to merge into what the grammar binds
      def self.ingest(input)
        match = WES_SHIM.match(input)
        return [input, {}] unless match && (match[:type] || match[:lang])

        bindings = {}
        bindings[:wes_type] = match[:type] if match[:type]
        bindings[:wes_language] = match[:lang] if match[:lang]
        rest = input[match.end(0)..]
        ["#{match[:root]}#{match[:number]}#{rest}", bindings]
      end
    end
  end
end
