# Research log

Running record of decisions and reasoning. One entry per working session.
Record *why*, not just *what* — the commands are in R history, the reasoning isn't.

---

## 2026-09-20 — Environment setup and reproduction gate

### Environment
- 2019 Intel MacBook Air, macOS Monterey 12.6.3, 16 GB RAM. Constrains software versions.
- R 4.4.1 + RStudio 2024.09.1+394 — the pair Posit certifies for macOS 12. Installed R 4.6.1 first, then downgraded: current RStudio needs macOS 14, and the certified pairing for this OS is 4.4.1. Nothing in this analysis needs 4.6.
- Bioconductor 3.20, org.Hs.eg.db, arrow.
- Cloned github.com/souravUCSF/lkb1-functional-loss.

### Gene symbol mapping
Five of the 30 signature genes carry legacy symbols in the authors' CSV. Mapped via org.Hs.eg.db ALIAS→SYMBOL:
PHF17→JADE1, GPR110→ADGRF1, MOSC1→MTARC1, C6orf176→LINC00473, C21orf125→LINC00319.

**Why this matters:** the discovery matrix uses *legacy* symbols; the cBioPortal API uses *current* ones; the paper's Figure S1 uses current. No source is "correct." Matching the wrong convention would silently drop 5/30 genes with no error and produce plausible but wrong scores. Saved both columns to `lkb1_signature_mapped.csv`.

LINC00473 and LINC00319 are lncRNAs — flagged as at risk of being filtered out of protein-coding-only matrices in other cohorts. Present in LUAD discovery and in cBioPortal LUSC.

### Units and scale
- `luad_expr_discovery.parquet`: 232 × 20,512, values 0–~7 with many exact zeros → log2(RSEM+1), matching the paper's Methods.
- STK11 median 9.982 across all 232 discovery samples; paper reports 10.03 for WT-only. Lower here because the 55 genomic-loss cases are included. First verification against a published number.
- `derive_signature.py` pipeline starts with `StandardScaler()`, so coefficients are weights on **standardized** expression, not raw log2 RSEM. Scoring must z-score each gene within cohort first.
- Their fetcher pulls `_median_Zscores` but that's for the 7-gene co-mutation panel only. For signature scoring use the raw `_rna_seq_v2_mrna` profile (datatype CONTINUOUS) and transform yourself — using their z-score profile would standardize already-standardized data against a different reference.

### Offline reproduction: external cohorts
Computed AUROC from committed `external_luad_scores.parquet` using `genomic_loss` as label:
- CAS 0.9694 (published 0.969)
- CPTAC 0.9247 (published 0.925)
- OncoSG 0.9796 (published 0.980)

Sample counts 51/110/169 match the paper. SU2C-MARK absent from this file (came from Zenodo separately), hence 330 rows not 398.

**What this establishes:** their committed scores reproduce their published AUROCs, and my AUROC implementation is correct against three independent published values. **What it does not establish:** that my scoring code reproduces their scores — these are their `sig_score` values, not mine.

### Rejected check
In-sample AUROC on the 232 discovery samples came out 0.9997. Discarded as meaningless: the final model was fit on exactly those samples, so near-perfect separation is guaranteed by construction. Confirms code runs and signs are right; no evidence about signature performance.

Spearman 0.848 between my linear scores and their OOF probabilities. Not a failure — OOF values are probabilities from five different fold models and saturate near 1 (observed range ~0.87–0.98), so rank correlation against an unbounded linear score is expected to fall short of 1.

### Reproduction gate: LUSC — PASSED
Independent end-to-end test on a cohort the model never trained on.

Pipeline: resolve 30 current symbols → Entrez via `/genes/fetch` (all 30 resolved); pull `lusc_tcga_pan_can_atlas_2018_rna_seq_v2_mrna` (14,520 rows = 30 genes × 484 samples, raw RSEM); reshape wide; log2(x+1); `scale()` within cohort; multiply by coefficients.

**AUROC 0.9268 vs published 0.926.**

7 genomic-loss cases, matching `n_genomic_loss` in the prevalence table.

### Amendment 1 to pre-specification (2026-09-20)
**Analysis set = mRNA sample list ∩ sequenced sample list, per cohort. Counts reported per cohort.**

Discovered when 3 samples produced NA labels. Investigation: LUSC mRNA list = 484, sequenced list = 484, **intersection = 481**. Three samples have RNA but no mutation calls (TCGA-56-8623-01, TCGA-66-2737-01, TCGA-98-A53D-01); three different samples have mutation calls but no RNA (TCGA-34-2604-01, TCGA-34-2605-01, TCGA-34-2609-01). Equal counts are coincidence — easy to assume the lists are identical because 484 = 484.

The authors evidently made the same intersection without stating it. Prevalence denominators depend on this, so it must be reported.

### Open items
- [ ] Verify the intersection rule per cohort before scoring each one.
- [ ] Confirm whether lncRNA signature genes survive in non-lung cohorts (gene recovery rule: exclude cohort if <28/30 present).
- [ ] Appendix A of pre-spec: native lineage designations per tumor type. Not yet started.
- [ ] Set bioRxiv/PubMed alerts for STK11, LKB1.
- [ ] Decide purity source (ABSOLUTE vs CPE) and obtain it.

---

## 2026-09-21 — Gene set collection audit

### C8 audit (msigdbr 26.1.0, collection C8)
866 sets, 20,573 genes. 818 sets clear the 15-gene minimum, so that floor barely binds. Max set size 1,771 genes — **open question: an upper bound is probably needed, since a 1,771-gene set is not a cell identity program. Decide the number before seeing which sets it removes.**

Contributing studies by set count: DESCARTES 247, HE 126, TRAVAGLINI 54, FAN 50, BUSSLINGER 38, GAO 32, AIZARANI 31, ZHONG 31, LAKE 30, GAUTAM 29.

**Adult-only rule applied** (fetal programs in adult tumours are a different hypothesis than transdifferentiation to another adult lineage — *why I set it this way: [your words]*). DESCARTES and HE are both fetal, removing 373 of 866 sets.

What survives for the confirmatory cohorts:
- LUAD native → `TRAVAGLINI_LUNG_ALVEOLAR_EPITHELIAL_TYPE_2_CELL` (+ `..._SIGNALING_ALVEOLAR_EPITHELIAL_TYPE_2_CELL`; same cell type, functional state)
- LUSC native → `TRAVAGLINI_LUNG_BASAL_CELL`
- STAD native → BUSSLINGER adult gastric sets (pit, isthmus, chief, neck)
- COADREAD → only `GAO_LARGE_INTESTINE_ADULT_*`, seven sets, **no adult enterocyte set**. Weak native designation.

**Open:** whether AT1 is masked in LUAD. AT2 differentiates into AT1 during repair, so an AT1 program is arguably within-lineage — same logic as neural crest in SKCM. *My call and why: [your words]*

### SKCM excluded — the rule fired again
C8 contains **no adult skin atlas**. No keratinocyte, epidermis or Reynolds sets. The only melanocyte sets are `GAUTAM_EYE_*` (choroid, cornea, iris) — ocular melanocytes, which differ from cutaneous melanocytes in biology. SKCM is cutaneous melanoma, so there is no defensible native reference.

Excluded under consequence 3 of the Appendix A rule (candidate native set cannot be bounded / no valid native available). Second rule-driven exclusion after SARC. The neural crest masking analysis and trajectory boundary become moot.

Also absent from C8 adult coverage: breast, cervix, endometrium, ovary, esophagus, head and neck. C8 supports roughly four of twelve cohorts.

### Collection decision changed: C8 → HPA primary
C8's uneven coverage — flagged in the pre-spec as its known weakness — turned out to be disqualifying for two thirds of the cohorts. Reversed the primary/replication ordering.

**HPA version 25.1**, `proteinatlas.tsv`, 20,162 genes × 119 columns. Version pinned.

`RNA tissue specificity` classes: Tissue enriched 3,132; Tissue enhanced 6,356; Group enriched 1,547; Low tissue specificity 8,096; Not detected 1,031.

**Tissue enriched alone is too small.** Per-tissue set sizes: lung 17, breast 19, esophagus 18, ovary 5, endometrium 3, stomach 36, intestine 123. Ovary and endometrium fail the 15-gene minimum outright; lung, breast and esophagus barely clear it. Structural, not a quirk: "enriched" requires ≥4× higher expression than every other tissue, so tissues sharing biology with others have almost nothing unique. Testis gets 932 because it is transcriptionally exceptional; lung gets 17.

**Decision: pool Tissue enriched + Tissue enhanced + Group enriched.** Approximate per-tissue counts then: lung 96, esophagus 290, cervix 205, ovary 86, intestine 681, skin 268. All clear the minimum.

Cost accepted: "enhanced" is a weaker claim than "enriched," and "group enriched" genes are shared across several tissues by definition — the same shared-machinery problem already flagged for gastric/intestinal and pan-neuronal/CNS. Specificity is therefore not assumed; it is tested (below).

*Note:* the counts above parse one tissue per gene, which is wrong for group-enriched genes that list several. Redo the parse properly when building sets.

### GTEx specificity check — threshold still open
Set construction rule: pooled three classes, group-enriched genes assigned to **every** tissue they list, then filtered by discrimination against normal GTEx tissue.

Proposed threshold AUROC ≥ 0.80 for a program to separate its own normal tissue from the tissues it will be scored against. Rationale: 0.7 is conventionally weak; 0.9 might fail shared-machinery pairs that are still usable.

**Not yet fixed.** Plan: run the test on a few pairs, inspect the distribution of discrimination values, then fix the threshold and record that the distribution was inspected first. This is deliberately not the same as tuning the threshold to obtain a wanted result, and the log should show the ordering.

### Next session
1. Build HPA sets from pooled classes, handling multi-tissue group-enriched assignments correctly.
2. Obtain GTEx median expression by tissue.
3. Run discrimination on a few pairs → inspect distribution → fix threshold → apply → record which pairs drop.
4. Update Appendix A: final set membership as **explicit gene lists**, not prose descriptions.
5. Record the C8 → HPA collection change as a dated pre-spec amendment, with the coverage audit as the reason.

### Still open from before
- [ ] Upper bound on set size.
- [ ] AT1 masked in LUAD?
- [ ] Schwann cell precursor boundary — now moot if SKCM stays excluded.
- [ ] bioRxiv/PubMed alerts for STK11, LKB1.
- [ ] Purity source: ABSOLUTE vs CPE.

