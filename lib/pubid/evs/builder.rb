# frozen_string_literal: true

module Pubid
  module Evs
    # Builds an EVS national adoption from the composed parse tree: the
    # structured :adopted subtree (produced by the embedded CEN grammar) goes
    # straight to the CEN/CENELEC builder as data — no string
    # re-serialization anywhere.
    class Builder < Pubid::Builder::Base
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        data = flatten_array(data) if data.is_a?(Array)

        adopted = Pubid::CenCenelec::Builder.build(data[:adopted])

        Identifiers::NationalAdoption.new(
          base: adopted,
          separator: data[:evs_separator] || "-",
        )
      end
    end
  end
end

Pubid::Evs::Builder.prepend(Pubid::Builder::AllPartsWrap)
