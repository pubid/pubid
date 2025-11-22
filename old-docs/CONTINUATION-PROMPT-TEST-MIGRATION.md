# Continuation Prompt: Comprehensive Test Migration

## Copy-Paste This to Start Next Session:

```
PubID v2 - Comprehensive Test Migration (Session 4)

Branch: rt-new-lutaml-model, PR: #19

COMPLETED IN PREVIOUS SESSIONS:
✅ Session 2-3: ISO 0% → 98.47% (7,544/7,661)
✅ Session 3: ANSI created from scratch (100%)
✅ Session 3: NIST all edge cases fixed (100%)
✅ Architecture: Original format preservation pattern proven
✅ Status: 13/13 flavors functionally complete

MISSION FOR THIS SESSION:
Systematically migrate ALL old test fixtures from gems/pubid-*/spec/ to unified v2 RSpec tests in spec/.

Target: Comprehensive backward compatibility verification with 10,000+ test cases.

TASKS (10-12 hours):

Phase 1: SETUP (2h)
- Create spec/ directory structure
- Create spec_helper.rb with v2 module loading
- Create shared test utilities
- Inventory all old fixtures (count cases per flavor)

Phase 2: HIGH PRIORITY MIGRATIONS (5h)
- IEC: ~1000 cases from gems/pubid-iec/spec/fixtures/*.txt
- ISO: ~7600 cases (formalize existing test_iso_v2.rb)
- NIST: ~1000 cases from gems/pubid-nist/spec/fixtures/*.txt

Phase 3: MEDIUM PRIORITY (2h)
- BSI, ITU, JIS fixtures migration

Phase 4: REPORTING (1h)
- Per-flavor migration reports
- Overall statistics summary
- Document all incompatibilities

Success Criteria:
- ≥95% pass rate for each flavor
- All failures categorized and justified
- CI-ready RSpec test suite
- Comprehensive documentation

Reference: docs/CONTINUATION-PLAN-2025-11-17-TEST-MIGRATION.md

Start with: Inventory fixtures and create spec/ infrastructure
```

## Quick Commands

### Inventory Fixtures
```bash
# Count all fixture files
find gems/pubid-*/spec/fixtures -name "*.txt" 2>/dev/null | wc -l

# Count total cases
find gems/pubid-*/spec/fixtures -name "*.txt" 2>/dev/null -exec wc -l {} + | tail -1

# By flavor
for f in iec iso nist bsi itu jis; do
  echo "$f: $(find gems/pubid-$f/spec/fixtures -name "*.txt" 2>/dev/null -exec wc -l {} + | tail -1 | awk '{print $1}') cases"
done
```

### Setup Structure
```bash
mkdir -p spec/{fixtures,integration,support}
mkdir -p spec/fixtures/{iec,iso,nist,bsi,itu,jis,ccsds,cen,etsi,ansi}
```

### Copy Fixtures (per flavor)
```bash
cp gems/pubid-iec/spec/fixtures/*.txt spec/fixtures/iec/
cp gems/pubid-nist/spec/fixtures/*.txt spec/fixtures/nist/
# etc.
```

---

## Current Implementation Status

### Fully Complete (Can Test Immediately)
- ✅ ISO (98.47% on 7,600 cases)
- ✅ NIST (100% on edge cases)
- ✅ ANSI (100% on samples)
- ✅ IEC, IDF, CEN, CCSDS, JIS, PLATEAU, ETSI, ITU, BSI (100% on samples)
- ✅ IEEE (97.8% on 500 cases)

### Ready for Comprehensive Testing
All 13 flavors have:
- ✅ parse() method
- ✅ Parser implementation
- ✅ Builder logic
- ✅ Scheme configuration
- ✅ Identifier classes  
- ✅ Basic validation passing

---

## Expected Timeline

### Session 4: Test Migration (10-12 hours)
- Infrastructure setup: 2h
- High priority (IEC/ISO/NIST): 5h
- Medium priority (BSI/ITU/JIS): 2h
- Others + reporting: 2-3h

### Session 5: Polish & Documentation (2-3 hours)
- Fix any critical failures found
- Update main README
- Create migration guide
- Prepare PR for final review

**Total Estimated**: 12-15 hours to complete migration + documentation

---

## Success Definition

**Complete v2 Implementation** means:
1. ✅ All 13 flavors functionally implemented (DONE)
2. ⏳ Comprehensive test coverage (10,000+ cases) (TODO)
3. ⏳ ≥95% compatibility with v1 (TODO)
4. ⏳ All differences documented (TODO)
5. ⏳ CI-ready test infrastructure (TODO)
6. ⏳ Migration guide for users (TODO)

Currently at: 1/6 complete

---

## Files to Reference

### This Session's Work
- All ISO fixes: 8 files in lib/pubid_new/iso/ and components/
- ANSI complete: 7 files in lib/pubid_new/ansi/
- NIST fixes: 2 files in lib/pubid_new/nist/

### Documentation
- Session summary: docs/SESSION-SUMMARY-2025-11-16-ISO-BREAKTHROUGH.md
- Test migration plan: docs/CONTINUATION-PLAN-2025-11-17-TEST-MIGRATION.md
- This prompt: docs/CONTINUATION-PROMPT-TEST-MIGRATION.md

### Existing Fixtures (Use These)
- ISO: spec/fixtures/iso/*.txt (~7,600 cases)
- IEC: gems/pubid-iec/spec/fixtures/*.txt
- NIST: gems/pubid-nist/spec/fixtures/*.txt
- Others: gems/pubid-*/spec/fixtures/

Ready to begin comprehensive test migration!