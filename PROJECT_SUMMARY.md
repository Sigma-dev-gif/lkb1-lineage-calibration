# Project summary — 24 September 2026

**Joel Minocha** · Analysis repo: github.com/Sigma-dev-gif/lkb1-lineage-calibration · Package: github.com/Sigma-dev-gif/gscalibrate

---

# Part 0 — What this project is, in four sentences

It began as a pan-cancer test of whether LKB1 loss lets tumours express lineage programs foreign to their tissue of origin. The hypothesis was pre-registered and was not supported. The control built to test it — random gene sets matched on size and expression — killed 65% of the analysis's own statistically significant results, which turned out to be the more important finding. Investigating why led to a structural limit on that class of control, an independent replication outside TCGA, and a released R package that implements the check and warns when it cannot be trusted.

---

# Part 1 — The biological question

## Hypotheses (pre-registered, dated before any data)

**H1 (primary).** In LKB1-deficient tumours, lineage programs foreign to the tissue of origin are expressed at higher levels than in LKB1-intact tumours of the same type.

**H2 (secondary).** The specific foreign programs engaged are non-random with respect to tissue of origin.

## Why it was worth asking

Prior own work found STK11-mutant lung adenocarcinoma shows co-elevated neuroendocrine and hepatocyte programs, replicated in TCGA LUAD and GSE72094. Mouse models show Lkb1 deletion drives adeno-to-squamous transition. Reviews note STK11-associated dedifferentiation in gallbladder cancer and glioblastoma. Nobody had asked whether this is a general property of LKB1 loss.

The enabling tool was Bandyopadhyay & Gordan (bioRxiv 2026.07.23.740219), a 30-gene transcriptional signature of LKB1 functional loss that identifies deficient tumours **without** STK11 mutation, expanding the analysable population roughly 3.7-fold. Their paper covered prevalence, metabolic dependency and immune phenotype — not lineage.

## Data

| Source | Use |
|---|---|
| cBioPortal, TCGA PanCancer Atlas | RNA-seq (RSEM) for 15 cohorts; mutation and CNA calls |
| GTEx v11, GENCODE 47, 54 standard tissues | Specificity gate for lineage programs |
| Human Protein Atlas v25.1 | Lineage program definitions (37 tissues → 14 scored) |
| MSigDB Hallmark | Tier 2 control programs |
| MCP-counter; xCell | Stromal marker sets (fibroblast, endothelial, adipocyte) |
| GDC PanCanAtlas ABSOLUTE mastercalls | Tumour purity, ploidy, genome doublings |
| GDC TCGA-CDR Supplemental Table S1 | Histology for ESCA and CESC splits; sex |
| GEO GSE72094 (Affymetrix GPL15048) | External validation, 442 LUAD samples |

**Primary cohorts (nine fetched, ten analysed entities):** LUAD 510, STAD 409→373, LUSC 481, HNSC 507, COADREAD 532, ESCA 181 (split ESCC 94 / EAC 87), BRCA 1,064, CESC 288→239, UCEC 515.

**Replication cohorts (Part II only):** KIRC 400, PRAD 493→460, LIHC 361, GBM 159, THCA 488, BLCA 406.

---

# Part 2 — Building the instrument

## Signature reproduction: passed on all nine cohorts

Reimplemented from scratch — symbol mapping, cBioPortal fetch, log2 transform, within-cohort z-scoring, weighted sum — then validated against the source paper's published within-cohort AUROCs.

| Cohort | Reproduced | Published |
|---|---|---|
| LUAD | 0.889 | 0.889 |
| LUSC | 0.927 | 0.927 |
| HNSC | 0.822 | 0.822 |
| ESCA | 0.759 | 0.759 |
| BRCA | 0.786 | 0.786 |
| CESC | 0.862 | 0.862 |
| UCEC | 0.692 | 0.692 |
| STAD | 0.910 | 0.904 |
| COADREAD | 0.707 | 0.703 |

Five genes required legacy-symbol mapping (PHF17→JADE1, GPR110→ADGRF1, MOSC1→MTARC1, C6orf176→LINC00473, C21orf125→LINC00319). Two are lncRNAs that a protein-coding filter silently drops.

## Lineage programs: five contamination sources found and handled

MSigDB C8 was the pre-specified collection. It **failed a coverage audit** — no adult skin atlas, and no adult reference for breast, cervix, endometrium, ovary, oesophagus or head and neck. Switched to HPA v25.1, pooling Tissue-enriched + Tissue-enhanced + Group-enriched (tissue-enriched alone gave lung 17 genes, ovary 5).

