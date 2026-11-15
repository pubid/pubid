# frozen_string_literal: true

# The floor rides the engine-linked graduation (parsanol-rs#519): the
# engine version moves above the legacy rubygems line (1.3.x) so the
# engine-linked runtime gems (`{engine-semver}.{runtime-digit}` — e.g.
# 1.5.0.0) sort correctly forever, and the pessimistic floor `~> 1.5.0`
# takes the 1.5.x.y runtimes (the runtime digits float within 1.5). The
# fleet's artifacts run at the 1.5.0.0 graduation branch.
RSpec.describe "pubid.gemspec parsanol dependency" do
  let(:requirement) do
    gemspec = Gem::Specification.load(
      File.expand_path("../../pubid.gemspec", __dir__),
    )
    gemspec.runtime_dependencies.find { |d| d.name == "parsanol" }.requirement
  end

  %w[1.5.0.0].each do |version|
    it "accepts the engine-linked graduation runtime #{version}" do
      expect(requirement).to be_satisfied_by(Gem::Version.new(version))
    end
  end

  %w[1.3.151 1.3.149 1.3.122].each do |version|
    it "rejects the legacy-line release #{version}" do
      expect(requirement).not_to be_satisfied_by(Gem::Version.new(version))
    end
  end

  %w[1.3.62 1.3.109 1.3.110 1.3.112 1.3.114].each do |version|
    it "rejects the pre-edition-field release #{version}" do
      expect(requirement).not_to be_satisfied_by(Gem::Version.new(version))
    end
  end
end
