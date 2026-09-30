# Paper outline, version 2
2026-09-27 · supersedes v1

**The project now supports two papers.** They share data and code but have different claims, audiences and venues. Attempting one paper that does both would weaken each.

---

# PAPER A — the biology (write this one first)

### Title
**Loss of native lineage identity in LKB1-deficient tumours**

### Abstract (238 words)

Loss of the tumour suppressor LKB1 (STK11) is common across epithelial cancers and is associated with metabolic reprogramming and an immune-cold phenotype. Whether it alters the differentiation state of the tumour itself has not been tested systematically.

We pre-registered a pan-cancer test of the hypothesis that LKB1-deficient tumours express lineage programs foreign to their tissue of origin, using a published 30-gene signature of LKB1 functional loss to identify deficient tumours beyond those carrying STK11 mutations. **The hypothesis was not supported** in either confirmatory cohort; equivalence bounds exclude standardised effects above 0.36.

A post hoc analysis found the opposite pattern: LKB1-deficient tumours show reduced expression of their *own* tissue's lineage program. We pre-registered this before testing it in six held-out cohorts, where five of six confirmed it. The effect is dose-dependent against the continuous signature score (LUAD β = −0.051, p = 5.6×10⁻²⁴), competitively significant under a gene-set test valid given inter-gene dependence (p = 0.0011), and replicated in an independent non-TCGA cohort with mutation-defined groups (p = 0.025). It survives adjustment for tumour purity, stromal content and normal-lung content, and it is specific: of six driver alterations tested, LKB1 shows the largest effect and KRAS shows none.

The effect is not mediated by AMPK or SIK signalling, LKB1's canonical substrates, suggesting a non-canonical route that bulk transcriptomics cannot resolve.

### Structure
1. **Introduction** — LKB1 biology; the signature; prior dedifferentiation reports in Lkb1-null mice; the pre-registered question.
2. **Methods** — cohorts, signature reproduction against published AUROCs, HPA programs and the specificity gate, five contamination sources, pre-registration and twelve amendments, covariates.
3. **Results**
   - 3.1 H1 not supported; equivalence bounds
   - 3.2 Native loss in LUAD and HNSC, direction established
   - 3.3 Pre-registered confirmation in six held-out cohorts (5/6)
   - 3.4 Dose-response, 5 of 7 cohorts
   - 3.5 Competitive significance (directional rSEA)
   - 3.6 Independent replication, GSE72094
   - 3.7 Purity, stroma, alveolar-content controls
   - 3.8 Driver specificity; KRAS null; joint model
   - 3.9 Mechanism: not AMPK, not SIK, not mTOR
4. **Discussion** — dedifferentiation without transdifferentiation; relation to adeno-to-squamous transition in Lkb1-null mice; what phosphoproteomics could resolve.
5. **Limitations** — STAD and UCEC null; effect sizes vary six-fold; survival weak and LUAD-only; mechanism tested at mRNA level only; observational.

### Figures
1. Native program score against continuous signature score, seven cohorts, one panel each.
2. Forest plot: driver specificity, six drivers × three cohorts.
3. Directional rSEA — up- and down-portion competitive p, all 14 programs.
4. GSE72094 replication.

### Venue
Cancer-biology or cancer-genomics journal. The finding is specific, replicated and mechanistically open.

---

# PAPER B — the methods (write second)

### Title
**Competitive gene set tests on per-sample scores: how often they fail, and why two obvious repairs cannot work**

### Abstract (211 words)

Per-sample gene set scores are widely treated as ordinary variables in regression and survival models. In five published studies examined in full, including a tool that pre-computes survival analyses for 13,434 gene sets, none reported a correction for dependence among genes.

Across four TCGA cohorts and 50 Hallmark sets, 84 of 105 associations significant after Benjamini–Hochberg correction — 80% — fail an empirical null built from matched-random gene sets. Using real expression with random sample splits, so the null is true by construction, type I error reaches 0.30.

The empirical null is itself invalid. It is computed within a fixed sample split and therefore captures only gene-sampling variation: for HALLMARK_E2F_TARGETS the within-split null has SD 0.047 while the set's own coefficient varies across splits with SD 0.110. Two repairs were attempted and both fail for principled reasons. Matching random draws on inter-gene correlation is impossible — real programs reach ρ = 0.245 while random draws of equal size reach at most 0.021. Combining gene randomization with sample permutation reverts to the self-contained null (Maciejewski 2014), which we confirm empirically.

We compare three valid alternatives on the same data and show they disagree with each other, and we release an R package implementing the diagnostic.

### Structure
1. **Introduction** — the workflow; the literature audit; the competitive/self-contained distinction (Goeman & Bühlmann 2007); what is already known (Wu & Smyth 2012, Venet 2011, Smyth's public comments).
2. **Methods** — plasmode design; the three corrections attempted; CAMERA, ROAST and rSEA as comparators.
3. **Results**
   - 3.1 The literature audit
   - 3.2 80% attrition across cohorts
   - 3.3 Type I error to 0.30 on real data with true nulls
   - 3.4 The variance decomposition: 2.3× too narrow
   - 3.5 Coherence matching is impossible (0.245 vs 0.021)
   - 3.6 Hybrid correction reverts to self-contained — theory and confirmation
   - 3.7 Three valid methods, three answers: 38 BH → 6 Tier 1 → 9 rSEA, overlap 4
   - 3.8 55.5% background DE explains why self-contained testing is uninformative here
4. **Discussion** — practical guidance; when each method applies.
5. **Limitations** — three simulation designs produced spurious results and were withdrawn; the ROAST small-set claim was retracted after the method's author corrected it; no independent rerun yet.

### Figures
1. rSEA scatter: self-contained vs competitive adjusted p, 50 Hallmark sets, log axes. **The whole argument in one panel.**
2. Within-split null vs across-split observed distribution, same gene set, same axis.
3. Attrition across methods.
4. Coherence: real sets vs random draws, three collections.

### Venue
NAR Genomics and Bioinformatics or Bioinformatics Advances. Briefings in Bioinformatics if the regime map is expanded.

---

## Order and why

**Paper A first.** The finding is complete, replicated and specific, and it answers the question the project set out to ask — in the negative for H1 and in the positive for something adjacent. Gordan's expertise is directly relevant and he has offered time in six weeks.

**Paper B second.** Its claims have been revised repeatedly and three of its components were retracted. It needs the independent rerun and a settled regime map before submission. It is also the paper that most needs a statistician's read.

**For the STS report:** Paper A is the primary narrative. Paper B is how the finding was made trustworthy — the control that killed 65% of the original results is what forced the analysis that found the real effect.
