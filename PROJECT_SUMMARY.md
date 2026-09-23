# Project summary — 23 September 2026

Author: Happy Minocha
Repository: github.com/Sigma-dev-gif/lkb1-lineage-calibration

---

## 1. The original question

Does loss of LKB1 (STK11) function relax lineage constraint in cancer — do LKB1-deficient tumours express transcriptional programs belonging to cell lineages foreign to their tissue of origin, across cancer types?

**Origin.** Prior own work found STK11-mutant lung adenocarcinoma shows elevated neuroendocrine and hepatocyte programs, replicated in TCGA LUAD and GSE72094. Mouse models show Lkb1 deletion drives adeno-to-squamous transition. Whether this generalises had not been tested.

**Enabling tool.** Bandyopadhyay & Gordan (bioRxiv 2026.07.23.740219) derived a 30-gene signature of LKB1 functional loss that identifies deficient tumours without STK11 mutation, expanding the analysable population ~3.7-fold. Their work covered prevalence, metabolic dependency and immune phenotype — not lineage.

**H1 (primary).** In LKB1-deficient tumours, lineage programs foreign to the tissue of origin are expressed at higher levels than in intact tumours of the same type.
**H2 (secondary).** The foreign programs engaged are non-random with respect to tissue of origin.

---

## 2. Data

| Source | Use |
|---|---|
| cBioPortal, TCGA PanCancer Atlas | RNA-seq (RSEM) for 15 cohorts; mutation and CNA status |
| GTEx v11 (GENCODE 47, 54 standard tissues) | Specificity gate for lineage programs |
| Human Protein Atlas v25.1 | Lineage program definitions (37 tissues → 14 scored) |
| MSigDB Hallmark | Tier 2 control programs |
| MCP-counter, xCell | Stromal marker sets (fibroblast, endothelial, adipocyte) |
| GDC PanCanAtlas `TCGA_mastercalls.abs_tables_JSedit.fixed.txt` | ABSOLUTE purity and ploidy |
| GDC TCGA-CDR Supplemental Table S1 | Histology for ESCA and CESC splits; sex |

**Cohorts.** Primary nine: LUAD 510, STAD 409→373, LUSC 481, HNSC 507, COADREAD 532, ESCA 181 (→ESCC 94 / EAC 87), BRCA 1,064, CESC 288→239, UCEC 515. Replication six (Part II only): KIRC 400, PRAD 493→460, LIHC 361, GBM 159, THCA 488, BLCA 406.

---

## 3. Design and its hard parts

### Instrument reproduction — passed
The 30-gene signature was reimplemented from scratch and validated against the source paper's within-cohort AUROCs. **All nine cohorts reproduce**: six matched to three decimals first pass (LUAD 0.889, LUSC 0.927, HNSC 0.822, ESCA 0.759, BRCA 0.786, CESC 0.862); UCEC 0.692 exact; STAD 0.910 vs 0.904 and COADREAD 0.707 vs 0.703 after the missing-data rule below.

### Lineage programs — five contamination sources found
MSigDB C8 was pre-specified but failed a coverage audit (no adult skin atlas; no adult reference for breast, cervix, endometrium, ovary, oesophagus, head and neck). Switched to HPA v25.1.

1. **Immune leakage** — purged with GO:0045321 (993 genes). The broader GO:0002376 was tested and rejected: it removed 45% of the lung program including SFTPA1 and CLDN18, canonical alveolar genes with immune annotations.
2. **Immunoglobulin segments** — 81/306 stomach and 141/857 intestine genes were IG variable regions from plasma cells. GO misses these entirely. Purged by gene-family pattern; stomach margin 0.94 → 1.81.
3. **Squamous cross-reactivity** — cervix could not be separated from vagina (margin 0.01). Merged into a 34-gene pan-squamous program (margin 4.19). A residual test asking whether cervix-minus-core still beat vagina failed at 0.08, so the distinction died on evidence.
4. **Motile cilia** — fallopian tube failed against testis (−1.20) on shared axonemal genes; a ciliary purge was attempted and still failed. Program dropped.
5. **Stromal contamination** — fibroblast, endothelial and adipocyte markers found inside lineage programs, including three endothelial markers inside the lung program. Purged from the programs rather than from the markers, so no gene sits in both a score and its own covariate.

**14 scoreable programs.** Excluded as non-lineage signal: lymphoid tissue, bone marrow (infiltrate), testis (cancer-testis antigen derepression).

### Cohort exclusions — all rule-generated before results
| Cohort | Reason |
|---|---|
| SARC | No cohort-level cell of origin; foreign set collides with its own contaminants |
| SKCM | No cutaneous melanocyte reference in either collection |
| OV | Tubal program failed the gate, leaving only the minority-origin hypothesis scoreable — every tumour of tubal origin would score its native lineage as foreign |
| CESC adeno + adenosquamous | Glandular native lineage unscoreable after the squamous merge |

