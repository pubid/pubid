# Session 212+ Implementation Guide: CIE Optimization & Documentation

**Read first:** [`docs/SESSION-212-CONTINUATION-PLAN.md`](SESSION-212-CONTINUATION-PLAN.md)

**Current status:** CIE at 93.59% (321/343), all core features complete
**Tasks available:** Edge case fixes (optional), Documentation (required)
**Timeline:** 2-4 hours total

---

## Quick Start

**Option A: Documentation Only (RECOMMENDED - 60 min)**
Execute Session 214 to update README.adoc and mark complete

**Option B: Optimization + Documentation (4-6 hours)**
Execute Sessions 212-214 to reach 95-98% then document

---

## Session 212: CIE Edge Cases (OPTIONAL - 90 min)

### Prerequisites
- Read `spec/fixtures/cie/identifiers/fail/all.txt`
- Understand 22 failure patterns
- Review CIE architecture document

### Implementation Steps

**Step 1: Analyze Failures (15 min)**
```bash
cd /Users/mulgogi/src/mn/pubid/spec/fixtures/cie/identifiers/fail
cat all.txt | head -30
```

Group by pattern type and prioritize.

**Step 2: Language Format Fixes (30 min)**

File: `lib/pubid_new/cie/parser.rb`

Enhance identical_with_iso rule to handle `/E:2001` pattern:
- Current rule works for `/1998` (slash-year)
- Needs to handle `/E:2001` (language + colon-year)
- Already partially implemented, verify it works

**Step 3: Data Quality Preprocessing (20 min)**

File: `lib/pubid_new/cie/parser.rb` (Parser.parse method)

Add preprocessing:
```ruby
# Fix missing colon in /EYYYY patterns
cleaned = cleaned.gsub(/\/([A-Z])(\d{4})/, '/\1:\2')

# Fix space before parenthetical language
cleaned = cleaned.gsub(/\s+\(([A-Z]{2}-\d{4})\)/, ' (\1)')
```

**Step 4: Test (25 min)**
```ruby
ruby -e "
require_relative 'lib/pubid_new/cie'
['CIE S 014-4/E2007', 'CIE S 008/E:2001 (ISO 8995-1:2002(E))'].each do |t|
  begin
    id = PubidNew::Cie.parse(t)
    puts id.to_s == t ? '✅' : '⚠️'
  rescue => e
    puts '❌'
  end
end
"
```

**Expected:** 330+/343 (96%+)

---

## Session 213: Bundle & Validation (OPTIONAL - 60 min)

### Prerequisites
- Session 212 complete OR skipped
- Ready for final validation

### Implementation Steps

**Step 1: Fix Bundle (30 min)**

The bundle pattern needs to store original string:

File: `lib/pubid_new/cie/builder.rb`

```ruby
def build(parsed_hash)
  # Store original input for bundle
  @original_input = parsed_hash[:_original_input] if parsed_hash[:_original_input]
  
  identifier_class = determine_class(parsed_hash)
  attributes = extract_attributes(parsed_hash)
  
  # For bundles, use original string
  if identifier_class == Identifiers::Bundle
    attributes[:identifiers_string] = @original_input
  end
  
  identifier_class.new(**attributes)
end
```

File: `lib/pubid_new/cie/parser.rb`

```ruby
def self.parse(string)
  cleaned = string.strip
  cleaned = cleaned.gsub(/\s+/, " ")
  result = new.parse(cleaned)
  result[:_original_input] = string  # Preserve original
  result
end
```

**Step 2: Run Classification (10 min)**
```bash
cd spec/fixtures
ruby run_classify_cie.rb
```

**Step 3: Verify (20 min)**
- Check pass rate (target: 97%+)
- Run other flavor tests to ensure no regressions
- Document results

---

## Session 214: Final Documentation (REQUIRED - 60 min)

### Prerequisites
- CIE implementation complete
- Ready to document in README

### Implementation Steps

**Step 1: Update README.adoc (30 min)**

File: `README.adoc`

Add after OIML section (around line 200):