## 2026-09-21 (cont.) — HPA set construction and GTEx specificity gate

### Sets built
Pooled Tissue enriched + Tissue enhanced + Group enriched from HPA v25.1. Group-enriched genes assigned to **every** tissue listed in `RNA tissue specific nTPM` (semicolon-separated `tissue: nTPM`). Numbered tissue labels (`skin 1`, `stomach 1`, `endometrium 1`) stripped — no `stomach 2` exists to distinguish from.

Result: **37 tissues, all ≥15 genes.** Saved as `hpa_tissue_sets_v25.1.rds`.

Note: skin now has 604 genes, where C8 had no adult skin atlas at all. **Do not silently reverse the SKCM exclusion on this basis** — HPA gives skin *tissue*, not cutaneous melanocytes, which is not obviously the missing reference. Revisit deliberately or leave excluded.

### GTEx reference
**GTEx V11**, `GTEx_Analysis_2025-08-22_v11_RNASeQCv2.4.3_gene_median_tpm.gct.gz`, GENCODE 47. 74,628 genes × 68 tissue columns. Version pinned.

Programs scored as mean log2(median TPM + 1) across member genes.

### LCM columns excluded
V11 added laser-capture microdissection pilot columns. These behaved as artifacts: `Liver_Portal_Tract` ranked second for lung, intestine, pancreas **and** kidney — one column placing second for four unrelated programs is a property of the column, not of lineage biology. `*_Mixed_Cell` columns behaved similarly.

Removed 14 LCM columns, leaving **54** — matching GTEx's documented 54 standard tissue sites, which is independent confirmation the right ones were dropped.

`Esophagus_Mucosa` and `Esophagus_Muscularis` were **retained**: standard GTEx sampling sites since V8, not LCM. A name-pattern match over-removed them; caught by inspection.

*Verify against V11 sample annotations rather than names before publication.*

### Whole tissue, not mucosa
Whole-tissue columns used throughout rather than mucosa columns, for cross-tissue comparability — mucosa columns exist only for some tissues and mixing makes tissues non-comparable. Mucosa retained as a stated sensitivity option.

### Specificity results (54 standard columns)
14 of 15 tested programs rank 1 in their own tissue. Margins over nearest other tissue:

testis 3.44 · liver 2.70 · pancreas 2.49 · prostate 2.41 · lung 2.19 · ovary 1.91 · kidney 1.76 · skin 1.69 · intestine 1.37 · esophagus 1.14 · stomach 0.93 · endometrium 0.64 · breast 0.51 · cervix 0.01 · **vagina −0.35 (fails)**

Lung — the anchor cohort's native program — scores 5.35 vs runner-up 3.16, 188/192 genes recovered. Clean.

**No natural gap in the distribution.** Failures cluster by *cause*, not by margin, which is why a single numeric cutoff is the wrong instrument.

### The gate (fixed before any tumour data examined)

**Hard gate:** program must rank 1 in its own tissue.

**Flag threshold: margin < 2.0 triggers inspection.** Non-exclusionary — flagging means "look," not "drop." Set at 2.0 rather than 1.5 because 1.5 would land immediately below kidney (1.76) and skin (1.69), two cases labelled "genuinely specific" by eye without inspection; a threshold sitting just under one's own eyeballing confirms the eyeballing instead of testing it. Over-flagging costs a paragraph; under-flagging costs a missed confound.

Flagged set: cervix, breast, endometrium, stomach, esophagus, intestine, skin, kidney (8/15).

**Every flag gets one of four named dispositions, closed before scoring:**
1. **Masked** — documented non-neoplastic lineage change (stomach/colon)
2. **Merged** — programs demonstrably don't separate (squamous cluster)
3. **Covariate** — composition, not identity (breast/adipose)
4. **Cleared, reason recorded** — inspection found no mechanism

"Cleared" must remain a real option with written reasoning, or flagging becomes soft exclusion and this is a hard cut with extra steps.

**The threshold and all dispositions were set on GTEx normals with no tumour data examined.**

### Squamous merge — tested, not asserted
Pan-squamous program = intersection of cervix, vagina, esophagus, skin sets. **38 genes.**

Test 1 — does it separate squamous from non-squamous? Esophagus_Mucosa 6.53, Skin_Sun_Exposed 6.22, Skin_Not_Sun_Exposed 6.19, Vagina 5.75, Cervix_Ectocervix 5.39, then a cliff to Minor_Salivary_Gland 2.13. Margin ≈3.3. **Largest clean separation observed anywhere in this analysis.**

Test 2 — does cervix-minus-core still beat vagina? Cervix_Ectocervix 4.199 vs Vagina 4.119, **margin 0.08** (from 0.01). No recoverable cervix-specific identity in this gene set. The distinction dies on evidence rather than judgment — which is the point of having run the test.

**Consequence, stated rather than discovered later:** LUSC, HNSC, ESCC and CESC-squamous all take pan-squamous as native. Those four cohorts collapse to one native category and their results become claims about glandular, neuroendocrine or mesenchymal foreign lineages only. **Squamous-to-squamous claims across them are gone.** Real loss, honestly taken.

The direction that survives is the one the project needs: a squamous program in LUAD remains scoreable, because glandular→squamous is a separation the data supports. Squamous transdifferentiation in LUAD is documented (adenosquamous histology; squamous transformation after EGFR TKI). The merge arguably strengthens that finding by making the claim "squamous" rather than "esophageal squamous," which was never defensible.

### Open dispositions

**Intestine beaten by Spleen (1.37) — the serious one.** This is immune-gene leakage in the intestine program. Not a tumour-specific artifact: the set carries immune genes and will score in **every** cohort it is applied to. Worse than breast/adipose, because immune infiltrate varies with purity, stage and outcome — a leaking lineage program can manufacture associations that look biological. **A covariate cannot repair a set whose membership is wrong.**

Disposition: purge immune-associated genes and re-test; then clear, merge or drop. **Generalise: test all 37 sets for immune leakage before scoring, not just intestine.**

**Endometrium beaten by Cervix_Endocervix (0.64).** No obvious home — not metaplasia, not composition. Merging would gut UCEC by fusing the native category with its nearest neighbour, leaving almost nothing foreign. Disposition: **cleared with reason recorded** — two Müllerian glandular epithelia, imperfect separation expected. Endocervical-program findings in UCEC are uninterpretable; other foreign lineages remain scoreable. *Named as a judgment call, not a derivation.*

**Breast beaten by Adipose_Subcutaneous (0.51).** Composition, not lineage confusion. Fat in a breast is not documented non-neoplastic lineage change, so the masking rule must not stretch to cover it — deconvolve and carry adipose fraction as a BRCA-specific covariate. Keeping masking and purity as separate mechanisms matters: a reviewer who sees the masking rule absorbing contamination problems will ask what else it absorbs.

**Skin (1.69) and kidney (1.76)** — flagged at the 2.0 threshold, inspection not yet done.

**Also noted:** endometrium's runner-up is endocervix and ovary's is fallopian tube — a Müllerian cluster with the same structure as the squamous one, touching UCEC, CESC and OV.

### Caution carried forward
GTEx normals are the easy case. Cross-reactivity in bulk tumours will be worse, not better. **Every margin here is an upper bound on the separation achievable downstream.**

### Next
1. Immune-leakage test across all 37 sets (running).
2. Inspect skin and kidney; close their dispositions.
3. Purge and re-test intestine.
4. Write final set membership into Appendix A as **explicit gene lists**.
5. Record C8 → HPA collection change as a dated pre-spec amendment.

## 2026-09-21 (cont.) — Immune purge and gate closure

### Ordering, stated honestly
The intestine/spleen flag revealed a general problem, not a local one. The remedy was therefore generalised to all sets, the full gate rerun, and the table reported as it came out. A remedy discovered mid-analysis and applied uniformly with everything rerun is defensible; applying it only to the sets that failed would not be. This history is the true one and is recorded as such.

### Immune programs dropped from the foreign-lineage space
Lymphoid tissue and bone marrow are excluded as scoreable foreign lineages across all cohorts. None of the twelve cohorts is hematologic, so these programs could only ever appear as foreign — and a high lymphoid score in a solid tumour measures tumour-infiltrating lymphocytes. That is an infiltrate claim wearing a lineage claim's clothes, and it would correlate with purity, stage and outcome in ways that look like a finding. Same justification as masking: a documented non-tumour source of signal that bulk data cannot separate.

They are also exempt from the purge and from the immune-gap criterion. **Not a carve-out** — the purge is defined as removing immune genes from *non-immune* programs, so the exemption is the definition applying. Same shape as the STAD/LUAD asymmetry: one rule, different consequences by tissue.

### Purge criterion — external, not data-driven
**This was nearly got wrong.** The first instinct was to build the immune gene list from the HPA lymphoid and bone marrow sets — i.e. from the same object being tested, derived from the same expression data. Improved margins would then have been partly an artifact of removing genes selected for being high in the tissues the programs cross-reacted with. Circular, and exactly the failure the gate exists to prevent.

Criterion used instead: **GO:0045321 "leukocyte activation," all descendants, via org.Hs.eg.db (Bioconductor 3.20). 993 genes.** External, citable, versioned, independent of expression data, applied blind to which sets it affects.

**GO:0002376 "immune system process" (2,967 genes) was tested and rejected.** It removed 45.3% of the lung set — the anchor cohort's native program — including SFTPA1, CLDN18, CTSH and EPAS1. Those are canonical alveolar identity genes that carry immune annotations because lung is an immunological organ. GO:0045321 spares SFTPA1, CLDN18, CTSH and EPAS1 while removing FGR, SPI1, TBX21, DOCK2 and LILRB2.

**Stated cost of the narrower term:** it under-removes. GZMB, CD68, CSF3R, MARCO and TLR8 are not annotated under leukocyte activation and survive the purge despite being unambiguously macrophage/NK genes. The term spares epithelial identity at the price of leaving some hematopoietic genes behind. This tradeoff is deliberate and should be presented as such, not as a clean solution.

### Immunoglobulin genes — the larger contaminant
Inspecting why stomach's runner-up became Minor_Salivary_Gland after the GO purge: the top 25 genes driving the overlap were almost entirely **immunoglobulin variable-region segments** (IGKV, IGHV, IGLV, IGKJ, IGHD) plus JCHAIN and LYZ.

