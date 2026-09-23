# Appendix A: Native lineage designations

**Status:** Fixed before any expression data were scored. Part of the pre-specification.
**Date:** 2026-09-20

---

## The rule

Native lineage is the normal, non-neoplastic cell of origin under the dominant histogenetic model, assigned at the cohort level.

Lineages that a **documented non-neoplastic process in that organ** would produce — metaplasia, precursor states, or the developmental ancestor of the native cell — are **masked**: dropped from scoring entirely, rather than counted as foreign.

Masking exists because a binary native/foreign split forces a bad trade. Call a metaplastic lineage native and you assert an origin you cannot defend; call it foreign and your top hits are known benign biology. Masking states something narrower and true: this lineage is not scored in this cohort because a non-tumor explanation is documented and cannot be separated from a plasticity event with these data.

### Consequences accepted in advance

1. **Masking is conservative.** It forfeits detection of intestinal programs in EAC and STAD and gastric programs in COADREAD — which is plausibly where real transdifferentiation lives. This is the price of not arguing about metaplasia in review.
2. **Where a cohort contains two diseases with different origins, split by histology before masking.** Splitting is preferred to multi-native assignment whenever sample size allows, because multi-native enlarges the native set for every sample, including those that did not require it.
3. **Where the candidate native set cannot be bounded** — where naming all plausible origins absorbs enough of the transcriptome that "foreign" loses meaning — exclude the cohort.

---

## Designations

| Cohort | Native lineage | Masked | Status |
|---|---|---|---|
| LUAD | Alveolar type II | — | Confirmatory |
| STAD | Gastric glandular (pit/isthmus/chief) | Intestinal | Confirmatory |
| LUSC | Airway basal | — | Exploratory |
| HNSC | Basal keratinocyte | — | Exploratory |
| COADREAD | Intestinal epithelium | Gastric | Exploratory |
| ESCA → ESCC | Esophageal squamous basal | — | Exploratory |
| ESCA → EAC | Gastric/glandular | Intestinal, squamous | Exploratory |
| BRCA | Mammary epithelium (luminal + basal/myoepithelial) | — | Exploratory |
| CESC | Split: squamous / endocervical glandular | — | Exploratory |
| UCEC | Endometrial glandular | Squamous (morular differentiation) | Exploratory |
| SKCM | Melanocyte | Neural crest and derivatives | Exploratory |
| OV | Tubal secretory + ovarian surface epithelium | — | Flagged, exploratory only |
| SARC | — | — | **Excluded** |

Thirteen rows: twelve signature-validated cohorts, with ESCA split into ESCC and EAC. SARC is excluded, leaving twelve scoreable entities.

---

## The rule fires three times, identically

Intestinal metaplasia of gastric mucosa (STAD), Barrett's oesophagus preceding EAC, and gastric-type differentiation in sessile serrated lesions preceding BRAF-mutant right-sided colorectal cancer (COADREAD, MUC5AC and MUC6 expression) are all documented non-neoplastic lineage change in the organ in question. One rule, three cohorts, no cohort-specific clause.

COADREAD is masked cohort-wide rather than split into serrated and conventional pathways, because that split is probabilistic — BRAF status, CIMP, and sidedness, none definitive — and a fuzzy split is worse than a clean conservative rule.

**Accepted cost, stated in advance:** masking gastric programs in COADREAD may remove the dominant foreign-lineage signal in the serrated subset. If the colorectal result depends on gastric programs, it is confounded with serrated-pathway differentiation and cannot be separated with these data. That will be reported as such.

## Asymmetry between the two confirmatory cohorts

Intestinal programs are masked in STAD, while a gastric or intestinal program in LUAD would be a scoreable foreign lineage. This is the rule applying identically in both cases, not an exception: intestinal metaplasia of gastric mucosa is a documented non-neoplastic process; intestinal metaplasia of alveolar epithelium is not. The rule is organ-specific by construction, and its asymmetric consequences follow from the biology rather than from the analysis.

---

## Contested designations

These five calls are judgment rather than convention, and are the designations most likely to be challenged.