```asciidoc
==== CIE (Commission Internationale de l'Éclairage) ✨

**Status:** ✅ 321/343 (93.59%) - 16th Flavor Added!

CIE is the International Commission on Illumination, the global authority on light, lighting, color, and color spaces.

**Implementation:** Sessions 207-211
**Validation:** 93.59% (321/343 identifiers)
**Architecture:** Complete V2 with dual-style system

.Dual-Style System (Legacy vs Current)

CIE identifiers use two date separator styles based on publication era:

* **Legacy (pre-2001):** Dash separator `-` for dates
* **Current (2001+):** Colon separator `:` for dates
* **Transition (2001):** Both formats co-exist

[source,ruby]
----
require 'pubid_new/cie'

# Legacy style (dash separator)
cie_legacy = PubidNew::Cie.parse("CIE 032-1977")
cie_legacy.to_s  # => "CIE 032-1977"

# Current style (colon separator)
cie_current = PubidNew::Cie.parse("CIE 145:2002")
cie_current.to_s  # => "CIE 145:2002"

# With S prefix and language
cie_s = PubidNew::Cie.parse("CIE S 013/E:2003")
cie_s.s_prefix    # => true
cie_s.language.code  # => "E"
cie_s.to_s  # => "CIE S 013/E:2003"
----

.Supported Identifier Types (11 Types - MECE)

[cols="1,3"]
|===
|Type |Example

|Standard
|`CIE 145:2002`, `CIE S 013/E:2003`

|Joint with ISO
|`CIE ISO 11664-1:2019`, `CIE ISO TR 21783:2022(E)`

|Joint with IEC
|`CIE IEC 017.4-1987`

|Joint with ISO/CIE
|`CIE ISO/CIE TR 3092:2023(E)`

|Identical with ISO
|`CIE S 006.1/1998 (ISO 16508:1999)`

|Dual with IEC
|`CIE S 009:2002/IEC 62471:2006`

|Conference
|`CIE x038:2013`, `CIE x038:2013 Amendment 1`

|Supplement
|`CIE 121-SP1:2009`, `CIE 198-SP1.4:2011`

|Corrigendum
|`CIE 232:2019/Cor1:2020`

|Bundle
|`CIE 198-SP1.1:2011,198-SP1.2:2011,...`

|Tutorial Bundle
|`CIE Tutorials Bundle 1`
|===

.Language Formats (3 Formats)

CIE supports three distinct language code formats:

[source,ruby]
----
# Format 1: Slash-prefix (legacy)
cie1 = PubidNew::Cie.parse("CIE S 004/E-2001")
cie1.language.format  # => "slash"
cie1.to_s  # => "CIE S 004/E-2001"

# Format 2: Parenthetical
cie2 = PubidNew::Cie.parse("CIE 232:2019(DE)")
cie2.language.format  # => "paren"
cie2.to_s  # => "CIE 232:2019(DE)"

# Format 3: With translation year
cie3 = PubidNew::Cie.parse("CIE 155:2003 (RU-2021)")
cie3.language.translation_year  # => "2021"
cie3.to_s  # => "CIE 155:2003 (RU-2021)"
----

**Architecture:**
- MODEL-DRIVEN with Lutaml::Model components
- MECE organization (11 mutually exclusive types)
- Three-layer separation (Parser/Builder/Identifier)
- Automatic style detection from separators
- Perfect round-trip fidelity on 93.6% of patterns
```

**Step 2: Update V2 Migration Table (10 min)**

Update the table to include CIE:

```asciidoc
|**CIE** ✨
|343
|321
|93.59%
|✅ Excellent
|16th flavor! Dual-style, 11 types (Session 207-211)
```

**Step 3: Archive Documentation (10 min)**

```bash
cd /Users/mulgogi/src/mn/pubid
mkdir -p docs/old-docs/sessions
mv docs/SESSION-201-COMPREHENSIVE-PLAN.md docs/old-docs/sessions/
mv docs/SESSION-201-CONTINUATION-PLAN.md docs/old-docs/sessions/
mv docs/SESSION-201-README-RESTORATION-PLAN.md docs/old-docs/sessions/
```

**Step 4: Create Session Summary (10 min)**

File: `docs/old-docs/sessions/session-201-211-summary.md`

