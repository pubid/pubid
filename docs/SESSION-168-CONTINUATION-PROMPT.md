# Session 168 Continuation Prompt: CSA Simple Pattern Fixes

**Read First:** [`docs/SESSION-168-CONTINUATION-PLAN.md`](SESSION-168-CONTINUATION-PLAN.md:1)

---

## Quick Context

**Session 167 Complete:** CEN enhanced to 100% (71/71) ✅

**Current Status:**
- CEN: 71/71 (100%) ✅
- CSA: 863/901 (95.78%) - 15 simple fixes needed
- Overall: 87,778/88,924 (98.71%)

**CSA Failures (15 identifiers):**
```
CSA C22.1:24 Code & Handbook Package  # No CSA prefix + package
CSA 12.2-02                            # Dash year
CSA 12.4:22                            # Dotted number
CSA 15189HB:25                         # Letter suffix
CSA 2.15:16 (R2021)                    # Dotted + reaffirm
CSA 3.11:15 (R2020)                    # Similar
(+ 9 more similar patterns)
```

IEEE FAILURES: FIX ALL NOW
```
#IEEE Std 1232-2002 (Revision of IEEE Std 1232-1995, IEEE Std 1232.1-1997 and IEEE Std 1232.2-1998)#
#IEEE Std 242-2001 (Revision of IEEE Std 242-1986) [IEEE Buff Book]#
#IEEE Std 446-1995 [The Orange Book]#
#IEEE Std 493-1997 [IEEE Gold Book]#
#IEEE Std 551-2006 [The Violet Book]#
#IEEE Std 602-1996 [The White Book]#
#IEEE Std 665-1995 (R2001) (Revision of IEEE Std 665-1987)#
#IEEE Std 739-1995 [The Bronze Book]#
#IEEE Std 802.1Q, 2003 Edition (Incorporates IEEE Std 802.1Q-1998, IEEE Std 802.1u-2001, IEEE Std 802.1v-2001, and IEEE Std 802.1s-2002)#
#IEEE Std 802.1Q, 2012 Edition, (Incorporating IEEE Std 802.1Q-2011, IEEE Std 802.1Qbe-2011, IEEE Std 802.1Qbc-2011,IEEE Std 802.1Qbb-2011, IEEE Std 802.1Qaz-2011, IEEE Std 802.1Qbf-2011,IEEE Std 802.1Qbg-2012, IEEE Std 802.1aq-2012, IEEE Std 802.1Q-2012#
#IEEE Std 802.1Q-2005 (Incorporates IEEE Std 802.1Q1998, IEEE Std 802.1u-2001, IEEE Std 802.1v-2001, and IEEE Std 802.1s-2002)#
#IEEE Std 802.1X-2020 (Revision of IEEE Std 802.1X-2010 Incorporating IEEE Std 802.1Xbx-2014 and IEEE Std 802.1Xck-2018)#
#IEEE Std 802.1ag - 2007 (Amendment to IEEE Std 802.1Q - 2005 as amended by IEEE Std 802.1ad - 2005 and IEEE Std 802.1ak - 2007)#
#IEEE Std 802.21-2017 (Revision of IEEE Std 802.21-2008 as amended by IEEE Std 802.21a-2012, IEEE Std 802.21b-2012, IEEE Std 802.21c-2014, and IEEE Std 802.21d-2015)#
#IEEE Std 802.21-2017 (Revision of IEEE Std 802.21-2008 as amended by IEEE Std 802.21a-2012, IEEE Std 802.21b-2012, IEEE Std 802.21c-2014, and IEEE Std 802.21d-2015) - Redline#
#IEEE Std 802.21c-2014 (Amendment to IEEE Std IEEE Std 802.21-2008 as amended by IEEE Std 802.21a-2012 and IEEE Std 802.21b-2012)#
#IEEE Std 802.3ak-2004 (Amendment to IEEE Std 802.3-2002 as amended by IEEE Stds 802.3ae-2002, 802.3af-2003 and 802.3aj-2003)#
#IEEE Std 802.3bm-2015 (Amendment to IEEE Std 802.3-2012 as amended by IEEE Std 802.3bk-2013 and IEEE Std 802.3bj-2014 )#
#IEEE Std 802.3bs-2017 (Amendment to IEEE 802.3-2015 as amended by IEEE's 802.3bw-2015, 802.3by-2016, 802.3bq-2016, 802.3bp-2016, 802.3br-2016, 802.3bn-2016, 802.3bz-2016, 802.3bu-2016, 802.3bv-2017, and IEEE 802.3-2015/Cor1-2017)#
#IEEE Std 802.3bz-2016 (Amendment to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, IEEE Std 802.3by(TM)-2016, IEEE Std 802.3bq-2016, IEEE Std 802.3bp-2016, IEEE Std 802.3br-2016, and IEEE Std 802.3bn-2016)#
#IEEE Std 802.3cc-2017 (Amendment to IEEE Std 802.3-2015 as amended by IEEE&#x2019;s 802.3bw-2015, 802.3by-2016, 802.3bq-2016, 802.3bp-2016, 802.3br-2016, 802.3bn-2016, 802.3bz-2016, 802.3bu-2016, 802.3bv-2017, 802.3-2015/Cor 1-2017, and 802.3bs-2017)#
#IEEE Std 802.3ct-2021 (Amendment to IEEE Std 802.3-2018 as amended by IEEE's 802.3cb-2018, 802.3bt-2018, 802.3cd-2018, 802.3cn-2019, 802.3cg-2019, 802.3cq-2020, 802.3cm-2020, 802.3ch-2020,802.3ca-2020, 802.3cr-2021, 802.3cu-2021, and 802.3cv-2021)#
#IEEE Std 802.3cu-2021 (Amendment to IEEE Std 802.3-2018 and its approved amendments)#
#IEEE Std 844.1-2017/CSA C22.2 No. 293.1-17#
#IEEE Std 844.2-2017/CSA C293.2-17#
#IEEE Std 844.3-2019/CSA C22.2 No. 293.3:19#
#IEEE Std 844.4-2019/CSA C293.4:19#
#IEEE Std 91a-1991 &amp; IEEE Std 91-1984#
#IEEE Std 960-1989, Std 1177-1989#
#IEEE Std C37.101 -2006 (Revision of IEEE Std C37.101-1993/Incorporates IEEE Std C37.101-2006/Cor1:2007) - Redline#
#IEEE Std C37.102 -2006 (Revision of IEEE Std C37.102-1995) - Redline#
#IEEE Std C37.20.3-2001 - IEEE Standard for metal-enclosed interrupter switchgear#
#IEEE Std C50.12-2005 (Previously designated as ANSI C50.12-1982)#
#IEEE Std C57.110&#x2122;-2018 (Revision of IEEE Std C57.110-2008)#
#IEEE Std C57.13-1993(R2003) (Revision of IEEE Std C57.13-1978#
#IEEE Std C62.35- 2010 (Revision of IEEE Std C62.35-1987)#
#IEEE Std C62.43-2005 (R2010) (Revision of IEEE Std C62.43-1999)#
#IEEE Std. 1244.2-2000#
#IEEE Std 1003.1-2001 (Revision of IEEE Std 1003.1-1996 and IEEE Std 1003.2-1992)#
#IEEE Std 308-1974 (Revision of IEEE Std 308-1971 and ANSI N41.12-1975)#
#IEEE Std 323-1974 (Revision of IEEE 323-1971 and ANSI N41.5-1971)#
#IEEE Std 588-1976 (ANSI C37.86-1975) (Revision of IEEE Std 288-1969 and IEEE Std 328-1971)#
#IEEE Std C37.48-2020 (Revision of IEEE Std C37.48-2005 and IEEE Std C37.48.1-2011)#
#IEEE Std C95.3-2021 (Revision of IEEE Std C95.3-2002 and IEEE Std C95.3.1-2010)#
#IEEE Std 802.11aj-2018 (Amendment to IEEE Std 802.11-2016 as amended by IEEE Std 802.11ai-2016 and IEEE Std 802.11ah-2016)#
#IEEE Std 802.11ak-2018 (Amendment to IEEE Std 802.11-2016 as amended by IEEE Std 802.11ai-2016, IEEE Std 802.11ah-2016, and IEEE Std 802.11aj-2018)#
#IEEE Std 802.11aq-2018 (Amendment to IEEE Std 802.11-2016 as amended by IEEE Std 802.11ai-2016, IEEE Std 802.11ah-2016, IEEE Std 802.11aj-2018, and IEEE Std 802.11ak-2018)#
#IEEE Std 802.11n-2009 (Amendment to IEEE Std 802.11-2007 as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, and IEEE Std 802.11w-2009)#
#IEEE Std 802.11p-2010 (Amendment to IEEE Std 802.11-2007 as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, IEEE Std 802.11n-2009, and IEEE Std 802.11w-2009)#
#IEEE Std 802.11s-2011 (Amendment to IEEE Std 802.11-2007 as amended by IEEE 802.11k-2008, IEEE 802.11r-2008, IEEE 802.11y-2008, IEEE 802.11w-2009, IEEE 802.11n-2009, IEEE 802.11p-2010, IEEE 802.11z-2010, IEEE 802.11v-2011, and IEEE 802.11u-2011)#
#IEEE Std 802.11v-2011 (Amendment to IEEE Std 802.11-2007 as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, IEEE Std 802.11w-2009, IEEE Std 802.11n-2009, IEEE Std 802.11p-2010, and IEEE Std 802.11z-2010)#
#IEEE Std 802.11w-2009 (Amendment to IEEE Std 802.11-2007 as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, and IEEE Std 802.11y-2008)#
#IEEE Std 802.11z-2010 (Amendment to IEEE Std 802.11-2007 as amended by IEEE Std 802.11k-2008, IEEE Std 802.11r-2008, IEEE Std 802.11y-2008, IEEE Std 802.11w-2009, IEEE Std 802.11n-2009, and IEEE Std 802.11p-2010)#
#IEEE Std 802.15.3f-2017 (Amendment to IEEE Std 802.15.3-2016 as amended by IEEE Std 802.15.3d-2017, and IEEE Std 802.15.3e-2017)#
#IEEE Std 802.15.4j-2013 (Amendment to IEEE Std 802.15.4-2011 as amended by IEEE Std 802.15.4e-2012, IEEE Std 802.15.4f-2012, and IEEE Std 802.15.4g-2012)#
#IEEE Std 802.15.4k-2013 (Amendment to IEEE Std 802.15.4-2011 as amended by IEEE Std 802.15.4e-2012, IEEE Std 802.15.4f-2012, IEEE Std 802.15.4g-2012, and IEEE Std 802.15.4j-2013)#
#IEEE Std 802.15.4m-2014 (Amendment to IEEE Std 802.15.4-2011 as amended by IEEE Std 802.15.4e-2012, IEEE Std 802.15.4f-2012, IEEE Std 802.15.4g-2012, IEEE Std 802.15.4j-2013, and IEEE Std 802.15.4k-2013)#
#IEEE Std 802.15.4p-2014 (Amendment to IEEE Std 802.15.4-2011 as amended by IEEE Std 802.15.4e-2012, IEEE Std 802.15.4f-2012, IEEE Std 802.15.4g-2012, IEEE Std 802.15.4j-2013, IEEE Std 802.15.4k-2013, and IEEE Std 802.15.4m-2014)#
#IEEE Std 802.15.4u-2016 (Amendment to IEEE Std 802.15.4-2015 as amended by IEEE Std 802.15.4n-2016 and IEEE Std 802.15.4q-2016)#
#IEEE Std 802.15.4y-2021 (Amendment to IEEE Std 802.15.4-2020 as amended by IEEE Std 802.15.4z-2020 and IEEE Std 802.15.4w-2020)#
#IEEE Std 802.1AEcg-2017 (Amendment to IEEE Std 802.1AE-2006 as amended by IEEE Std 802.1AEbn-2011 and IEEE Std 802.1AEbw-2013)#
#IEEE Std 802.1Qaz-2011 (Amendment to IEEE Std 802.1Q-2011 as amended by IEEE Std 802.1Qbe-2011, IEEE Std 802.1Qbc-2011, and IEEE Std 802.1Qbb-2011)#
#IEEE Std 802.1Qbb-2011 (Amendment to IEEE Std 802.1Q-2011 as amended by IEEE Std 802.1Qbe-2011 and IEEE Std 802.1Qbc-2011)#
#IEEE Std 802.1Qbf-2011 (Amendment to IEEE Std 802.1Q-2011 as amended by IEEE Std 802.1Qbe-2011, IEEE Std 802.1Qbc-2011, IEEE Std 802.1Qbb-2011, and IEEE Std 802.1Qaz-2011)#
#IEEE Std 802.1Qbg-2012 (Amendment to IEEE Std 802.1Q-2011 as amended by IEEE Std 802.1Qbe-2011, IEEE Std 802.1Qbc-2011, IEEE Std 802.1Qbb-2011, IEEE Std 802.1Qaz-2011, IEEE Std 802.1Qbf-2011, and IEEE Std 802.aq-2012)#
#IEEE Std 802.1Qcr-2020 (Amendment to IEEE Std 802.1Q-2018 as amended by IEEE Std 802.1Qcp-2018, IEEE Std 802.1Qcc-2018, IEEE Std 802.1Qcy-2019, and IEEE Std 802.1Qcx-2020)#
#IEEE Std 802.1Qcx-2020 (Amendment to IEEE Std 802.1Q-2018 as amended by IEEE Std 802.1Qcp-2018, IEEE Std 802.1Qcc-2018, and IEEE Std 802.1Qcy-2019)#
#IEEE Std 802.1Qcy-2019 (Amendment to IEEE Std 802.1Q-2018 as amended by IEEE Std 802.1Qcp-2018 and IEEE Std 802.1Qcc-2018)#
#IEEE Std 802.1aq-2012 (Amendment to IEEE Std 802.1Q-2011 as amended by IEEE Std 802.1Qbe-2011, IEEE Std 802.1Qbc-2011, IEEE Std 802.1Qbb-2011, IEEE Std 802.1Qaz-2011, and IEEE Std 802.1Qbf-2011)#
#IEEE Std 802.21d-2015 (Amendment to IEEE Std 802.21-2008 as amended by IEEE Std 802.21a-2012, IEEE Std 802.21b-2012, and IEEE Std 802.21c-2014)#
#IEEE Std 802.3bn-2016 (Amendment to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, IEEE Std 802.3by-2016, IEEE Std 802.3bq-2016, IEEE Std 802.3bp-2016, and IEEE Std 802.3br-2016)#
#IEEE Std 802.3bp-2016 (Amendment to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, IEEE Std 802.3by-2016, and IEEE Std 802.3bq-2016)#
#IEEE Std 802.3bq-2016 (Amendment to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, and IEEE Std 802.3by-2016)#
#IEEE Std 802.3br-2016 (Amendment to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, IEEE Std 802.3by-2016, IEEE Std 802.3bq-2016, and IEEE Std 802.3bp-2016)#
#IEEE Std 802.3bu-2016 (Amendment to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, IEEE Std 802.3by-2016, IEEE Std 802.3bq-2016, IEEE Std 802.3bp-2016, IEEE Std 802.3br-2016, IEEE Std 802.3bn-2016, and IEEE Std 802.3bz-2016)#
#IEEE Std 802.3bv-2017 (Amendment to IEEE Std 802.3-2015 as amended by IEEE 802.3bw-2015, IEEE 802.3by-2016, IEEE 802.3bq-2016, IEEE 802.3bp-2016, IEEE 802.3br-2016, IEEE 802.3bn-2016, IEEE 802.3bz-2016, and IEEE 802-3bu-2016)#
#IEEE Std 802.3ca-2020 (Amendment to IEEE Std 802.3-2018 as amended by IEEE 802.3cb-2018, IEEE 802.3bt-2018, IEEE 802.3cd-2018, IEEE 802.3cn-2019, IEEE 802.3cg-2019, IEEE 802.3cq-2020, IEEE 802.3cm-2020, and IEEE 802.3ch-2020)#
#IEEE Std 802.3cd-2018 (Amendment to IEEE Std 802.3-2018 as amended by IEEE Std 802.3cb-2018 and IEEE Std 802.3bt-2018)#
#IEEE Std 802.3cg-2019 (Amendment to IEEE Std 802.3-2018 as amended by IEEE Std 802.3cb-2018, IEEE Std 802.3bt-2018, IEEE Std 802.3cd-2018, and IEEE Std 802.3cn-2019)#
#IEEE Std 802.3ch-2020 (Amendment to IEEE Std 802.3-2018 as amended by IEEE Std 802.3cb-2018, IEEE Std 802.3bt-2018, IEEE Std 802.3cd-2018, IEEE Std 802.3cn-2019, IEEE Std 802.3cg-2019, IEEE Std 802.3cq-2020, and IEEE Std 802.3cm-2020)#
#IEEE Std 802.3cm-2020 (Amendment to IEEE Std 802.3-2018 as amended by IEEE Std 802.3cb-2018, IEEE Std 802.3bt-2018, IEEE Std 802.3cd-2018, IEEE Std 802.3cn-2019, IEEE Std 802.3cg-2019, and IEEE Std 802.3cq-2020)#
#IEEE Std 802.3cn-2019 (Amendment to IEEE Std 802.3-2018 as amended by IEEE Std 802.3cb-2018, IEEE Std 802.3bt-2018, IEEE Std 802.3cd-2018, IEEE Std 802.3cn-2019, and IEEE Std 802.3cg-2019)#
#IEEE Std 802.3cn-2019 (Amendment to IEEE Std 802.3-2018 as amended by IEEE Std 802.3cb-2018, IEEE Std 802.3bt-2018, and IEEE Std 802.3cd-2018)#
#IEEE Std 802.3cq-2020 (Amendment to IEEE Std 802.3-2018 as amended by IEEE Std 802.3cb-2018, IEEE Std 802.3bt-2018, IEEE Std 802.3cd-2018, IEEE Std 802.3cn-2019, and IEEE Std 802.3cg-2019)#
#IEEE Std 802.3cr-2021 (Amendment to IEEE Std 802.3-2018 as amended by IEEE 802.3cb-2018, IEEE 802.3bt-2018, IEEE 802.3cd-2018, IEEE 802.3cn-2019, IEEE 802.3cg-2019, IEEE 802.3cq-2020, IEEE 802.3cm-2020, IEEE 802.3ch-2020, and IEEE 802.3ca-2020)#
#IEEE P802.11af/D5.0 (Amendment to IEEE Std 802.11-2012, as amended by IEEE Std 802.11ae-2012, IEEE Std 802.11aa-2012, IEEE Std 802.11ad-2012, and IEEE Std 802.11ac_D5.0)#
#IEEE P802.11af/D6.0, October 2013 (Amendment to IEEE Std 802.11-2012, as amended by IEEE Std 802.11ae-2012, IEEE Std 802.11aa-2012, IEEE Std 802.11ad-2012, and IEEE Std 802.11ac_D7.0)#
#IEEE P802.11aq/D3.0 October 2015 (Amendment to IEEE Std 802.11REVmc, as amended by IEEE Std 802.11ah-2016 and IEEE Std 802.11ai-2016)#
#IEEE P802.11aq/D7.0 October 2016 (Amendment to IEEE Std 802.11REVmc, as amended by IEEE Std 802.11ah-2016 and IEEE Std 802.11ai-2016)#
#IEEE Std 802.11ac-2013 (Amendment to IEEE Std 802.11-2012, as amended by IEEE Std 802.11ae-2012, IEEE Std 802.11aa-2012, and IEEE Std 802.11ad-2012)#
#IEEE Std 802.11ad-2012 (Amendment to IEEE Std 802.11-2012, as amended by IEEE Std 802.11ae-2012 and IEEE Std 802.11aa-2012)#
#IEEE Std 802.11af-2013 (Amendment to IEEE Std 802.11-2012, as amended by IEEE Std 802.11ae-2012, IEEE Std 802.11aa-2012, IEEE Std 802.11ad-2012, and IEEE Std 802.11ac-2013)#
#IEEE Std 802.15.4v-2017 (Amendment to IEEE Std 802.15.4-2015, as amended by IEEE Std 802.15.4n-2016, IEEE Std 802.15.4q-2016, IEEE Std 802.15.4u-2016, and IEEE Std 802.15.4t-2017)#
#IEEE Std 16-1955 (Supersedes C48-1931 and AIEE 16A 1951)#
#IEEE Std 802.15.4-2015/Cor 1-2018 (Amendment to IEEE Std 802.15.4-2015 as amended by IEEE Std 802.15.4n-2016, IEEE Std 802.15.4q-2016, IEEE Std 802.15.4u-2016, IEEE Std 802.15.4t-2017 and IEEE Std 802.15.4v-2017)#
#IEEE Std 802.15.4s-2018 (Amendment to IEEE Std 802.15.4-2015 as amended by IEEE Std 802.15.4n-2016, IEEE Std 802.15.4q-2016, IEEE Std 802.15.4u-2016, IEEE Std 802.15.4t-2017, IEEE Std 802.15.4v-2017, and IEEE Std 802.15.4-2015/Cor 1-2018)#
#IEEE Std 802.1Qbv-2015 (Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015, IEEE Std 802.1Qcd-2015, and IEEE Std 802.1Q-2014/Cor 1-2015)#
#IEEE Std 802.1Qca-2015 (Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qcd-2015 and IEEE Std 802.1Q-2014/Cor 1-2015)#
#IEEE Std 802.1Qci-2017 (Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015, IEEE Std 802.1Qcd-2015, IEEE Std 802.1Q-2014/Cor 1-2015, IEEE Std 802.1Qbv-2015, IEEE Std 802.1Qbu-2016, and IEEE Std 802.1Qbz-2016)#
#IEEE Std 1003.1, 2013 Edition (incorporates IEEE Std 1003.1-2008, and IEEE Std 1003.1-2008/Cor 1-2013)#
```

---

## Session 168 Tasks (60 min)

### Goal
CSA from 95.78% to 97%+ (878+/901) using proper parser patterns

### Pattern Types (All Simple!)

1. **Dotted numbers** (8 IDs): `12.4`, `2.15`, `3.11`
2. **Dash year format** (2 IDs): `12.2-02`, `8.3-2015`
3. **Letter suffix** (1 ID): `15189HB`
4. **Package keywords** (3 IDs): `Code & Handbook Package`
5. **Optional CSA prefix** (1 ID): `C22.1:24`

### Tasks

1. **Update parser** (40 min)
   - Add dotted_number rule (`digits >> dot >> digits`)
   - Support letter suffix in codes (`15189HB`)
   - Add package_portion rule
   - Make CSA prefix optional for edge cases

2. **Update SingleIdentifier** (10 min)
   - Add `package` attribute

3. **Test and validate** (10 min)
   - Run classification
   - Verify 878+/901 (97%+)

---

**Expected:** CSA 97%+ in 60 minutes! 🚀

**Key:** Parser-only work, no architecture changes needed!