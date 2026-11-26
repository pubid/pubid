# frozen_string_literal: true

require "shellwords"

# The PFS tooling, wrapped for the gem's rake (issue #152).
#
# The machinery lives in pubid-grammar (scripts/pfs); these tasks run it
# against the SIBLING checkout (../pubid-grammar, or PUBID_GRAMMAR_PATH)
# — the grammar repo is the SSOT and the commands mutate only there.
#
#   rake pfs:new[Acme,scheme=acme,out=definitions/acme.pfs]
#   rake pfs:lint[definitions/acme.pfs]
#   rake pfs:doctor                  the drift checks (pin, freshness,
#                                    contracts, gem parity, attestation)
#   rake pfs:capture[specimen.txt,scheme=acme,out=draft.pfs]
#   rake pfs:cutover[acme_pfs]       the dev-alias -> canonical gates
#
# The first bracketed value is the positional argument; the rest are
# name=value options (rake delivers them verbatim, so the tasks parse
# them). The doctor's gem-parity check reads THIS checkout's data/parg/
# — so `rake pfs:doctor` from the gem is the consumer-side view of the
# same drift the grammar repo's doctor reports.

GRAMMAR_PATH = ENV["PUBID_GRAMMAR_PATH"] ||
  File.expand_path("../../../pubid-grammar", __dir__)
PFS_CLI = File.join(GRAMMAR_PATH, "scripts/pfs")

# Runs the PFS CLI. The script carries a shebang but ships
# non-executable (the repo's convention); it is invoked as `ruby`.
def pfs_run(*args)
  unless File.file?(PFS_CLI)
    abort "the PFS CLI is not at #{PFS_CLI} — set PUBID_GRAMMAR_PATH " \
          "to a pubid-grammar checkout"
  end
  ruby "#{PFS_CLI} #{args.join(' ')}"
end

# rake delivers bracketed values positionally; the name=value ones are
# parsed into --flags here.
def pfs_flags(args, *keys)
  keys.filter_map do |key|
    raw = args.extras.find { |e| e.start_with?("#{key}=") }
    next unless raw

    "--#{key} #{Shellwords.escape(raw.split('=', 2)[1])}"
  end
end

def pfs_testsuite_path
  ENV["PUBID_TESTSUITE_PATH"] ||
    File.expand_path("../../../pubid-testsuite", __dir__)
end

def pfs_task_new(args)
  org = args[:org] or abort "usage: rake pfs:new[<Org>,scheme=...,out=...]"
  pfs_run("new", Shellwords.escape(org),
          *pfs_flags(args, :scheme, :title, :publisher, :prefixes, :out))
end

def pfs_task_lint(args)
  file = args[:file] or
    abort "usage: rake pfs:lint[<definition.pfs>] " \
          "(the path is relative to #{GRAMMAR_PATH})"
  pfs_run("lint", Shellwords.escape(File.expand_path(file, GRAMMAR_PATH)))
end

def pfs_task_doctor
  pfs_run("doctor", "--gem-root", Shellwords.escape(Dir.pwd),
          "--testsuite-root", Shellwords.escape(pfs_testsuite_path))
end

def pfs_task_capture(args)
  input = args[:input] or
    abort "usage: rake pfs:capture[<identifiers.txt>,scheme=...,out=...]"
  pfs_run("capture", Shellwords.escape(File.expand_path(input)),
          *pfs_flags(args, :scheme, :title, :publisher, :out))
end

def pfs_task_cutover(args)
  key = args[:key] or abort "usage: rake pfs:cutover[<org>_pfs]"
  pfs_run("cutover", Shellwords.escape(key),
          "--gem-root", Shellwords.escape(Dir.pwd),
          "--testsuite-root", Shellwords.escape(pfs_testsuite_path))
end

namespace :pfs do
  desc "Scaffold a composed flavor (rake pfs:new[Org,scheme=acme,out=P])"
  task :new, [:org] do |_task, args|
    pfs_task_new(args)
  end

  desc "Pre-compile diagnostics (rake pfs:lint[definitions/acme.pfs])"
  task :lint, [:file] do |_task, args|
    pfs_task_lint(args)
  end

  desc "Drift checks: the fleet pin, freshness, the contracts round, " \
       "gem parity (this checkout's data/parg/), the attestation"
  task :doctor do
    pfs_task_doctor
  end

  desc "The lossless wizard substrate (rake pfs:capture[spec.txt,scheme=k])"
  task :capture, [:input] do |_task, args|
    pfs_task_capture(args)
  end

  desc "The dev-alias -> canonical gates + plan (rake pfs:cutover[k_pfs])"
  task :cutover, [:key] do |_task, args|
    pfs_task_cutover(args)
  end
end