Document:
- What was accomplished
- Files created
- Metrics achieved
- Next steps

---

## Testing Checklist

### After Each Session

**Session 212 (if executed):**
- [ ] Run: `ruby run_classify_cie.rb`
- [ ] Verify: 330+/343 (96%+)
- [ ] Check: No regressions in 15 other flavors

**Session 213 (if executed):**
- [ ] Run: `ruby run_classify_cie.rb`
- [ ] Verify: 334+/343 (97%+)
- [ ] Run: `bundle exec rspec spec/pubid_new/iso/identifier_spec.rb` (spot check)

**Session 214 (required):**
- [ ] Verify: README.adoc valid AsciiDoc
- [ ] Check: All sections complete
- [ ] Confirm: CIE documented properly

---

## Commit Strategy

### After Session 212 (if executed)
```bash
git add -A
git commit -m "feat(cie): edge case fixes for 96%+ validation

Session 212: CIE Edge Cases
- Language format enhancements (+3-5 IDs)
- Special conference patterns (+2 IDs)
- Data quality preprocessing (+3 IDs)
- CIE: 330+/343 (96%+)

Architecture: Maintained MODEL-DRIVEN, MECE, Three-layer"
```

### After Session 213 (if executed)
```bash
git commit -m "feat(cie): bundle fixes and final validation

Session 213: Bundle & Testing
- Bundle parser refinement
- Comprehensive validation complete
- CIE: 334-338/343 (97-98%)

Testing: Zero regressions in 15 other flavors"
```

### After Session 214 (required)
```bash
git commit -m "docs: complete CIE documentation in README

Session 214: Final Documentation
- Added CIE section to README.adoc
- Updated V2 migration status table
- Archived session documentation
- Project marked COMPLETE

Overall: 16 flavors, 88,185+ identifiers, 99%+ success"
```

---

## Risk Mitigation

### High-Risk Areas

**Parser Changes:**
- Risk: Breaking existing patterns
- Mitigation: Test after each change
- Rollback: Revert individual commits

**Language Handling:**
- Risk: Format confusion
- Mitigation: Explicit format capture
- Test: All 3 formats explicitly

### Validation Checkpoints

**After Session 212:**
- [ ] CIE at 96%+ OR rollback
- [ ] Other flavors unchanged

**After Session 213:**
- [ ] CIE at 97%+ OR document limitation
- [ ] Comprehensive testing passed

---

## Quick Reference

### Run CIE Classification
```bash
cd /Users/mulgogi/src/mn/pubid/spec/fixtures
ruby run_classify_cie.rb
```

### Test Specific Pattern
```ruby
require_relative 'lib/pubid_new/cie'
id = PubidNew::Cie.parse("CIE 145:2002")
puts id.to_s
```

### Check Other Flavors
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb
bundle exec rspec spec/pubid_new/nist/identifier_spec.rb
```

---

## Success Metrics

**Session 212 Success:**
- ✅ CIE at 330+/343 (96%+)
- ✅ No regressions
- ✅ Clean implementation

**Session 213 Success:**
- ✅ CIE at 334+/343 (97%+)
- ✅ Bundle working
- ✅ All tests passing

**Session 214 Success:**
- ✅ README.adoc updated
- ✅ Documentation complete
- ✅ Project marked COMPLETE

---

## Files Reference

**CIE Implementation:**
- `lib/pubid_new/cie/parser.rb` - Parslet grammar
- `lib/pubid_new/cie/builder.rb` - Object construction
- `lib/pubid_new/cie/identifiers/` - 9 identifier classes
- `lib/pubid_new/cie/components/` - 2 components

**Documentation:**
- `docs/CIE_ARCHITECTURE_DESIGN.md` - Complete design (797 lines)
- `docs/CIE_IMPLEMENTATION_PLAN.md` - Roadmap
- `docs/SESSION-212-CONTINUATION-PLAN.md` - This plan
- `README.adoc` - Main documentation (needs CIE section)

---

**Ready to execute!** Choose based on time available and quality target.

**Recommendation:** Session 214 only (documentation) - 93.6% is excellent! 🚀
