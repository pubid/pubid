# frozen_string_literal: true

# The floor rides the v2-dialect migration (parsanol#352): 1.3.110 broke
# plain parses and 1.3.111 (the trivia exemption, parsanol#355) plus the
# re-baked emission-2 artifacts are the first combination that parses
# them. The gemspec floor keeps a bundle that depends on pubid off the
# broken older engines.
RSpec.describe "pubid.gemspec parsanol dependency" do
  let(:requirement) do
    gemspec = Gem::Specification.load(
      File.expand_path("../../pubid.gemspec", __dir__),
    )
    gemspec.runtime_dependencies.find { |d| d.name == "parsanol" }.requirement
  end

  %w[1.3.111].each do |version|
    it "accepts the v2-dialect trivia-exempt release #{version}" do
      expect(requirement).to be_satisfied_by(Gem::Version.new(version))
    end
  end

  %w[1.3.62 1.3.109 1.3.110].each do |version|
    it "rejects the pre-migration release #{version}" do
      expect(requirement).not_to be_satisfied_by(Gem::Version.new(version))
    end
  end
end