Each program must rank first in its own GTEx tissue; margin below 2.0 triggers inspection with one of four named dispositions.

**1. Immune leakage.** Purged using GO:0045321 "leukocyte activation", 993 genes. The broader GO:0002376 was tested and **rejected**: it removed 45% of the lung program including SFTPA1, CLDN18, CTSH and EPAS1 — canonical alveolar genes that carry immune annotations.

**2. Immunoglobulin segments.** 81 of 306 stomach genes and 141 of 857 intestine genes were IG variable-region segments from mucosal plasma cells. GO misses these entirely. Purged by gene-family pattern; stomach margin went 0.94 → 1.81.

**3. Squamous cross-reactivity.** Cervix could not be separated from vagina (margin 0.01). Merged into a 34-gene pan-squamous core (margin 4.19). A residual test — does cervix-minus-core still beat vagina? — failed at 0.08, so the distinction died on evidence rather than on judgement.

**4. Motile cilia.** Fallopian tube failed against testis at −1.20 on shared axonemal genes (CFAP53, SPAG6, DNAAF8). A ciliary-gene purge was attempted and it still failed at −0.84. Program dropped.

**5. Stromal contamination.** Fibroblast, endothelial and adipocyte markers found inside lineage programs — including three endothelial markers (ACVRL1, HHIP, VEPH1) inside the **lung** program, the native program of the anchor cohort. Purged from the programs rather than from the markers, so no gene sits in both a score and its own covariate.

**Result: 14 scoreable programs.** Excluded as non-lineage signal sources: lymphoid tissue and bone marrow (infiltrate); **testis** (cancer-testis antigen derepression — MAGE, GAGE, NY-ESO-1 are expressed in many solid tumours via promoter hypomethylation with no germ-cell identity behind them).

## Cohort exclusions — every one generated by a rule written first

| Excluded | Rule |
|---|---|
| SARC | No cohort-level cell of origin across pooled histologies; the foreign set collides with its own principal contaminants |
| SKCM | No cutaneous melanocyte reference in either collection; HPA skin is keratinocyte-dominated, which is not melanoma's native cell |
| OV | Tubal program failed the gate, leaving only the minority-origin hypothesis scoreable — under the STIC model every tumour would score its native lineage as foreign, a systematic false positive in the hypothesis's own direction |
| CESC adeno + adenosquamous | Glandular native lineage unscoreable after the squamous merge |

The masking rule — programs a documented non-neoplastic process would produce are masked, not called foreign — fired identically three times: intestinal metaplasia in STAD, Barrett's before EAC, gastric-type differentiation in serrated lesions before COADREAD.

## Missing data: a rule the pre-spec already contained

STAD had 36 samples missing 6 signature genes; COADREAD 173 and UCEC 346 samples missing the **identical** 2,214 genes. A direct sample-level API query returned an empty list at HTTP 200 — the values do not exist in cBioPortal.

The failure mode was silent: NAs propagated through `scale()` into scores, and `rank()` places NA last, depressing AUROC without any error.

**Rule applied: remove whichever costs less, keeping ≥28 of 30 signature genes.** COADREAD and UCEC dropped two genes and kept all samples; STAD dropped 36 samples. Completeness computed per cohort, not globally — a global restriction would have cut STAD's native program from 231 genes to 170 to accommodate two exploratory cohorts.

## Controls

**Tier 1** — 100 random gene sets per program, matched on gene count and GTEx expression decile, drawn from a 13,632-gene universe excluding all scored and Tier 2 genes. Seed 20260922.

**Tier 2** — six Hallmark programs (E2F, G2M, hypoxia, OXPHOS, MYC, IFN-γ), immune-purged, then stripped of genes shared with any scored lineage program. Entered as first principal component.

**Covariates** — ABSOLUTE purity; fibroblast, endothelial and adipocyte scores; Tier2_PC1.

**Falsification criteria, fixed in advance:** significance after correction, attenuation ≤50% on adding Tier2_PC1, **and** the effect must exceed the Tier 1 empirical null.

---

# Part 3 — The primary result

## H1 is not supported

| Cohort | n | deficient | β | Holm p | attenuation | **Tier 1 p** |
|---|---|---|---|---|---|---|
| LUAD | 497 | 129 | 0.270 | 3.2×10⁻⁹ | −0.52 | **0.73** |
| STAD | 362 | 50 | 0.106 | 0.076 | 0.01 | **0.62** |

