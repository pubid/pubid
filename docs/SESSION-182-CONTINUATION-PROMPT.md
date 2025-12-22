# Session 182+ Continuation Prompt: NIST V2 Migration - Phases 2-6

**Context:** Session 181 completed Phase 1 (V1 Feature Documentation). Sessions 182-184 will complete V2 migration.

---

## Current Status

**Session 181 Complete:** Phase 1 - V1 Feature Documentation ✅

**Deliverables:**
- ✅ [`docs/NIST_V1_FEATURES.md`](NIST_V1_FEATURES.md:1) - 500+ line comprehensive V1 documentation
- ✅ 12 major V1 feature categories documented
- ✅ All V1 core files, parsers, and specs analyzed

**V1 Critical Features Identified:**
1. Stage (id + type → "fpd", "ipd") - MISSING in V2
2. Translation (3-letter codes) - MISSING in V2
3. Supplement (separate from edition) - MISSING in V2
4. Format tracking (mr/short/long/abbrev) - MISSING in V2
5. Edition (year/month/day) - MISSING in V2
6. Version (dotted notation) - MISSING in V2
7. Update (/Upd1-YYYYMM) - MISSING in V2
8. Multi-format rendering - MISSING in V2

---

## What to Do

**READ FIRST:**
1. [`docs/SESSION-182-CONTINUATION-PLAN.md`](SESSION-182-CONTINUATION-PLAN.md:1) - Complete migration plan (Phases 2-6)
2. [`docs/NIST_V1_FEATURES.md`](NIST_V1_FEATURES.md:1) - V1 features reference

**DO NOT:**
- Try to "enhance" or "fix" incrementally
- Make changes without reading V1 implementation
- Compromise architecture for quick fixes
- Skip component classes in favor of attributes

**DO:**
- Follow the plan EXACTLY (Phases 2→3→4→5→6)
- Create proper Lutaml::Model components
- Port V1 patterns PRECISELY
- Test against V1 specs for 100% parity
- Maintain MODEL-DRIVEN architecture

---

## Session 182 Immediate Goal

**Phase 2: V2 Component Architecture** (90 minutes)

Create 5 Lutaml::Model component classes:

### Task 2.1: Stage Component (25 min)
**File:** `lib/pubid_new/nist/components/stage.rb`

**Requirements:**
- Attributes: `id` (string), `type` (string)
- Load STAGES from archived-gems YAML
- Rendering: "ipd" (short/mr), "(Initial Public Draft)" (long)
- Validation: id must be i/f/1-9, type must be pd/wd/prd

**Example V1 behavior:**
```ruby
Stage.new(id: "i", type: "pd").to_s(:short) # => "ipd"
Stage.new(id: "f", type: "pd").to_s(:long)  # => "(Final Public Draft)"
```

### Task 2.2: Edition Component (20 min)
**File:** `lib/pubid_new/nist/components/edition.rb`

**Requirements:**
- Attributes: `number`, `year`, `month`, `day` (all optional)
- Rendering: "2-2020" (short), "Edition 2 (2020)" (long)
- Handle year-only, year+month, year+month+day combinations

### Task 2.3: Version Component (15 min)
**File:** `lib/pubid_new/nist/components/version.rb`

**Requirements:**
- Attribute: `value` (string for dotted notation)
- Rendering: "ver1.0.2" (short/mr), "Version 1.0.2" (long)

### Task 2.4: Update Component (15 min)
**File:** `lib/pubid_new/nist/components/update.rb`

**Requirements:**
- Attributes: `number`, `year`, `month`
- Rendering: "/Upd1-202102" (short), ".u1-202102" (mr)

### Task 2.5: Translation Component (15 min)
**File:** `lib/pubid_new/nist/components/translation.rb`

**Requirements:**
- Attribute: `code` (3-letter string)
- Rendering: " spa" (short), ".spa" (mr)

**After completing Phase 2:**
- Run basic tests
- Verify components work as Lutaml::Model classes
- Move to Phase 3 (Parser Migration)

