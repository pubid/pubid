# frozen_string_literal: true

module Pubid
  module Jcgm
    # Base class for JCGM supplement identifiers (amendments, corrigenda, etc.)
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true
      attribute :iteration, Pubid::Components::Code

      # lutaml's default polymorphic deserialization rebuilds the nested base
      # document as a bare Pubid::Jcgm::Identifier, dropping its concrete
      # Guide/GumGuide subclass — so a later render blows up on
      # publisher_portion. Re-run the base sub-hash through
      # Identifier.from_hash, which re-dispatches by `_type` to the concrete
      # class (JCGM's generic from_hash). This targeted
      # fixup keeps JCGM's default component auto-serialization intact (a full
      # explicit key_value remap would instead drop every auto-mapped
      # attribute from to_hash).
      def self.from_hash(data, options = {})
        identifier = super
        base = data && (data["base_identifier"] || data[:base_identifier])
        if base && identifier.respond_to?(:base_identifier=)
          identifier.base_identifier =
            ::Pubid::Jcgm::Identifier.from_hash(base, options)
        end
        identifier
      end

      # Delegate publisher to base_identifier
      def publisher
        base_identifier&.publisher
      end
    end
  end
end