LUAD's composite foreign-lineage index is highly significant and survives Tier 2 adjustment — but matched-random gene sets produce an effect at least as large in 73% of draws. STAD does not reach significance.

Both pre-specified sensitivity analyses agree: wild-type-only (the non-genomic population the source paper made novel) and ABSOLUTE "called"-only.

## The single most illustrative number

**LUAD endometrium: nominal p = 6.9×10⁻⁶, BH p = 3.0×10⁻⁵, Tier 1 p = 0.58.**

Reported under standard practice this is a clear finding. Random gene sets matched only on size and expression level beat it 58% of the time.

## Attrition across three filters

99 per-program tests in eight cohorts → **43 significant after Benjamini–Hochberg** → **15 survive Tier 1** → **6 also survive CAMERA**.

**28 of 43 BH-significant results (65%) fail empirical calibration.** No result ever survives Tier 1 while failing BH; the filters nest perfectly.

## The six survivors, confirmed at 1,000 draws

| Cohort | Program | β | BH p | CAMERA p | Tier 1 p |
|---|---|---|---|---|---|
| HNSC | pancreas | 0.781 | 4.7×10⁻¹⁰ | 0.017 | 0.000 |
| HNSC | kidney | 0.694 | 2.8×10⁻⁹ | 0.025 | 0.000 |
| LUAD | pancreas | 0.899 | 1.1×10⁻²⁰ | 0.041 | 0.005 |
| HNSC | liver | 0.502 | 5.6×10⁻⁵ | 0.033 | 0.037 |
| STAD | thyroid | 0.627 | 7.7×10⁻⁵ | 0.043 | 0.041 |
| HNSC | intestine | 0.519 | 2.6×10⁻⁵ | 0.050 | 0.043 |

Three of six are borderline even at 1,000 draws. All are descriptive by pre-specification and cannot rescue a failed primary test.

**HNSC survives purity stratification.** Deficient HNSC tumours have higher purity (0.57 vs 0.49, p = 5.4×10⁻⁴), but all four programs stay positive across all three purity terciles. Not an artifact — an unanticipated, exploratory, tissue-specific result in a cohort that was never part of the hypothesis.

## A safeguard that proved unnecessary

Amendment 6 pre-committed to reporting the hepatocyte result under both purged and unpurged Tier 2, because the lineage-shared purge cut in the hypothesis's favour. Result: **identical** (β 0.746 vs 0.747, Tier 1 p 0.13 both). The bias the safeguard was written against did not exist.

---

# Part 4 — CAMERA: independent corroboration, and a regime

Running `limma::camera()` on the same data, groupings and design:

| | Tier 1 fails | Tier 1 survives |
|---|---|---|
| CAMERA fails | 84 | 9 |
| CAMERA survives | **0** | 6 |

**Zero contradictions across 99 tests.** Spearman 0.74 between the two p-values. CAMERA is strictly more conservative. An established correction published in 2012 agrees with the empirical procedure wherever it has an opinion.

**But CAMERA's estimated inter-gene correlation does not predict the empirical floor** (Spearman −0.19; the full VIF −0.23). Two corrections agreeing on outcomes while disagreeing on the quantity said to drive them.

**What separates the nine discordant cases is set size, not correlation:** median m of 371 (both), 220 (Tier 1 only), 164 (neither), while ρ barely moves (0.048 vs 0.035). Every concordant survivor has m ≥ 297; nearly every discordant case m ≤ 231.

**Statable regime: CAMERA is conservative for small gene sets at low inter-gene correlation, relative to a matched-random empirical null.**

---

# Part 5 — Part II: a pre-registered replication that mostly failed

Four predictions registered before the six replication cohorts were fetched.

| | Prediction | Outcome |
|---|---|---|
| **P1** | Tumour-state splits give standardized floor ≈4; sex ≈2 | Supported in the original eight (LKB1 4.15, genomic-only 4.01, WGD 4.02, sex 2.29). **Failed to replicate**: WGD 2.52, sex 2.99 — reversed |
| **P2** | Inflation is not specific to ssGSEA | **Supported.** LUAD: ssGSEA 7.68, GSVA 7.62, mean-z 6.55. HNSC: 2.99 vs 3.53 |
| **P3** | Inter-set correlation predicts the floor | **Failed.** r = 0.12 at one draw, 0.17 at twenty |
| **P4** | Replication in six new cohorts | **Failed** (see P1) |