---

## Critical V1 Examples to Preserve

**Stage:**
```ruby
"NIST SP 800-53r5 ipd"  # stage.id="i", stage.type="pd"
"NIST.SP.800-66r2.ipd"  # MR format
```

**Translation:**
```ruby
"NIST SP 1262es" → "NIST SP 1262 spa"  # Transform es→spa
"NIST SP 800-189 IPD spa"  # Stage + translation
```

**Edition:**
```ruby
"NBS FIPS 107-Mar1985" → edition.year=1985, edition.month=3
"NBS FIPS 11-1-Sep30/1977" → year=1977, month=9, day=30
```

**Update:**
```ruby
"NIST SP 800-53r4/Upd3-2015"
"NIST AMS 300-8r1 (February 2021 update)" → "/Upd1-202102"
```

**Version:**
```ruby
"NIST SP 800-63v1.0.2"
"NIST SP 1011v1ver2.0"  # volume + version
```

**Format rendering:**
```ruby
id.to_s(:short)  # => "NIST SP 800-53r5"
id.to_s(:long)   # => "National Institute... Special Publication 800-53, Revision 5"
id.to_s(:mr)     # => "NIST.SP.800-53r5"
id.to_s(:abbrev) # => "Natl. Inst... Spec. Publ. 800-53, Rev. 5"
```

---

## Architecture Principles (NEVER VIOLATE)

1. **MODEL-DRIVEN** - All concepts as Lutaml::Model components
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **V1 Compatibility** - 100% feature parity REQUIRED
5. **Format Preservation** - Track parsed format, render in 4 formats
6. **Component Architecture** - Stage, Edition, Version, Update, Translation as proper classes
7. **Supplement Separation** - Supplement is NOT part of Edition!

---

## File Structure

**Components to create:**
```
lib/pubid_new/nist/components/
├── stage.rb              # Session 182
├── edition.rb            # Session 182
├── version.rb            # Session 182
├── update.rb             # Session 182
└── translation.rb        # Session 182
```

**Files to modify (later phases):**
```
lib/pubid_new/nist/
├── parser.rb             # Phase 3 (Session 182-183)
├── builder.rb            # Phase 4 (Session 183)
└── identifiers/
    └── base.rb           # Phase 4 (Session 183)
```

---

## Success Metrics

**Phase 2 (Session 182):**
- ✅ 5 component files created
- ✅ All components inherit from Lutaml::Model::Serializable
- ✅ All components have proper to_s(format) methods
- ✅ Basic unit tests passing

**Overall (Sessions 182-184):**
- ✅ NIST at 100% with V1 feature parity
- ✅ All V1 specs passing
- ✅ Fixture validation at 100%
- ✅ 4 render formats working

---

## Quick Start (Session 182)

```bash
# 1. Read the migration plan
open docs/SESSION-182-CONTINUATION-PLAN.md

# 2. Read V1 features reference
open docs/NIST_V1_FEATURES.md

# 3. Create components directory
mkdir -p lib/pubid_new/nist/components

# 4. Start with Stage component
# Follow Phase 2, Task 2.1 from continuation plan
```

---

## Timeline (COMPRESSED)

| Session | Phases | Duration | Deliverables |
|---------|--------|----------|--------------|
| 182 | Phase 2 (90 min) | 1.5 hrs | 5 components |
| 182-183 | Phase 3 (150 min) | 2.5 hrs | Parser migration |
| 183 | Phase 4 (90 min) | 1.5 hrs | Builder/Identifier |
| 184 | Phase 5-6 (150 min) | 2.5 hrs | Specs + validation |
| **Total** | **All** | **8 hrs** | **Complete** |

---

**Status:** Ready to begin Phase 2 (V2 Component Architecture)
**Priority:** CRITICAL - NIST currently BROKEN
**Approach:** Systematic V1 to V2 migration, architecture-first

Let's restore NIST properly! 🎯