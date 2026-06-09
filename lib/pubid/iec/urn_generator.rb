# frozen_string_literal: true

module Pubid
  module Iec
    # Generates IEC URNs in the legacy positional format used as ground truth
    # by relaton-data-iec:
    #
    #   urn:iec:std:{publisher}:{number}[-{part}]:{date}:{type}:{deliverable}:{language}[:{adjuncts}]
    #
    # e.g. +urn:iec:std:iec:60050-102:2007:::+ (type after date; trailing empty
    # type/deliverable/language slots). This is a port of relaton-iec's
    # +Relaton::Iec.code_to_urn+ operating on +identifier.to_s+, which
    # round-trips faithfully. The all-parts series URN is the one exception: it
    # omits the language slot (8 fields), so it has a dedicated branch.
    class UrnGenerator < Pubid::UrnGenerator::Base
      # Deliverable markers occupying the positional deliverable slot.
      DELIVERABLES = /cmv|csv|exv|prv|rlv|ser/

      def generate
        return series_urn if identifier.respond_to?(:all_parts) && identifier.all_parts

        code_to_urn(identifier.to_s, urn_language)
      end

      private

      # Hyphen-joined language codes (e.g. "en-fr"), or nil when unset.
      def urn_language
        return nil unless identifier.respond_to?(:languages)

        langs = identifier.languages
        return nil unless langs&.any?

        langs.map(&:code).join("-")
      end

      # The all-parts series URN drops the language slot and carries no part or
      # date: urn:iec:std:iec:80000:::ser.
      def series_urn
        code = identifier.to_s.sub(/\s*\(all parts\)\s*\z/, "")
        m = code.downcase.match(/(?<head>\S+)\s+(?<pnum>[\d-]+)/)
        head = m[:head].split("/").join("-")
        ["urn", "iec", "std", head, m[:pnum], "", "", "ser"].join(":")
      end

      # Port of Relaton::Iec.code_to_urn.
      def code_to_urn(code, lang = nil)
        rest = code.downcase.sub(%r{
          (?<head>[^\s]+)\s
          (?<type>is|ts|tr|pas|srd|guide|tec|wp)?(?(<type>)\s)
          (?<pnum>[\d-]+)\s?
          (?<_dd>:)?(?(<_dd>)(?<date>[\d-]+)\s?)
        }x, "")
        m = $~
        return unless m && m[:head] && m[:pnum]

        deliv = DELIVERABLES.match(code.downcase).to_s
        urn = ["urn", "iec", "std", m[:head].split("/").join("-"), m[:pnum],
               m[:date], m[:type], deliv, lang]
        (urn + adjunct_to_urn(rest)).join(":")
      end

      # Port of Relaton::Iec.ajunct_to_urn — recursively emits amd/cor/ish
      # adjuncts, prefixing "plus" for the "+" (consolidated) relation.
      def adjunct_to_urn(rest)
        r = rest.sub(%r{
          (?<pl>\+|/)(?(<pl>)(?<adjunct>(?:amd|cor|ish))(?<adjnum>\d+)\s?)
          (?<_d2>:)?(?(<_d2>)(?<adjdt>[\d-]+)\s?)
        }x, "")
        m = $~ || {}
        return [] unless m[:adjunct]

        plus = "plus" if m[:pl] == "+"
        urn = [plus, m[:adjunct], m[:adjnum], m[:adjdt]]
        urn + adjunct_to_urn(r)
      end
    end
  end
end
