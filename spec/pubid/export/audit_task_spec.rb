# frozen_string_literal: true

require "spec_helper"
require "rake"
require "stringio"

# Ensure `require "pubid/export"` inside the rake task resolves.
$LOAD_PATH.unshift(File.expand_path("../../../lib", __dir__))

RSpec.describe "export:audit rake task" do
  let(:rake_file) do
    File.expand_path("../../../lib/tasks/export.rake", __dir__)
  end

  before do
    Rake.application = Rake::Application.new
    load rake_file
  end

  def invoke_audit
    original = $stdout
    $stdout = StringIO.new
    Rake::Task["export:audit"].invoke
    $stdout.string
  ensure
    $stdout = original
  end

  it "runs without raising" do
    expect { invoke_audit }.not_to raise_error
  end

  it "prints an audit summary" do
    expect(invoke_audit).to include("Audit Summary:")
  end
end
