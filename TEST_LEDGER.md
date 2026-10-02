# Test ledger
Every analysis run in this project, with its status. 2026-09-28.

**Purpose:** hundreds of tests were run. Publishing the full list is the strongest available answer to "did you go fishing?" Status is **CONFIRMATORY** (pre-registered before data), **AMENDED** (pre-registered with a dated amendment), or **POST HOC**.

---

## CONFIRMATORY — specified before any data was examined

| Test | Result |
|---|---|
| H1, composite foreign-lineage index, LUAD | β 0.270, Holm p 3.2×10⁻⁹, **Tier 1 p 0.73 — not supported** |
| H1, composite, STAD | β 0.106, Holm p 0.076, **Tier 1 p 0.62 — not supported** |
| Sensitivity: WT-only population | Agrees |
| Sensitivity: ABSOLUTE "called" only | Agrees |
| Hepatocyte both-versions (Amendment 6) | Identical, β 0.746 vs 0.747 |
| H2, non-randomness of foreign programs | Not reached; H1 failed |
| Signature AUROC reproduction, 9 cohorts | All reproduce |

## AMENDED — pre-registered with a dated amendment

| Test | Amendment | Result |
|---|---|---|
| Per-program secondary tests, 99 | A12 | 43 BH-significant, 15 survive Tier 1 |
| Missing-data rule | A10 | Applied to STAD, COADREAD, UCEC, PRAD; **not waived** at GSE65858 |
| Cohort exclusions | Rule-generated | SARC, SKCM, OV, CESC non-squamous |
| Part II P1: split type | Part II | Supported in 8 original, **failed** in 6 replication |
| Part II P2: method generality | Part II | **Supported** |
| Part II P3: inter-set correlation | Part II | **Failed**, r 0.12 |
| Part II P4: replication | Part II | **Failed** |
| Native loss in six held-out cohorts | Pre-registered before testing | **5 of 6 pass** |
| Ratio replication, COADREAD/BRCA | Pre-registered | 2.67, 2.12 vs LUAD 2.34 |
| rSEA agreement with CAMERA | Pre-registered | Held |
| VIF term as mechanism | Pre-registered, 300 reps | Spearman 0.602 — **did not outperform m** |
| Separation rule out of sample | Pre-registered | Spearman 0.924 |

## POST HOC — exploratory, discovered after looking

### Methods
Empirical null attrition (65%, then 80%) · CAMERA comparison, 99 tests · plasmode design · 14-cohort regime map · grouping axis · sample-size curve, 3 cohorts · scoring-method comparison · coherence impossibility (0.245 vs 0.021) · coherence decomposition by program · the separation rule and its power-law form · purity as a distinct regime · Reactome regime map · survival diagnostic · audit applied to four published cohorts · specification curve, 27 cells

### Biology
Native lineage loss (discovered in LUAD and HNSC, **then pre-registered** for the six held-out cohorts) · dose-response, 13 cohorts · directional rSEA · driver specificity, 6 drivers × 3 cohorts · purity strata · alveolar-content adjustment · C8 Travaglini collection · GSE72094 replication · CPTAC RNA replication · CPTAC protein null and four explanations · DepMap cell lines · master regulators, 32 genes × 8 cohorts · pathologist grade, 6 cohorts · stemness separation · survival, 4 cohorts · meta-PCNA adjustment · equivalence bounds · immune programs · THCA/PRAD reversal · hormone hypothesis · NKX2-1

### Mechanism (all post hoc, none supported)
AMPK phosphosite · SIK family · SIK–CRTC–CREB transcriptional · MARK, NUAK, BRSK, SNRK · 11 Reactome pathway scores

---

## WITHDRAWN OR RETRACTED

| Claim | Status |
|---|---|
| ROAST over-rejects below m ≈ 150 | **Retracted** after Smyth's correction; real data agreed with him |
| Simulation grid 1 CAMERA result | Withdrawn — design artifact |
| Simulation grid 2 type I errors | Withdrawn — superseded by plasmode |
| Variance correction (v0.2) | Withdrawn — reverts to self-contained null |
| Hybrid decision rule (m < 150) | Withdrawn with the ROAST claim |
| Coherence as mechanism | Not supported, ρ 0.14 |
| SIK mediation | Not supported after proliferation adjustment |
| Survival floor prediction | Withdrawn — does not transfer |
| Tier 1 survivor list as findings | Withdrawn — rSEA rejects all four HNSC survivors |

---

## Corrections made to our own work

1. **p-values computed as b/n**, which can return zero. Corrected to (b+1)/(n+1) per Phipson and Smyth. All stored values recomputed; the 65% attrition figure was unchanged.
2. **Proliferation not adjusted for** in early mechanism tests. Added as a fixed covariate once found to confound; the SIK result did not survive.
3. **Three simulation designs** produced results that did not replicate on real data. All final numbers come from real data.
4. **The TF analysis is not independent** of the program analysis — the genes overlap. Reported as a readable subset of the same signal, not corroboration.

---

## Multiple testing

Benjamini–Hochberg within each analysis family, not across the whole project. **The number of post hoc tests above means no individual exploratory p-value should be read as confirmatory evidence.** The findings that carry weight are those pre-registered before the data that tested them, or replicated in held-out cohorts, and they are labelled as such throughout.
