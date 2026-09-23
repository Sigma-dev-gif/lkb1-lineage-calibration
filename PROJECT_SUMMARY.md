# Project summary as of 2026-09-23

## The question

Does loss of LKB1 (STK11) function relax lineage constraint in cancer — that is, do LKB1-deficient tumours express transcriptional programs belonging to cell lineages foreign to their tissue of origin, across cancer types?

**Origin.** Prior work (own manuscript) found that STK11-mutant lung adenocarcinoma shows elevated neuroendocrine and hepatocyte programs, replicated across TCGA LUAD and GSE72094. Mouse models show Lkb1 deletion drives adeno-to-squamous transition. Reviews note STK11-associated dedifferentiation in gallbladder and glioblastoma. Whether this is a general property of LKB1 loss had not been tested.

**Enabling tool.** Bandyopadhyay & Gordan (bioRxiv 2026.07.23.740219) derived a 30-gene transcriptional signature of LKB1 functional loss that identifies deficient tumours *without* STK11 mutation, expanding the analysable population ~3.7-fold. Their analysis covered prevalence, metabolic dependency and immune phenotype — not lineage.

## Hypotheses (pre-registered)

**H1 (primary).** In LKB1-deficient tumours, lineage programs foreign to the tissue of origin are expressed at higher levels than in LKB1-intact tumours of the same type.

**H2 (secondary).** The specific foreign programs engaged are non-random with respect to tissue of origin.

## Design

### Instrument reproduction
The 30-gene signature was reimplemented from scratch — symbol mapping, cBioPortal fetch, log2 transform, within-cohort standardization, weighted sum — and validated against the source paper's published within-cohort AUROCs.

**All nine cohorts reproduce.** Six matched to three decimals on the first pass (LUAD 0.889, LUSC 0.927, HNSC 0.822, ESCA 0.759, BRCA 0.786, CESC 0.862). Two initially failed and were resolved by a missing-data rule (below): STAD 0.910 vs 0.904, COADREAD 0.707 vs 0.703. UCEC 0.692 exactly.

### Lineage programs
MSigDB C8 was specified as the primary collection but **failed a coverage audit**: after excluding fetal atlases, adult references exist for lung, stomach and marginally colon, but not breast, cervix, endometrium, ovary, oesophagus or head and neck. C8 contains no adult skin atlas; its only melanocyte sets are ocular.

Switched to **Human Protein Atlas v25.1**, pooling Tissue enriched + Tissue enhanced + Group enriched (tissue-enriched alone gave lung 17 genes, ovary 5). Result: 37 tissue programs, all ≥15 genes.

### Specificity gate (GTEx v11, 54 standard tissues)
Every program must rank first in its own tissue; margin <2.0 triggers inspection with one of four dispositions (masked / merged / covariate / cleared-with-reason).

**Five contamination sources found and handled:**
1. **Immune leakage** — purged with GO:0045321 "leukocyte activation" (993 genes). The broader GO:0002376 was tested and rejected: it removed 45% of the lung program including SFTPA1, CLDN18, CTSH, EPAS1 — canonical alveolar genes with immune annotations.
2. **Immunoglobulin genes** — 81/306 of the stomach program and 141/857 of intestine were IG variable-region segments (plasma cells in gut mucosa). GO misses these entirely. Purged by gene-family pattern. Stomach margin 0.94 → 1.81.
3. **Squamous cross-reactivity** — cervix could not be distinguished from vagina (margin 0.01). Merged into a 34-gene pan-squamous program (margin 4.19). A residual test — does cervix-minus-core still beat vagina? — failed at 0.08, so the distinction died on evidence.
4. **Motile-cilia cluster** — fallopian tube failed against testis (margin −1.20) on shared axonemal machinery (CFAP53, SPAG6, DNAAF8…). A ciliary-gene purge was attempted and it still failed. Program dropped.
5. **Stromal contamination** — fibroblast, endothelial and adipocyte markers (MCP-counter, xCell) were found inside lineage programs, including three endothelial markers in the lung program. Purged from the programs, not from the markers, so no gene sits in both a score and its covariate.

**Scoreable programs: 14.** Excluded as non-lineage signal sources: lymphoid tissue, bone marrow (infiltrate), testis (cancer-testis antigen derepression).