**One of four holds.** Like-for-like WGD comparison: original cohorts 3.10–5.81, all above 3; new cohorts 2.09–3.89, three of five below 3.

Other explanations tested and failed: sample size (R² = 0.09), global group separation (r = 0.61, contradicted by BRCA vs LUAD). Best surviving candidate: **background DE density, R² = 0.57** — suggestive, with clear counterexamples, not established.

## The control that reframed everything, run last

On a **random 50/50 split** of LUAD samples, nominal and empirical p-values agree closely (0.49/0.42, 0.56/0.46, 0.48/0.41, 0.22/0.17) and the standardized floor is **1.50 — below the theoretical 1.96.**

There is no inflation intrinsic to gene-set scoring. It appears only when the grouping variable tracks something real, because the empirical null is built from random sets tested against that same grouping.

*This control should have been the first thing run. It was the last.*

---

# Part 6 — The structural limit

## Simulation grid 1 was wrong, and why

120 cells, 200 reps. Correlation induced by a single latent factor affecting all genes equally — so the tested set and the background were equally correlated, leaving nothing for a competitive test to correct. CAMERA rejected 0% whenever ρ > 0. **That result reflects the design, not CAMERA.**

## Simulation grid 2: Tier 1 is anti-conservative

Rewritten with correlation induced separately inside and outside the set. Background ρ = 0.05, set ρ = 0.15, no true effect:

| m | Tier 1 type I error |
|---|---|
| 75 | 0.035 |
| 250 | **0.125** |
| 900 | **0.255** |

Tier 1 matches on size and expression decile but **not on internal coherence**. Real gene sets are coherent by construction; random draws are not. The null is built from less-correlated sets than the one being tested, so it is too narrow.

## The fix was attempted and failed

Correlation-matched draws — generate 3–5× the candidates, keep those closest in coherence to the target. At m = 250: unmatched 0.10, **matched 0.15**. No improvement. Selecting the closest candidates draws from the extreme tail of the candidate distribution, which is itself a form of the problem being solved.

## Why no fix is possible — the decisive measurement

Mean inter-gene correlation of the 14 scored programs in TCGA LUAD:

| Program | m | ρ | | Program | m | ρ |
|---|---|---|---|---|---|---|
| lung | 137 | **0.245** | | intestine | 671 | 0.061 |
| pan-squamous | 30 | 0.153 | | breast | 110 | 0.045 |
| endometrium | 72 | 0.115 | | pancreas | 272 | 0.045 |
| ovary | 156 | 0.109 | | kidney | 420 | 0.044 |
| stomach | 201 | 0.094 | | thyroid | 157 | 0.042 |
| urinary bladder | 108 | 0.068 | | liver | 902 | 0.041 |
| | | | | adrenal | 206 | 0.037 |
| | | | | prostate | 109 | 0.028 |

**Random 250-gene draws: minimum 0.009, median 0.013, maximum 0.021.**

Lung requires ρ = 0.245 — roughly twelve times what any random draw reaches. Even the least coherent program exceeds the random maximum. **No pool of random draws can match a real gene set on coherence, because coherence is what makes it a gene set.**

This is a structural limit, not an implementation detail.

## It also resolves an apparent contradiction

Grid 2 predicts over-rejection growing with m, so Tier1-only false passes should concentrate in large sets. Empirically they sit at median m = 220, *smaller* than the concordant survivors at 371.

**Resolution: in real programs ρ and m are negatively correlated (Spearman −0.47).** Lung ρ = 0.245 at m = 137; liver ρ = 0.041 at m = 902. Large tissue programs are heterogeneous; small ones are tight. Grid 2 held ρ fixed while varying m — a combination that does not occur in real data. The two effects largely cancel.

## What still stands, and why — two separate arguments

**The 65% attrition holds.** Those 28 results failed a null that was, if anything, too easy to beat.

**The six survivors hold for a different reason.** All six also cleared CAMERA, which estimates ρ from the actual set and is therefore immune to the coherence failure. They are protected by concordance, not by Tier 1.

---

# Part 7 — ROAST: correct where Tier 1 fails, inflated where it doesn't

Rotation testing preserves observed correlation structure by construction instead of reproducing it in draws.

**Type I error**, background ρ = 0.05, 200 reps:

| m | set ρ | Tier 1 | ROAST |
|---|---|---|---|
| 75 | 0.05 | — | **0.135** |
| 250 | 0.05 | — | 0.060 |
| 900 | 0.05 | — | 0.050 |
| 75 | 0.15 | 0.035 | **0.100** |
| 250 | 0.15 | **0.125** | 0.060 |
| 900 | 0.15 | **0.255** | 0.065 |