GO misses these entirely — IG segments are structural gene segments, not annotated under leukocyte activation.

Scale (pattern `^IG[HKL][VDJC]|^IGH[ADEGM]|^JCHAIN`, 411 genes in GTEx):
stomach 81/306 · intestine 141/857 · breast 7 · esophagus 4 · cervix 2 · lung 2

A quarter of the stomach program and a sixth of intestine were measuring plasma-cell content. Gut-associated lymphoid tissue, as expected — and STAD is confirmatory. In tumours this varies with inflammation and infection status; *H. pylori*-associated gastritis alone would move the score.

IG genes added to the purge by **gene-family name pattern** — a structural criterion, external to the expression data, so no circularity reintroduced.

Effect: stomach margin 0.94 → **1.81**, runner-up Minor_Salivary_Gland → Small_Intestine. Intestine 1.46 → **1.80**, runner-up → Stomach. The two are now each other's nearest neighbour, which is the honest gastric–intestinal adjacency already anticipated in Appendix A, no longer buried under plasma-cell signal.

Urinary bladder recovered from rank 6 to rank 1 (margin 0.95).

### Final gate table (GO:0045321 + IG purge, 54 standard GTEx columns)
15/16 rank 1. Margins: testis 3.44 · lung 2.74 · liver 2.71 · pancreas 2.52 · prostate 2.38 · ovary 1.91 · stomach 1.81 · intestine 1.80 · kidney 1.75 · skin 1.68 · esophagus 1.15 · urinary bladder 0.95 · endometrium 0.63 · breast 0.50 · cervix 0.02 · **vagina −0.35 (fails)**

Saved: `hpa_sets_purged_v25.1.rds`, `gate_provenance.rds`, `gtex_specificity_final.csv`.

### All flags now have dispositions — gate closed
| Flag | Cause | Disposition |
|---|---|---|
| cervix 0.02, vagina −0.35, esophagus 1.15, skin 1.68 | squamous cross-reactivity | **merged** → pan-squamous (38-gene core; residual cervix test failed at 0.08, so no recoverable cervix-specific identity) |
| stomach 1.81, intestine 1.80 | gastric–intestinal adjacency | **masked** per Appendix A rule |
| breast 0.50 | adipose composition, not lineage | **covariate** (deconvolve, BRCA-specific adipose fraction). Masking rule must not absorb contamination problems |
| endometrium 0.63 | Müllerian glandular adjacency (endocervix) | **cleared, reason recorded.** Merging would gut UCEC by fusing native with nearest neighbour. Endocervical-program findings in UCEC uninterpretable; other foreign lineages remain scoreable. *Judgment call, named as one* |
| kidney 1.75 | shared gluconeogenic/P450 machinery with liver (G6PC1, PAH, CYP4F2, CYP4A11, EHHADH, SLC27A2) | **cleared, reason recorded.** Genuine shared physiology between the two gluconeogenic organs. Neither is a cohort — footnote, not a constraint |
| urinary bladder 0.95 | squamous (esophageal mucosa) | parked. Urothelium is not squamous, but **squamous metaplasia of bladder is documented** — if bladder ever surfaces as a foreign lineage it belongs in the masking discussion, not the merge |

Skin's inspection confirmed squamous: KRT32, KRT6B, KRT16, KRT33A, SLURP2, CALML3, EVPLL, CLCA2, TMPRSS11F.

**Everything above was set on GTEx normals with no tumour data examined.**

### Timeline corrected
Junior year → **Regeneron STS deadline is November 2027**, roughly fourteen months out, not six weeks. Paper can plausibly be accepted rather than merely preprinted by submission.

### Next
1. Per-cohort scoring pipeline — generalise the LUSC fetch (mRNA ∩ sequenced intersection built in).
2. Write final set membership into Appendix A as explicit gene lists.
3. Record C8 → HPA collection change as a dated pre-spec amendment.
4. Purity source: ABSOLUTE vs CPE.
5. bioRxiv/PubMed alerts for STK11, LKB1.

## 2026-09-21 (cont.) — Fetch pipeline, gate corrections, third exclusion

### Name-mismatch bug — silent dropout
`map` used underscores (`thyroid_gland`, `fallopian_tube`, `adrenal_gland`) while `sets_purged2` uses spaces. Three programs silently returned nothing and were never scored in the gate; the table showed 16 rows instead of 19 with no error. Caught only because a per-tissue recovery check printed `set = 0`.

**Failure mode worth remembering: a lookup mismatch produces wrong results with no error message.** Check `setdiff(names(a), names(b))` whenever joining two named structures.

After fixing: thyroid gland rank 1 margin 2.79 (clean), adrenal gland rank 1 margin 2.08 (clean), **fallopian tube rank 2 margin −1.20 (fails)**.

### Fallopian tube fails — motile-cilia cluster
Beaten by Testis. Inspection: CFAP53, CFAP276, CFAP206, DNAAF8, SPAG6, TCTE1, DRC7, DAW1, TTC29, DYNLRB2, ZMYND10, RIBC2, DEUP1 — axonemal and ciliogenesis machinery shared between tubal motile cilia and sperm flagella. Genuine shared biology.

Rescue attempted on the immune-purge pattern: removed GO:0044782 (cilium organization, 427 genes), stripping 57 from the set. Still failed, margin −0.84. **Program dropped — died on evidence after a fair rescue attempt**, same as cervix.

Third shared-machinery cluster found: squamous, Müllerian, motile-cilia.

### Consequence 4 added, OV excluded
New rule: *where the specificity gate removes a program a cohort requires as native, that cohort is excluded.*

Distinct from consequence 3 and deliberately not folded into it. Consequence 3 = **designation** failure (SARC: unbounded native set, foreign set colliding with contaminants). Consequence 4 = **measurement** failure (native set bounded and small, but a required program unscoreable).

**OV excluded.** Keeping only the ovarian-surface-epithelium half would make the *minority* origin hypothesis the sole native. Under the dominant STIC model most of the cohort is tubal in origin, so those tumours would score their own native lineage as foreign — a **systematic false positive in the direction of the hypothesis**, concentrated in the samples most likely misassigned. That is the reason, not loss of power.

Checked whether consequence 4 fires elsewhere: only vagina and fallopian tube fail the gate, and vagina is native to no cohort. **Fires once.**

### SKCM exclusion reasoning restated
Original reason (no adult skin atlas in C8) no longer holds after the HPA switch — HPA has a 604-gene skin program. Exclusion stands on a different argument: HPA skin is a **tissue** program dominated by keratinocyte identity, and melanoma's native cell is the melanocyte. Offering a non-native program as native creates the same asymmetry consequence 4 describes. *An exclusion whose stated reason has been invalidated must be re-argued or dropped.*

### Cohort count — stated, not left to subtraction
**Ten analysed entities.** Confirmatory: LUAD, STAD. Exploratory: LUSC, HNSC, COADREAD, ESCC, EAC, BRCA, CESC, UCEC. Excluded: SARC, SKCM (consequence 3), OV (consequence 4).

LUSC, HNSC, ESCC and CESC all take pan-squamous as native, so ten cohorts carry **seven distinct native designations**. The paper should frame this as "across seven tissue contexts," not imply twelve independent tests.

### Fetch pipeline
Working: sample-set intersection (mRNA ∩ sequenced) then chunked expression pull from `{study}_rna_seq_v2_mrna` (raw RSEM, CONTINUOUS).

Problems hit and fixed:
- **HTTP/2 framing errors** — fixed with `config(http_version = 2)` (libcurl constant for HTTP/1.1), smaller chunks, retries with backoff.
- **Empty chunks crash the parse** — genes in cBioPortal's registry but absent from a study's profile return an empty array; added a `is.data.frame`/`nrow` guard.
- **Protein-coding filter dropped needed genes.** Fetching `type == "protein-coding"` excluded LINC00473 and LINC00319 — the two signature lncRNAs flagged in the very first session — plus **437 non-coding genes across the lineage sets**. Fetch list corrected to protein-coding ∪ all genes required by any set: **20,084 IDs**.

LUAD saved: `expr_luad_raw.rds`, 510 × 18,528. All 30 signature genes present. Per-tissue recovery in the tumour matrix is good (lung 140/147, stomach 202/231); the remaining gap is genes absent from the RNA-seq profile.

**Note the gate/scoring mismatch this created:** GTEx contains all biotypes, so gate margins were computed on fuller sets than the tumour scoring would have used before the fix. Corrected now, but worth re-checking that gate and scoring use identical gene sets.

Remaining cohorts fetching (stad, lusc, hnsc, coadread, esca, brca, cesc, ucec). **Some chunks gave up** — cause not yet diagnosed. Distinguish: scattered failures across cohorts = server flakiness (fix: longer exponential backoff, more attempts, chunk 500); all chunks failing for one cohort = that study uses a different sample-list ID. **Check dimensions of every saved file rather than assuming success.**

### Still to do before scoring
1. Retry failed fetches; verify all eight cohort files.
2. **Purity data** — ABSOLUTE or CPE. Not on cBioPortal in the same call; comes from TCGA pan-cancer supplementary tables. Real task.
3. **Tier 2 Hallmark sets** — purged and gated like lineage sets.
4. **Tier 1 random draws** — GTEx deciles, fixed seed, recorded in Appendix A.
5. **ESCA histology split** into ESCC and EAC — unsolved.
6. Verify gate and scoring use identical gene sets after the biotype fix.

## 2026-09-22 — Recovery, full fetch, controls, purity, ESCA split

### Session recovery
RStudio hung on launch restoring a multi-gigabyte workspace. Force-quit and relaunched clean; in-memory objects lost, but **every file saved with `saveRDS` survived.** That is the whole reason for saving everything to disk the moment it exists.

Wrote `setup.R`, which restores all objects from files each session (`source("setup.R")`). Disabled workspace auto-restore and auto-save. Working directory must be the project folder — the first `list.files()` returned nothing because RStudio had opened in the home directory.

### Fetch complete — nine cohorts
| Cohort | Samples | Genes | Note |
|---|---|---|---|
| luad | 510 | 18,527 | |
| stad | 409 | 17,606 | profile ceiling |
| lusc | 481 | 18,527 | gap-filled |
| hnsc | 507 | 18,527 | |
| coadread | 532 | 18,527 | gap-filled |
| esca | 181 | 17,606 | profile ceiling |
| brca | 1,064 | 18,527 | gap-filled |
| cesc | 288 | 18,527 | |
| ucec | 515 | 18,527 | |

