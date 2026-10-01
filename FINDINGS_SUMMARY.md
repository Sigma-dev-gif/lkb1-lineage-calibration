# All findings to date
2026-09-27 · every result, with its current status

---

## PART 1 — THE BIOLOGY

### 1.1 The pre-registered hypothesis: NOT SUPPORTED

**H1:** LKB1-deficient tumours express lineage programs foreign to their tissue of origin.

| Cohort | n | deficient | β | Holm p | **Tier 1 p** |
|---|---|---|---|---|---|
| LUAD | 497 | 129 | 0.270 | 3.2×10⁻⁹ | **0.73** |
| STAD | 362 | 50 | 0.106 | 0.076 | **0.62** |

Significant by conventional testing; random gene sets beat LUAD's result 73% of the time.

**Equivalence bounds:** effects above **0.36 (LUAD)** and **0.22 (STAD)** are excluded. The null is informative, not underpowered.

### 1.2 What is there instead: NATIVE LINEAGE LOSS

LKB1-deficient tumours show **reduced** expression of their **own** tissue's lineage program.

**Dose-response against the continuous signature score**, purity + stromal covariates, signature genes removed:

| Cohort | native program | n | β | p |
|---|---|---|---|---|
| LUSC | pan-squamous | 476 | −0.0905 | 5.0×10⁻⁷ |
| HNSC | pan-squamous | 494 | −0.0857 | 3.3×10⁻⁴ |
| CESC | pan-squamous | 236 | −0.0798 | 5.5×10⁻⁴ |
| COADREAD | intestine | 527 | −0.0590 | 1.3×10⁻⁸ |
| LUAD | lung | 497 | −0.0507 | 5.6×10⁻²⁴ |
| BRCA | breast | 1,023 | −0.0167 | 5.8×10⁻⁴ |
| UCEC | endometrium | 504 | −0.0147 | 0.136 |
| STAD | stomach | 362 | +0.0065 | 0.668 |

**Six of eight.** The three pan-squamous cohorts agree closely (−0.080 to −0.091) despite being different tissues.

### 1.3 Evidence supporting it

| Test | Result |
|---|---|
| **Pre-registered** in six held-out cohorts | 5 of 6 pass |
| **Direction** (split rSEA, LUAD) | down p = **0.0011**; up p = 0.9998 |
| **Specification curve** | **27 of 27** negative and significant; β −0.044 to −0.103 |
| **Purity terciles** | significant in the high tercile in LUAD, LUSC, COADREAD; **strongest at 81% purity** in COADREAD |
| **Alveolar-content adjustment** | attenuated 21.9% → 33.6% up, not abolished |
| **Independent collection** (MSigDB C8 Travaglini) | all 6 lung cell-type sets negative and significant |
| **External replication** (GSE72094) | lung down, rSEA p = **0.025**, mutation-defined groups |
| **Third cohort** (CPTAC RNA) | 29.1% up, median t = −1.11, Wilcoxon p = **1.1×10⁻⁷** |
| **Circularity** | signature–program gene overlap 0–2; results unchanged after removal |
| **Driver specificity** | largest of 6 drivers; **KRAS null** (−0.014, p = 0.63) |
| **Co-occurrence** | LKB1 β unchanged (−0.263) with KRAS and TP53 in the model |

### 1.4 Boundaries on the claim

| Test | Result | Reading |
|---|---|---|
| **Protein level** (CPTAC) | 59.8% up, p = 0.265 — **null** | The finding is transcriptional |
| Proteome positive control | sterol proteins +0.361, **p = 0.0026** | Assay is powered; the null is real |
| **Cell lines** (DepMap, 34 vs 173) | −0.004, **p = 0.92** | Uninformative: lung genes sit at the 25.7th percentile in lines vs 48.2nd in tumours — floor effect |
| Survival (LUAD) | HR 0.755 → **0.822** after meta-PCNA, p = 0.027 | Weak; one of four cohorts; a third is proliferation |
| Proliferation | β −0.051 → −0.043 with proliferation adjusted | ~15% is proliferation; effect survives |

### 1.5 Mechanism: four candidates, none supported

| Candidate | Test | Result |
|---|---|---|
| AMPK | ACACA S80 + 34-site phospho score | Signalling **consistent with impairment** (p = 0.034); **no evidence of mediation** (3.6% shift) |
| SIK | phospho family score | Apparent mediation **not supported** after proliferation adjustment (p 0.0003 → 0.075) |
| SIK–CRTC–CREB | two transcriptional target sets | **Not supported**; no attenuation with either |
| MARK, NUAK, BRSK, SNRK | phospho family scores | Uninterpretable — confounded with proliferation |

**Mechanism unknown. Cross-sectional data cannot resolve it.** Requires perturbation experiments.

