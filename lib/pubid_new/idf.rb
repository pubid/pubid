module PubidNew
  module Idf
  end
end

require_relative "idf/identifiers/international_standard"
require_relative "idf/identifiers/reviewed_method"

module PubidNew
  module Idf
    IDENTIFIER_TYPES = [
      Identifiers::InternationalStandard,
      Identifiers::ReviewedMethod,
    ].freeze

    SUPPLEMENT_IDENTIFIER_TYPES = [
    ].freeze

    Scheme = PubidNew::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: SUPPLEMENT_IDENTIFIER_TYPES,
    )
  end
end

require_relative "idf/builder"
require_relative "idf/parser"
