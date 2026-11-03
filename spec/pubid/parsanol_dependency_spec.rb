# frozen_string_literal: true

# The floor rides parsanol's single dialect axis (ruby#357): 1.3.114 is
# the release whose artifact envelope records `edition` ("v1"/"v2") in
# place of the `mode` + `emission` pair, and these artifacts are re-baked
# at it. The pessimistic floor names 1.3.122 - the engine the fleet's
# artifacts are re-baked at and whose array-binding contract (#408) and
# loud-loss check (#413) the builders are aligned to.
RSpec.describe "pubid.gemspec parsanol dependency" do
  let(:requirement) do
    gemspec = Gem::Specification.load(
      File.expand_path("../../pubid.gemspec", __dir__),
    )
    gemspec.runtime_dependencies.find { |d| d.name == "parsanol" }.requirement
  end

  %w[1.3.122].each do |version|
    it "accepts the edition-field release #{version}" do
      expect(requirement).to be_satisfied_by(Gem::Version.new(version))
    end
  end

  %w[1.3.62 1.3.109 1.3.110 1.3.112 1.3.114].each do |version|
    it "rejects the pre-edition-field release #{version}" do
      expect(requirement).not_to be_satisfied_by(Gem::Version.new(version))
    end
  end
end