### SKCM — neural crest masked

Melanocytes are neural crest derivatives, so a neural program in melanoma is movement back along its own developmental lineage. The claim this study makes is transdifferentiation: a tumour acquiring the identity of an unrelated cell type. Dedifferentiation toward origin is a different phenomenon with a different mechanism, and allowing the first to count as evidence for the second would be a category error.

Counting neural crest as foreign would also fail in a systematic rather than random way. Every melanoma with a dedifferentiated phenotype would inflate the foreign score, and that inflation tracks a known melanoma cell state — the MITF-low / AXL-high axis — so it would not average out across samples.

Forfeited: genuine neural transdifferentiation in melanoma becomes undetectable. Accepted, because it could not be distinguished from dedifferentiation with these data in any case.

**Boundary of the mask.** The mask is drawn at the melanocyte's own developmental trajectory, not at the ancestral tissue's full potency. Neural crest gives rise to Schwann cells, peripheral neurons, adrenal chromaffin cells, craniofacial cartilage and some smooth muscle, but a melanoma does not pass through those states on its way to being a melanocyte. Masking the full derivative tree would remove a large fraction of the foreign space in SKCM without justification; masking the trajectory removes only what dedifferentiation toward origin could plausibly revert to.

Masked: neural crest, migratory neural crest, melanoblast, and melanocyte-precursor programs.
Not masked: differentiated Schwann cell, peripheral neuronal, adrenal chromaffin, chondrocytic and smooth muscle programs.

*Open:* Schwann cell precursors are a documented alternative source of melanocytes in some contexts, which places them at a genuine branch point. Decide explicitly whether SCP programs fall inside the trajectory mask, and record the decision here before scoring.

### BRCA — whole mammary epithelial compartment native

Luminal and basal/myoepithelial cells are both resident cell types of normal breast. Neither is foreign to the organ.

Luminal versus basal is a subtype axis within the tissue — it is how breast cancer is classified, not evidence of lineage escape. Designating only luminal as native would cause basal-like tumours to score high by construction, and the top hits would be a recapitulation of PAM50 rather than a discovery.

This is the rule applied correctly rather than a compromise: the rule designates the normal cell of origin as native, and both are normal cells of this organ.

Forfeited: luminal-to-basal plasticity, which is real and interesting, becomes invisible. It is a within-tissue question and belongs to a different study design.

### ESCA — split into ESCC and EAC

TCGA's own ESCA marker paper found the two to be molecularly distinct diseases, with EAC resembling chromosomally unstable gastric adenocarcinoma more than it resembles ESCC.

The origins differ accordingly: ESCC from esophageal squamous basal cells, EAC from Barrett's oesophagus, which is already intestinalised columnar epithelium.

The consequential move is treating EAC as gastroesophageal at the point of cohort definition, which resolves the Barrett's problem before scoring occurs. The alternative — a single ESCA cohort carrying a complicated mask — places the fix downstream, where it is harder to defend. This is consequence 2 of the rule operating as written, which is worth stating plainly, because it shows the rule generating the decision rather than the decision being retrofitted to the rule.

### SARC — excluded

SARC fails the rule twice.

It fails on native lineage: TCGA-SARC pools leiomyosarcoma, dedifferentiated liposarcoma, undifferentiated pleomorphic sarcoma, myxofibrosarcoma and synovial sarcoma. There is no cohort-level cell of origin, and synovial sarcoma's origin is itself unresolved.

It fails on the foreign set: for a mesenchymal tumour, the foreign set necessarily includes fibroblast and endothelial programs, which are precisely the contaminating populations present in every bulk tumour. The signal and the artifact are the same genes.

Purity adjustment does not resolve this. Purity indicates how much non-tumour tissue is present, not which non-tumour tissue. Adjusting for stromal fraction in a tumour whose native lineage is stromal removes the biology along with the confound.

The rule was written before the cohorts were examined, and SARC fell out of it. Keeping the cohort would have been preferable; the exclusion follows from the rule rather than from the data.

### OV — flagged, not excluded

