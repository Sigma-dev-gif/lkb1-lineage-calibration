# Paper draft: abstract and outline
Version 1 · 2026-09-25

---

## Title options

1. **Gene-randomization nulls for per-sample gene set scores are anti-conservative, and why**
2. **A missing variance component in competitive gene set tests on per-sample scores**
3. **Most significant gene set associations do not survive calibration: mechanism and correction**

Option 2 is the most accurate; option 3 is the most likely to be read. Decide after the results section is drafted.

---

## Abstract (247 words)

Per-sample gene set scores — ssGSEA, GSVA, mean-z — are widely treated as ordinary variables in regression and survival models. In five published studies we examined in full, including a tool that pre-computes survival analyses for 13,434 gene sets, none reported any correction for dependence among genes.

We tested a pre-registered pan-cancer hypothesis about lineage programs in LKB1-deficient tumours, with a control comparing each result against random gene sets matched on size and expression. The hypothesis was not supported. More consequentially, 28 of 43 associations that survived Benjamini–Hochberg correction — 65% — failed the control; across four TCGA cohorts and 50 Hallmark sets, 84 of 105 failed (80%). Using real expression with random sample splits, so that the null is true by construction, type I error reached 0.30.

We identify the cause. A gene-randomization null is computed within a fixed sample split and therefore captures only the variation arising from which genes were drawn. A real gene set's statistic also varies with which samples fall in each group, and that component is larger: for HALLMARK_E2F_TARGETS in lung adenocarcinoma, the within-split null has SD 0.047 while the set's own coefficient varies across splits with SD 0.110. The null is 2.3-fold too narrow, replicated in two held-out cohorts.

Rescaling the null to the across-split spread restores calibration (0.30 to 0.045), leaves already-calibrated sets unchanged, extends to Cox models, and agrees with rotation testing. We release an R package implementing it.

---

## One-page outline

### 1. Introduction
- Per-sample gene set scores as variables: the workflow, and how common it is (518 papers, 2 in 2019 to ~100/year).
- The literature audit: five papers, none reporting a correction; two also using optimal-cutpoint dichotomisation.
- Known precedent, stated up front: Wu & Smyth 2012 (CAMERA), Goeman & Bühlmann 2007, Smyth's public comments on pre-ranked GSEA. **We are not claiming the phenomenon is unknown.** What is missing is a quantification for this workflow, a mechanism, and a correction.
- What this paper adds.

### 2. Methods
*(Everything here is settled and can be drafted now.)*
- Data: TCGA PanCancer Atlas, 15 cohorts; GTEx v11; HPA v25.1; MSigDB; GSE72094.
- Signature reproduction and validation against published AUROCs.
- Lineage program construction and the specificity gate; five contamination sources and their handling.
- Pre-registration and the twelve dated amendments; rule-generated cohort exclusions.
- The missing-data rule.
- Tier 1 and Tier 2 controls; covariates.
- The plasmode design: real expression, random splits, true null.
- Statistical detail: p = (b+1)/(n+1); Monte Carlo SEs on all simulated rates.

### 3. Results

**3.1 The primary analysis and its failure.** H1 not supported in either confirmatory cohort. Equivalence bounds: effects above 0.36 (LUAD) and 0.22 (STAD) excluded, so this is a bound rather than a power failure.

**3.2 The attrition.** 99 tests → 43 BH-significant → 15 surviving. LUAD endometrium as the illustrative case: BH p = 3.0×10⁻⁵, empirical p = 0.58. **Figure 1.**

**3.3 Generalisation.** 80% failure across four cohorts on Hallmark; coherence exceeding random draws in 88–92.5% of sets across Hallmark, Reactome and GO:BP. Replication in GSE72094 on a different platform.

**3.4 Corroboration.** CAMERA agrees on 90 of 99 tests with zero contradictions.

**3.5 What the cause is not.** Coherence, set size, PC loading, expression profile, and the CAMERA variance inflation term — each tested and not supported, with the measurement that rules it out. The VIF case is decisive: predicted spread ratios 1.15–4.05 against measured 0.93–1.17.

**3.6 The mechanism.** Within-split null SD 0.047 vs across-split SD 0.110. Replicated: 2.67 (COADREAD), 2.12 (BRCA), with an uninflated control at 1.34–1.45. **Figure 2.**

**3.7 The correction.** Centre and rescale; both operations required (centring alone gives 0.33, rescaling alone 0.01, together 0.043–0.053). Replicated in two held-out cohorts. Extends to Cox with reduced effect (0.19 → 0.073). Agrees with `limma::roast`. **Figure 3.**

**3.8 Software.** `gscalibrate`.

### 4. Discussion
- Why this is the competitive vs self-contained distinction, measured.
- Practical guidance for anyone using per-sample scores as variables.
- Why draw-based nulls cannot be repaired by better matching: real programs reach ρ = 0.245, random draws cap at 0.021.
- Relation to rotation testing and CAMERA.

### 5. Limitations
- The mechanism and correction were found post hoc; held-out confirmation, not pre-registration.
- No independent rerun by another party.
- Three simulation designs produced spurious results and were withdrawn; all final numbers come from real data.
- The ROAST small-set claim was retracted after the method's author corrected it.
- Cox correction incomplete (0.067–0.073, not 0.05).
- One data source for the primary analysis, one external cohort.
- H1's null does not exclude effects below the detection floor.
- HNSC signal is exploratory and unreplicated; replication attempted in GSE65858 and blocked at 26/30 signature genes.
- Causal test attempted and not possible: A549 transcribes mutant STK11 mRNA, leaving 4 vs 2 samples.

---

## Figures

**Figure 1.** Attrition. 99 → 43 → 15, with LUAD endometrium annotated.
**Figure 2.** Two distributions for one gene set: within-split null (SD 0.047) against across-split observed (SD 0.110), on the same axis. This is the paper in one image.
**Figure 3.** Type I error before and after correction, across cohorts and sets, with the uninflated control.
**Supplementary.** Coherence of real sets vs random draws across three collections; the five eliminated mechanisms.

---

## To write first
Methods (all settled) and Results 3.1–3.4 (all settled). Leave 3.5–3.7 as placeholders until the independent rerun is done.