### 1.6 Other biology
- **Immune loss in LUAD:** interferon alpha (14.4% up, median t = −4.07), interferon gamma, inflammatory response, TNFA all decreased. Matches the known immune-cold phenotype. **Does not replicate** — HNSC and COADREAD have zero competitive survivors; BRCA's six contain none immune.
- **HNSC per-program survivors** (pancreas, kidney, liver, intestine) survive BH, CAMERA, Tier 1 and purity stratification, but **not rSEA** (best 0.124). Method-dependent.

---

## PART 2 — THE METHODS

### 2.1 The practice
518 papers use per-sample gene set scores as tested variables; 2 in 2019 rising to ~100/year. **Five read in full: none reports any correlation correction**, most report no multiple-testing correction. One is a tool precomputing survival analyses for 13,434 gene sets.

### 2.2 The failure rate

| | BH significant | survive empirical null | % failing |
|---|---|---|---|
| HPA lineage programs, 8 cohorts | 43 / 99 | 15 | **65%** |
| Hallmark, LUAD | 38 / 50 | 6 | 84% |
| Hallmark, HNSC | 26 / 50 | 3 | 88% |
| Hallmark, COADREAD | 21 / 50 | 3 | 86% |
| Hallmark, BRCA | 20 / 50 | 9 | 55% |
| **Hallmark, all four** | **105** | **21** | **80%** |

**Measured on real data with true nulls** (random sample splits): type I error to **0.30**.

Illustrative: LUAD endometrium, BH p = 3.0×10⁻⁵, empirical p = 0.58.

### 2.3 CAMERA agrees
99 tests: 84 agree negative, 6 agree positive, 9 Tier1-passes/CAMERA-fails, **0 contradictions**. Spearman 0.74.

### 2.4 The empirical null is itself invalid
Within-split null SD **0.047**; the set's own coefficient across splits SD **0.110**. **2.3× too narrow.** Replicated: 2.67 (COADREAD), 2.12 (BRCA); uninflated control 1.34–1.45.

### 2.5 Two repairs, both impossible

| Repair | Why it fails |
|---|---|
| Match draws on coherence | Real programs reach ρ = **0.245**; random draws cap at **0.021**. 88–92.5% of sets across Hallmark, Reactome and GO exceed the random maximum |
| Gene randomization + sample permutation | Reverts to the self-contained null (**Maciejewski 2014**); confirmed — competitive p 0.110 → restandardized p 0.003 |

Also failed: VIF rescaling (predicted spread ratios 1.15–4.05, measured 0.93–1.17); real-set null (only 15 of 1,195 Reactome sets match lung on size and coherence).

### 2.6 Three valid methods, three answers
LUAD Hallmark: **38 BH → 6 Tier 1 → 9 rSEA → 4 both.**

**BH alone keeps 38 of 50. Any dependence-aware method keeps 6 to 9. Which 6 to 9 depends on the method.**

### 2.7 Why: 55.5% background DE
In LUAD, 55.5% of genes differ individually. rSEA: **50 of 50 self-contained significant** (10⁻¹¹ to 10⁻⁵¹), 9 competitively. The self-contained answer is correct and useless.

### 2.8 Expert confirmation
- **Smyth** (CAMERA, ROAST): *"Randomizing gene sets is extremely anti-conservative because it ignores inter-gene correlations."* Also corrected a false claim of ours about ROAST.
- **Goeman** (competitive/self-contained): confirmed the framing — regression gives valid self-contained tests; the random-set comparison attempts the competitive question and is anti-conservative because the set is correlated.

---

## PART 3 — RETRACTED OR WITHDRAWN

| Claim | Status |
|---|---|
| ROAST over-rejects for small sets | **Retracted** — Smyth corrected it; real data agreed with him |
| Simulation grid 2 type I errors | **Withdrawn** — superseded by plasmode on real data |
| The variance correction (v0.2) | **Withdrawn** — reverts to the self-contained null |
| Hybrid decision rule (m < 150) | **Withdrawn** with the ROAST claim |
| Coherence as the mechanism | **Not supported** — ρ vs type I error = 0.14 |
| SIK mediation | **Not supported** — proliferation confound |

Three simulation designs produced spurious results. **All final numbers come from real data.**

---

## PART 4 — DELIVERABLES

- `gscalibrate` 0.3.0 — lm and Cox, 12 tests, R CMD check clean, documented as a diagnostic not a correction
- Two public repos with dated commit history
- OSF registration of the pre-specification
- Pre-specification with 12 dated amendments
- Two paper outlines

---

## PART 5 — OPEN

1. **Neither paper written**
2. Mechanism unknown
3. No causal experiment
4. No independent rerun by another person
5. Regime map limited to 4 cohorts
6. Published-claims reanalysis not started
7. STAD and UCEC null and unexplained
8. Protein-level null unexplained