### Cohort exclusions — all rule-generated
| Cohort | Reason |
|---|---|
| SARC | No cohort-level cell of origin across pooled histologies; foreign set collides with its own principal contaminants (fibroblast, endothelial). Consequence 3. |
| SKCM | No cutaneous melanocyte reference in either collection. HPA supplies skin *tissue*, dominated by keratinocyte identity, which is not melanoma's native cell. Consequence 3. |
| OV | Fallopian tube failed the gate, so only the *minority* origin hypothesis (ovarian surface epithelium) remains scoreable. Every tumour of tubal origin would score its own native lineage as foreign — a systematic false positive in the hypothesis's direction. **Consequence 4**, added as a rule and then applied. |
| CESC adeno/adenosquamous | Glandular native lineage unscoreable (cervix merged into pan-squamous). Consequence 4, second firing. |

**Ten analysed entities, seven distinct native designations** (LUSC, HNSC, ESCC and CESC all take pan-squamous).

### Missing-data rule
Blocks of samples lacked blocks of genes: STAD 36 samples × 6 signature genes; COADREAD 173 and UCEC 346 samples × the **identical** 2,214 genes. A direct API query for affected pairs returned empty at status 200 — the values do not exist. NAs had propagated through `scale()` into scores, and `rank()` places NA last, silently depressing AUROC.

**Rule: remove whichever costs less, keeping ≥28/30 signature genes.** COADREAD and UCEC drop two genes and keep all samples; STAD drops 36 samples (site-clustered, reported as non-random). Missingness is not associated with genomic loss.

Completeness is per cohort, not global — a global restriction would have cut STAD's native program from 231 to 170 genes to accommodate two exploratory cohorts.

### Controls
**Tier 1 — matched random sets.** 100 draws per program, matched on gene count and GTEx expression decile, from a 13,632-gene universe excluding all scored and Tier 2 genes. Seed 20260922.

**Tier 2 — coherent but lineage-irrelevant programs.** Six Hallmark sets, immune-purged, then stripped of genes shared with any scored program. Entered as Tier2_PC1 (first PC of the block).

**Covariates:** ABSOLUTE purity (GDC PanCanAtlas), fibroblast, endothelial, adipocyte scores, Tier2_PC1.

### Primary test
Composite foreign-lineage index: all foreign programs standardized within cohort and averaged. One test per confirmatory cohort, Holm across two. Per-program tests are secondary and descriptive.

Falsification criteria fixed in advance: significance retained after correction, attenuation ≤50% on adding Tier2_PC1, **and** the effect must exceed the Tier 1 empirical null.

## Primary result

| | n | deficient | β | Holm p | attenuation | **Tier 1 p** |
|---|---|---|---|---|---|---|
| LUAD | 497 | 129 | 0.270 | 3.2×10⁻⁹ | −0.52 | **0.73** |
| STAD | 362 | 50 | 0.106 | 0.076 | 0.01 | **0.62** |

**H1 is not supported.** LUAD's composite is highly significant and survives Tier 2 adjustment, but random gene sets matched on size and expression produce an effect at least as large in 73% of draws. STAD does not reach significance.

Both sensitivity analyses (WT-only; ABSOLUTE "called" only) agree.

**The control did its job.** LUAD endometrium: nominal p = 6.9×10⁻⁶, BH p = 3.0×10⁻⁵, **Tier 1 p = 0.58**. Reported by nominal significance alone it would have read as a clear finding.

Surviving every control (descriptive, cannot rescue H1): pancreas in LUAD (Tier 1 p 0.01); prostate and thyroid in STAD (0.00, 0.01); the HNSC composite (0.00, eight of thirteen programs clearing individually).

Hepatocyte both-versions analysis (pre-committed): identical under purged and unpurged Tier 2 (β 0.746 vs 0.747, Tier 1 p 0.13 both). The confound the safeguard was written against did not materialise.

## Part II — pre-registered methodological replication

Investigating *why* H1 failed produced a post-hoc observation: the empirical null floor varies 2–8× across cohorts and splits, against a theoretical 1.96. Four predictions were pre-registered and tested.