Two competing origins are proposed: the fallopian tube secretory cell (the STIC model, now dominant) and the ovarian surface epithelium (the older view).

Both are Müllerian, so the candidate native set remains bounded. This is what separates OV from SARC — consequence 3 does not fire.

Multi-native assignment is the honest response to an unsettled question in the field rather than a hedge. A null result in OV is uninformative, because the enlarged native set reduces power to detect anything foreign. Wherever OV appears in the results, the model dependence is to be stated in the same sentence.

---

## Program-specificity check (prerequisite, before scoring)

Gastric and intestinal epithelium are both foregut-derived glandular epithelium with substantial shared transcriptional programs. Independent of metaplasia, a gastric gene set scored in colonic tissue may be elevated through shared glandular identity rather than lineage change.

Before scoring any tumour data, each program pair used in this analysis will be tested for discrimination between the corresponding **normal** tissues in GTEx. Program pairs that fail to separate normal tissue are uninformative in both directions and will be excluded, with the exclusion recorded here.

---

## Consequence 4 (added 2026-09-21)

**Where the specificity gate removes a program that a cohort requires as native, that cohort is excluded.** A native lineage that cannot be scored cannot be excluded from the foreign set. The resulting asymmetry produces *false positives*, not merely reduced power.

This is a distinct failure mode from consequence 3 and must not be folded into it. Consequence 3 is a **designation** failure: too many plausible origins, the native set unbounded, the foreign set colliding with the principal contaminants (SARC). Consequence 4 is a **measurement** failure: the native set is bounded and small, but a required program cannot be scored. Stretching one rule to cover both would invite the question of what else has been stretched.

### OV — excluded under consequence 4

OV was designated multi-native: tubal secretory cell (STIC model, dominant) plus ovarian surface epithelium (older view).

The fallopian tube program **fails the specificity gate**: rank 2, margin −1.20, beaten by Testis. Inspection showed the overlap is axonemal and ciliogenesis machinery — CFAP53, CFAP276, CFAP206, DNAAF8, SPAG6, TCTE1, DRC7, DAW1, TTC29, DYNLRB2, ZMYND10, RIBC2, DEUP1 — shared between fallopian tube motile cilia and sperm flagella. Genuine shared biology, not contamination.

A rescue was attempted on the same pattern as the immune purge: removal of GO:0044782 (cilium organization, 427 genes) stripped 57 genes from the set. The program still failed, margin −0.84. **The program dies on evidence after a fair attempt to rescue it**, as cervix did.

Excluding only the tubal half would leave OV with ovarian surface epithelium as its sole native lineage — the *minority* hypothesis. Every tumour whose true origin is tubal would then score its own native lineage as foreign. Under the dominant model that is most of the cohort. The result would be a systematic false positive, in the direction of the hypothesis, concentrated in the samples most likely to be misassigned. That is the reason for exclusion, not the loss of power.

Note: the failure is partly an artifact of tissue-level rather than cell-type resolution. The designated origin is the *secretory* cell; HPA's tissue-level program pools secretory and ciliated epithelium. This is the granularity cost accepted in the C8 → HPA switch.

### SKCM — exclusion reasoning restated for HPA

SKCM was originally excluded during the C8 audit: C8 contains no adult skin atlas and its only melanocyte sets are ocular (GAUTAM_EYE choroid, cornea, iris), leaving cutaneous melanoma with no defensible native reference.

**That reason no longer applies as written.** The switch to HPA supplies a skin program (604 genes, gate margin 1.68, merged into pan-squamous).

The exclusion stands on a different argument: HPA's skin program is a **tissue** program, dominated by keratinocyte identity. Melanoma's native cell is the melanocyte, a neural-crest derivative resident in but not defining skin. Scoring melanoma against a keratinocyte-dominated program would treat the tumour's actual native lineage as unrepresented while offering a non-native program as native — the same asymmetry consequence 4 describes. No cutaneous melanocyte program is available in either collection.

The neural crest masking analysis and the melanocyte-trajectory boundary above are retained for record but are moot while SKCM is excluded.