**Power** at effect 0.1: 0.92–0.99 at low set correlation, 0.64–0.76 at high.

ROAST is correctly calibrated at m = 250 and 900 — exactly where Tier 1 fails badly — and is 17× faster. **But it over-rejects at m = 75.**

**No method is universally correct.** Small gene sets are hard for all three, for three different reasons: Tier 1 by coherence mismatch, CAMERA by conservatism, ROAST by rotation strain. The empirical CAMERA result and the simulated ROAST result independently converge on the same regime.

---

# Part 8 — External validation: it replicates outside TCGA

**GSE72094**, Affymetrix array GPL15048, 442 lung adenocarcinomas, 22,115 unique gene symbols. Independent of TCGA in platform, patients, institution and processing.

**Grouping: STK11 mutation from sequencing — 68 mutant, 374 wild-type.** No expression involved in defining groups.

The signature could not be scored: only 26 of 30 genes map to this 2012-era array, below the 28/30 floor. **The rule was applied, not waived.**

| Program | m | ρ | β | nominal p | Tier 1 p | floor_std |
|---|---|---|---|---|---|---|
| pancreas | 244 | 0.023 | 0.417 | 0.0015 | 0.50 | 5.33 |
| liver | 828 | 0.031 | 0.323 | 0.014 | 0.96 | 4.99 |
| ovary | 146 | 0.083 | −0.281 | 0.033 | 0.82 | 5.38 |
| lung | 124 | **0.245** | −0.271 | 0.040 | 0.73 | 5.69 |
| (10 others) | | | | n.s. | 0.78–1.00 | 4.66–5.81 |

**Standardized floors 4.66–5.81 against a theoretical 1.96.** Four programs reach nominal significance; every one dies at Tier 1.

**Lung ρ = 0.245 — identical to the TCGA LUAD value on a completely different platform.** The coherence measurement that makes draw-matching impossible is not an artifact of RNA-seq or of one dataset.

---

# Part 9 — The literature: the practice, and the precedent

## Five papers where the score is the tested variable

PubMed adoption curve: 2 papers (2019) → 64 (2021) → 138 (2022) → ~100/year since. 518 total.

| Paper | Score as tested variable | Correlation correction | Multiple testing |
|---|---|---|---|
| PESSA, *PLoS Comput Biol* 2024 (tool) | 13,434 gene sets × 238 datasets × 51 cancers | None | None reported |
| Glycolysis/CLN6, *Acta Biochim Biophys Sin* 2026 | Cox across Hallmark sets, top five reported | None | None |
| Sarcoma six-gene, *Aging* 2024 | Hallmarks scanned against OS | None | None reported |
| STAD amino-acid, *Int Immunopharmacol* 2024 | 29 immune scores; 26 significant | None | None |
| CRC stemness, *Stem Cell Res Ther* 2022 | 26 Cox tests → 13 retained at p<0.05 | None | None |

PESSA and CRC stemness both use optimal-cutpoint dichotomisation — a second, separately documented inflation source. The CRC stemness paper reports correlations *among its own 26 scores* in a supplementary figure and does not use them.

Claim phrased as "no correction is reported," never "none was applied."

## The precedent: Gordon Smyth confirmed it, and had said it first

Emails sent to Smyth (WEHI), Wu (UNC), Irizarry (Dana-Farber), Leek (Fred Hutch), Waldron (CUNY), Bandyopadhyay (UCSF) and Dudoit (Berkeley).

**Smyth replied within a day, twice.** First reply addressed sample-label permutation — the email had been too dense and hadn't distinguished randomizing gene sets from permuting samples. A one-sentence follow-up got:

> "It is a distinct problem. Randomizing gene sets is extremely anti-conservative because it ignores inter-gene correlations."

He linked a Bioconductor thread containing, from 2.4 years earlier:

> "Pre-ranked GSEA make the wildly unrealistic assumption that genes are statistically independent... gives wildly inflated statistical significance. In effect, pre-ranked GSEA is detecting gene sets that contain co-regulated genes rather than gene sets that are differentially expressed between the experimental conditions."

**The phenomenon is confirmed by the authority and is not novel.** It is the fifth time a novelty claim in this project shrank on contact with the literature.

