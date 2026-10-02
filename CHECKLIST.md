# Remaining items
Updated 2026-09-27 (evening) · supersedes the earlier 50-item list

**The arc:** a failed pre-registered hypothesis exposed a statistical problem; the corrected analysis revealed native lineage loss; the project produced a rule and a tool that predict when gene-set results can be trusted.

**The concrete thing** (the equivalent of other finalists' tool or count): **the separation rule** — floor ≈ 2.37 × (median |t|)^1.38, validated across 25 cohort-grouping combinations, shipped as `sep_index()`. A one-number check, computable before any gene-set test, that says whether the analysis is in the danger zone. Plus the counterintuitive consequence: **bigger studies are worse.**

---

## TIER 1 — these decide the outcome

- [ ] **1. Write the paper.** One STS report, one arc. Nothing else on this list matters as much.
  - [x] Introduction drafted (PAPER_SECTIONS.md) — **needs your origin paragraph**
  - [x] Discussion drafted — **needs your limitations section**
  - [x] "What didn't work" section drafted (10 items)
  - [x] Figure specifications written (5 figures + supplementary)
  - [ ] **METHODS — yours to write.** Scaffold in PAPER_SECTIONS.md
  - [ ] Results section — write after the figures exist
- [x] **2a. `verify.R` written and confirmed** — reproduces β −0.0507, median |t| 2.350, floor 7.02 vs random 1.37
- [ ] **2b. Independent rerun by another person** on a clean machine
- [ ] **3. The Gordan experiment.** Re-express LKB1 in LKB1-null cells, measure native lineage genes. The only causal evidence available. Blocking action: schedule the meeting; have a figure ready.
- [x] **4a. Census protocol written** (CENSUS_PROTOCOL.md) — **timestamp on OSF before screening**
- [ ] **4b. Run the census.** 10–15 exactly reproducible papers
- [x] **5a. Literature search done.** No prior rule predicting floor from a transcriptome-wide statistic. **Closest parallel: polygenicity-driven inflation in TWAS (AJHG 2026) — must be cited.** Novelty is narrower: new *for gene-set testing*, not as a general idea.
- [x] **5b. Prospective test on GSE72094** — predicted 3.66, observed 4.67. Correct regime, ~20% under-prediction.
- [ ] **5c. More platforms** if time allows
- [ ] **6. Defend everything cold.** Explain every choice without notes. Check STS rules on AI disclosure and state your AI use plainly in the report.

### Census inclusion criteria — write and timestamp on OSF BEFORE screening any paper
1. **Grouping** unambiguous: mutation status, a named clinical variable, or a published sample list.
2. **Data** public: TCGA or GEO with accession numbers.
3. **Scoring method** named with enough detail to implement (method, gene sets, version).
4. **Test** identifiable from the methods section.
5. **Success check:** their reported nominal result reproduces to a stated tolerance *before* any calibration is applied.

**Criterion 5 is what makes it defensible.** A paper you cannot match is **excluded**, not counted as a failure.

---

## TIER 2 — new findings that would materially strengthen it

- [ ] **7. DNA methylation as the mechanism.** Kottakis et al., *Nature* 2016 linked LKB1 loss to increased DNA methylation via serine metabolism. TCGA has methylation for these cohorts. **Pre-register one prediction:** lineage-gene promoters are more methylated in LKB1-deficient tumours. Principled, with prior literature — unlike the kinase family scores.
- [x] **8. Lineage master regulators — DONE.** 25 of 32 negative, 22 after BH. CDX2 −0.367, NKX2-1 −0.065, TP63 −0.219. Not independent of the program analysis; report as a readable subset.
- [ ] ~~8b~~ NKX2-1 (lung), SOX2/TP63 (squamous), CDX2 (intestine). If the master regulator falls with LKB1 loss, "native loss" becomes concrete and explainable in one sentence.
- [x] **9. Pathology grade — DONE.** HNSC ρ −0.459 (p 4.5×10⁻²⁶); LKB1-vs-grade +0.222 surviving adjustment. **KIRC reverses** (−0.102, p 0.003). LUAD/COADREAD/BRCA have no grade field.
- [ ] ~~9b~~ TCGA records tumour grade and histologic pattern. If native loss tracks pathologist-graded poor differentiation, it is validated against something independent of expression.
- [x] **10. Stemness — DONE.** BENPORATH_ES absorbs ~15%; **85% survives**. Not a renamed stemness signal.
- [ ] ~~10b~~ Compare against the TCGA stemness index (Malta et al., *Cell* 2018), so nobody can say it is a known signal renamed.
- [x] **11. Protein null — DONE, and it is NOT explained.** Four checks all clean: compression slope 0.988, predicted −0.303 vs observed +0.133, missing genes less changed, lung genes better coupled (0.613 vs 0.532). Report as genuine discordance.
- [ ] ~~11b~~ Check mRNA–protein correlation for lineage genes in CPTAC. If these genes correlate poorly in general, the null is expected rather than contradictory.
- [x] **12. Hormone hypothesis — DONE, NOT SUPPORTED.** THCA function genes rise (TSHR +0.171), NKX2-1 alone falls (−0.265). PRAD incoherent. **The reversal stands unexplained.**
- [x] **13. HNSC discrepancy — RESOLVED.** Down-portion 50% at p<0.05 vs 34.1% background, only 30 genes. Direction differs sharply (−1.58 vs +0.68), proportion barely. The two tests measure different things.
- [ ] **14. Derive the separation rule theoretically.** Why does the floor scale with median |t| to roughly the 1.4 power? Theory plus data beats a fitted curve.
- [x] **15. Effect sizes — DONE.** Deficient vs intact in SD: LUSC −0.62, LUAD −0.50, CESC −0.47, COADREAD −0.43, HNSC −0.25, BRCA −0.15.

---

## TIER 3 — credibility

- [x] **16. Test ledger written** (TEST_LEDGER.md) — confirmatory / amended / post hoc, plus 9 withdrawn claims and 4 self-corrections
- [ ] **17. Power and equivalence bounds for every important null** — STAD, the protein level, the mechanism tests.
- [ ] **18. Statistician review of the code**, ideally through Gordan's network.
- [ ] **19. Preprint, then journal submission.**
- [ ] **20. Submit `gscalibrate` to Bioconductor.**
- [ ] **21. Present once** before the application, to practise defending it.
- [ ] **22. Two recommendation letters** — Gordan, and a teacher who knows the work.

---

## TIER 4 — the application

- [x] **23a. Figure specifications written.** Data files named for each.
- [ ] **23b. Make the figures:** the attrition (43→15→6) · the coherence gap (0.245 vs 0.021) · the regime map with the rule · native loss across cohorts · the experiment
- [ ] **24. A one-sentence headline that is exactly true.**
- [ ] **25. A plain-language "this could help" line.**
- [ ] **26. Essays** on the moment the control overturned your own results, and what you did next.
- [ ] **27. Interview prep** — general science problem-solving, plus the hardest questions about the project.

---

## EXPLICITLY SKIPPING

Single-cell · the Shiny app · immunotherapy response · more mechanism hunting in the same data · more cohorts beyond what validation needs · any new biological hypothesis not listed above.

Each costs time and adds false-positive risk without making the central claims harder to attack. The report has 20 pages; every addition takes space from what matters.

---

## THE STOPPING RULE

Before adding anything: **does this make the central claim harder to attack?** If yes, add it. If it only adds another result, skip it.

---

## WHERE FURTHER IMPROVEMENTS COME FROM

Not from more analysis. Once a draft exists:
- **Gordan** — the biology
- **A statistician** — the methods
- **A smart non-expert** — clarity
- **One adversarial reader** — whose only job is to find the weakest claim and attack it

**Their objections are the real remaining to-do list.**

---

## THE TARGET WRITE-UP

With the Gordan experiment:
> Joel Minocha, 17, created a simple test that tells cancer researchers when their results may be false. A popular method compares the activity of gene groups between tumours, and Joel discovered that it fails more often in larger studies, not less. He found a rule that predicts how badly it will fail from information researchers already have, built software that flags at-risk analyses, and used it to check published studies. While testing an idea about how cancers lose the tumour-suppressor gene LKB1, he found the opposite of what was expected: many tumours lose their own tissue identity, a result he confirmed in the lab.

Without it, end at "...lose their own tissue identity across seven cancer types."
