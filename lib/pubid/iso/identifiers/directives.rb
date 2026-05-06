# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      class Directives < SingleIdentifier
        attribute :type, ::Pubid::Components::Type, default: -> { self.class.type[:key] }
        attribute :subgroup, ::Pubid::Components::Code

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pubguide,
            stage_code: :published,
            type_code: :dir,
            abbr: ["DIR", "Directives Part", "Directives, Part", "Directives,",
                   "Directives"],
            short_abbr: "DIR",
            long_abbr: "Directives, Part",
            name: "Directives",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :dir, title: "Directives", short: "DIR" }
        end

        def to_s(**opts)
          context = build_rendering_context(nil, format: :human, **opts)
          Pubid::Renderers::DirectivesRenderer.new(self).render(context:,
                                                                **opts.slice(:with_edition))
        end

        # Directives use a different URN scheme: urn:iso:doc instead of urn:iso:std
        # Format: urn:iso:doc:{publisher}[:{subgroup}][:{subgroup_number}]:dir[:{number}][:{part}][:{year}]
        def to_urn
          parts = ["urn", "iso", "doc"]

          copubs = copublishers || []
          parts << ([publisher] + copubs).map(&:body).map(&:downcase).join("-")

          if subgroup
            subgroup_parts = subgroup.value.split
            parts << subgroup_parts[0].downcase if subgroup_parts[0]
            parts << subgroup_parts[1] if subgroup_parts[1]
          end

          parts << "dir"

          parts << number.value if number
          parts << part.value.downcase if part
          parts << date.year if date

          parts.join(":")
        end
      end
    end
  end
end
