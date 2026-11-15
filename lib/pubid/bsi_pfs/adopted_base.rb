# frozen_string_literal: true

module Pubid
  module BsiPfs
    # The adopted-base dispatch hook (pubid#706 §4, the coded escape
    # hatch — pubid-grammar#121 feature 4). The generated builder calls
    # this module at the captured adopted run; this module owns the
    # value-dependent dispatch the declaration cannot carry:
    #
    #   * the adopted string parses with the OWNING scheme's flavor —
    #     the en.overlay routing the module library declares: EN, CEN,
    #     CLC, HD, ENV, ES, CR and CWA leads through Pubid::CenCenelec
    #     (the cen inner), ISO leads through Pubid::Iso, IEC and CISPR
    #     leads through Pubid::Iec;
    #   * the wrapper class follows what came back: a CEN identifier is
    #     the adopted European norm (BS EN …, including the multi-level
    #     chains — "BS EN ISO 105-B06:2020" is this wrapper over a CEN
    #     adoption over the ISO document); anything else is the adopted
    #     international standard (BS ISO …, BS IEC …);
    #   * a run no flavor owns, or a run the owning flavor rejects, is a
    #     REJECTION (Pubid::Errors::ParseError) — never a silently empty
    #     wrapper (the parse-failure contract's nil/raise rule).
    module AdoptedBase
      CEN_LEADS = %w[EN CEN CLC HD ENV ES CR CWA].freeze
      ISO_LEADS = %w[ISO].freeze
      IEC_LEADS = %w[IEC CISPR].freeze

      class << self
        # The adoption identifier the captured run builds. Raises when the
        # run names no known flavor or the owning flavor rejects it.
        def build(builder, data)
          adopted_str = builder.unwrap(data[:adopted])&.to_s&.strip
          if adopted_str.nil? || adopted_str.empty?
            raise ::Pubid::Errors::ParseError,
                  "an adopted run captured no document (#{builder.flavor_name})"
          end

          adopted_id = parse_adopted(adopted_str)
          publisher = builder.unwrap(data[:publisher])&.to_s

          attrs = { adopted: adopted_id }
          attrs[:publisher] =
            ::Pubid::Components::Publisher.new(body: publisher) if publisher

          wrapper_class(adopted_id).new(**attrs)
        end

        # The implicit probe: BSI carries none — the coded builder's
        # adoptions are all printed ("BS EN …", "BS ISO …"); there is no
        # number-range adoption to probe. Always nil, so the generated
        # builder's probe point stays explicit and inert.
        def implicit(_builder, _data)
          nil
        end

        private

        # The wrapper class by what the owning flavor came back with: a
        # CEN identifier (including a CEN adoption of an ISO/IEC document)
        # is the adopted European norm; an ISO/IEC identifier is the
        # adopted international standard.
        def wrapper_class(adopted_id)
          if adopted_id.class.name.start_with?("Pubid::CenCenelec::")
            Identifiers::AdoptedEuropeanNorm
          else
            Identifiers::AdoptedInternationalStandard
          end
        end

        # The en.overlay routing: the lead token names the owning flavor.
        # An unknown lead is a rejection citing the run; a run the owning
        # flavor rejects propagates THAT flavor's Pubid::Errors::ParseError
        # (the delegation route the coded builder keeps — the owning
        # flavor's parse failure is the honest attribution).
        def parse_adopted(adopted_str)
          lead = adopted_str.split(/\s|\//, 2).first.to_s
          klass = dispatch(lead)
          if klass.nil?
            raise ::Pubid::Errors::ParseError,
                  "no owning flavor parses the adopted run #{adopted_str.inspect}"
          end

          klass.parse(adopted_str)
        end

        def dispatch(lead)
          if CEN_LEADS.include?(lead)
            ::Pubid::CenCenelec
          elsif ISO_LEADS.include?(lead)
            ::Pubid::Iso
          elsif IEC_LEADS.include?(lead)
            ::Pubid::Iec
          end
        end
      end
    end
  end
end
