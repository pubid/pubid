# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Components
    # Adoption component — captures the metadata when one identifier adopts
    # another. Originally surfaced as BSI's AdoptedInternationalStandard /
    # AdoptedEuropeanNorm and CEN-CENELEC's AdoptedEuropeanNorm; the same
    # shape applies to CSA adoptions and IEEE Adopted-Standard relationships.
    #
    # Shape (union across BSI, CEN-CENELEC, CSA, IEEE):
    # - base:                     the adopted document (polymorphic Identifier).
    # - adopter_publisher:        the publisher doing the adopting (BS, EN,
    #                             CAN/, CSA, IEEE).
    # - edition:                  edition of the adoption (BSI-only).
    # - date:                     adoption date (replaces ad-hoc year attrs).
    # - translation_lang:         translation language code (BSI-only).
    # - translation_upper:        upper-case translation marker (BSI-only).
    # - translation_suffix_type:  "version" or "Translation" (BSI-only).
    # - reaffirmation_year:       "(R2004)" reaffirmation notation (BSI, CSA).
    # - expert_commentary:        true when the adoption ships with commentary
    #                             (BSI-only).
    # - expert_commentary_topic:  topic of the commentary (BSI-only).
    # - publisher_prefix:         CSA-specific dash-vs-space prefix.
    #
    # Render delegates to the base identifier; the adopter's renderer decides
    # the prefix and any suffix notation (translation, reaffirmation,
    # commentary) by calling adoption.render(context:).
    class Adoption < Lutaml::Model::Serializable
      attribute :base, ::Pubid::Identifier, polymorphic: true
      attribute :adopter_publisher, ::Pubid::Components::Publisher
      attribute :edition, :string
      attribute :date, ::Pubid::Components::Date
      attribute :translation_lang, :string
      attribute :translation_upper, :string
      attribute :translation_suffix_type, :string
      attribute :reaffirmation_year, :string
      attribute :expert_commentary, :boolean
      attribute :expert_commentary_topic, :string
      attribute :publisher_prefix, :string

      IDENTITY_FIELDS = %i[
        base adopter_publisher edition date translation_lang translation_upper
        translation_suffix_type reaffirmation_year expert_commentary
        expert_commentary_topic publisher_prefix
      ].freeze

      def present?
        IDENTITY_FIELDS.any? { |f| present_value?(public_send(f)) }
      end

      def render(context: nil)
        return "" unless base

        body = base.to_s
        body += translation_suffix if translation_lang
        body += reaffirmation_suffix if reaffirmation_year
        body += commentary_suffix if expert_commentary
        body
      end

      def to_s(**opts)
        render(context: opts[:context])
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        IDENTITY_FIELDS.all? { |f| public_send(f) == other.public_send(f) }
      end

      alias eql? ==

      def hash
        @hash ||= [self.class, *IDENTITY_FIELDS.map { |f| public_send(f) }].hash
      end

      private

      def present_value?(value)
        return false if value.nil?
        return value if [true, false].include?(value)

        value.is_a?(String) ? !value.empty? : !value.nil?
      end

      def translation_suffix
        type = translation_suffix_type || "Translation"
        lang = translation_lang&.upcase
        " #{lang}#{type}"
      end

      def reaffirmation_suffix
        " (R#{reaffirmation_year})"
      end

      def commentary_suffix
        topic = expert_commentary_topic
        topic ? " (Commentary: #{topic})" : " (Commentary)"
      end
    end
  end
end
