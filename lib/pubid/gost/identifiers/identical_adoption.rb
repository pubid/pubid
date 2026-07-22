# frozen_string_literal: true

module Pubid
  module Gost
    module Identifiers
      # Identical adoption (IDT per ISO Guide 2). The GOST is
      # structurally and technically identical to the adopted
      # foreign standard. The slash IS part of the official
      # GOST designation.
      #
      # Examples:
      #   ГОСТ 31610.18-2016/IEC 60079-18:2014
      #   ГОСТ Р 58904-2020/ISO/TR 25901-1:2016
      #   ГОСТ 31425.5-2025/ISO 9902-5:2001
      #
      # The MOD and NEQ degrees are NOT modeled here — they're
      # bibliographic metadata (Relaton relations), not part of the
      # identifier.
      class IdenticalAdoption < Identifier
        attribute :base, ::Pubid::Gost::Identifier, polymorphic: true
        attribute :adopted, ::Pubid::Identifier, polymorphic: true

        key_value do
          map "base",    to: :base
          map "adopted", to: :adopted
        end

        def self.type
          { key: :"identical-adoption", title: "Identical Adoption", short: nil }
        end

        def number; base&.number; end
        def year; base&.year; end
        def copublisher; base&.copublisher; end
        def subtype; base&.subtype; end
      end
    end
  end
end
