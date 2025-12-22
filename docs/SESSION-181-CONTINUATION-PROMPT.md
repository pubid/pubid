# Session 181+ Continuation Prompt: NIST V1 to V2 Migration

**Context:** Session 180 attempted NIST enhancements but broke critical V1 features. Proper V1 to V2 migration needed.

---

## Current Status

**NIST V2 is BROKEN** - Lost critical features:
- ❌ Stage system (fpd, ipd, pd with id+type)
- ❌ Translation (3-letter language codes: slo, es, pt)
- ❌ Supplement (separate from edition)
- ❌ Format tracking (mr/short/long/abbrev rendering)
- ❌ Multiple render formats

**User Feedback:**
> "Your NIST parsing is broken and wrong. You lost all the draft stages like fpd, languages like slo/es, Supplement, format tracking. You MUST fully port the archived-gems specs!"

---

## What to Do

**DO NOT** try to "enhance" or "fix" NIST incrementally.

**DO** properly migrate V1 to V2 following this plan:
1. Read ALL V1 implementation (`archived-gems/pubid-nist/lib/pubid/nist/**/*.rb`)
2. Read ALL V1 specs (`archived-gems/pubid-nist/spec/**/*.rb`)
3. Create V2 Lutaml::Model components for Stage, Edition, Version, Update
4. Port V1 parser patterns to V2 Parslet grammar
5. Test against ALL V1 specs for 100% feature parity

---

## Critical Files to Read First

**Before doing ANYTHING, read these files:**

```bash
# Core V1 architecture
archived-gems/pubid-nist/lib/pubid/nist/identifier/base.rb
archived-gems/pubid-nist/lib/pubid/nist/stage.rb
archived-gems/pubid-nist/lib/pubid/nist/edition.rb
archived-gems/pubid-nist/lib/pubid/nist/version.rb
archived-gems/pubid-nist/stages.yaml

# V1 parsers
archived-gems/pubid-nist/lib/pubid/nist/parsers/default.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/sp.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/fips.rb

# V1 specs
archived-gems/pubid-nist/spec/pubid_nist/identifier_spec.rb
```

---

## Comprehensive Plan

**Read:** `docs/SESSION-181-NIST-V1-TO-V2-MIGRATION-PLAN.md`

This contains:
- 6 phases of work (12 hours estimated, compressed)
- Implementation status tracker
- Success criteria
- All V1 features to preserve
- Component architecture design
- File structure

---

## Session 181 Immediate Goal

**Phase 1: V1 Feature Documentation (2 hours)**

1. Read ALL V1 core files (30 min)
2. Read ALL V1 parsers (45 min)
3. Read ALL V1 specs (45 min)
4. Create `docs/NIST_V1_FEATURES.md` documenting everything (30 min)

**Output:** Complete understanding of V1 architecture documented

---

## Key V1 Features Example

```ruby
# Stage system
"NIST SP 800-160v1r1 fpd"
# stage.id = "f", stage.type = "pd"
# Renders: "fpd" (short), "(Final Public Draft)" (long)

# Translation
"NIST SP 800-181r1 slo"  # slo = Slovakian
"NIST SP 800-181r1es"    # es = Spanish

# Supplement
"NIST SP 955 Suppl"      # supplement attribute

# Format detection
"NIST.SP.984.4"          # Machine-readable format
# to_s(:mr) => "NIST.SP.984.4"
# to_s(:short) => "NIST SP 984 Part 4"

# Multiple rendering
id.to_s(:short)  # => "NIST SP 800-28 Version 2"
id.to_s(:long)   # => "NIST Special Publication 800-28 Version 2"
id.to_s(:mr)     # => "NIST.SP.800-28.ver2"
id.to_s(:abbrev) # => "SP 800-28 Version 2"
```

---

## Architecture Principles

**MAINTAIN:**
1. **MODEL-DRIVEN** - All concepts as Lutaml::Model components
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **V1 Compatibility** - 100% feature parity required
5. **Component Architecture** - Stage, Edition, Version as proper classes

**NEVER compromise** on V1 feature parity for quick fixes.

---

## Timeline (COMPRESSED)

| Session | Phase | Duration | Deliverable |
|---------|-------|----------|-------------|
| 181 | Phase 1 | 2 hrs | V1 features documented |
| 182 | Phase 2 | 2 hrs | V2 components created |
| 183 | Phase 3 | 3 hrs | Parser migrated |
| 184 | Phase 4 | 2 hrs | Builder/Identifier updated |
| 185 | Phase 5 | 2 hrs | V1 specs ported |
| 186 | Phase 6 | 1 hr | Validation & docs |

**Total:** 6 sessions, 12 hours

---

## Success Metric

**Target:** NIST at 100% with full V1 feature parity
- ✅ All V1 features working
- ✅ All V1 specs passing
- ✅ Fixture validation 100%
- ✅ Multiple render formats working

---

## Quick Start (Session 181)

```bash
# 1. Read the full migration plan
open docs/SESSION-181-NIST-V1-TO-V2-MIGRATION-PLAN.md

# 2. Read V1 core implementation
read archived-gems/pubid-nist/lib/pubid/nist/identifier/base.rb
read archived-gems/pubid-nist/lib/pubid/nist/stage.rb
read archived-gems/pubid-nist/stages.yaml

# 3. Read V1 parsers (most important)
read archived-gems/pubid-nist/lib/pubid/nist/parsers/default.rb
read archived-gems/pubid-nist/lib/pubid/nist/parsers/sp.rb

# 4. Document findings
create docs/NIST_V1_FEATURES.md
```

---

**Status:** Ready to begin proper V1 to V2 migration
**Priority:** CRITICAL - NIST is currently broken
**Approach:** Systematic, architecture-first, V1-compatible

Let's do this right! 🎯