### What remains distinct, stated precisely
1. **Different workflow.** Smyth describes pre-ranked GSEA, where gene permutation *is* the test. This concerns per-sample scores entered as regression outcomes — same dependence, different procedure, and the one with no correction reported anywhere in the audit.
2. **Quantification.** "Wildly inflated" versus 0.125 and 0.255 type I error; ρ = 0.245 against draws capped at 0.021 as the structural reason; 65% attrition in a pre-registered analysis; floor ≈ 5.2 replicated in an independent cohort.
3. **ROAST over-rejects at m = 75.** Not in that thread, not found documented elsewhere. Possibly the one genuinely new observation.
4. **The literature audit itself** — the adoption curve and the five documented cases.

---

# Part 10 — The deliverable

**`gscalibrate` 0.1.0** — github.com/Sigma-dev-gif/gscalibrate

`calibrate_geneset()` returns, per gene set: observed β, nominal p, empirical p against matched-random draws, `floor_95`, `floor_std` (comparable to 1.96), `rho_set`, `rho_null_max`, and a `reliable` flag.

**The limitation is built into the tool.** `reliable` is FALSE when the set's coherence exceeds twice the maximum any draw achieved, and the function warns, pointing to `limma::roast` and `limma::cameraPR`. The vignette states the numbers and includes a worked example where the flag fires.

Four unit tests (seven assertions, all passing) covering calibration under the null, detection of a real effect, correct flagging of a coherent set, and input validation. **`R CMD check`: 0 errors, 0 warnings, 1 note** (a failed timestamp lookup). Meets CRAN's technical bar.

One instructive finding from the tests: **a real effect creates coherence**, so the flag fires on true positives too. It cannot distinguish "coherent because it is a real gene set" from "coherent because the effect is real." Stated as a limitation.

---

# Part 11 — Limitations, in full

- H1's null result does not exclude lineage effects below the detection floor.
- ESCC contributes nothing: excess functional loss 5.0, exactly the 5% floor by construction; pre-registered MDE d ≈ 1.0.
- Prevalence estimates differ from the source paper by 1–3 points because thresholding conventions are unspecified there. AUROC, invariant to those conventions, does reproduce.
- Part II's central observation is **post hoc**; three of four pre-registered follow-ups failed.
- The mechanism behind between-cohort floor variation remains **unexplained**. Four candidate explanations tested and rejected.
- **Tier 1 is anti-conservative for internally coherent sets**, and this cannot be engineered around.
- The `reliable` flag cannot distinguish set coherence from effect-induced coherence.
- Simulations use a single-latent-factor correlation structure; real correlation is block-structured.
- Primary analysis uses one gene-set collection (HPA); external validation uses one non-TCGA cohort.
- Tier 1 p resolution is 1/n_null.

---

# Part 12 — What is done, and what is left

**Done.** Pre-registration with 12 dated amendments plus Part II. Instrument reproduced across nine cohorts. Five contamination sources identified and handled. Four rule-generated cohort exclusions. Primary hypothesis tested and not supported. Sensitivity analyses. CAMERA comparison. Two simulation grids. ROAST comparison. External validation in GSE72094. Literature audit. Correspondence with CAMERA's author. A tested, documented, installable R package. Both repositories public, pre-specification committed before results.

**Left.**
1. **The paper** — not started. Abstract first.
2. A mentor with a computational biology lab, for a corresponding author and an independent letter.
3. Preprint, then submission. Venue depends on how the ROAST small-set observation holds up: NAR Genomics and Bioinformatics or Bioinformatics Advances realistic; PLOS Computational Biology a reach.
4. STS report, written fresh from the paper rather than pasted from it.

---

# Part 13 — The one-paragraph version

A pre-registered pan-cancer test of whether LKB1 loss relaxes lineage constraint found no support for the hypothesis in either confirmatory cohort. The matched-random control built to test it eliminated 28 of 43 associations that had survived Benjamini–Hochberg correction, and `limma::camera` independently agreed with that control on 90 of 99 tests with zero contradictions. Stress-testing the control in simulation revealed that it is itself anti-conservative for internally coherent gene sets — type I error 0.255 at 900 genes — and that this cannot be repaired by matching draws on correlation, because real tissue programs reach mean inter-gene correlation of 0.245 while random draws of equal size reach at most 0.021. Rotation testing is correctly calibrated in that regime but over-rejects for small sets, so no available method is universally correct. The inflation replicates in an independent non-TCGA cohort with a genomically-defined grouping. The work is released as an R package that performs the check and refuses to vouch for its own answer when the tested set is too coherent for the method to be trusted.
