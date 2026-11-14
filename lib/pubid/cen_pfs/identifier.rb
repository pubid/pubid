module Pubid
  module CenPfs
    # The shared base of every concrete CenPfs class. The
    # serialization is the shared ::Pubid::Identifier's (the coded
    # flavor's own shape): flat publisher/copublishers scalars, the
    # date flattened to its fields, and the draft stage compacted
    # to its code by the class hooks below.
    class Identifier < ::Pubid::Identifier
      # The ETSI-style version suffix ("EN 302 326-2 V2.2.1").
      attribute :version, :string

      # A published document holds no type, stage or typed stage, so
      # a nil one means "published", not "any stage": `EN 1325` is
      # not `prEN 1325`. The three components repeat one entry of
      # the stage registry, so they move together.
      subset_strict :type, :stage, :typed_stage

      # The bodies that print as a publisher prefix. The publisher
      # attribute also holds the deliverable types that ARE the
      # designation ("CR 954"); those stay under
      # with_publisher: false, as `BS` does for BSI.
      PUBLISHER_PREFIXES = ["CEN", "CLC", "CENELEC", "EN", "CWA", "HD", "ES", "CR", "ENV"].freeze

      def publisher_prefixes
        super.select do |prefix|
          PUBLISHER_PREFIXES.include?(prefix.split("/").first)
        end
      end

      # The publisher serializes as a bare string, the copublishers
      # as a list of strings (the coded flavor's flat-scalar table).
      def self.flat_scalar_components
        super.merge(publisher: "publisher", copublishers: "copublishers")
      end

      def self.flat_scalar_fields
        super.merge(publisher: :body, copublishers: :body)
      end

      # The declared draft stages: the serialized code is the key,
      # the official-URN code the declared `urn:` value.
      STAGE_CODES = {
        "pren" => { stage_code: :proposal },
        "fpren" => { stage_code: :final_proposal },
      }.freeze

      # A draft stage serializes as its typed-stage code
      # ("stage" => "pren"); #inflate_scalar_components rebuilds
      # the three components from it (the coded compact-hash shape).
      def self.compact_hash(model, hash)
        stage = model.typed_stage
        return unless stage && hash.key?("typed_stage")
        return unless model.type == stage.to_type &&
                      model.stage == stage.to_stage

        hash.delete("type")
        hash.delete("typed_stage")
        hash["stage"] = stage.code.to_s
      end

      # Reads the short stage form back; the nested form still
      # reads as before.
      def self.inflate_scalar_components(data)
        data = super
        return data unless data.is_a?(::Hash) && component_attribute?(:stage)

        key = data.key?("stage") ? "stage" : :stage
        value = data[key]
        return data unless value.is_a?(::String) || value.is_a?(::Symbol)

        stage = locate_stage_by_code(value)
        return data unless stage

        data = data.dup
        data.delete(key)
        data["type"] = stage.to_type.to_hash
        data["stage"] = stage.to_stage.to_hash
        data["typed_stage"] = stage.to_hash
        data
      end

      # The stage entry by serialized code, or nil.
      def self.locate_stage_by_code(code)
        Builder.stage_by_code(code.to_s)
      end

      # The draft stage's own code is the MR type segment
      # ("en.pren.10160"); a published identifier has no typed
      # stage, so the shared hook answers nil.
      def mr_type
        stage = typed_stage
        return super unless stage && stage.stage_code.to_s != "published"

        stage.code.to_s.downcase
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

      private

      # "amd.1.2005" from ("amd", "1", 2005). A nil or blank
      # segment is left out.
      def mr_join_segments(*segments)
        segments.map(&:to_s).reject(&:empty?).join(".").downcase
      end
    end
  end
end