**P1 — split type.** Predicted tumour-state ≈4, sex ≈2. Supported in the original eight (medians: LKB1 4.15, genomic-only 4.01, WGD 4.02, sex 2.29). **Failed to replicate** in six new cohorts (KIRC, PRAD, LIHC, GBM, THCA, BLCA): WGD 2.52, sex 2.99 — prediction reverses. Like-for-like WGD comparison: original 3.10–5.81 (all >3) vs new 2.09–3.89 (three of five <3).

**P2 — generality across methods.** Resolved in the "general" direction. LUAD: ssGSEA 7.68, GSVA 7.62, mean-z 6.55. HNSC: 2.99 vs 3.53. Mean-z uses no ranks or KS statistic, so this is not a scoring-algorithm artifact.

**P3 — mechanism (inter-set correlation).** **Failed.** r = 0.12 (one draw), 0.17 (20 draws), against a 0.5 threshold. Reported as unexplained, per the pre-specification. Noted limitation: CAMERA's inter-gene correlation is computed *within* sets from residuals; what was measured is correlation *between* set scores. The test may have measured the wrong quantity — which is a limitation of the test, not a rescue of the hypothesis.

**P4 — replication.** **Failed** (see P1).

**One of four predictions holds.**

Other explanations tested and failed: sample size (R² = 0.09), global group separation (r = 0.61, contradicted by BRCA vs LUAD).

## The control that reframed it
Run on a **random 50/50 split** of LUAD, nominal and empirical p-values agree closely (0.49/0.42, 0.56/0.46, 0.48/0.41, 0.22/0.17) and the standardized floor is **1.50** — *below* theory.

**There is no inflation intrinsic to gene-set scoring.** It appears only when the grouping variable tracks something real, because the empirical null is built from random sets tested against that same grouping.

> The empirical null for a gene-set score depends on the **grouping variable**, not only on the gene set. Against a random grouping it matches parametric theory. Against real biological groupings it is 1.5–3× wider, varying by cohort in ways that four tested explanations fail to predict.

This control should have been run first. It was run last.

## Relation to prior work — no novelty claim
Inter-gene correlation inflating gene-set statistics was characterised by **Wu & Smyth (CAMERA, NAR 2012)**, who estimate a variance inflation factor from the data, and refined by **QuSAGE** (Yaari 2013). GSEA's own documentation notes enrichment scores must be adjusted for correlations with the expression dataset. The Tier 1 procedure is an empirical analogue, arrived at independently.

The contribution is **demonstration and quantification in a workflow where the correction is routinely omitted** — per-sample gene-set scores entered as regression outcomes — not discovery.

## Deliverable
`calibrate_geneset()` — given an expression matrix, gene sets, a grouping and covariates, returns observed β, nominal p, **empirical p** from matched-random sets, and the 95th-percentile null floor. Validated against a known result (LUAD liver: β 0.745 vs 0.746). Because nothing predicts the floor, empirical calibration per analysis is the only remedy; the four failed explanations are the argument *for* the tool.

## Honest limitations
- H1's failure is a null result in ten entities; it does not exclude lineage effects below the detection floor.
- ESCC contributes nothing: excess functional loss 5.0 (exactly the 5% floor), pre-registered MDE d ≈ 1.0. Pre-registered as "treat a significant result here as suspect."
- Prevalence estimates do not reproduce the source paper (1–3 points) because thresholding conventions are unspecified there. AUROC, which is invariant to those conventions, does reproduce.
- Part II's central observation is post-hoc; three of four pre-registered follow-ups failed.
- Mechanism unexplained.
- Single data source (TCGA), single gene-set collection for the primary analysis.
- 77 zero-variance genes in LUAD contribute no rank information.
- Tier 1 p resolution is 0.01 at 100 draws; liver at 0.07–0.13 cannot be resolved without more.

## Files
`PRESPECIFICATION.md` (12 amendments + Part II) · `APPENDIX_A_lineage_designations.md` · `RESEARCH_LOG.md` · `setup.R` · `analysis.R` · `calibrate_geneset.R` · `scores/` · `scores_new/` · `results_primary.rds` · `results_inflation.rds` · `results_p4.rds`

## Not started
The write-up.
