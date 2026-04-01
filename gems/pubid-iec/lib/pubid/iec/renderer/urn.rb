module Pubid::Iec::Renderer
  class Urn < ::Pubid::Core::Renderer::Urn
    STAGES = { ACD: 20.99,
               ACDV: 30.99,
               ADTR: 40.99,
               ADTS: 40.99,
               AFDIS: 40.99,
               APUB: 50.99,
               BPUB: 60,
               CAN: 30.98,
               CCDV: 40.20,
               CD: 30.20,
               CDISH: 50.20,
               CDM: 30.60,
               CDPAS: 50.20,
               CDTR: 50.20,
               CDTS: 50.20,
               CDVM: 40.91,
               CFDIS: 50.20,
               DECDISH: 50.00,
               DECFDIS: 50.00,
               DECPUB: 60.00,
               DEL: 10.98,
               DELPUB: 99.60,
               DTRM: 50.92,
               DTSM: 50.92,
               MERGED: 30.97,
               NCDV: 40.91,
               NDTR: 50.92,
               NDTS: 50.92,
               NFDIS: 50.92,
               PCC: 30.60,
               PNW: 10.20,
               PPUB: 60.60,
               PRVC: 40.60,
               PRVD: 50.60,
               PRVDISH: 50.60,
               PRVDPAS: 50.60,
               PRVDTR: 50.60,
               PRVDTS: 50.60,
               PRVN: 10.60,
               PWI: 0,
               RDISH: 50.00,
               RFDIS: 50.00,
               RPUB: 60.00,
               SPLIT: 30.96,
               TCDV: 40.00,
               TDISH: 50.00,
               TDTR: 50.00,
               TDTS: 50.00,
               TPUB: 60.00,
               WPUB: 95.99
    }.freeze

    def render_identifier(params)
      result = "urn:iec:std:#{params[:publisher]}#{params[:copublisher]}" \
               "#{params[:type]}:#{params[:number]}" \
               "#{params[:part]}#{params[:conjuction_part]}"

      # Positional fields — always colon-separated even when empty
      result += ":#{strip_leading_colon(params[:year])}"

      stage_value = [params[:stage], params[:vap], params[:urn_stage],
                     params[:corrigendum_stage], params[:iteration],
                     params[:version], params[:part_version]].map(&:to_s).join
      result += ":#{strip_leading_colon(stage_value)}"

      result += ":#{strip_leading_colon(params[:edition])}"

      # Non-positional suffixes
      result += params[:amendments].to_s
      result += params[:corrigendums].to_s
      result += params[:fragment].to_s

      result
    end

    def render(with_date: true, with_language_code: :iso, annotated: false, **args)
      base = render_base_identifier(**args.merge(
        with_date: with_date, with_language_code: with_language_code, annotated: annotated,
      ))
      lang = strip_leading_colon(@prerendered_params[:language].to_s)
      if @prerendered_params.key?(:all_parts)
        "#{base}ser"
      else
        "#{base}:#{lang}"
      end
    end

    def render_number(number, _opts, _params)
      number.to_s.downcase
    end

    def render_vap(vap, _opts, _params)
      ":#{vap.map(&:downcase).join('-')}"
    end

    def render_fragment(fragment, _opts, _params)
      ":frag:#{fragment}"
    end

    def render_version(version, _opts, _params)
      ":v#{version}"
    end

    def render_part_version(part_version, _opts, _params)
      ":v#{part_version}"
    end

    def render_conjuction_part(conjuction_parts, _opts, _params)
      if conjuction_parts.is_a?(Array)
        conjuction_parts.map(&:to_i).sort.map { |conjuction_part| ",#{conjuction_part}" }.join
      else
        ",#{conjuction_parts}"
      end
    end

    def render_stage(stage, _opts, params)
      ":stage-#{sprintf('%s', stage.to_s(:urn))}"
    end

    def render_type(type, _, _)
      ":#{type.downcase}"
    end

    def render_amendments(amendments, _opts, _params)
      amendments&.map(&:urn)&.join || ""
    end

    def render_corrigendums(corrigendums, _opts, _params)
      corrigendums&.map(&:urn)&.join || ""
    end

    def render_language(language, _opts, _params)
      ":" + (language.is_a?(Array) ? language.join("-") : language)
    end

    def render_copublisher(copublisher, _opts, _params)
      "-" + Array(copublisher).map { |c| c.to_s.downcase }.join("-")
    end

    private

    def strip_leading_colon(value)
      s = value.to_s
      s.start_with?(":") ? s[1..] : s
    end

  end
end
