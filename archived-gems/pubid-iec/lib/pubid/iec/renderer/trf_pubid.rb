module Pubid::Iec::Renderer
  class TrfPubid < Pubid
    def render_identifier(params)
      "%<publisher>s%<copublisher>s TRF%<trf_publisher>s %<number>s%<part>s%<conjuction_part>s"\
      "%<part_version>s%<version>s%<trf_version>s%<decision_sheet>s%<trf_series>s%<test_type>s"\
      "%<year>s%<vap>s" % params
    end

    def render_vap(vap, _opts, _params)
      " #{vap}"
    end

    def render_conjuction_part(conjuction_parts, _opts, _params)
      conjunction_symbol = case _params[:publisher]
                           when "IECEE"
                             # IECEE TRFs use '&' as parts separator (IECEE OD-2020)
                             "&"
                           else
                             # when "IECEx"
                             # IECEx TRFs use ',' as parts separator (IECEx OD-010-1)
                             ","
                           end

      if conjuction_parts.is_a?(Array)
        conjuction_parts.map(&:to_i).sort.map do |conjuction_part|
          "#{conjunction_symbol}#{conjuction_part}"
        end.join
      else
        "#{conjunction_symbol}#{conjuction_parts}"
      end
    end

    def render_trf_publisher(trf_publisher, _opts, _params)
      " #{trf_publisher}"
    end

    def render_test_type(test_type, _opts, _params)
      "_#{test_type}"
    end

    def render_trf_series(_trf_series, _opts, _params)
      "_SE"
    end
  end
end
