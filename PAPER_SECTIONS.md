# Draft sections
2026-09-28 · Introduction, Discussion, What-didn't-work, Figure specs

**Not included: the Methods section.** That is the section judges probe hardest and it records your own judgment calls. Write it yourself; a scaffold is at the end of this document.

---

# INTRODUCTION (draft, ~700 words)

A standard workflow in cancer genomics computes a per-sample score for each gene set — ssGSEA, GSVA, or a mean of standardised expression — and then treats that score as an ordinary variable. The score is compared between mutation groups, entered into a Cox model, or correlated with stage or survival. PubMed returns 518 such papers, rising from 2 in 2019 to roughly 100 per year since 2022.

The p-values these analyses produce assume that genes are statistically independent. They are not. Inter-gene correlation inflates gene-set statistics, a problem characterised by Wu and Smyth, who introduced CAMERA to estimate and correct for it, and refined by Yaari and colleagues in QuSAGE. Tamayo and colleagues demonstrated empirically that ignoring gene–gene correlation produces substantial variance inflation. Venet, Dumont and Detours showed that most *random* gene signatures are significantly associated with breast cancer outcome, because much of the transcriptome correlates with proliferation.

Goeman and Bühlmann drew the distinction that organises all of this. A **self-contained** test asks whether any gene in the set is associated with the outcome. A **competitive** test asks whether the set is *more* associated than genes outside it. The two answer different questions and can disagree sharply. Self-contained tests are statistically well-founded but can be too easily rejected when many genes are active; competitive tests ask the more biologically interesting question but, as Goeman and Bühlmann note and Maciejewski later proved, no available competitive method is valid under arbitrary dependence.

Of five papers we read in full that use per-sample scores as tested variables — including a published tool that pre-computes survival analyses for 13,434 gene sets across 238 datasets — **none reports any correction for inter-gene correlation**, and most report no multiple-testing correction either.

What is missing from this literature is not awareness that the problem exists. It is a way to know, before running an analysis, how badly it will be affected.