### Missing-data rule
STAD 36 samples lacked 6 signature genes; COADREAD 173 and UCEC 346 lacked the **identical** 2,214 genes. Direct API query returned empty at status 200 — the values do not exist. NAs had propagated through `scale()` and `rank()` places NA last, silently depressing AUROC.
**Rule: remove whichever costs less, keeping ≥28/30 signature genes.** Completeness computed per cohort, not globally.

### Controls
- **Tier 1** — 100 matched-random sets per program, matched on gene count and GTEx expression decile, 13,632-gene universe, seed 20260922.
- **Tier 2** — six Hallmark programs, immune-purged then stripped of lineage-shared genes; entered as first principal component.
- **Covariates** — ABSOLUTE purity, fibroblast, endothelial, adipocyte, Tier2_PC1.

---

## 4. Primary result: H1 not supported

| | n | deficient | β | Holm p | attenuation | **Tier 1 p** |
|---|---|---|---|---|---|---|
| LUAD | 497 | 129 | 0.270 | 3.2×10⁻⁹ | −0.52 | **0.73** |
| STAD | 362 | 50 | 0.106 | 0.076 | 0.01 | **0.62** |

LUAD's composite is highly significant and survives Tier 2 adjustment, but matched-random gene sets produce an equal or larger effect in 73% of draws. Both sensitivity analyses (WT-only; ABSOLUTE "called" only) agree.

**The control did its job.** LUAD endometrium: nominal p = 6.9×10⁻⁶, BH p = 3.0×10⁻⁵, **Tier 1 p = 0.58**.

Hepatocyte both-versions analysis (pre-committed in Amendment 6): identical under purged and unpurged Tier 2 (β 0.746 vs 0.747). The confound the safeguard was written against did not materialise.

---

## 5. The false-positive rate, and CAMERA

Across 99 per-program tests in eight cohorts:

**43 significant after Benjamini–Hochberg. 28 of those 43 (65%) fail empirical calibration.** No result survives Tier 1 while failing BH.

Running limma's `camera()` on the same data:

| | Tier 1 fails | Tier 1 survives |
|---|---|---|
| CAMERA fails | 84 | 9 |
| CAMERA survives | **0** | 6 |

Zero contradictions; Spearman 0.74 between the two p-values. An established correction (Wu & Smyth, *NAR* 2012) agrees with the empirical procedure wherever it has an opinion.

**But CAMERA's estimated inter-gene correlation does not predict the empirical floor** (Spearman −0.19; full VIF −0.23). Two corrections agreeing on outcomes while disagreeing on the quantity said to drive them.

### Six survivors of 99, at 1,000 draws
| Cohort | Program | β | BH p | CAMERA p | Tier 1 p |
|---|---|---|---|---|---|
| HNSC | pancreas | 0.781 | 4.7×10⁻¹⁰ | 0.017 | 0.000 |
| HNSC | kidney | 0.694 | 2.8×10⁻⁹ | 0.025 | 0.000 |
| LUAD | pancreas | 0.899 | 1.1×10⁻²⁰ | 0.041 | 0.005 |
| HNSC | liver | 0.502 | 5.6×10⁻⁵ | 0.033 | 0.037 |
| STAD | thyroid | 0.627 | 7.7×10⁻⁵ | 0.043 | 0.041 |
| HNSC | intestine | 0.519 | 2.6×10⁻⁵ | 0.050 | 0.043 |

Attrition 99 → 43 → 15 → 6, perfectly nested. Three of six are borderline.

**HNSC survives purity stratification.** Deficient HNSC tumours have higher purity (0.57 vs 0.49, p = 5.4×10⁻⁴), but all four programs stay positive in all three purity terciles. Not an artifact.

### What the discordant nine show
CAMERA's disagreements track **set size, not correlation**: median m of 371 (both), 220 (Tier 1 only), 164 (neither), while ρ barely differs (0.048 vs 0.035). Every concordant survivor has m ≥ 297; nearly every discordant case has m ≤ 231. **Statable regime: CAMERA is conservative for small gene sets at low inter-gene correlation.**

---

## 6. Part II — pre-registered replication of the inflation observation

Four predictions were registered before the six replication cohorts were touched.

