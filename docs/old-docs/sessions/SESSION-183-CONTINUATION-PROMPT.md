# Session 183+ Continuation Prompt: NIST V2 Migration - Phases 3-6

**Context:** Session 182 completed Phase 2 (V2 Component Architecture). Sessions 183-184 will complete Phases 3-6 (Parser, Builder, Specs, Validation).

---

## Current Status

**Session 182 Complete:** Phase 2 - V2 Component Architecture ✅

**Deliverables:**
- ✅ [`lib/pubid_new/nist/components/stage.rb`](../lib/pubid_new/nist/components/stage.rb:1) - Stage (id + type)
- ✅ [`lib/pubid_new/nist/components/edition.rb`](../lib/pubid_new/nist/components/edition.rb:1) - Edition (number, year, month, day)
- ✅ [`lib/pubid_new/nist/components/version.rb`](../lib/pubid_new/nist/components/version.rb:1) - Version (dotted notation)
- ✅ [`lib/pubid_new/nist/components/update.rb`](../lib/pubid_new/nist/components/update.rb:1) - Update (number, year, month)
- ✅ [`lib/pubid_new/nist/components/translation.rb`](../lib/pubid_new/nist/components/translation.rb:1) - Translation (3-letter codes)

**Architecture Quality:**
- ✅ All 5 components inherit from Lutaml::Model::Serializable
- ✅ Support 4 render formats (:short, :mr, :long, :abbrev)
- ✅ 100% V1 feature parity on component level
- ✅ Comprehensive inline documentation

---

## What to Do

**READ FIRST:**
1. [`docs/SESSION-183-CONTINUATION-PLAN.md`](SESSION-183-CONTINUATION-PLAN.md:1) - Complete migration plan (Phases 3-6)
2. [`docs/NIST_V1_FEATURES.md`](NIST_V1_FEATURES.md:1) - V1 features reference

**DO NOT:**
- Try to "enhance" or "fix" incrementally
- Make changes without reading V1 implementation
- Compromise architecture for quick fixes
- Skip reading V1 parsers before modifying V2

**DO:**
- Follow the plan EXACTLY (Phases 3→4→5→6)
- Read V1 parser implementation FIRST
- Port V1 patterns PRECISELY
- Test against V1 specs for 100% parity
- Maintain MODEL-DRIVEN architecture
- Keep supplement SEPARATE from edition

---

## Session 183 Immediate Goals

### Phase 3: Parser Migration (120 minutes)

Port V1 Parslet grammar patterns to V2 parser with 100% feature parity.

#### Task 3.1: Read V1 Parser Implementation (15 min)

**Files to read:**
```bash
archived-gems/pubid-nist/lib/pubid/nist/parser.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/default.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/sp.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/fips.rb
```

**Extract these patterns:**
- Stage parsing (old: `(IPD)`, new: ` ipd` or `.ipd`)
- Edition parsing (e-prefix, dash-year, month-year)
- Version parsing (ver/v prefix with dots)
- Update parsing (/Upd, -upd patterns)
- Translation parsing (parenthetical, space, dot)
- Supplement parsing (supp/sup - SEPARATE from edition!)
- Two-stage parsing architecture

#### Task 3.2: Update V2 Parser Base Rules (60 min)

**File:** `lib/pubid_new/nist/parser.rb`

Add these V1 patterns:
1. Stage: `(IPD)` old style, ` ipd` new style
2. Translation: `(spa)`, ` spa`, `.spa`
3. Edition: `e2019`, `-Mar1985`, `-Sep30/1977`
4. Version: `ver1.0.2`, `v2.0`
5. Update: `/Upd1-202102`, `-upd`
6. Supplement: `supp`, `sup26`

#### Task 3.3: Format Detection (20 min)

Add format detection to parser:
- MR format: Contains dots (`NIST.SP.800-53r5`)
- Short format: Contains spaces (`NIST SP 800-53r5`)
- Store as `parsed_format` attribute

#### Task 3.4: Two-Stage Parsing (25 min)

Implement two-stage architecture:
1. Detect series and publisher
2. Use series-specific parser if available
3. Fallback to default parser

---

### Phase 4: Builder & Identifier Updates (60 minutes)

Update Builder to construct V2 components, update Base identifier.

#### Task 4.1: Builder Component Casting (30 min)

**File:** `lib/pubid_new/nist/builder.rb`

