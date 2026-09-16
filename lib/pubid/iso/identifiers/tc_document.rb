# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      # Technical Committee Document
      # Format: TC 184/SC 4/WG 3 N 123, JTC 1 N 456, TC 184 N 100
      class TcDocument < Identifier
        # The committee structure: plain strings ("TC", "184", "SC", "4").
        # Each held a Components::Code carrying nothing but `value`, and the
        # serialized form was already the bare scalar.
        attribute :tc_type, :string
        attribute :tc_number, :string
        attribute :sc_type, :string
        attribute :sc_number, :string
        attribute :wg_type, :string
        attribute :wg_number, :string

        # TC types from ISO system
        TC_TYPES = %w[TC JTC PC IT CAB CASCO COPOLCO COUNCIL CPSG CS DEVCO GA
                      GAAB INFCO ITN ISOlutions REMCO TMB TMBG WMO DMT JCG SGPM
                      ATMG CCCC CCCC-TG JDMT JSAG JSCTF-TF JTCG JTCG-TF SAG_Acc
                      SAG_CRMI SAG_CRMI_CG SAG_ESG SAG_ESG_CG SAG_MRS SAG_SF SAG_SF_CG
                      SMCC STMG MENA_STAR].freeze

        # WG types from ISO system
        WG_TYPES = %w[AG AhG WG JWG QC TF PPC CAG CSC ITSAG CSC/FIN CSC/NOM CSC/OVE
                      CSC/SP CSC SF ITSG JAG JCTF JSG JTAG JTG].freeze

        # TC documents don't use typed stages like other identifiers
        TYPED_STAGES = [].freeze

        # Serialize the committee structure on top of the inherited ISO
        # mapping; TC documents have no stage. The attributes are plain
        # strings, so lutaml needs no converter (the ETSI/OIML shape).
        key_value do
          map "tc_type", to: :tc_type
          map "tc_number", to: :tc_number
          map "sc_type", to: :sc_type
          map "sc_number", to: :sc_number
          map "wg_type", to: :wg_type
          map "wg_number", to: :wg_number
        end

        # TC documents have no stage; suppress the inherited stage emission.
        def stage_to_kv(_model, _doc); end

        def self.type
          { key: :tc,
            web: :tc_document, title: "Technical Committee Document", short: "TC" }
        end

        def self.typed_stages
          TYPED_STAGES
        end

        def to_s(...)
          result = publisher.to_s if publisher

          # Add TC type and number
          result += "/#{tc_type} " unless tc_type.to_s.empty?
          result += tc_number.to_s unless tc_number.to_s.empty?

          # Add SC type and number
          unless sc_type.to_s.empty? || sc_number.to_s.empty?
            result += "/#{sc_type} "
            result += sc_number.to_s
          end

          # Add WG type and number
          unless wg_type.to_s.empty? || wg_number.to_s.empty?
            result += "/#{wg_type} "
            result += wg_number.to_s
          end

          # Add document number
          result += " N #{number}" unless number.to_s.empty?

          # Add year if present
          result += ":#{date.render}" if date&.year

          result
        end

        # Generate URN for TC document
        # Format: urn:iso:doc:iso:tc:184:sc-4:wg-3:123
        def to_urn
          urn_ctx = Rendering::RenderingContext.urn
          parts = ["urn:iso:doc"]
          parts << publisher.render(context: urn_ctx) if publisher

          # Add TC
          parts << "tc:#{tc_number}" unless tc_number.to_s.empty?

          # Add SC
          parts << "sc-#{sc_number}" unless sc_number.to_s.empty?

          # Add WG
          parts << "wg-#{wg_number}" unless wg_number.to_s.empty?

          # Add document number
          parts << number.to_s unless number.to_s.empty?

          parts.join(":")
        end

        def ==(other)
          return false unless other.is_a?(TcDocument)

          publisher == other.publisher &&
            tc_type == other.tc_type &&
            tc_number == other.tc_number &&
            sc_type == other.sc_type &&
            sc_number == other.sc_number &&
            wg_type == other.wg_type &&
            wg_number == other.wg_number &&
            number == other.number
        end
      end
    end
  end
end
