module Pubid
  module Iec
    module Renderer
      class TrfUrn < Urn
        def render_identifier(params)
          "urn:iec:std:%<publisher>s%<copublisher>s:trf%<trf_publisher>s:%<number>s" \
          "%<part>s%<conjuction_part>s%<year>s%<vap>s" \
          "%<version>s%<part_version>s" \
          "%<trf_version>s" % params
        end

        def render_trf_version(trf_version, _opts, _params)
          ":v#{trf_version}" unless trf_version.empty?
        end

        def render_trf_publisher(trf_publisher, _opts, _params)
          ":#{trf_publisher.downcase}"
        end
      end
    end
  end
end