*[STATE THE WORK'S ORIGIN HERE IN YOUR OWN WORDS: the pre-registered LKB1 lineage hypothesis, where it came from, and that the control built to test it is what exposed the problem.]*

This paper makes four contributions.

**First, a quantification.** Across 14 TCGA cohorts and 50 Hallmark gene sets each, 80% of associations significant after Benjamini–Hochberg correction fail an empirical null built from matched-random gene sets. Measured on real expression with random sample splits — so that the null is true by construction — type I error reaches 0.30.

**Second, a demonstration that two obvious repairs cannot work.** Matching random draws on inter-gene correlation is impossible: real tissue programs reach mean inter-gene correlation of 0.245 while random draws of the same size reach at most 0.021, and 88–92.5% of sets across Hallmark, Reactome and Gene Ontology exceed what any random draw achieves. Combining gene randomisation with sample permutation reverts to the self-contained null, a result due to Maciejewski that we confirm empirically.

**Third, a predictive rule.** The empirical null floor scales as approximately 2.37 × (median |t|)^1.38, where median |t| is the median absolute per-gene t-statistic for the grouping across the whole transcriptome. Across 25 cohort–grouping combinations spanning mutation status, sex, age, tumour purity and random assignment, Spearman correlation is 0.902 and log-log R² is 0.826. The rule orders correctly out of sample and errs by roughly 20–30% in magnitude. A counterintuitive consequence follows and is confirmed in three cohorts: **the problem worsens as sample size grows.**

An analogous polygenicity-driven inflation has been described in transcriptome-wide association studies, where it likewise increases with sample size and is corrected by a computed inflation parameter. The convergence of two independent literatures on the same relationship between diffuse background signal and false-positive inflation suggests the mechanism is general.

**Fourth, a tool.** `gscalibrate` implements the diagnostic in one function call, taking an expression matrix and a grouping and returning the predicted floor before any gene-set test is run.

---

# DISCUSSION (draft, ~900 words)

## What the rule means in practice

The central practical result is that the reliability of a gene-set test can be predicted from a statistic the analyst already has. Compute the median absolute per-gene t-statistic for your grouping. Below roughly 0.9, the parametric test is close to calibrated. Above 1.7, expect most results significant after multiple-testing correction not to survive a competitive test.

This reframes the problem usefully. The question is not whether gene-set testing is reliable in general — it is reliable in some settings and badly unreliable in others, and the difference is measurable in advance. In our 14 cohorts the failure rate ranged from 0% in bladder cancer, where the floor sat at 1.95 against a theoretical 1.96, to 88.5% in head and neck cancer.

## Why bigger studies are worse

Subsampling three cohorts shows the floor rising monotonically with sample size: in lung adenocarcinoma from 2.34 at n = 60 to 7.05 at n = 497. The mechanism is straightforward. The spread of the null distribution is set by the gene-set sampling and changes little; the standard error of the observed statistic shrinks as √n. The standardised floor therefore grows.

This runs against the intuition that larger studies are more trustworthy. For competitive gene-set testing on per-sample scores, the opposite holds, and the same relationship has been reported in transcriptome-wide association studies.

## Composition is its own regime

Groupings defined by tumour purity inflate the floor beyond what their separation statistic predicts — by 4.62 units on average, controlling for median |t|. Composition-driven separation shifts whole cell-type programs coherently, which is precisely the structure random gene draws cannot reproduce. Analysts comparing groups that differ in cellular composition should expect worse behaviour than the rule predicts.

## Why the obvious repairs fail

Our results explain why two natural fixes do not work, and both explanations are general rather than specific to our implementation.

Matching draws on coherence fails because of a ceiling. Real gene sets reach mean inter-gene correlation an order of magnitude higher than any random draw of the same size, so no candidate pool exists to match from. Decomposing that coherence shows it is a median of 18% compositional, ranging from essentially none in native tissue programs to 80% in foreign ones, with genuine co-regulation accounting for the remainder.

Combining gene randomisation with sample permutation fails for a reason established by Maciejewski: such hybrids test the self-contained null, not the competitive one. We confirm this directly — a set with competitive p = 0.110 gave restandardised p = 0.003, tracking its nominal p of 5×10⁻¹³.

## What to use instead

Three dependence-aware methods were compared on the same data: CAMERA, ROAST, and rSEA's closed-testing procedure. **They do not agree.** In lung adenocarcinoma across 50 Hallmark sets, 38 are significant after Benjamini–Hochberg alone, 6 survive the empirical null, 9 survive rSEA's competitive test, and only 4 survive both. CAMERA agreed with the empirical null on 90 of 99 tests with no contradictions in either direction.

The honest summary: Benjamini–Hochberg alone retains 38 of 50; any dependence-aware method retains 6 to 9; which 6 to 9 depends on the method. We do not resolve that disagreement and do not recommend one method over the others.

## Limitations

*[WRITE THIS SECTION YOURSELF — see the what-didn't-work list below for content.]*

## The biological finding

*[PAPER A HAS ITS OWN DISCUSSION. If combining into one STS report, this is where native lineage loss goes.]*

---

# WHAT DIDN'T WORK (factual list — include this section)

Few papers include one. It is the strongest available evidence of how the work was done.

**1. The ROAST small-set claim — retracted.** Simulation suggested `limma::roast` over-rejects for gene sets below about 150 genes (type I error 0.225 at m = 30). Gordon Smyth, the method's author, responded that roast controls type I error correctly at all set sizes. Real data agreed with him: ROAST rejects *more* for large sets than small ones. The claim was withdrawn.

**2. Three simulation designs produced spurious results.** The first induced correlation with a single latent factor affecting all genes equally, making the tested set and background equally correlated — a case with nothing for a competitive test to correct. The second held inter-gene correlation fixed while varying set size, a combination that does not occur in real data. The third produced the retracted ROAST result. **All final numbers in this paper come from real expression data.**

**3. A variance correction — withdrawn.** Rescaling the within-split null to the observed across-split spread appeared to restore calibration. It collapses to the nominal self-contained test, which is the test whose failures motivated the work.

**4. Variance-inflation rescaling — failed.** No exponent of the CAMERA variance inflation factor restored calibration; two cells needed heavy correction and two were broken by any. Decisively, the VIF predicts spread ratios of 1.15–4.05 where measured ratios are 0.93–1.17.

**5. A real-set null — infeasible.** Of 1,195 Reactome sets, only 15 match the lung program on both size and coherence; 7 match E2F targets. A null distribution needs 60 or more.

**6. Coherence as the mechanism — not supported.** Mean inter-gene correlation correlates with type I error at only 0.14. Liver, at ρ = 0.041, shows type I error of 0.267; lung, six times more coherent, shows 0.100.

**7. Four candidate mechanisms for the biological finding — none supported.** AMPK signalling is measurably impaired (ACACA S80, p = 0.034) but shows no evidence of mediation (3.6% coefficient shift). An apparent SIK mediation disappeared after adjusting for proliferation (p 0.0003 → 0.075). The SIK–CRTC–CREB axis showed no attenuation with either of two target sets. MARK, NUAK, BRSK and SNRK family scores were confounded with proliferation and uninterpretable.

**8. The survival version of the rule does not transfer.** Across three cohorts the observed floors were 3.19, 1.76 and 3.10 against predictions of 2.97, 2.52 and 1.74 — the ordering is wrong. `sep_index_surv` reports the separation statistic only.

**9. A causal test was attempted and was not possible.** GSE6135 provides LKB1 re-expression in two lung lines, but A549 carries a nonsense mutation and still transcribes mutant mRNA, leaving 4 versus 2 samples in the one usable line.

**10. The protein-level null is unexplained.** Four principled explanations were tested and rejected: ratio compression (genome-wide slope 0.988), low power (predicted effect −0.303, observed +0.133), detection bias (missing genes *less* changed, p = 0.107), and poor mRNA–protein coupling (lung genes 0.613 vs background 0.532). Reported as a genuine discordance.

---

# FIGURE SPECIFICATIONS

**Figure 1 — The regime map.** `regime_map_all.rds`.
x: median |t| (log scale). y: median standardised floor (log scale). 14 points, labelled by cohort. Overlay the fitted power law and a horizontal dashed line at 1.96. Add the random-grouping floors as open grey circles near the line. **One panel showing that inflation is predictable and that random groupings sit at theory.**

**Figure 2 — Bigger studies are worse.** `size_curve_2.rds` plus the LUAD curve.
x: n (60, 120, 250, ~500). y: median floor. Three lines for LUAD, BRCA, COADREAD. Dashed line at 1.96.

**Figure 3 — The attrition.** `regime_map_all.rds`.
Stacked or slope chart: for each of 14 cohorts, BH-significant → Tier 1 surviving → rSEA surviving. Annotate BLCA (0% failing) and HNSC (88.5%).

**Figure 4 — The coherence ceiling.** `coherence_decomposition.rds` plus random draws.
Horizontal bars: 14 real programs by mean inter-gene correlation, with a vertical line at 0.021 marking the random-draw maximum. **Shows why matching is impossible, in one image.**

**Figure 5 — Native lineage loss.** `native_all_cohorts.rds`.
Forest plot: 13 cohorts, β with 95% CI, vertical line at 0. Order by effect. Mark the six pre-registered held-out cohorts.

**Supplementary:** driver specificity forest plot · master regulators by cohort · purity strata · the Travaglini replication · GSE72094 and CPTAC replication.

---

# METHODS SCAFFOLD — write the prose yourself

Each subsection needs three things: **what you did, why it matters, what rule decided it.**

**1. Data.** TCGA PanCancer Atlas via cBioPortal, 15 cohorts. GTEx v11 (54 standard tissues, 14 LCM pilot excluded). Human Protein Atlas v25.1. MSigDB Hallmark, Reactome, GO:BP, C8. MCP-counter and xCell marker sets. GDC ABSOLUTE purity (UUID 4f277128). TCGA-CDR Supplemental Table S1. GSE72094 (Affymetrix GPL15048, 442 samples). CPTAC LUAD via LinkedOmics (110 tumours, RNA + proteome + phosphoproteome, 109 with mutation calls). DepMap 22Q2.

**2. Signature reproduction.** 30 genes, log2(RSEM+1), within-cohort z-score, weighted sum. Five legacy symbol mappings (PHF17→JADE1, GPR110→ADGRF1, MOSC1→MTARC1, C6orf176→LINC00473, C21orf125→LINC00319); two are lncRNAs a protein-coding filter silently drops. Validated against published within-cohort AUROCs: seven exact to three decimals, STAD 0.910 vs 0.904, COADREAD 0.707 vs 0.703.

**3. Lineage programs.** MSigDB C8 pre-specified, failed a coverage audit, switched to HPA v25.1. Specificity gate: each program must rank first in its own GTEx tissue; margin below 2.0 triggers inspection with one of four named dispositions. Five contamination sources — immune leakage, immunoglobulin segments, squamous cross-reactivity, motile cilia, stromal markers — one sentence each here, full detail in supplement. 14 scoreable programs. Three exclusions on a stated principle (lymphoid, bone marrow, testis).

**4. Pre-registration.** Twelve dated amendments. Four rule-generated cohort exclusions (SARC, SKCM, OV, CESC non-squamous). The masking rule, which fired identically three times. The missing-data rule: remove whichever costs less, keeping ≥28 of 30 signature genes — applied to STAD (36 samples dropped), COADREAD and UCEC (2 genes dropped), and PRAD (932 genes dropped). **Say explicitly: the rule was applied, not waived, including where it cost a cohort** (GSE65858 at 26/30).

**5. Controls and covariates.** Tier 1: 100 random sets per program matched on size and GTEx expression decile, 13,632-gene universe, seed 20260922. Tier 2: six Hallmark programs, immune-purged and lineage-shared-purged, entered as PC1. Covariates: ABSOLUTE purity, fibroblast, endothelial, adipocyte. Proliferation added as a fixed covariate from 2026-09-27 onward, after it was found to confound the phosphosite analyses.

**6. The plasmode design.** Real TCGA expression with random sample splits, so the null is true by construction and no distributional assumption is made. **Explain that this was adopted after three synthetic designs produced results that did not survive scrutiny, and that all final numbers come from it.**

**7. Statistical detail.** Permutation p-values as (b+1)/(n+1), per Phipson and Smyth — a correction applied after the error was found. Monte Carlo standard errors on every simulated rate. Benjamini–Hochberg within analysis families. Every result labelled confirmatory (pre-registered), amended (with date), or post hoc.
