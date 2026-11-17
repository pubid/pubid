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
    #   * the adopted document lands on the builder's declared
    #     ADOPTED_ATTRIBUTE — the uniform `base` (the codec's root-first
    #     walk, the from_hash key and the MR join read it);
    #   * the wrapper's own glued edition face (the declared
    #     ADOPTED_EDITION_FACE, "BS HD IEC 60364-8-81 ED1") lifts out of
    #     the run BEFORE the delegation — the owning flavor drops it, the
    #     wrapper column carries it (the coded builder's own extraction);
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
          adopted_str = captured_run(builder, data)
          run, edition = extract_edition(builder, adopted_str)
          adopted_id = parse_adopted(run)

          wrapper_class(adopted_id).new(**wrapper_attrs(builder, data,
                                                        adopted_id, edition))
        end

        # The implicit probe: BSI carries none — the coded builder's
        # adoptions are all printed ("BS EN …", "BS ISO …"); there is no
        # number-range adoption to probe. Always nil, so the generated
        # builder's probe point stays explicit and inert.
        def implicit(_builder, _data)
          nil
        end

        private

        # The captured run, stripped — or the rejection (the parse-failure
        # contract's nil/raise rule: an adopted run that captured no
        # document never builds a silently empty wrapper).
        def captured_run(builder, data)
          adopted_str = builder.unwrap(data[:adopted])&.to_s&.strip
          if adopted_str.nil? || adopted_str.empty?
            raise ::Pubid::Errors::ParseError,
                  "an adopted run captured no document (#{builder.flavor_name})"
          end

          adopted_str
        end

        # The wrapper's attributes: the adopted document under the
        # builder's declared model column, the captured head token as the
        # publisher, and the lifted edition face when the run carried one.
        def wrapper_attrs(builder, data, adopted_id, edition)
          attrs = { adopted_attribute(builder) => adopted_id }
          publisher = builder.unwrap(data[:publisher])&.to_s
          if publisher
            attrs[:publisher] =
              ::Pubid::Components::Publisher.new(body: publisher)
          end
          attrs[:edition] = edition if edition
          attrs
        end

        # The wrapper's model column for the adopted document, from the
        # generated builder's declaration (the capture name when it
        # declares none — the legacy slot).
        def adopted_attribute(builder)
          if builder.class.const_defined?(:ADOPTED_ATTRIBUTE)
            builder.class::ADOPTED_ATTRIBUTE.to_sym
          else
            :adopted
          end
        end

        # The declared glued edition face, lifted from the run's tail
        # ("BS HD IEC 60364-8-81 ED1" — the ordinal glues to the face,
        # there is no edition_space). Returns the cleaned run and the
        # ordinal; a run with no face passes through untouched.
        def extract_edition(builder, adopted_str)
          unless builder.class.const_defined?(:ADOPTED_EDITION_FACE)
            return [adopted_str, nil]
          end

          face = builder.class::ADOPTED_EDITION_FACE
          match = adopted_str.match(/\s+#{face}(\d+)\s*\z/)
          return [adopted_str, nil] unless match

          [adopted_str.sub(/\s+#{face}#{match[1]}\s*\z/, ""), match[1]]
        end

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
                  "no owning flavor parses the run #{adopted_str.inspect}"
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
