module PubidNew
  module Idf
  end
end

require_relative "idf/identifiers/international_standard"
require_relative "idf/identifiers/reviewed_method"
require_relative "idf/identifiers/amendment"
require_relative "idf/identifiers/corrigendum"

module PubidNew
  module Idf
    IDENTIFIER_TYPES = [
      Identifiers::InternationalStandard,
      Identifiers::ReviewedMethod,
    ].freeze

    SUPPLEMENT_IDENTIFIER_TYPES = [
      Identifiers::Amendment,
      Identifiers::Corrigendum,
    ].freeze

    Scheme = PubidNew::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: SUPPLEMENT_IDENTIFIER_TYPES,
    )

    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new(Scheme)

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:idf, Idf)
end

require_relative "idf/builder"
require_relative "idf/parser"
