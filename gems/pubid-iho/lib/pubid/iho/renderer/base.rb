module Pubid::Iho::Renderer
  class Base < Pubid::Core::Renderer::Base
    def render_identifier(params)
      "%{publisher} %{type}-%{number}%{appendix}%{part}%{annex}%{version}" % params
    end

    def render_part(part, _opts, _params)
      " Part #{part}"
    end

    def render_appendix(appendix, _opts, _params)
      " Ap. #{appendix}"
    end

    def render_annex(annex, _opts, _params)
      " Annex #{annex}"
    end

    def render_version(version, _opts, _params)
      " #{version}"
    end
  end
end
