# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      # Technical Committee Document
      # Format: TC 184/SC 4/WG 3 N 123, JTC 1 N 456, TC 184 N 100
      class TcDocument < Base
        # TC type (TC, JTC, PC, IT, etc.)
        attribute :tc_type, ::Pubid::Components::Code
        # TC number
        attribute :tc_number, ::Pubid::Components::Code
        # SC type
        attribute :sc_type, ::Pubid::Components::Code
        # SC number
        attribute :sc_number, ::Pubid::Components::Code
        # WG type
        attribute :wg_type, ::Pubid::Components::Code
        # WG number
        attribute :wg_number, ::Pubid::Components::Code

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

        # Serialize the committee structure (all plain-string Codes) on top of
        # the inherited ISO mapping; TC documents have no stage.
        key_value do
          map "tc_type", with: { to: :tc_type_to_kv, from: :tc_type_from_kv }
          map "tc_number", with: { to: :tc_number_to_kv, from: :tc_number_from_kv }
          map "sc_type", with: { to: :sc_type_to_kv, from: :sc_type_from_kv }
          map "sc_number", with: { to: :sc_number_to_kv, from: :sc_number_from_kv }
          map "wg_type", with: { to: :wg_type_to_kv, from: :wg_type_from_kv }
          map "wg_number", with: { to: :wg_number_to_kv, from: :wg_number_from_kv }
        end

        # TC documents have no stage; suppress the inherited stage emission.
        def stage_to_kv(_model, _doc); end

        def tc_type_to_kv(m, doc) = emit_code(doc, "tc_type", m.tc_type)
        def tc_type_from_kv(m, v) = m.tc_type = build_code(v)
        def tc_number_to_kv(m, doc) = emit_code(doc, "tc_number", m.tc_number)
        def tc_number_from_kv(m, v) = m.tc_number = build_code(v)
        def sc_type_to_kv(m, doc) = emit_code(doc, "sc_type", m.sc_type)
        def sc_type_from_kv(m, v) = m.sc_type = build_code(v)
        def sc_number_to_kv(m, doc) = emit_code(doc, "sc_number", m.sc_number)
        def sc_number_from_kv(m, v) = m.sc_number = build_code(v)
        def wg_type_to_kv(m, doc) = emit_code(doc, "wg_type", m.wg_type)
        def wg_type_from_kv(m, v) = m.wg_type = build_code(v)
        def wg_number_to_kv(m, doc) = emit_code(doc, "wg_number", m.wg_number)
        def wg_number_from_kv(m, v) = m.wg_number = build_code(v)

        def self.type
          { key: :tc, title: "Technical Committee Document", short: "TC" }
        end

        def self.typed_stages
          TYPED_STAGES
        end

        def to_s(...)
          result = publisher.to_s if publisher

          # Add TC type and number
          result += "/#{tc_type.value} " if tc_type&.value
          result += tc_number.value.to_s if tc_number&.value

          # Add SC type and number
          if sc_type&.value && sc_number&.value
            result += "/#{sc_type.value} "
            result += sc_number.value.to_s
          end

          # Add WG type and number
          if wg_type&.value && wg_number&.value
            result += "/#{wg_type.value} "
            result += wg_number.value.to_s
          end

          # Add document number
          result += " N #{number.value}" if number&.value

          # Add year if present
          result += ":#{date.year}" if date&.year

          result
        end

        # Generate URN for TC document
        # Format: urn:iso:doc:iso:tc:184:sc-4:wg-3:123
        def to_urn
          parts = ["urn:iso:doc"]
          parts << publisher.to_s.downcase if publisher

          # Add TC
          parts << "tc:#{tc_number.value}" if tc_number&.value

          # Add SC
          parts << "sc-#{sc_number.value}" if sc_number&.value

          # Add WG
          parts << "wg-#{wg_number.value}" if wg_number&.value

          # Add document number
          parts << number.value if number&.value

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
