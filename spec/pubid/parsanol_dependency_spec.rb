# frozen_string_literal: true

# parsanol 1.3.110 made the v2 named-tree dialect the default
# (parsanol#352), and pubid's grammars then fold per-atom captures into
# their values ("number" => "[{digit: \"2\"}, ...]"). The Gemfile pin does
# not reach a bundle that depends on pubid, so the cap must live in the
# gemspec. Delete this spec together with the cap once pubid parses the
# v2 dialect.
RSpec.describe "pubid.gemspec parsanol dependency" do
  let(:requirement) do
    gemspec = Gem::Specification.load(
      File.expand_path("../../pubid.gemspec", __dir__),
    )
    gemspec.runtime_dependencies.find { |d| d.name == "parsanol" }.requirement
  end

  %w[1.3.62 1.3.109].each do |version|
    it "accepts the classic-dialect release #{version}" do
      expect(requirement).to be_satisfied_by(Gem::Version.new(version))
    end
  end

  %w[1.3.110 1.3.111].each do |version|
    it "rejects the v2-dialect-default release #{version}" do
      expect(requirement).not_to be_satisfied_by(Gem::Version.new(version))
    end
  end
end
