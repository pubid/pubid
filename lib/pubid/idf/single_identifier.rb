# frozen_string_literal: true

module Pubid
  module Idf
    # Base class for single IDF identifiers (base documents)
    #
    # This class provides common attributes for all base document types
    # like InternationalStandard and ReviewedMethod.
    #
    # Supplement identifiers (amendments, corrigenda) should NOT inherit
    # from this class - they should inherit directly from Identifier.
    #
    # Note: The type attribute is inherited from the base Identifier class.
    # Concrete classes should add their own default value like:
    #   attribute :type, Components::Type, default: -> { self.class.type[:key] }
    class SingleIdentifier < Identifier
    end
  end
end
