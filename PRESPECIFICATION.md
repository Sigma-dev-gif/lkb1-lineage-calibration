# Pre-specification: LKB1 functional loss and lineage program expression across cancer types

**Author:** Joel Minocha
**Date written:** 2026-09-20
**Status:** Written before any outcome data were examined. Amendments must be dated and appended, never overwritten.

---

## 1. Background and motivation

Prior work established that STK11/LKB1 loss in lung adenocarcinoma associates with elevated neuroendocrine and hepatocyte transcriptional programs, replicated across TCGA LUAD and GSE72094 (Minocha, prior manuscript). Mouse models show Lkb1 deletion promotes histological plasticity and adeno-to-squamous transition. Reviews note STK11-associated dedifferentiation in gallbladder and glioblastoma. Whether LKB1 loss relaxes lineage constraint as a general property, across tissues, has not been tested systematically.

Bandyopadhyay and Gordan (bioRxiv 2026.07.23.740219) derived a 30-gene transcriptional signature of LKB1 functional loss that identifies deficient tumors including those without STK11 mutation, expanding the analyzable population roughly 3.7-fold. Their analysis addressed prevalence, metabolic dependency and immune phenotype. It did not examine lineage or differentiation programs.

## 2. Hypotheses

**H1 (primary).** In tumors with LKB1 functional loss, lineage programs foreign to the tissue of origin are expressed at higher levels than in LKB1-intact tumors of the same type.

**H2 (secondary).** The specific foreign programs engaged are non-random with respect to tissue of origin — that is, tumors do not drift toward arbitrary identities but toward a restricted, tissue-dependent set.

H2 is designated secondary and will be reported as such regardless of outcome. It is the more interesting claim and the more likely to be underpowered.

## 3. Falsification criteria

H1 is not supported if, in the confirmatory tumor types, foreign-lineage scores show no elevation in signature-positive relative to signature-negative tumors after Holm correction, OR if any observed elevation is not distinguishable from that produced by size- and composition-matched control gene sets.

H2 is not supported if the distribution of which foreign programs are elevated is consistent with random selection from the available program set.

A null result for either is a reportable finding and will be written up as such.

## 4. LKB1 status assignment

- Signature: the published 30-gene elastic-net signature, weights as committed in `data/derived/lkb1_loss_signature.csv` of the authors' repository.
- Gene symbols updated to current HGNC via org.Hs.eg.db ALIAS mapping, verified 2026-09-20: PHF17→JADE1, GPR110→ADGRF1, MOSC1→MTARC1, C6orf176→LINC00473, C21orf125→LINC00319. All 30 resolved; no NAs.
- **Check required before scoring:** LINC00473 and LINC00319 are lncRNAs and may be absent from protein-coding-filtered expression matrices. Gene recovery will be reported per cohort. If fewer than 28 of 30 genes are present in a cohort, that cohort is excluded.
- Genomic loss defined as in the source paper: deleterious STK11 mutation (nonsense, frameshift, splice-site, translation-start, other truncating) or homozygous deletion (GISTIC = -2).
- Scores standardized within cohort. Positivity threshold set at 95% specificity in confidently-intact controls, following the source paper.
- **Reproduction gate:** before any lineage analysis, per-cohort prevalence estimates must be reproduced against the published `master_prevalence_table.csv`. Analysis does not proceed if these do not agree within the published intervals.

## 5. Lineage program scoring

**Primary collection:** MSigDB C8 cell type signature gene sets. Chosen because it is the one MSigDB collection defined by cell identity rather than pathway activity, so elevation is interpretable as expression of another cell type's marker program rather than activation of a signaling pathway. Version number to be recorded at time of download and fixed thereafter.

**Known weakness, stated in advance:** C8 is assembled from separate single-cell studies with heterogeneous tissues, sequencing depth and marker-calling rules. Set sizes and specificity vary; organ coverage is uneven.

**Replication collection:** Human Protein Atlas tissue-enriched genes. Uniform derivation, better cross-tissue comparability. The primary effect must replicate here to be claimed.

**Scoring method:** ssGSEA via GSVA, consistent with prior work. Scores computed within cohort.

**Inclusion rule for programs (fixed in advance):** a program enters the analysis only if it contains at least 15 genes after intersection with the expression matrix.

**Inclusion rule for tumor types:** a tumor type enters the analysis only if its native lineage and at least three plausible foreign lineages meet the program inclusion rule.

**Definition of "foreign":** the native lineage for each tumor type is designated in advance in a lookup table (Appendix A, to be completed before scoring) based on the normal cell of origin. All other programs in the analysis are foreign. Programs for lineages anatomically adjacent to the tumor site are flagged separately and reported as a distinct category, because contamination is most plausible there.

## 6. Confounder control

Purity is the central threat: a foreign-lineage score may reflect contaminating normal tissue rather than tumor cells adopting a different identity.

**Primary model:** ABSOLUTE purity (or CPE consensus) as a covariate.

**Not used as the measure of record:** ESTIMATE, because it is expression-derived from the same data as the lineage score, making the adjustment partly circular. Retained as a concordance check only.

**Sensitivity analysis:** rerun restricted to tumors with purity ≥ 0.7; direction and magnitude must hold.

**Composition adjustment:** purity is a scalar and cannot distinguish "less tumor" from "more of the specific normal cell type resembling the scored lineage." Cell-type fractions will be estimated (CIBERSORTx or BayesPrism) and each lineage score must survive adjustment for the fraction of the nearest matching cell type.

**Negative control gene sets:** matched for set size and mean expression level, drawn from programs with no plausible lineage relationship to the tissue. Effects must exceed those seen in controls.

## 7. Confirmatory versus exploratory

**Confirmatory (2 tumor types), designated on biological grounds independent of classifier performance:**

1. **Lung adenocarcinoma.** Highest STK11 genomic loss frequency (10.1%); mouse models show Lkb1 deletion promotes histological plasticity; prior positive finding in this tissue.
2. **Gastric adenocarcinoma.** Gastric epithelium has well-documented lineage plasticity; STK11 loss is represented; tissue is biologically distinct from lung, testing generality.

These justifications are stated independently of the within-tissue AUROC ranking. Selecting the top-performing cohorts out of twelve would be selection on the outcome, and pre-registering that selection afterward would launder rather than remove the bias.

**Specific confound for gastric, written in advance:** intestinal metaplasia is genuine lineage change occurring in *non-tumor* gastric epithelium. Contaminating metaplastic tissue would produce the predicted signal with no tumor cell changing identity. Intestinal-lineage programs in gastric tumors will therefore be reported separately and not counted toward H1 unless they survive composition adjustment.

**Exploratory (remaining signature-validated cohorts):** reported in a separate table, labeled hypothesis-generating, not used to support H1 or H2.

## 8. Statistical plan

- Confirmatory tests: Holm correction across the two confirmatory tumor types, α = 0.05.
- Exploratory tests: Benjamini-Hochberg within the exploratory table, reported separately.
- Effect sizes reported with confidence intervals throughout; significance alone will not be treated as the finding.
- Models include purity as covariate; cohort-stratified where pooling.

## 9. Scoop monitoring

bioRxiv and PubMed alerts set for STK11 and LKB1. If the cross-tissue lineage question is published during the project, this document records the independent origination date.

## 10. Amendments

Any deviation from this plan must be recorded below with date and reason, before the analysis is rerun.

*(none yet)*

---

## Appendix A: native lineage designations

*To be completed before any scoring. Each tumor type mapped to its normal cell of origin and the corresponding C8/HPA program(s).*
