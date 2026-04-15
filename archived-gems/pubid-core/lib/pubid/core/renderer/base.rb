require "set"

module Pubid::Core::Renderer
  class Base
    attr_accessor :params

    LANGUAGES = {
      "ru" => "R",
      "fr" => "F",
      "en" => "E",
      "ar" => "A",
      "es" => "S",
    }.freeze

    SEMANTIC_CLASSES = {
      publisher: "publisher",
      number: "docnumber",
      part: "part",
      year: "year",
      edition: "edition",
      amendments: "amendment",
      corrigendums: "corrigendum",
      language: "language",
      typed_stage: "doctype",
      stage: "stage",
      iteration: "iteration",
      addendum: "addendum",
    }.freeze

    SEPARATOR_CHARS = Set.new(["-", ":", "/", " ", ",", "."]).freeze

    def initialize(params)
      @params = params
    end

    # Wraps rendered value in a <span> tag with a semantic CSS class.
    # Leading/trailing separator characters are preserved outside the span.
    # @param key [Symbol] parameter key (e.g. :publisher, :number)
    # @param rendered_value [String] the rendered string value
    # @return [String] annotated or original value
    def annotate_value(key, rendered_value)
      css_class = SEMANTIC_CLASSES[key]
      return rendered_value if css_class.nil?

      str = rendered_value.to_s
      return str if str.empty?

      # Extract leading separators
      leading = ""
      while !str.empty? && SEPARATOR_CHARS.include?(str[0])
        leading << str[0]
        str = str[1..]
      end

      # Extract trailing separators
      trailing = ""
      while !str.empty? && SEPARATOR_CHARS.include?(str[-1])
        trailing = str[-1] + trailing
        str = str[0..-2]
      end

      return rendered_value if str.empty?

      "#{leading}<span class=\"#{css_class}\">#{str}</span>#{trailing}"
    end

    # Prerender parameters and store in @prerendered_params
    # @param opts [Hash] options for render method, eg. { with_language_code: :single, with_date: true }
    # @return [Renderer::Base] self
    def prerender(**opts)
      @prerendered_params = prerender_params(@params, opts)
      @prerendered_params.default = ""
      self
    end

    def render_base_identifier(**args)
      prerender(**args)

      render_identifier(@prerendered_params)
    end

    def prerender_params(params, opts)
      params.map do |key, value|
        next unless value
<<<<<<< HEAD:archived-gems/pubid-core/lib/pubid/core/renderer/base.rb

        if respond_to?("render_#{key}")
          [key, send("render_#{key}", value, opts, params)]
        else
          [key, value]
        end
=======
        rendered = if respond_to?("render_#{key}")
                     send("render_#{key}", value, opts, params)
                   else
                     value
                   end
        rendered = annotate_value(key, rendered) if opts[:annotated] && rendered
        [key, rendered]
>>>>>>> origin/main:gems/pubid-core/lib/pubid/core/renderer/base.rb
      end.compact.to_h
    end

    # Renders amendment and corrigendum when applied through identifier type
    def render_supplement(supplement_params, **args)
      base = if supplement_params[:base].type == :amd
               # render inner amendment (cor -> amd -> base)
               render_supplement(supplement_params[:base].to_h, **args)
             else
               self.class.new(supplement_params[:base].to_h).render_base_identifier(
                 # always render year for identifiers with supplement
                 **args.merge({ with_date: true }),
               )
             end
      supplement = case supplement_params[:typed_stage].type.type
                   when :amd
                     render_amendments(
                       [Pubid::Iso::Amendment.new(**supplement_params.slice(
                         :number, :year, :typed_stage, :edition, :iteration
                       ))],
                       args,
                       nil,
                     )
                   when :cor
                     render_corrigendums(
                       [Pubid::Iso::Corrigendum.new(**supplement_params.slice(
                         :number, :year, :typed_stage, :edition, :iteration
                       ))],
                       args,
                       nil,
                     )
                     # copy parameters from Identifier only supported by Corrigendum
                   end

      if supplement_params[:base].language
        base + supplement + render_language(supplement_params[:base].language,
                                            args, nil)
      else
        base + supplement
      end
    end

    # Render identifier
    # @param with_date [Boolean] include year in output
    # @param with_language_code [:iso,:single] render document language as 2-letter ISO 639-1 language code or single code
<<<<<<< HEAD:archived-gems/pubid-core/lib/pubid/core/renderer/base.rb
    def render(with_date: true, with_language_code: :iso, **args)
      render_base_identifier(**args.merge({ with_date: with_date,
                                            with_language_code: with_language_code })) + @prerendered_params[:language].to_s
=======
    def render(with_date: true, with_language_code: :iso, annotated: false, **args)
      render_base_identifier(**args.merge({ with_date: with_date, with_language_code: with_language_code, annotated: annotated})) + @prerendered_params[:language].to_s
>>>>>>> origin/main:gems/pubid-core/lib/pubid/core/renderer/base.rb
    end

    def render_identifier(params)
      render_base(params)
    end

    def render_publisher(publisher, _opts, params)
      return publisher unless params[:copublisher]

      case params[:copublisher]
      when Array
        ([publisher] + params[:copublisher].map(&:to_s).sort.map(&:to_s)).map do |pub|
          pub.gsub("-", "/")
        end.join("/")
      else
        [publisher, params[:copublisher]].join("/")
      end
    end

    def render_amendments(amendments, _opts, _params)
      amendments.sort.map(&:render_pubid).join("+")
    end

    def render_corrigendums(corrigendums, _opts, _params)
      corrigendums.sort.map(&:render_pubid).join("+")
    end

    def render_part(part, _opts, _params)
      "-#{part}"
    end

    def render_year(year, opts, _params)
      opts[:with_date] && ":#{year}" || ""
    end

    def render_language(language, opts, _params)
      if opts[:with_language_code] == :single
        "(#{LANGUAGES[language]})"
      else
        "(#{language})"
      end
    end
  end
end