- **P1** (tumour-state splits ≈4, sex ≈2, in units of the coefficient's own SE): supported in the original eight (LKB1 4.15, genomic-only 4.01, WGD 4.02, sex 2.29). **Failed to replicate** in six new cohorts: WGD 2.52, sex 2.99 — the prediction reverses.
- **P2** (generality across scoring methods): **supported**. LUAD ssGSEA 7.68, GSVA 7.62, mean-z 6.55; HNSC 2.99 vs 3.53. Mean-z uses no ranks or KS statistic, so this is not an algorithm artifact.
- **P3** (mechanism is inter-set correlation): **failed**, r = 0.12 at one draw and 0.17 at twenty. Reported as unexplained.
- **P4** (replication): **failed**, see P1.

**One of four holds.**

Other explanations tested and failed: sample size (R² = 0.09), global group separation (r = 0.61, contradicted by BRCA vs LUAD). Best current candidate: background DE density, R² = 0.57 with clear counterexamples — suggestive, not established.

### The control that reframed everything
On a **random 50/50 split** of LUAD, nominal and empirical p-values agree closely and the standardized floor is **1.50**, below the theoretical 1.96. There is no inflation intrinsic to gene-set scoring; it appears only when the grouping variable tracks something real. This control should have been run first. It was run last.

---

## 7. Literature audit — five papers

Adoption curve from PubMed: 2 (2019) → 138 (2022) → ~100/year since; 518 total.

| Paper | Score as tested variable | Correlation correction | Multiple testing |
|---|---|---|---|
| PESSA, *PLoS Comput Biol* 2024 (tool) | 13,434 sets × 238 datasets × 51 cancers | None | None reported |
| Glycolysis/CLN6, *Acta Biochim Biophys Sin* 2026 | Cox across Hallmark sets | None | None |
| Sarcoma six-gene, *Aging* 2024 | Hallmarks scanned against OS | None | None reported |
| STAD amino-acid, *Int Immunopharmacol* 2024 | 29 immune scores, 26 significant | None | None |
| CRC stemness, *Stem Cell Res Ther* 2022 | 26 Cox tests → 13 retained | None | None |

PESSA and CRC stemness both use optimal-cutpoint dichotomisation, a second and separately documented inflation source. The CRC stemness paper reports correlations *among* its 26 scores in a supplementary figure and still does not account for them.

Claim phrased as "no correction is reported," not "none was applied."

---

## 8. Simulation — and a problem with the method

**Grid 1** (120 cells, 200 reps): Tier 1 calibrated near nominal under the null; CAMERA rejected 0% whenever ρ > 0. But correlation was induced by a single latent factor affecting all genes equally, so the set and the background were equally correlated — a case with nothing for a competitive test to correct. The design, not CAMERA, produced that result.

**Grid 2** (24 cells, block-structured correlation): the important result, and it goes against the method.

**Tier 1 is anti-conservative when the tested set is more internally correlated than the random sets it is compared against.** At background ρ 0.05 and set ρ 0.15: type I error **0.125 at m = 250** and **0.255 at m = 900**, against nominal 0.05. The inflation grows with set size.

Mechanism: Tier 1 matches on size and expression decile but **not on internal coherence**. Real gene sets are coherent by construction; random matched sets are not. The null is built from less-correlated sets than the one being tested, so it is too narrow.

This is precisely the problem CAMERA was built for, and why CAMERA estimates ρ from the actual set rather than from random draws.

**Consequence.** The 65% attrition figure stands — those findings failed a null that was, if anything, too easy to beat. But "empirical calibration is the remedy" does not stand as written. The procedure has a calibration failure of its own.

**In progress:** a corrected Tier 1 that matches candidate draws on internal correlation as well as size and expression. If it removes the inflation, the contribution becomes an improved method rather than a critique — and the flaw was found by the author, in simulation, before anyone else.

---

## 9. Relation to prior work

No discovery claim. Inter-gene correlation inflating gene-set statistics was characterised by **Wu & Smyth (CAMERA, *NAR* 2012)** and refined by **QuSAGE (2013)**. The contribution is demonstration and quantification in a workflow where the correction is routinely omitted, plus the CAMERA set-size regime, plus a tool.

---

## 10. Limitations

- H1's null result does not exclude lineage effects below the detection floor.
- ESCC contributes nothing: excess functional loss 5.0, exactly the floor; pre-registered MDE d ≈ 1.0.
- Prevalence estimates differ from the source paper by 1–3 points because thresholding conventions are unspecified there; AUROC, which is invariant to them, does reproduce.
- Part II's central observation is post hoc; three of four pre-registered follow-ups failed.
- Mechanism unexplained.
- **Tier 1 is anti-conservative for internally coherent sets** (§8) — the most serious open issue.
- Single data source (TCGA), single gene-set collection for the primary analysis.
- Tier 1 p resolution is 0.01 at 100 draws.

---

## 11. Outstanding work

1. Finish and validate the correlation-matched Tier 1.
2. External validation outside TCGA (recount3, METABRIC, CPTAC, ICGC); second gene-set collection.
3. Package `calibrate_geneset()` with tests, vignette and documentation.
4. Paper draft → preprint → submission. Target depends on whether the simulation establishes the CAMERA regime as general; NAR Genomics and Bioinformatics or Bioinformatics Advances realistic, PLOS Computational Biology a reach.
5. Find a mentor with a computational biology lab — needed for a corresponding author and for an independent letter.
6. STS report, written fresh from the paper.
