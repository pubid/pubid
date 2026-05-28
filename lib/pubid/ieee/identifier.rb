# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifier
      class << self
        def parse(input)
          Identifiers::Base.parse(input)
        end

        # Factory mirroring pubid 1.x's `Pubid::Ieee::Identifier.create` API.
        # Dispatches via {Pubid::Ieee::Scheme.locate_identifier_klass_by_type_code}.
        # Default subclass (no `type:`) is Identifiers::Standard — the
        # canonical class produced by parsing typical IEEE identifiers.
        def create(type: nil, **opts)
          klass = type ?
                  Scheme.locate_identifier_klass_by_type_code(type) :
                  Identifiers::Standard
          attrs = coerce_create_attrs(opts)
          # ProjectDraftIdentifier renders the "P" prefix from typed_stage,
          # not from `type`. Set both so the output matches a parsed form.
          if klass == Identifiers::ProjectDraftIdentifier
            attrs[:type] = "P"
            attrs[:typed_stage] ||= Scheme.locate_typed_stage_by_abbr("P")
          end
          klass.new(**attrs)
        end

        private

        def coerce_create_attrs(opts)
          attrs = {}
          attrs[:publisher] = opts[:publisher].to_s if opts[:publisher]
          if opts[:copublisher]
            attrs[:copublisher] =
              Array(opts[:copublisher]).map(&:to_s)
          end
          # :code or :number alias
          if (v = opts[:code] || opts[:number])
            attrs[:code] = v.to_s
          end
          %i[year edition month day draft_status].each do |k|
            v = opts[k]
            attrs[k] = v.to_s unless v.nil?
          end
          attrs[:redline] = opts[:redline] if opts.key?(:redline)
          # TODO(create-shim): amendments/corrigenda/revision_of/incorporates
          # are nested Base relations; not yet wired through.
          attrs
        end
      end
    end
  end
end
