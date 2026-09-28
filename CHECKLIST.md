# Project checklist
Updated 2026-09-25 · **16 of 50 done, 4 failed-and-reported, 1 retracted**

---

## DONE (16)

**A. Verification**
- [x] **3a. p-value formula** — was `b/n`, can return 0. Now `(b+1)/(n+1)`, Phipson & Smyth 2010.
- [x] **3b. Fragile-step audit** — z-score direction +0.733, seed reproducible, no gene leakage into Tier 1, no ambiguous symbol mappings, `deficient` coded correctly.
- [x] **4a. All stored p-values corrected** — 65% attrition unchanged at 28/43; all six survivors hold.
- [x] **4b. Monte Carlo SEs** — and the discovery that earlier "eliminated" mechanisms were tested at 50–100 reps (SE ≈ 0.03), so they are "not supported at that resolution," not eliminated.

**C. Diagnosis → fix**
- [x] **9. MECHANISM IDENTIFIED.** The gene-randomization null conditions on the sample split, so it captures gene-sampling variation only. Within-split null SD 0.047; the real set's statistic varies across splits with SD 0.110. **The null is 2.3× too narrow.** Replicated: G2M ratio 2.67 (COADREAD), 2.12 (BRCA), 2.34 (LUAD); Notch control 1.45, 1.34.
- [x] **12. Residual-coherence flag** — raw ρ 0.200 vs residual 0.003 for a pure effect; 0.554 vs 0.554 for genuine coherence. In the package.
- [x] **13. ROAST diagnosis** — see RETRACTED.
- [x] **THE CORRECTION** (not on the original list). Rescaling the within-split null to the observed across-split spread: type I error 0.18→0.08, 0.17→0.005, 0.13→0.065, with the uninflated control unchanged. Derived from the mechanism, not fitted.

**D. Scale**
- [x] **15. Plasmode** — real TCGA expression, random splits, no simulator. Supersedes all synthetic type I error numbers.
- [x] **17 (partial). Regime map** — Hallmark × 4 cohorts (80% of BH-significant results fail); coherence across Hallmark, Reactome and GO:BP (88–92.5% of sets exceed any random draw).
- [x] **19 (partial). External cohort** — GSE72094, different platform, floors 4.66–5.81 vs theoretical 1.96.

**E. Biology**
- [x] **S1. Equivalence bounds** — effects above 0.36 (LUAD) and 0.22 (STAD) excluded. The null is a bound, not a power failure.

**F. Literature**
- [x] **25 (partial). Audit** — 5 papers read in full, none reporting any correlation correction; adoption curve 2 → ~100 papers/year.

**G. Software**
- [x] **27 (partial). Package built** — `gscalibrate` 0.1.0, 7 tests passing, R CMD check clean, vignette, published.

**H. Credibility**
- [x] **32. Smyth contact** — three substantive replies. Confirmed the central finding; corrected two errors.

---

## FAILED AND REPORTED (4) — these are results, not gaps
- [x] **10. VIF rescaling** — no exponent works; two cells need heavy correction, two are broken by any. **And decisively: the VIF predicts spread ratios of 1.15–4.05 while measured ratios are 0.93–1.17.** Wrong axis — it corrects gene-level dependence when the missing variance is sample-level.
- [x] **11. Real-set null** — only 15 of 1,195 Reactome sets match lung on size and coherence; 7 match E2F. A null needs 60+.
- [x] **22. Causal test** — **no adequate test possible**, not a null result. A549 transcribes mutant STK11 mRNA so restoration is invisible; that leaves 4 vs 2 samples in H2126.
- [x] **S4-adjacent. Coherence as mechanism** — ρ = 0.14 vs type I error. True as a measurement, not the cause.

## RETRACTED (1)
- [x] **ROAST small-set over-rejection.** Smyth: *"roast() controls the type I error rate correctly for all gene set sizes."* Real data agreed with him. Third spurious result from that simulator. **Item 14's hybrid rule withdrawn with it.**

---

## REMAINING (34)

### Immediate — this week
- [ ] **Tighten the correction** — G2M overcorrects to 0.005; test rescaling variants at 300 reps
- [ ] **7. Read Venet et al. 2011** — likely the closest ancestor, still unread
- [ ] **6/8. Contribution statement** in one sentence, surviving Goeman & Bühlmann, CAMERA, Venet
- [ ] **31. Mentor** — top priority; Bandyopadhyay follow-up is the best lead
- [ ] **Reply to Tamayo** in own words about the AI question
- [ ] **27b. Put the correction in the package**, replace the coherence-keyed `reliable` flag

### Verification
- [ ] **1. Clean-machine reproduction** — renv or Docker, one script regenerates every number
- [ ] **2. Independent rerun** by another person
- [ ] **5. OSF timestamp** (GitHub history can be rewritten)
- [ ] **Withdraw grid-2 numbers** from the write-up; plasmode supersedes them

### Scale
- [ ] **16. Block-structured correlation** in any remaining synthetic work
- [ ] **17b. Full regime map** — 33 TCGA types × 4 collections × 4 grouping types
- [ ] **18. More methods** — singscore, AUCell, GSVA; fry, mroast, globaltest
- [ ] **19b. More external cohorts** — CPTAC, other platforms
- [ ] **S3. Multiverse / specification curve**
- [ ] **S6. Non-cancer data** — GTEx, pseudobulk, proteomics

### Biology
- [ ] **20. Replicate HNSC** in CPTAC or GEO, pre-registered first
- [ ] **21. Protein-level check** (CPTAC)
- [ ] **23. DepMap/CCLE**
- [ ] **24. Single-cell** — is bulk coherence composition or co-regulation?
- [ ] **S2. Hierarchical model** across cohorts

### Literature
- [ ] **25b. Systematic audit** — pre-registered sample of 100 of 518, coding protocol, second coder
- [ ] **26. Reanalyze published claims** with public data

### Software
- [ ] **S5. Cox models + optimal cutpoints** — the workflow the audited papers actually use
- [ ] **28. Bioconductor submission**
- [ ] **29. Documentation and coverage**
- [ ] **30. Real users**
- [ ] **S7. Shiny app**
- [ ] **S8. Reporting checklist**

### Credibility
- [ ] **33. bioRxiv preprint, then submit**
- [ ] **34. Present** — BioC, local seminar, ISEF
- [ ] **35. Compliance forms**
- [ ] **S9. Teach it**

### Application
- [ ] **36–41.** Report around one story · Figure 1 legible in 10 s · null as strength · own contribution explicit · essays · non-specialist readers
- [ ] **42–43.** General science prep · drill the hard questions

---

## The story, as it now stands
1. Pre-registered pan-cancer hypothesis. Not supported.
2. The control killed 65% of the analysis's own BH-significant results — 80% across four cohorts on Hallmark.
3. Seven candidate mechanisms tested and not supported.
4. **The real mechanism: the null conditions on the sample split and is 2.3× too narrow.** Replicated in two held-out cohorts.
5. A correction that follows from the mechanism and restores approximate calibration.
6. A released tool.

**Still missing:** the paper.