---

## Cohorts analysed — stated explicitly

Twelve signature-validated cohorts, less three exclusions, with ESCA split:

| | |
|---|---|
| **Confirmatory (2)** | LUAD, STAD |
| **Exploratory (8)** | LUSC, HNSC, COADREAD, ESCC, EAC, BRCA, CESC, UCEC |
| **Excluded (3)** | SARC (consequence 3), SKCM (consequence 3), OV (consequence 4) |

**Ten analysed entities.** Note that LUSC, HNSC, ESCC and CESC all take pan-squamous as native following the merge, so ten cohorts carry **seven distinct native designations**.

All three exclusions were generated by rules and tests fixed before the data were examined. None was chosen for convenience; SARC and OV would both have been preferable to keep.

---

## Scored programs and control specification (fixed 2026-09-22)

The set of programs scored as foreign lineages is defined once, in `scored_programs.rds`, and is not reconstructed elsewhere.

| Scored (14) | Not scored, with reason |
|---|---|
| lung, stomach, intestine, liver, breast, endometrium, ovary, pancreas, kidney, prostate, thyroid gland, adrenal gland, urinary bladder, **pan-squamous** | lymphoid tissue, bone marrow — infiltrate, not lineage · testis — cancer-testis antigen derepression · fallopian tube — failed specificity gate · cervix, vagina, esophagus, skin — merged into pan-squamous |

**Tier 1 random-draw seed: 20260922.** 100 draws per scored program, matched on gene count and GTEx v11 expression decile, from a 13,664-gene universe.

---

## Amendment (2026-09-22): CESC and masks

**CESC → squamous only (n = 254).** Cervical adenocarcinoma and adenosquamous carcinoma excluded under **consequence 4**: their glandular native lineage has no scoreable program, since the cervix program was merged into pan-squamous and no endocervical glandular program exists. The CESC "split" designated above is therefore implemented as a restriction rather than a split. Native: pan-squamous.

**STAD — pancreas masked** (serosal/perigastric sampling; conservative resolution of a marginal case).

**UCEC — pan-squamous** remains masked; lower-segment extension to cervix added as a second reason alongside morular differentiation.

### Cohorts analysed — updated

| | |
|---|---|
| **Confirmatory (2)** | LUAD, STAD |
| **Exploratory (8)** | LUSC, HNSC, COADREAD, ESCC, EAC, BRCA, CESC (squamous only), UCEC |
| **Excluded (3 whole cohorts)** | SARC (consequence 3), SKCM (consequence 3), OV (consequence 4) |
| **Excluded (histologic subsets)** | CESC adenocarcinoma and adenosquamous (consequence 4) |

Consequence 4 has now fired twice — OV, and the CESC glandular subset — on the same measurement-failure logic.

---

## Mask table — consolidated (2026-09-22)

| Cohort | Native | Masked | Reason for mask |
|---|---|---|---|
| LUAD | lung | — | |
| STAD | stomach | intestine | Intestinal metaplasia of gastric mucosa — documented non-neoplastic lineage change |
| STAD | | pancreas | Serosal invasion and perigastric sampling; marginal case resolved conservatively |
| COADREAD | intestine | stomach | Gastric-type differentiation in sessile serrated lesions (MUC5AC, MUC6) |
| EAC | stomach (gastro-oesophageal) | intestine | Barrett's oesophagus — intestinalised columnar epithelium precedes EAC |
| EAC | | pan-squamous | Tumour arises within squamous oesophagus |
| ESCC | pan-squamous | — | |
| LUSC | pan-squamous | — | |
| HNSC | pan-squamous | — | |
| CESC (squamous) | pan-squamous | endometrium | Endocervical–endometrial anatomical continuity |
| UCEC | endometrium | pan-squamous | Morular differentiation; also lower-segment extension to cervix |
| BRCA | breast | — | |

**Scoreable programs: 14** — lung, stomach, intestine, liver, breast, endometrium, ovary, pancreas, kidney, prostate, thyroid gland, adrenal gland, urinary bladder, pan-squamous.
