# Census protocol — pre-registration
**Timestamp this on OSF BEFORE screening any paper. Do not read results sections first.**

Version 1 · 2026-09-28 · Joel Minocha

---

## Purpose

To establish, for a defensible and exactly reproducible sample of published studies, what fraction of their reported gene-set findings survive a test that accounts for inter-gene dependence.

**This is not an accusation of error.** The framing throughout is: *this analysis would have been affected by a problem no correction was available for at the time of publication.* Neutral wording is a requirement of the protocol, not a courtesy.

---

## Design decision, recorded in advance

A larger sample of loosely reproduced papers was considered and **rejected**. Reconstructing a grouping variable from an incomplete methods section risks reporting that a paper's finding fails when the reconstruction is what failed. With authors contacted and results made public, that error would be serious.

**Target: 10 to 15 papers reproduced exactly.** A smaller defensible number is preferred to a larger fragile one.

---

## Inclusion criteria

A paper enters the census only if **all five** hold.

**1. Grouping is unambiguous.** The variable dividing samples is one of: a named gene's mutation status; a named clinical variable with a stated threshold; or an explicitly published sample list. Phrases such as "high versus low expression" without a stated cut-off **fail** this criterion.

**2. Data are public.** TCGA study identifier or GEO accession stated in the paper.

**3. Scoring method is implementable.** Method named (ssGSEA, GSVA, mean-z, or other), gene sets identified by collection and version or supplied as a table, and any normalisation stated.

**4. The statistical test is identifiable.** The reported test — t-test, Wilcoxon, linear model, Cox, log-rank — is stated or unambiguous from the figure.

**5. Reproduction succeeds.** *The success check.* Their reported nominal result reproduces to within a stated tolerance **before any calibration is applied.**

Tolerance, fixed in advance:
- p-values: within one order of magnitude, and on the same side of 0.05
- effect sizes, hazard ratios, correlations: within 25% relative
- counts of significant sets: within 20%

**A paper that fails criterion 5 is EXCLUDED, not counted as a failure.** This is what makes the census defensible.

---

## Screening procedure

1. Draw the candidate pool from the PubMed search already recorded: per-sample gene set scores used as tested variables, 518 papers.
2. Screen in a pre-fixed order — most recent first — and record every decision including exclusions and their reason.
3. Stop when 15 papers have passed criterion 5, or when 60 papers have been screened, whichever comes first.
4. Record the screening log in full, including papers excluded at each criterion.

**Do not screen selectively.** Working through in a fixed order, recording every exclusion, is what prevents the sample being chosen to produce a particular answer.

---

## Analysis, for each included paper

1. Reproduce the original analysis exactly. Record the reproduced value against the published one.
2. Compute `sep_index` for their grouping and record the predicted floor.
3. Apply three dependence-aware tests: the matched-random empirical null, `limma::camera`, and `rSEA::SEA`.
4. Record, for each reported finding: survives all three, survives some, survives none.
5. Record disagreements between methods. **Do not pick a favourite.**

---

## Reporting

**Primary outcome:** of N findings reproduced exactly, how many survive all three dependence-aware tests.

**Secondary:** the distribution of predicted floors across the included cohorts; agreement among the three methods; the exclusion log.

**Required wording.** Findings that do not survive are described as *"not distinguishable from a matched-random gene set under a competitive test."* They are **never** described as wrong, false, irreproducible or erroneous.

**Author contact.** Every included paper's corresponding author is contacted with the result before any public posting, with at least 30 days to respond, and any response is reported.

---

## Pre-registered expectation

Based on the regime map, most included cohorts will fall in the moderate-to-severe range (predicted floor above 3), and **more than half** of reproduced findings will not survive all three tests.

**Recording this in advance means a lower figure is also a result**, and will be reported as such.

---

## Deviations

Any departure from this protocol is recorded with its date and reason, and reported alongside the results.
