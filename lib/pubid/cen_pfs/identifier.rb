  module Pubid
    module CenPfs
      class Identifier < ::Pubid::Identifier
        attribute :number, :string
        attribute :part, :string
        attribute :date, ::Pubid::Components::Date

        EN_TYPE_MAP = {
          "pubid:cencenelec:european-norm" => "Pubid::CenPfs::Identifiers::EuropeanNorm",
        }.freeze

        key_value do
          map "_type", to: :_type, polymorphic_map: EN_TYPE_MAP
          map "number", to: :number
          map "part", to: :part
          map "year", with: { to: :year_to_kv, from: :year_from_kv }
        end

          # --- date serialized flat (the shared flat-scalar shape) ---
          def year_to_kv(model, doc)
            emit_date_part(doc, "year", model.date&.year)
          end

          def year_from_kv(model, value)
            date_for(model).year = value.to_s
          end

          def emit_date_part(doc, key, val)
            return if val.nil? || val.to_s.empty?

            doc.add_child(Lutaml::KeyValue::DataModel::Element.new(key, val.to_s))
          end

          def date_for(model)
            model.date ||= ::Pubid::Components::Date.new
          end

        PUBLISHER = "CEN"

        # The scheme's declared publisher token: the internal-form
        # cut (to_s(with_publisher: false)) strips it from the
        # rendered face.
        def publisher_prefixes
          [PUBLISHER]
        end

        def self.parse(identifier)
          unless identifier.is_a?(String)
            raise Pubid::Errors::InvalidInputError,
                  Pubid::INPUT_NOT_A_STRING_MESSAGE
          end

          if identifier.length > Pubid::MAX_INPUT_LENGTH
            raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
          end

          identifier = ::Pubid.utf8_input(identifier)

          parsed = Pubid::Parg::Model.bound(:cen_pfs, identifier)
          Builder.build(parsed)
        end
      end
    end
  end