18,527 is the observed ceiling of the 20,084-gene fetch list. **stad and esca both stop at exactly 17,606** — two gastroesophageal cohorts on an identical count points to a shared, narrower profile annotation, not failed chunks. Gap-fill returned nothing for either.

Overnight gave-ups were scattered across cohorts (server load, not a wrong sample-list ID); fixed with chunk size 500, exponential backoff to 60 s, eight attempts.

**Coverage verified:** all 30 signature genes present in all nine cohorts. stad and esca lose only 2 genes from each lineage program relative to the others (stomach 200 vs 202; lung 138 vs 140), so the missing ~920 genes barely touch the scored sets.

### Tier 2 built; testis excluded
Six Hallmark sets, immune purge applied, then lineage-shared genes removed. Testis dropped from the foreign space — cancer-testis antigen derepression first, proliferation overlap second (see Amendment 6).

Two ordering errors of the same shape: the lineage-shared purge was run first with testis still counted, then Tier 1 was drawn with fallopian tube and the four merged squamous programs still counted. Cause: no single definition of the scored set. Fixed by saving `scored_programs.rds` and reading it everywhere (Amendment 7).

Final Tier 2: E2F 182, G2M 181, hypoxia 139, OXPHOS 168, MYC 183, IFN-γ 124.

**Liver shares 22 hypoxia, 21 OXPHOS and 10 IFN-γ genes.** The lineage-shared purge protects the hepatocyte score from a partly real confound, which cuts in the direction of the hypothesis. Pre-specified: hepatocyte results reported under both purged and unpurged Tier 2; if the finding survives only the purged version, it is reported as confound-sensitive.

### Tier 1 drawn
Seed 20260922, 100 draws per program for 14 programs, 13,664-gene universe, matched on size and GTEx decile. Pan-squamous rebuilt from purged sets (34 genes) and re-verified on GTEx: margin ≈3.1, unchanged.

### Purity
cBioPortal clinical attributes contain no purity. Source: **GDC PanCanAtlas, `TCGA_mastercalls.abs_tables_JSedit.fixed.txt`, UUID 4f277128-f793-4354-a13d-30cc7fe9f6b5.** 10,786 samples. The `array` column is the 15-character barcode and matches sample IDs directly.

`call status`: called 9,847 · legacy_call 558 · maf_call 146 · snp_call 56 · legacy_maf_call 35 · blank 144. **Every non-blank status carries a purity value; only the 144 blanks are missing.** The non-"called" labels are alternative ABSOLUTE methods, not failures.

**Rule: use any sample with non-missing purity. Sensitivity analysis: "called" only.**

The worry that near-diploid MSI tumours in COADREAD and UCEC would fail ABSOLUTE and be dropped did not hold: those cohorts lose 13 and 23 samples between matched and called — not a distinct subgroup. Recorded because it was a plausible concern that turned out not to bite.

Matched with usable purity: luad 499/510 · stad 405/409 · lusc 476/481 · hnsc 499/507 · coadread 530/532 · esca 161/181 · brca 1,042/1,064 · cesc 285/288 · ucec 505/515.

### ESCA split
cBioPortal was returning 503 all session. Split instead from the **TCGA-CDR Supplemental Table S1** (GDC UUID 1b5f413e-a8d1-4d10-92eb-7c4ae739ed81), `histological_type`, joined on 12-character patient barcode.

**EAC 87, ESCC 94, no unassigned samples.** Saved `esca_histology_split.rds`.

The 20 ESCA samples missing purity clustered by collection site (six from LN), which raised the possibility of histology-dependent missingness. Cross-tabulation: EAC 8/87 (9%), ESCC 12/94 (13%) — not meaningfully different.

**Power caveat, stated now:** with purity, EAC 79 and ESCC 82. At ~11% functional LKB1 loss that is roughly eight or nine signature-positive tumours per subtype. Both are exploratory; ESCA will contribute little inferentially and results should be framed that way from the start.

### Pre-specified, not yet checkable
At scoring, test whether missing purity is associated with signature positivity. If purity is missing more often in LKB1-deficient tumours, complete-case analysis is biased rather than merely smaller.

### Remaining
1. **Score the signature** in all nine cohorts; call functional loss at 95% specificity in confidently-intact controls.
2. **Score lineage programs** (14) and Tier 1/Tier 2 controls.
3. **Deconvolution** — required by §6 (lineage scores must survive adjustment for the nearest matching cell-type fraction; adipose fraction for BRCA). Not built. Does not block the primary model (purity + Tier2_PC1), which is the primary specification.
4. Add `scored_programs.rds`, `tier2_hallmark_purged.rds`, `tier1_draws.rds`, `esca_histology_split.rds` and the purity file to `setup.R`.

## 2026-09-22 (cont.) — Deconvolution scoped, stromal purge, pre-scoring boundary reached

**Deconvolution** was a pre-specified commitment still unbuilt. Settled before scoring rather than after, because once primary results exist any choice about this layer would be made knowing its effect.

Scoped down on a reasoned basis (Amendment 8): deconvolution can only estimate cell types present in its reference, so adjacent-organ epithelium is a masking problem, not a deconvolution one, and foreign programs with no resident counterpart need no adjustment. What remains is three resident stromal populations. BayesPrism/CIBERSORTx would have been several sessions for three numbers; marker-based scores were an afternoon.

**CESC**: implementing the long-designated squamous/glandular split exposed that the glandular half has no scoreable native program (cervix merged into pan-squamous). Consequence 4 fired a second time. Restricted to squamous: **239 of 288 samples retained.** The filter file had not actually been saved when first written; caught on a `file.exists()` check.

**ESCA MDE** pre-registered: d ≈ 0.99 unadjusted, 1.29 after correction, vs 0.34 for LUAD. Significant ESCA results will be treated as suspect.

**STAD–pancreas masked.** UCEC–squamous confirmed as already masked.

**Stromal purge** — the direction question was the substantive one. Initially proposed purging overlap from the stromal markers (the Tier 2 direction), which was backwards: the covariate exists to measure contamination inside the programs. Purged from the lineage side instead. Lung carried three endothelial markers — the anchor native program was partly measuring capillary content.

Adipocyte and MCP markers gathered **before** purging so the purge, re-gate and control rebuild happened once, not twice. Avoided a fourth ordering error of the same shape.

**Breast prediction tested and failed** (0.50 → 0.56): the adipose problem is sample composition, not program contamination.

**Pan-squamous margin correction:** 4.19 by the gate definition, not ~3.1; the two numbers measure different things and had been mixed.

### PRE-SCORING BOUNDARY
As of this entry no tumour has been scored. Every choice — cohorts, programs, gate, purges, masks, controls, covariates, model, falsification criteria, sensitivity analyses — is fixed in dated amendments 1–9.

Add to `setup.R` before the final `cat`:
```r
scored_sets <- readRDS("scored_programs.rds")
t2c         <- readRDS("tier2_hallmark_purged.rds")
tier1       <- readRDS("tier1_draws.rds")
stromal_m   <- readRDS("stromal_markers.rds")
esca_split  <- readRDS("esca_histology_split.rds")
cesc_keep   <- readRDS("cesc_histology_filter.rds")
pur         <- read.delim("TCGA_mastercalls.abs_tables_JSedit.fixed.txt", check.names = FALSE)
```

### Next: scoring
1. Signature score in all nine matrices; functional-loss call at 95% specificity in confidently-intact controls.
2. Check purity missingness vs signature positivity.
3. Lineage, Tier 1, Tier 2 and stromal scores.
4. Primary models per cohort; Holm across the two confirmatory, BH across exploratory.

## 2026-09-22 (cont.) — Reproduction across all nine cohorts; missing-data rule

**Reproduction gate closed properly.** It had only ever covered LUSC. Scored the signature on all nine whole cohorts and compared to the paper's within-cohort AUROCs. Six matched to three decimals first time; UCEC within 0.008.

**STAD and COADREAD failed** — and STAD is confirmatory, so it had to be understood. With only 7–8 loss cases, each case carries ~1/8 of the AUROC, so the gaps were about one tumour ranking wrong: a data problem affecting a few samples, not a scoring difference.

Diagnosis took several wrong turns worth recording:
1. Suspected NAs from the gap-fill reshape — **correct**, NAs in signature genes in exactly the failing cohorts, zero in LUAD.
2. Assumed a merge artifact and tried to re-merge — **wrong**; the fix changed nothing.
3. Found the refetch itself returned NA for those samples; confirmed with a direct sample-level API query returning an empty list at status 200. **The data does not exist in cBioPortal.**
4. COADREAD and UCEC share the identical 2,214 missing genes — the regularity that ruled out random corruption.

Missingness is site-clustered and not associated with genomic loss, so exclusion costs power rather than introducing bias.

**Rule:** remove whichever costs less, keeping ≥28/30 signature genes — the floor already in the pre-spec. COADREAD/UCEC drop two genes and keep every sample; STAD drops 36 samples. **All nine now reproduce the paper.** COADREAD going 0.595 → 0.707 by exactly this rule is good evidence the authors did the same.

Rejected a global complete-gene restriction: it would have cut STAD's native program by a quarter for a problem that exists only in two exploratory cohorts. Per-cohort completeness instead; restricted programs re-gated (all pass) and separate Tier 1 drawn for COADREAD/UCEC.

**Boundary correction:** Amendment 9's "no signature score computed" became false during this check. Amendment 10 states exactly what has and hasn't been computed. A stale boundary claim is worse than an honest amended one.

Add to `setup.R`:
```r
cu_restricted <- readRDS("coadread_ucec_restricted.rds")
stad_keep     <- readRDS("stad_complete_samples.rds")
```

### Next
Functional-loss calling: threshold at 95% specificity in confidently-intact controls (WT, STK11 ≥ cohort 40th percentile), per analysis entity. Then the purity-missingness vs signature-positivity check.

## 2026-09-22 (cont.) — LKB1 calls; last pre-scoring check passed

Fixed two definitions before seeing any counts: standardization within analysis entity, and deficient = genomic loss ∪ signature-positive WT (sensitivity: WT-only comparison).

Calls saved to `lkb1_calls.rds`. Deficient: LUAD 132, STAD 52, BRCA 178, LUSC 94, COADREAD 92, HNSC 86, UCEC 79, CESC 64, EAC 14, ESCC 13.

