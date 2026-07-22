# frozen_string_literal: true

module Pubid
  module Renderers
    # Machine-readable string renderer.
    #
    # Produces a lossless, dot-separated slug mirroring `to_s`'s structure:
    #
    #   ISO 9001:2015                       → ISO.9001.2015
    #   ISO/IEC 17031-1:2020                → ISO/IEC.17031-1.2020
    #   ISO 1234-1-2-3:2020                 → ISO.1234-1-2-3.2020
    #   ISO/TR 14627:2017                   → ISO.tr.14627.2017
    #   ISO 16634:--                        → ISO.16634.--
    #   ISO 9001:2015/Amd 1:2020            → ISO.9001.2015/amd.1.2020
    #   ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017
    #                                       → ISO/IEC.13818-1.2015/amd.3.2016/cor.1.2017
    #
    # The renderer recurses into a supplement's `base` (one level per
    # `mr_supplement_suffix`) so chained Cor→Amd→IS structures render fully —
    # without that recursion every supplement layer collapsed onto its own
    # type/number/year, dropping the base entirely (issue #142).
    class MrString < Base
      def render(context: nil, **)
        suffix = @id.mr_supplement_suffix

        if suffix
          base = @id.base
          head = base ? self.class.new(base).render : ""
          head.empty? ? suffix : "#{head}/#{suffix}"
        else
          render_flat(@id)
        end
      end

      private

      def render_flat(id)
        parts = []
        parts << id.mr_publisher
        parts << id.mr_type
        parts << id.mr_number_with_part
        parts << id.mr_year
        parts << id.mr_edition
        parts << id.mr_languages
        parts << id.mr_all_parts
        parts.compact.join(".")
      end
    end
  end
end
