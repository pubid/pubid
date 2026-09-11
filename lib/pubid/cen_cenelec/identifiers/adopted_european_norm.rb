# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # AdoptedEuropeanNorm wraps ISO/IEC identifiers
      # Example: "EN ISO 8601:2019" where ISO 8601:2019 is an ISO identifier object
      #
      # `publisher` is the inherited Components::Publisher ("EN", "CEN",
      # "CR", "HD"); a second publisher goes in `copublishers`. It used to be
      # an Array of Strings in that Components::Publisher attribute, so
      # `to_hash` raised on every adopted norm.
      class AdoptedEuropeanNorm < EuropeanNorm
        # Typed to the root class: the adopted document is an ISO or IEC
        # identifier, never a CEN one.
        attribute :adopted, ::Pubid::Identifier, polymorphic: true

        # Override self.type to return nil so that AdoptedEuropeanNorm is NOT
        # registered as a type in CenCenelec.identifier_types. The class is a
        # polymorphic wrapper that wraps an adopted ISO/IEC identifier under an
        # EN publisher; it is constructed explicitly by Builder#build_adopted_identifier,
        # not selected via type-code lookup. Returning nil here prevents
        # identifier_types auto-discovery from shadowing EuropeanNorm (which
        # also reports :en) in CenCenelec.locate_type(:en).
        def self.type
          nil
        end

        # Walk to the adopted document for the relaton-index key.
        #
        # This replaces reader methods named number, year, date, parts and
        # part that delegated to the adopted document. `number`, `date` and
        # `part` are lutaml attributes, so the serializer read the ISO values
        # through them and wrote them again at the top level of the hash.
        # `#root` is the documented wrapper shape (EuropeanPrestandard,
        # ConsolidatedIdentifier).
        def root
          adopted ? adopted.root : self
        end

        # MR "cen.iso.ts.21003-7.2019": the CEN publisher ("cen" or
        # "cen-clc"), then the adopted document's own MR string in place of a
        # number. These are hooks and not a `to_mr_string` override, so the
        # MR of an amendment on this norm renders its base the same way.
        def mr_publisher
          mr_join(*([publisher] + Array(copublishers)).compact
            .map { |p| p.to_s.downcase })
        end

        def mr_number_with_part
          adopted&.to_mr_string
        end
      end
    end
  end
end