Threshold verified: control positivity 5.0–5.8% everywhere.

**Prevalence didn't reproduce the paper** (1–3 points low in most cohorts, larger where standardization changed). Tested one alternative control definition; it didn't help, so kept the original rather than hunting for a convention that matches. Reasoning recorded: AUROC is the proper reproduction target because it's invariant to thresholding conventions, and it matched in all nine.

ESCC excess = 5.0 exactly — no functional loss above chance. Predicted uninformative by MDE; now shown.

**Purity-missingness check passed** — no association with deficiency in any entity.

**Everything before lineage scoring is done.** Next session scores the lineage programs and controls and fits the primary models — the first point at which the hypothesis can be tested.

## 2026-09-22 (cont.) — PRIMARY RESULT

### Scoring
ssGSEA (GSVA 2.0.7) with **`normalize = FALSE`**. The default normalizes each score by the range across all gene sets in the same call, so a lineage program scored alongside 14 sets and one scored alongside 1,400 Tier 1 sets would sit on different scales, invalidating the Tier 1 comparison. With normalization off, each score depends only on its own gene set and the sample's ranks. Stromal covariates as mean log2 expression (MCP-counter method), not ssGSEA.

Scored lineage (14 programs), Tier 2 (6), Tier 1 (1,400 sets) and stromal (3) for all ten entities before inspecting any. COADREAD and UCEC used their restricted gene space and draws. Saved to `scores/`.

Primary test statistic fixed in Amendment 12 while scoring was running.

### Primary result — confirmatory cohorts

| | n | deficient | Tier2 PC1 var | β (no T2) | β | SE | p | Holm p | attenuation | **Tier 1 p** |
|---|---|---|---|---|---|---|---|---|---|---|
| LUAD | 497 | 129 | 0.50 | 0.178 | 0.270 | 0.044 | 1.6×10⁻⁹ | 3.2×10⁻⁹ | −0.52 | **0.73** |
| STAD | 362 | 50 | 0.58 | 0.107 | 0.106 | 0.059 | 0.076 | 0.076 | 0.01 | **0.62** |

Tier 2 PC1 explains ≥40% of Tier 2 variance in both (0.50, 0.58), so the PC approach is valid per Amendment 4.

**H1 is not supported.**

LUAD shows a large, highly significant elevation in the foreign-lineage composite in LKB1-deficient tumours, surviving Holm correction and Tier 2 adjustment. But random gene sets matched on size and GTEx expression decile produce an effect at least as large in **73%** of draws. The pre-specified criterion — foreign-lineage elevation must exceed the Tier 1 empirical null — fails. The elevation is real; the lineage interpretation is not supported.

STAD does not reach significance (Holm p = 0.076), and also fails Tier 1 (0.62).

Negative attenuation in LUAD (−0.52) means adding Tier2_PC1 *increased* the coefficient: the general-dysregulation axis anticipated in Amendment 4 is not the explanation either.

**Interpretation, stated carefully.** Something about LKB1-deficient LUAD shifts ssGSEA scores broadly, across arbitrary gene sets of matched size and expression, not specifically across lineage programs. The Tier 1 control — which most comparable analyses omit — is what distinguishes these. Without it, the LUAD result would have read as strong support for lineage relaxation.

### Verification that the null is valid
The conclusion rests on the Tier 1 construction, so it was checked before being accepted:
- `tier1[[liver]]` is 100 × 510: rows are draws, columns samples — not transposed.
- 25 unique values in a 5×5 block: each row is a distinct random set, not one set repeated.
- Standardized null composite SD 0.55 vs real composite SD 0.48: same scale.

The null is correctly constructed. The negative result stands.

### Still to run (pre-specified)
- WT-only sensitivity (signature-positive WT vs signature-negative WT)
- "Called only" purity sensitivity
- Per-program secondary tests, LUAD and STAD (descriptive; cannot rescue H1)
- Exploratory composites, eight cohorts, BH
- **Hepatocyte both-versions analysis (Amendment 6) — not yet runnable.** Requires liver scored against the *unpurged* Tier 2; only the purged Tier 2 was scored. Separate small scoring step owed.

### Note for the write-up
This is a real result and a defensible paper. A pre-registered test of a plausible hypothesis, with a control specifically designed to catch the most likely false positive, which caught it. The negative is more informative than a positive would have been without the control.

### Sensitivity analyses (pre-specified)

| Entity | Mode | n | def | β | p | atten. | Tier 1 p |
|---|---|---|---|---|---|---|---|
| LUAD | WT only | 445 | 77 | 0.317 | 4.0×10⁻⁹ | −0.40 | 0.60 |
| STAD | WT only | 355 | 43 | 0.085 | 0.181 | 0.15 | 0.82 |
| LUAD | called only | 489 | 127 | 0.272 | 1.4×10⁻⁹ | −0.51 | 0.73 |
| STAD | called only | 360 | 49 | 0.116 | 0.054 | −0.01 | 0.54 |

Both sensitivities agree with the primary: the composite result is robust in significance and equally fails Tier 1. The WT-only analysis — the non-genomic population the source paper made novel — behaves the same as the combined group.

### Per-program secondary tests (descriptive; cannot rescue H1)

**LUAD** (13 foreign programs, BH within cohort):

| Program | β | p | BH | **Tier 1 p** |
|---|---|---|---|---|
| **pancreas** | 0.899 | 8.4×10⁻²² | 1.1×10⁻²⁰ | **0.01** |
| liver | 0.746 | 6.9×10⁻¹⁵ | 4.5×10⁻¹⁴ | **0.13** |
| endometrium | 0.259 | 6.9×10⁻⁶ | 3.0×10⁻⁵ | 0.58 |
| prostate | 0.436 | 3.5×10⁻⁵ | 1.1×10⁻⁴ | 0.28 |
| stomach | 0.381 | 6.2×10⁻⁵ | 1.6×10⁻⁴ | 0.61 |
| intestine | 0.309 | 1.9×10⁻³ | 4.0×10⁻³ | 0.77 |
| kidney | 0.248 | 8.7×10⁻³ | 1.6×10⁻² | 0.73 |
| adrenal gland | 0.220 | 1.9×10⁻² | 3.1×10⁻² | 0.71 |
| pan-squamous, thyroid, ovary, urinary bladder, breast | ≤0.13 | n.s. | n.s. | 0.75–0.96 |

**STAD** (11 foreign programs):

| Program | β | p | BH | **Tier 1 p** |
|---|---|---|---|---|
| **prostate** | 0.786 | 1.6×10⁻⁸ | 1.7×10⁻⁷ | **0.00** |
| **thyroid gland** | 0.627 | 2.1×10⁻⁵ | 7.7×10⁻⁵ | **0.01** |
| **adrenal gland** | 0.508 | 7.2×10⁻⁶ | 4.0×10⁻⁵ | **0.06** |
| ovary | 0.209 | 2.7×10⁻³ | 7.4×10⁻³ | 0.41 |
| lung | −0.266 | 0.035 | 0.068 | 0.33 |
| urinary bladder | −0.299 | 0.037 | 0.068 | 0.29 |
| endometrium, breast, kidney, pan-squamous, liver | — | n.s. | n.s. | 0.53–0.87 |

**Why the composite fails while individual programs pass: dilution.** Averaging 13 programs where two or three carry signal and ten carry none drags the composite toward the null, while the Tier 1 null composite averages 13 random sets with comparable variance and nothing to dilute. This is a property of the pre-specified test statistic, not a reason to prefer the per-program results.

**Tier 1 is doing exactly its job.** LUAD endometrium has nominal p = 7×10⁻⁶ and BH p = 3×10⁻⁵, yet random matched gene sets beat it 58% of the time. Reported by nominal significance alone it would read as a clear finding.

### Exploratory composites (BH across eight)

| Entity | n | def | β | p | BH | atten. | **Tier 1 p** |
|---|---|---|---|---|---|---|---|
| **HNSC** | 494 | 83 | 0.355 | 8.7×10⁻⁹ | 6.9×10⁻⁸ | −0.12 | **0.00** |
| LUSC | 476 | 93 | 0.180 | 4.6×10⁻⁴ | 1.8×10⁻³ | −0.05 | 0.21 |
| CESC | 236 | 63 | 0.160 | 0.032 | 0.086 | 0.10 | 0.83 |
| BRCA | 1,023 | 174 | 0.069 | 0.051 | 0.103 | 24.23* | 1.00 |
| ESCC | 82 | 12 | 0.191 | 0.189 | 0.302 | −0.68 | 0.04 |
| EAC | 79 | 13 | 0.101 | 0.363 | 0.484 | −0.25 | 0.89 |
| COADREAD | 527 | 91 | 0.016 | 0.713 | 0.815 | 0.75 | 0.97 |
| UCEC | 504 | 76 | −0.008 | 0.896 | 0.896 | 0.93 | 0.89 |

\* BRCA attenuation is uninterpretable: the no-Tier2 coefficient is near zero, so the ratio explodes. Not a meaningful value.

**HNSC is the only exploratory composite that survives everything** — BH significance, no attenuation, Tier 1 p = 0.00.

ESCC's Tier 1 p of 0.04 arrives with a non-significant model (p = 0.19) and n_def = 12, against its pre-registered MDE of d ≈ 1.0. Per Amendment 8, an apparent ESCA signal is **treated as suspect, not as a finding**.

### Where this leaves the project
**H1, as pre-specified, is not supported.** The composite foreign-lineage index fails the Tier 1 control in both confirmatory cohorts.

Surviving every control: **pancreas program in LUAD** (Tier 1 p = 0.01), **prostate and thyroid in STAD** (0.00, 0.01), and the **HNSC composite** (0.00). These are descriptive/exploratory by pre-specification and cannot convert a failed primary test into a positive one.

Liver in LUAD — the hepatocyte program extending the prior finding — is borderline at Tier 1 p = 0.13, and the owed both-versions analysis bears directly on it.

### Owed
- **Hepatocyte both-versions analysis (Amendment 6).** Requires liver scored against the *unpurged* Tier 2; only the purged version was scored. If liver survives only under purged Tier 2, it is reported as confound-sensitive.
- Interpretation of *why* pancreas, prostate, thyroid and adrenal — none an obvious a-priori candidate — are the programs that survive. Shared gene content between these programs and the surviving ones should be checked before any biological reading.

