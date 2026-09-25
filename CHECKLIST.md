# Project checklist — 50 items
Updated 2026-09-24. Tick as completed; each session starts here.

## A. Verify what exists (months 1–2)
- [x] **3a. p-value formula** — was `b/n`, can return 0. Now `(b+1)/(n+1)` per Phipson & Smyth 2010. Fixed in package, tests pass.
- [ ] **3b. Audit remaining fragile steps** — symbol mapping, NA handling, z-scoring direction, Tier 1 universe, seed handling
- [ ] **4a. Rerun all Tier 1 p-values** at 1,000 draws with corrected formula
- [ ] **4b. Monte Carlo SEs** on every simulated error rate
- [ ] **1. Clean-machine reproduction** — renv or Docker, one script regenerates every number
- [ ] **2. Independent rerun** by another person
- [ ] **5. OSF timestamp** of pre-spec and amendments

## B. Reframe (month 2)
- [ ] **6. Competitive vs self-contained null** (Goeman & Bühlmann 2007) as the organising frame
- [ ] **7. Literature: Venet 2011, Tamayo 2016, Wu & Smyth 2012, Geistlinger 2021, Smyth thread** — plus a real search for the sixth precedent
- [ ] **8. One-sentence contribution statement** that survives all of them

## C. From diagnosis to fix (months 2–5) — HIGHEST VALUE
- [ ] **10. Variance-inflation correction for Tier 1** — rescale null by √[(1+(m−1)ρ_set)/(1+(m−1)ρ_null)]
- [ ] **12. Residual-coherence flag** — compute ρ after regressing out group, so the flag stops firing on true positives
- [ ] **13. Diagnose ROAST small-set over-rejection** — 2,000 reps, vary set.statistic/nrot/df, test squeezeVar
- [ ] **14. Hybrid decision rule** — pick the calibrated method by (m, ρ); show type I control across the grid
- [ ] **9. Derive the floor analytically** and validate on all 15 cohorts + GSE72094
- [ ] **11. Real-set null** — draw from MSigDB C2/C5 matched on size and coherence
- [ ] **S4. Formal proof** of the structural limit (concentration inequality)

## D. Scale the benchmark (months 3–6)
- [ ] **15. Plasmode simulations** — real TCGA expression, random splits, spiked effects
- [ ] **16. Block-structured correlation** in the synthetic grid
- [ ] **17. Regime map** — Hallmark/Reactome/GO/HPA × 33 TCGA types × mutation/sex/stage/random
- [ ] **18. More methods** — singscore, AUCell, GSVA, ssGSEA; fry, mroast, GSEA, globaltest
- [ ] **19. More external cohorts** — other LUAD arrays, CPTAC
- [ ] **S3. Multiverse / specification-curve analysis**
- [ ] **S6. Non-cancer data** — GTEx, pseudobulk, proteomics

## E. Make the biology pay off (months 4–8)
- [ ] **20. Replicate HNSC** in CPTAC HNSCC or GEO, pre-registered first
- [ ] **21. Protein-level check** via CPTAC
- [ ] **22. Causal test** — LKB1 re-expression in A549 or similar, from GEO
- [ ] **23. DepMap/CCLE** — same programs without microenvironment
- [ ] **24. Single-cell** — is bulk coherence composition or co-regulation?
- [ ] **S1. Equivalence testing (TOST)** for H1 — "effects larger than X excluded"
- [ ] **S2. Hierarchical model** across cohorts

## F. Literature audit → reanalysis (months 5–9)
- [ ] **25. Systematic audit** — pre-registered sample of 100 of 518, coding protocol, second coder, inter-rater agreement
- [ ] **26. Reanalyze published claims** with public data; phrase as "does not survive calibration"

## G. Software (finish by month 10)
- [ ] **27. Add fixes to gscalibrate** — VIF correction, residual flag, hybrid rule, ROAST/CAMERA wrappers
- [ ] **S5. Cox models + optimal cutpoints** — the workflow the audited papers actually use
- [ ] **28. Bioconductor submission**
- [ ] **29. Documentation** — end-to-end LUAD vignette, test coverage
- [ ] **30. Real users**
- [ ] **S7. Shiny app**
- [ ] **S8. Reporting checklist** for authors and reviewers

## H. External credibility (months 3–12)
- [ ] **31. Mentor** with a computational biology lab
- [ ] **32. Stay in touch with Smyth** — send the ROAST finding and VIF correction
- [ ] **33. bioRxiv preprint, then submit**
- [ ] **34. Present** — BioC poster, local seminar, ISEF-affiliated fair
- [ ] **35. Compliance forms**
- [ ] **S9. Teach it** — workshop, only if genuine

## I. The application (months 10–13)
- [ ] **36. Report around one story**
- [ ] **37. Figure 1 legible in 10 seconds**
- [ ] **38. Null result as a strength**
- [ ] **39. Own contribution explicit**
- [ ] **40. Essays showing the thinking**
- [ ] **41. Non-specialist readers**

## J. Interview (months 13–14)
- [ ] **42. General science practice**
- [ ] **43. Drill the hard questions** — why not CAMERA, isn't this Venet 2011, is HNSC confounded, why does the flag fire on true positives

---
## Weaknesses to close (from finalist comparison)
1. **Tool diagnoses, doesn't fix** → items 10, 12, 14
2. **No causal layer** → item 22
3. **No plain-language line** → draft one sentence
4. **Leadership outside research** → longest lead time, start now
