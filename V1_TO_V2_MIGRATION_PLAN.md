# PubID V1 to V2 Migration Plan

**Date:** 2025-11-23  
**Session:** 5  
**Objective:** Systematically migrate V1 test structure to V2 architecture

---

## Executive Summary

This plan migrates PubID from V1 (gems/pubid-{flavor}/) to V2 (lib/pubid_new/):
1. Archive V1 code for reference
2. Document V1 → V2 API changes
3. Migrate identifier tests file-by-file
4. Consolidate fixtures
5. Document gaps

**Estimated Time:** 7.5-9.5 hours for ISO, 4-8 hours per additional flavor

---

## Current State Assessment

### V1 Structure (Deprecated)
```
gems/pubid-iso/spec/
├── fixtures/               # 14 fixture files
├── pubid_iso/
│   ├── identifier_spec.rb
│   └── identifier/        # 9 test files
└── spec_helper.rb
```

### V2 Structure (Active)
```
spec/
├── fixtures/iso/          # 25 files ✅ 
└── pubid_new/iso/
    ├── identifier_spec.rb   # 20 tests ✅
    ├── parser_spec.rb       # 56 tests ✅
    ├── builder_spec.rb      # 50 tests ✅
    ├── performance_spec.rb  # 6 tests ✅
    ├── components/          # 34 tests ✅
    └── identifiers/         # 2,859 tests ❌ (V1 API)
```

**Status:** Core 166 tests passing, identifiers need API migration

---

## Migration Phases

### Phase 1: Archive V1 Code (1 hour)

**Create structure:**
```bash
mkdir -p old_specs/pubid/{iso,iec,nist,ieee,itu,jis,etsi,bsi,cen,ccsds}
```

**Move V1 specs:**
```bash
mv gems/pubid-iso/spec old_specs/pubid/iso/v1_specs
# Repeat for each flavor
```

### Phase 2: Document API Mapping (30 min)

**Key V1 → V2 Changes:**

| V1 | V2 | Notes |
|----|----|----|
| `ClassName.parse(str)` | `PubidNew::Iso.parse(str)` | Use scheme |
| `publisher.body` | `publisher.publisher` | Renamed |
| `copublishers.first.body` | `publisher.copublisher.first` | Nested |
| `type.type_code` | `typed_stage.type_code` | Moved |
| `stage.stage_code` | `typed_stage.stage_code` | Moved |
| `typed_stage.abbreviation` | `typed_stage.abbr.first` | Now array |

**Save as:** `docs/V1_TO_V2_API_MAPPING.md`

### Phase 3: Migrate ISO Tests (4-6 hours)

**19 files to migrate in `spec/pubid_new/iso/identifiers/`**

**Priority order:**
1. Small files: data_spec.rb, extract_spec.rb
2. Medium files: guide_spec.rb, technical_report_spec.rb
3. Large files: amendment_spec.rb, corrigendum_spec.rb

**Per file process:**
1. Backup to `old_specs/pubid/iso/v2_before_migration/`
2. Replace V1 API with V2 API
3. Run tests, fix failures
4. Mark unsupported patterns as `pending`

**Example API updates:**
```ruby
# Parse
- let(:parsed) { described_class.parse(subject) }
+ let(:parsed) { PubidNew::Iso.parse(subject) }

# Publisher  
- expect(parsed.publisher.body).to eq("ISO")
+ expect(parsed.publisher.publisher).to eq("ISO")

# Copublisher
- expect(parsed.copublishers.first.body).to eq("IEC")
+ expect(parsed.publisher.copublisher.first).to eq("IEC")

# Type/Stage
- expect(parsed.type.type_code).to eq("amd")
- expect(parsed.stage.stage_code).to eq("published")
- expect(parsed.typed_stage.abbreviation).to eq("Amd")
+ expect(parsed.typed_stage.type_code).to eq("amd")
+ expect(parsed.typed_stage.stage_code).to eq("published")
+ expect(parsed.typed_stage.abbr.first).to eq("Amd")
```

### Phase 4: Consolidate Fixtures (1 hour)

**Audit:**
```bash
ls old_specs/pubid/iso/v1_specs/fixtures/
ls spec/fixtures/iso/
```

**Merge missing:**
```bash
for file in old_specs/pubid/iso/v1_specs/fixtures/*.txt; do
  basename=$(basename $file)
  [ ! -f spec/fixtures/iso/$basename ] && cp $file spec/fixtures/iso/
done
```

### Phase 5: Verify & Document (1 hour)

**Run full suite:**
```bash
bundle exec rspec spec/pubid_new/iso/ --format documentation | tee results.txt
```

**Create docs:**
- `IMPLEMENTATION_STATUS.md` - Update with results
- `docs/PARSER_GAPS.md` - Document unsupported patterns
- `docs/V1_TO_V2_MIGRATION_GUIDE.md` - For contributors

---

## Timeline

| Phase | Time | Cumulative |
|-------|------|------------|
| 1: Archive | 1h | 1h |
| 2: Document | 0.5h | 1.5h |
| 3: Migrate ISO | 4-6h | 5.5-7.5h |
| 4: Fixtures | 1h | 6.5-8.5h |
| 5: Verify | 1h | 7.5-9.5h |

**Per additional flavor:** 4-8h  
**Total (10 flavors):** ~50-80 hours

---

## Success Metrics

### Minimum (ISO)
- 80% tests passing/pending properly
- No V1 API calls
- Gaps documented

### Target (ISO)
- 90% tests passing/pending
- Migration guide created

### Ideal (ISO)
- 95%+ tests passing  
- Parser extensions identified

---

**Status:** Ready to Execute  
**Next Action:** Phase 1 - Archive V1 Code  
**Owner:** Kilo Code