## 2026-09-23 — Hepatocyte commitment closed; Tier 1 reinterpreted

Session infrastructure: wrote `analysis.R` (entities, foreign sets, `get_expr`, `ss`, `build`, `fit2`, `per_prog`, and `t2` — the immune-purged-only Tier 2). Every session is now `source("setup.R")` then `source("analysis.R")`.

### Hepatocyte both-versions analysis (Amendment 6) — CLOSED

| Tier 2 version | β | SE | p | Tier 1 p | PC1 var |
|---|---|---|---|---|---|
| purged (lineage-shared removed) | 0.746 | 0.093 | 6.9×10⁻¹⁵ | 0.13 | 0.50 |
| unpurged (immune purge only) | 0.747 | 0.093 | 5.9×10⁻¹⁵ | 0.13 | 0.49 |

**Identical.** The confound-sensitivity concern that motivated the requirement does not materialise. The lineage-shared purge — correctly flagged in Amendment 6 as cutting in the direction of the hypothesis — makes no difference to the liver result. Liver is **not** confound-sensitive; it is borderline on Tier 1 for unrelated reasons.

A safeguard was pre-registered against a bias that could have favoured the hypothesis, and on testing the bias was absent. That is a stronger position than not having checked.

*Note:* 77 genes have zero variance across LUAD samples and contribute no rank information to ssGSEA. Present in both the original and unpurged scoring; harmless, but stated in methods.

### Why pancreas, prostate, thyroid, adrenal? — not what it looked like

**Gene overlap is negligible.** Pancreas–liver share 30 genes (10% of pancreas), liver–adrenal 26, all other pairs ≤7. The surviving programs are not the same genes relabelled.

**Not one latent factor.** In LUAD, pancreas–liver correlate at 0.67 and both correlate ~0.53 with stomach, but prostate correlates ≤0.34 with everything and adrenal is similarly independent. At least three distinct signals.

**But correlation structure does not determine survival.** Stomach correlates 0.53–0.54 with pancreas and liver yet fails Tier 1 at 0.61, while pancreas passes at 0.01.

**What does determine it: effect size.** Across all 24 per-program tests in the confirmatory cohorts, Spearman correlation between |β| and Tier 1 p is **−0.87**.

### Reinterpretation: Tier 1 is an effect-size floor, not a program-specific test

The honest statement is not "these programs are special." It is:

> In LKB1-deficient tumours, random gene sets matched on size and GTEx expression decile produce foreign-lineage-scale effects up to roughly |β| ≈ 0.7. Only effects above that exceed chance. In LUAD only pancreas clears it; liver is borderline; everything else — including programs with nominal p as small as 7×10⁻⁶ — does not.

Null SDs of the Tier 1 coefficient in LUAD range 0.199 (intestine) to 0.364 (urinary bladder), median ≈0.28, so the ≈0.7 threshold is about **2.5 null SDs**. The 1.8-fold spread means the bar is not perfectly uniform — a given effect clears more easily against a tighter null — so this is a threshold with program-specific variation, not a single constant. Null SD is not a simple function of set size: intestine has 739 genes and the tightest null; prostate has 124 with a wider one.

**Consequences, both ways.**
- The negative result is stronger and more general. It quantifies a **detection floor** for bulk ssGSEA scoring of tissue-identity programs in cohorts of this size, applicable beyond this study.
- The "pancreas in LUAD is a finding" reading is weakened. Pancreas clears the bar chiefly by having the largest effect, not by being biologically privileged. It may still be real; Tier 1 alone does not establish that.

### Next
- Decide how the detection-floor framing enters the write-up — it may be the paper's main contribution rather than a caveat on a null result.
- Consider whether 100 Tier 1 draws is enough resolution (Tier 1 p is granular to 0.01); the pre-spec fixed 100, so any increase is an amendment with reasons.
- Remaining exploratory per-program tests not yet run (only composites done for the eight exploratory entities).

## 2026-09-23 (cont.) — Null inflation: a post-hoc methodological finding

**Provenance, stated first.** Everything below was found *post hoc*, while investigating why H1 failed. It was not pre-registered. It rests on 22 cohort-by-split observations from one dataset, one scoring method, one gene-set collection. It is a strong hypothesis, not an established result, and must be presented that way.

### The chain of wrong explanations, in order
1. **"These programs are special"** (pancreas, prostate, thyroid, adrenal). Killed by gene-overlap ≤30 genes between survivors and Spearman −0.87 between |β| and Tier 1 p: survival tracks effect size, not program identity.
2. **"Floor scales with 1/√n."** R² = 0.11. Killed by LUAD (n=497, floor 0.786) vs HNSC (n=494, floor 0.360).
   - *My error:* "minimum |β| among programs that cleared" is censored by which real effects happen to exist, not a property of the null. Replaced with the 95th percentile of the absolute null coefficient — unbiased.
3. **"Floor tracks global separation between groups."** r = 0.61, but BRCA/WGD has separation 2.80 and floor 0.258 while LUAD/LKB1 has 2.99 and 0.786. Not it.
4. **"Circularity — the LKB1 group is defined from expression."** Killed by the genomic-only split (52 cases called from mutation/CNA, no expression): standardized floor 4.01 vs LKB1's 4.15.
5. **Group-size imbalance.** Controlled by standardizing: floor ÷ √(1/n₁ + 1/n₀).

### What survived
Median standardized floor by split:

| Split | Source of grouping | Median floor_std |
|---|---|---|
| **sex** | clinical records | **2.29** |
| WGD | copy number | 4.02 |
| genomic LKB1 loss | mutation / CNA | 4.01 |
| LKB1 functional loss | expression signature | 4.15 |

`floor_std` is the empirical 95th percentile of the null coefficient in units of its own standard error — directly comparable to the theoretical 1.96.

Verified the anchor: the model's own SE for the group coefficient (median 0.099) matches the theoretical factor √(1/n₁+1/n₀) = 0.102, ratio 0.97. So the comparison to 1.96 is valid and not an artifact of normalization.

### The finding
> For gene-set score comparisons between **tumour-state** groups, the empirical null is about **2.1× wider** than parametric theory assumes (≈4.1 vs 1.96). A grouping unrelated to tumour biology (sex, 2.29) behaves as theory predicts. Groupings that track tumour state — LKB1 functional loss, genomic LKB1 loss, whole-genome doubling — all show the inflation, regardless of whether the grouping was derived from expression.

**Practical consequence.** Using the nominal 1.96 cutoff when the true null is 2.1× wider gives an actual false-positive rate of P(|z| > 1.96/2.11) ≈ **35%**, not 5%.

That is precisely what was observed: LUAD endometrium, nominal p = 6.9×10⁻⁶, Tier 1 p = 0.58.

**Plausible mechanism (untested):** ssGSEA scores of different gene sets are correlated because they are computed from the same sample-level expression ranks. When a grouping variable aligns with a major transcriptional axis — as any tumour-state variable does — every gene set separates the groups somewhat. The parametric standard error treats each gene set as independent and does not know this.

### Limitations
- Post hoc, n = 22 observations.
- One data source (TCGA), one scoring method (ssGSEA), one collection (HPA-derived).
- Mechanism proposed, not demonstrated.
- Tier 1 p resolution is 0.01 (100 draws).

## 2026-09-23 (cont.) — P2 resolved: inflation is not method-specific

### Literature check first — the phenomenon is not novel
Searched before investing further. **Wu and Smyth, CAMERA (*Nucleic Acids Research* 2012)** characterise exactly this: competitive gene set tests relying on gene permutation are "extremely sensitive to inter-gene correlation," and the method estimates a variance inflation factor from the data and incorporates it into the test. **QuSAGE** (Yaari et al. 2013) improves the VIF estimation. GSEA's own documentation states the enrichment score must be adjusted for correlations between gene sets and the expression dataset.

The 2.1× figure measured here **is** a variance inflation factor. The Tier 1 procedure is an empirical analogue of a correction that has been in limma for fourteen years, arrived at independently.

A second search for the specific workflow — per-sample gene-set scores entered as regression outcomes, where no correction is routinely applied — found no formal treatment, only an anecdotal Biostars comment that such false positives occur "all of the time." Absence of search hits is weak evidence and is not treated as establishing a gap.

**Consequence for the write-up:** no discovery claim. The contribution is demonstration and quantification in a workflow where the correction is routinely omitted, with CAMERA and QuSAGE cited as the precedent.

### P2 test: three scoring methods, same cohorts and splits

| Cohort (LKB1 split) | ssGSEA | GSVA | mean-z |
|---|---|---|---|
| LUAD | 7.68 | 7.62 | 6.55 |
| HNSC | 2.99 | — | 3.53 |

(standardized floor; theoretical value 1.96)

**mean-z is the decisive comparison.** It uses no ranks, no Kolmogorov–Smirnov statistic and no normalisation — simply the mean of standardized expression across a gene set. It still shows 3.3× inflation in LUAD and 1.8× in HNSC.

**P2 resolves in the "general" direction:** the inflation is a property of averaging correlated genes and testing the average against a tumour-state variable, not an artifact of any scoring algorithm. Between-cohort variation (roughly 2× to 7×) is far larger than between-method variation.

This is consistent with the CAMERA mechanism and extends the demonstration to the per-sample-score workflow across three scoring methods.

**Caveat:** LUAD is the highest-inflation cohort in the set (7.68 vs median 4.15 across splits). The three-method comparison is internally valid — same cohort, same split — but 7.6 must not be quoted as a general figure.

### Bug found and fixed
`mean_z` initially returned all-NA scores: `scale()` divides by each gene's SD, and the 77 zero-variance genes in LUAD produce NaN rows, which propagate through `colMeans` to any set containing one. GSVA discards constant genes automatically, which is why only the hand-written scorer failed. Fixed by removing zero-variance genes before scaling (18,527 → 18,450).

Worth noting the failure was loud (an error) rather than silent. A version that dropped NAs quietly would have scored a biased subset of samples without any warning.

## 2026-09-23 (cont.) — P3 FAILS: mechanism unexplained

Pre-registered prediction (Part II, P3): if the inflation arises from correlation among gene-set scores sharing sample-level expression ranks, mean absolute pairwise correlation among random-set scores should predict a cohort's standardized floor. Threshold |r| ≥ 0.5.