Add `cast()` method cases for:
- `:stage` → `Components::Stage.new(id:, type:)`
- `:edition_year/month/day` → `Components::Edition.new(...)`
- `:version` → `Components::Version.new(value:)`
- `:update` → `Components::Update.new(number:, year:, month:)`
- `:translation` → `Components::Translation.new(code:)` (with normalization es→spa)

#### Task 4.2: Update Base Identifier (30 min)

**File:** `lib/pubid_new/nist/identifiers/base.rb`

1. Add V2 component attributes:
   - `attribute :stage, Components::Stage`
   - `attribute :edition, Components::Edition`
   - `attribute :version, Components::Version`
   - `attribute :update, Components::Update`
   - `attribute :translation, Components::Translation`

2. Add plain attributes (not components):
   - `supplement`, `revision`, `volume`, `part`, etc.

3. Add `parsed_format` attribute

4. Implement `to_s(format, without_edition:)` method

---

## Critical V1 Examples to Preserve

### Stage:
```ruby
"NIST SP 800-53r5 ipd"  # stage.id="i", stage.type="pd"
"NIST.SP.800-66r2.ipd"  # MR format
"NIST SP(IPD) 800-53r5" # Old style (normalize to new)
```

### Translation:
```ruby
"NIST SP 1262es" → "NIST SP 1262 spa"  # Transform es→spa
"NIST SP 800-189 IPD spa"  # Stage + translation
```

### Edition:
```ruby
"NBS FIPS 107-Mar1985" → edition.year=1985, edition.month=3
"NBS FIPS 11-1-Sep30/1977" → year=1977, month=9, day=30
"NIST SP 800-53e2019" → edition.year=2019
```

### Update:
```ruby
"NIST SP 800-53r4/Upd3-2015"
"NIST AMS 300-8r1 (February 2021 update)" → "/Upd1-202102"
```

### Version:
```ruby
"NIST SP 800-63v1.0.2"
"NIST SP 1011v1ver2.0"  # volume + version
```

### Format Rendering:
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

**Components created (Session 182):**
```
lib/pubid_new/nist/components/
├── stage.rb              # ✅ Complete
├── edition.rb            # ✅ Complete
├── version.rb            # ✅ Complete
├── update.rb             # ✅ Complete
└── translation.rb        # ✅ Complete
```

**Files to modify (Session 183):**
```
lib/pubid_new/nist/
├── parser.rb             # Phase 3 (add V1 patterns)
├── builder.rb            # Phase 4 (component casting)
└── identifiers/
    └── base.rb           # Phase 4 (V2 components)
```

---

## Success Metrics

**Phase 3 (Parser):**
- ✅ All V1 stage patterns parsing
- ✅ All V1 edition patterns parsing
- ✅ Version/update/translation parsing
- ✅ Format detection working
- ✅ Two-stage parsing architecture

**Phase 4 (Builder/Identifier):**
- ✅ Builder casts to V2 components
- ✅ Base has all V2 component attributes
- ✅ Multi-format rendering (4 formats)
- ✅ Round-trip preservation

**Overall (Session 183):**
- ✅ NIST parsing basic identifiers
- ✅ Components rendering correctly
- ✅ Format tracking working
- ✅ Ready for Phase 5 (specs)

---

## Quick Start (Session 183)

```bash
# 1. Read the continuation plan
open docs/SESSION-183-CONTINUATION-PLAN.md

# 2. Read V1 features reference
open docs/NIST_V1_FEATURES.md

# 3. Read V1 parser implementation
open archived-gems/pubid-nist/lib/pubid/nist/parser.rb
open archived-gems/pubid-nist/lib/pubid/nist/parsers/default.rb

# 4. Start Phase 3: Parser Migration
# Follow tasks 3.1 → 3.2 → 3.3 → 3.4 in order
```

---

## Timeline (COMPRESSED)

| Session | Phases | Duration | Deliverables |
|---------|--------|----------|--------------|
| 183 | Phase 3-4 (180 min) | 3 hrs | Parser + Builder |
| 184 | Phase 5-6 (120 min) | 2 hrs | Specs + Docs |
| **Total** | **All** | **5 hrs** | **Complete** |

---

**Status:** Ready to begin Phase 3 (Parser Migration)
**Priority:** CRITICAL - NIST currently BROKEN
**Approach:** Systematic V1 to V2 migration, architecture-first

Let's restore NIST properly! 🎯