| Cohort | mean abs. correlation | floor_std |
|---|---|---|
| BRCA | 0.378 | 5.98 |
| STAD | 0.363 | 3.28 |
| COADREAD | 0.293 | 4.21 |
| UCEC | 0.283 | 2.91 |
| LUAD | 0.250 | **7.68** |
| CESC | 0.246 | 4.37 |
| LUSC | 0.235 | 4.08 |
| HNSC | **0.197** | 2.99 |

**r = 0.12** using draw 1; **r = 0.17** averaging over 20 draws. Measurement error was not the problem.

**P3 fails.** Per the pre-specification, the mechanism is reported as **unexplained**. No substitute explanation is offered.

The failure is not marginal: BRCA has the highest inter-set correlation (0.378) and a floor of 5.98, while LUAD has among the lowest correlation (0.250) and the highest floor (7.68). HNSC has the lowest correlation and one of the lowest floors — the only cohort consistent with the prediction.

### Consequence for the claim
Without a mechanism, this **cannot be asserted to be the CAMERA phenomenon in a new workflow.** CAMERA's inflation is driven specifically by inter-gene correlation; the analogous quantity measured here predicts nothing. The claim is therefore descriptive: an empirical inflation of unknown origin, quantified across cohorts, splits and scoring methods.

### Limitation of the test itself, stated honestly
CAMERA's inter-gene correlation is computed **among genes within a set**, from model residuals. What was measured here is correlation **between set scores**. These are different quantities, and the test may have measured the wrong thing rather than falsified the mechanism.

This is a limitation of the test, **not a rescue of the hypothesis.** The pre-specified prediction was stated in terms of between-score correlation and it failed on its own terms. A future test of the within-set residual correlation would be a *new* prediction requiring its own pre-registration, not a reinterpretation of this one.

### Running summary of the four predictions
- **P1** (split type: tumour-state ≈4, sex ≈2) — supported: medians 4.01/4.02/4.15 vs 2.29.
- **P2** (generality across methods) — resolves in the "general" direction: ssGSEA 7.68, GSVA 7.62, mean-z 6.55 in LUAD; 2.99 vs 3.53 in HNSC.
- **P3** (mechanism) — **FAILED**. Reported as unexplained.
- **P4** (replication in six new cohorts) — pending; cBioPortal returning 503.

## 2026-09-23 (cont.) — P4 FAILS TO REPLICATE

Six cohorts not used in any prior analysis here — KIRC, PRAD, LIHC, GBM, THCA, BLCA — fetched and scored after Part II was written. Predictions were on the record before any of these data were touched: **WGD ≈ 4 (range 3–5), sex ≈ 2 (range 1.8–2.8).**

### Result

| Cohort | Split | n | n_grp | floor_std |
|---|---|---|---|---|
| BLCA | WGD | 396 | 241 | 3.89 |
| KIRC | WGD | 386 | 66 | 3.34 |
| GBM | WGD | 151 | 24 | 2.52 |
| LIHC | WGD | 350 | 121 | 2.50 |
| PRAD | WGD | 439 | 35 | 2.09 |
| LIHC | sex | 350 | 237 | 3.70 |
| KIRC | sex | 386 | 244 | 3.27 |
| THCA | sex | 458 | 127 | 2.99 |
| BLCA | sex | 396 | 292 | 2.16 |
| GBM | sex | 150 | 97 | 1.86 |

**Medians: WGD 2.52, sex 2.99.** The prediction **reverses** — sex is higher — and WGD falls outside the predicted 3–5 range.

Not evaluable: PRAD sex (prostate cancer is male-only; `grp` has one level), THCA WGD (<20 samples in one group; thyroid cancers are largely near-diploid). Both are structural, reported as not evaluable rather than as failures.

### Direct comparison, same split, same pipeline

| | original 8 cohorts | new 6 cohorts |
|---|---|---|
| WGD | 3.10, 3.46, 3.82, 3.93, 4.10, 4.15, 5.29, 5.81 — **median 4.02**, all >3 | 2.09, 2.50, 2.52, 3.34, 3.89 — **median 2.52**, three of five <3 |
| sex | **median 2.29** | **median 2.99** |

The distributions barely overlap. **P1 does not replicate.**

### What survives and what does not

**Survives:** the inflation itself. Empirical floors of roughly 1.9 to 5.8 against a theoretical 1.96 appear in every cohort and both cohort sets. Gene-set score comparisons are not calibrated by parametric theory.

**Does not survive:** the structure. The claim that tumour-state splits inflate while biologically orthogonal splits do not was a property of the original eight cohorts. On new data it disappears and partially reverses.

**Four explanations for between-cohort variation have now been tested and failed:** split type (P1, failed on replication), inter-set correlation (P3, r = 0.17), sample size (R² = 0.09), global group separation (r = 0.61 but contradicted by BRCA/LUAD).

### Honest current summary
> Gene-set score comparisons show empirical nulls roughly 1 to 3 times wider than parametric theory, varying substantially between cohorts for reasons that none of four tested explanations predicts. Empirical calibration is therefore necessary and cannot be replaced by a rule of thumb.

This is weaker than the morning's version. It is what the pre-registered replication produced.

### Caveats on the test's fairness, stated
- The replication scored all 14 programs; the originals used per-cohort foreign sets of 11–13. Minor, but a difference between runs.
- Original "tumour-state" medians pooled LKB1, genomic-loss and WGD splits. The WGD-only comparison above is the like-for-like one and is the comparison that fails.
- PRAD deviation: 33 of 493 samples were missing 932 genes (8 collection sites). Samples dropped rather than genes, to keep the gene space identical across cohorts for the floor comparison. Discovered after fetching; recorded as a deviation. The Amendment 10 rule did not cover it, since no signature genes are involved in P4.

### Status of Part II
- **P1** — supported in the original eight, **fails to replicate** in six new cohorts.
- **P2** — inflation is general across ssGSEA, GSVA and mean-z.
- **P3** — **failed**; mechanism unexplained.
- **P4** — **failed to replicate.**

One of four pre-registered predictions holds. That is the result.

## 2026-09-23 (cont.) — Calibration function, and the control that reframes everything

### `calibrate_geneset()` written and validated
Given an expression matrix, gene sets, a grouping and optional covariates, it returns the observed coefficient, the nominal p, an **empirical p** from matched-random gene sets, and the 95th-percentile null floor. Gene sets matched on size and expression decile; zero-variance genes removed; scoring function pluggable (defaults to ssGSEA with `normalize = FALSE`).

Validated against a known result — LUAD liver: β 0.745 vs 0.746 from the main pipeline, nominal p 7.3×10⁻¹⁵ vs 6.9×10⁻¹⁵, empirical p 0.07 vs 0.13. The p difference is fresh random draws; at 100 draws the Monte Carlo error near p ≈ 0.1 is about ±0.03. **Liver sits close enough to the threshold that 100 draws cannot resolve 0.07 from 0.13** — a practical argument for more draws when a program matters.

### Random-grouping control — the missing piece
Ran the function on a **random 50/50 split** of LUAD samples, same covariates:

| Set | β | nominal p | empirical p | floor_95 |
|---|---|---|---|---|
| liver | −0.058 | 0.489 | 0.42 | 0.135 |
| pancreas | 0.049 | 0.555 | 0.46 | 0.137 |
| stomach | −0.057 | 0.479 | 0.41 | 0.143 |
| breast | −0.092 | 0.219 | 0.17 | 0.124 |

Nominal and empirical p-values **agree closely**. Standardized floor = 0.135 / 0.0897 = **1.50**, *below* the theoretical 1.96 — the nominal test is slightly conservative, not inflated.

### This reframes the finding
**There is no inflation intrinsic to gene-set scoring.** Against a random grouping the parametric test is correctly calibrated. Inflation appears only when the grouping variable tracks something real in the data — which is unsurprising once stated, because the empirical null is built from random gene sets tested *against that same grouping*. A grouping that separates samples along any real transcriptional axis will make random gene sets separate too.

Revised statement, and the most defensible one reached so far:

> The empirical null for a gene-set score depends on the **grouping variable**, not only on the gene set. Against a random grouping it matches parametric theory (1.50 vs 1.96). Against real biological groupings it is 1.5–3× wider, varying by cohort and grouping in ways that four tested explanations — split type, inter-set correlation, sample size, global separation — fail to predict.

This is cleaner than any earlier version, and the random-split control is what establishes it. It should have been run first; it was run last, after four explanatory hypotheses had already failed.

### Practical conclusion
Because nothing predicts the floor, no correction factor can be published. **Empirical calibration per analysis is the only remedy**, and that is what the function provides. The four failed explanations are the argument for the tool, not a weakness of it.

### Still to do
- Draw-count guidance in the function; warn when empirical p is near 0.05 at low `n_null`.
- Document, test on a second dataset, package.
- Write-up has not started.

## 2026-09-23 (cont.) — CAMERA corroboration, survivor list, DE-density hypothesis

### False-positive rate — the headline number
Across 99 per-program tests in eight cohorts:

| | fails Tier 1 | survives Tier 1 |
|---|---|---|
| not BH-significant | 56 | 0 |
| BH-significant | 28 | 15 |

**Of 43 associations significant after Benjamini–Hochberg correction, 28 (65%) do not survive empirical calibration.** No result survives Tier 1 while failing BH — calibration only removes findings, never adds them.

### CAMERA (limma) corroborates the empirical procedure
Ran `camera()` with `inter.gene.cor = NA` on the same cohorts, groupings and design.

| | Tier 1 fails | Tier 1 survives |
|---|---|---|
| CAMERA fails | 84 | 9 |
| CAMERA survives | **0** | 6 |

**Zero contradictions.** Spearman between CAMERA p and Tier 1 p = 0.74. CAMERA is strictly more conservative.

This matters: an established, theoretically grounded correction in limma since 2012 agrees with the empirical procedure on every case where it has an opinion. Tier 1 is not an ad hoc invention.

Of the nine disagreements, three are borderline on CAMERA (STAD prostate 0.053, LUSC pancreas 0.080, HNSC stomach 0.080). Clear disagreements: CESC adrenal (0.37), UCEC prostate (0.47).

**But the mechanism still is not inter-gene correlation.** CAMERA's estimated correlation vs Tier 1 p: Spearman −0.19; the full VIF (1 + (m−1)·ρ): −0.23. Two corrections agree on *outcomes* while disagreeing on the *quantity* said to drive them. **P3 stays failed.**

### Survivors: 6 of 99
Passing nominal significance, BH, CAMERA **and** Tier 1, confirmed at 1,000 draws:

| Cohort | Program | β | BH p | CAMERA p | Tier 1 p (1,000 draws) |
|---|---|---|---|---|---|
| HNSC | pancreas | 0.781 | 4.7×10⁻¹⁰ | 0.017 | **0.000** |
| HNSC | kidney | 0.694 | 2.8×10⁻⁹ | 0.025 | **0.000** |
| LUAD | pancreas | 0.899 | 1.1×10⁻²⁰ | 0.041 | **0.005** |
| HNSC | liver | 0.502 | 5.6×10⁻⁵ | 0.033 | 0.037 |
| STAD | thyroid gland | 0.627 | 7.7×10⁻⁵ | 0.043 | 0.041 |
| HNSC | intestine | 0.519 | 2.6×10⁻⁵ | 0.050 | 0.043 |

Attrition: 99 → 43 (BH) → 15 (Tier 1) → 6 (CAMERA). **Perfect nesting** — nothing passes a later filter having failed an earlier one, so the three can be presented as a sequence rather than as competing criteria.

Three of six sit just under 0.05 even at 1,000 draws and must be reported as borderline. Only kidney and the two pancreas results are strong.

### HNSC caveat — four of six survivors come from one cohort
HNSC deficient tumours have mean purity 0.57 vs 0.49 in intact (t-test p = 5.4×10⁻⁴). Purity is a covariate, but a difference this large in the cohort producing most of the survivors means those results depend on the purity adjustment being correct. Goes in limitations.

HNSC was not in the hypothesis, is not a confirmatory cohort, and has essentially no LKB1 lineage literature. Its results are exploratory and unanticipated.

### DE-density hypothesis — suggestive, not established
Proposed mechanism: a real grouping shifts *many* genes slightly, so a random gene set drawn from that transcriptome contains affected genes by construction and is not null with respect to the grouping. This is background differential-expression density, **not** inter-gene correlation — which would explain why CAMERA's VIF fails to predict the floor while CAMERA's p-values still agree with it.

Tested `pct_t_gt2` (percentage of 2,000 random genes with |t| > 2 between groups) against standardized floor:

| Cohort | % genes \|t\|>2 | floor_std |
|---|---|---|
| LUAD | 56.0 | 7.68 |
| COADREAD | 49.3 | 4.21 |
| BRCA | 48.6 | 5.98 |
| HNSC | 35.4 | 2.99 |
| STAD | 32.0 | 3.28 |
| UCEC | 29.4 | 2.91 |
| CESC | 26.9 | 4.37 |
| LUSC | 26.1 | 4.08 |

**Spearman 0.48, R² = 0.57.** Better than sample size (0.09) or inter-set correlation (0.17), but the weaker Spearman indicates the fit is driven by the extremes. Counterexamples: COADREAD 49.3% → 4.21 vs BRCA 48.6% → 5.98; HNSC 35.4% → 2.99 vs LUSC 26.1% → 4.08.

**Suggestive, not established.** It also supplies a specific parameter to vary in simulation, which is the natural next test.

### Next
1. **Public timestamp of the pre-specification** — OSF or a GitHub repo where the commit history shows the pre-spec dated before results. Converts the project's strongest claim from an assertion into something verifiable. Highest priority.
2. Literature audit — 3–5 published papers using per-sample gene-set scores as regression outcomes; document whether any reports a correlation correction.
3. Simulation: control inter-gene correlation, DE density, group separation, group-size imbalance, set size and coherence independently; identify what actually drives the floor.
4. External validation outside TCGA (recount3, METABRIC, CPTAC, ICGC) and a second gene-set collection.
5. Package `calibrate_geneset()` with tests, vignette, documentation.
6. Paper draft, then preprint, then the STS report written fresh.

## 2026-09-23 (cont.) — Literature audit complete

Purpose: substantiate "a workflow where the correction is routinely omitted" with citations rather than assertion. Criterion: per-sample gene-set scores entered as the tested variable in a statistical model (not ssGSEA used incidentally for immune deconvolution before a LASSO gene signature).

**Adoption curve, from PubMed result counts for "ssGSEA score survival analysis Cox regression tumor":** 2 (2019), 11 (2020), 64 (2021), 138 (2022), 108 (2023), 100 (2024), 68 (2025), 57 (2026 to date). 518 total. Supports "widely used" with a number.

| Paper | Scoring | Score as tested variable | Correlation correction | Multiple testing |
|---|---|---|---|---|
| **PESSA**, Yang et al., *PLoS Comput Biol* 2024 (tool) | ssGSEA via GSVA/GSEABase | Yes — 13,434 gene sets × 238 datasets × 51 cancers, median and optimal cut-off, log-rank + `coxph` on dichotomised and continuous scores | None | None reported |
| **Glycolysis/CLN6**, Cai et al., *Acta Biochim Biophys Sin* 2026 | ssGSEA via GSVA 1.46.0 | Yes — Cox across Hallmark sets; top five by HR reported; glycolysis selected to build the paper | None | None |
| **Sarcoma six-gene**, Liu et al., *Aging* 2024 | ssGSEA | Yes — Hallmark sets scanned against OS to find "cancer hallmarks most associated with prognosis" | None | None reported |
| **STAD amino-acid**, Zhu et al., *Int Immunopharmacol* 2024 | ssGSEA via GSVA | Yes — 16 immune cell scores + 13 immune functions compared between risk groups; 26 of 29 significant | None | None |
| **CRC stemness**, Zheng et al., *Stem Cell Res Ther* 2022 | ssGSEA via GSVA 1.34.0 | Yes — 26 stemness scores, univariate Cox each, 13 retained at P < 0.05 | None | None |

**Statistical methods as written.** CRC stemness, in full: Wilcoxon for two groups, Kruskal–Wallis for multiple, Kaplan–Meier with log-rank, optimal cutoff via `surv_cutpoint`, "A P value < 0.05 was regarded as statistically significant." STAD amino-acid: t-test or Wilcoxon by distribution, ANOVA or Kruskal–Wallis, "P < 0.05." Neither mentions correction of any kind.

**A second, compounding inflation source.** PESSA and the CRC stemness paper both use optimal-cutpoint dichotomisation. PESSA states the optimal cut-off "relies on the method of selecting the most significant p-value." Minimum-p-value cutpoint selection is separately known to inflate type I error and requires its own correction. Neither applies one.

**Notable:** the CRC stemness paper reports Spearman correlations *among* its 26 ssGSEA scores in a supplementary figure — the authors observed the correlation structure and still did not account for it in testing.

**Phrasing constraint for the write-up:** absence from a methods section is not proof of absence in practice. The claim is "no correction is reported," not "no correction was applied."

A third search ("GSVA score correlation clinical variable linear model tumor") returned nothing additional on target. Audit closed at five papers.

## 2026-09-23 (cont.) — The nine discordant cases, and HNSC is not a purity artifact

### CAMERA vs Tier 1: the disagreement is about set size, not correlation

Across 99 tests: 6 pass both, 84 fail both, 9 pass Tier 1 but fail CAMERA, **0 the reverse**. The perfect asymmetry warranted characterisation.

Median values by class:

| Class | n | median set size (m) | median inter-gene cor (ρ) | median \|β\| |
|---|---|---|---|---|
| both | 6 | **371** | 0.048 | 0.66 |
| Tier 1 only | 9 | **220** | 0.035 | 0.51 |
| neither | 84 | **164** | 0.033 | 0.18 |

**My prior hypothesis — that CAMERA fails weakly correlated sets — is not supported.** ρ barely differs between classes (0.048 vs 0.035), and HNSC prostate is discordant at ρ = 0.057, higher than several concordant cases. What separates the classes is **m**.

Every concordant survivor has m ≥ 297. Nearly every discordant case has m ≤ 231: prostate (124) in HNSC, STAD and UCEC; thyroid (170) in HNSC; adrenal (220) in CESC and LUSC; stomach (231) in HNSC. Exceptions: COADREAD kidney (445), and STAD thyroid (170) which passes CAMERA at 0.043.

**Mechanism.** CAMERA's variance inflation factor is 1 + (m−1)ρ. At ρ ≈ 0.04, a 124-gene set carries VIF ≈ 6 and a 941-gene set VIF ≈ 40 — so CAMERA penalises large sets far more heavily, yet large sets are the ones that pass, because the test statistic also gains power with m. The net effect favours large sets.

**Statable regime: CAMERA is conservative for small gene sets at low inter-gene correlation, relative to a matched-random empirical null.** This is a finding about a widely used method (limma, 2012), not about the present analysis. It is post hoc and derived from 99 observations in one dataset; the proper test is simulation varying m and ρ independently, which is now a concrete reason to run one.

### HNSC purity stratification — the signal holds

Four of six survivors are HNSC, where deficient tumours have higher purity (0.57 vs 0.49, p = 5.4×10⁻⁴). Tested by splitting into purity terciles and refitting the full model within each.

Group sizes: low 145/24, mid 152/14, high 114/45 (intact/deficient).

| Program | β full | p full | β low | β mid | β high |
|---|---|---|---|---|---|
| pancreas | 0.781 | 3.6×10⁻¹¹ | 1.052 | 0.779 | 0.591 |
| kidney | 0.694 | 4.2×10⁻¹⁰ | 0.838 | 1.061 | 0.484 |
| liver | 0.502 | 1.7×10⁻⁵ | 0.253 | 1.071 | 0.489 |
| intestine | 0.519 | 5.9×10⁻⁶ | 0.731 | 0.611 | 0.369 |

**All four are positive in all three strata.** No stratum abolishes the effect; nothing reverses. Liver is weakest at low purity (0.253) but still positive.

There is a gradient — three of four decline as purity rises — worth reporting, but the conclusion is that **the HNSC result is not an artifact of purity imbalance.** It moves from caveat to finding: an unanticipated, exploratory, tissue-specific result in a cohort that was never part of the hypothesis and has essentially no LKB1 lineage literature.

### Remaining
1. **Public timestamp of the pre-specification** — not done. Still the highest-value outstanding item.
2. Simulation varying m, ρ, DE density, group separation and imbalance independently.
3. External validation outside TCGA; second gene-set collection.
4. Package `calibrate_geneset()`.
5. Paper draft.
