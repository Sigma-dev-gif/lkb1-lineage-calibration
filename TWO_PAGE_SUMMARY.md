# When can a random gene set tell you anything?
### Calibration of per-sample gene set scores used as regression outcomes

**Joel Minocha** · September 2026
Code and pre-registration: github.com/Sigma-dev-gif/lkb1-lineage-calibration
R package: github.com/Sigma-dev-gif/gscalibrate

---

## The problem

Per-sample gene set scores — ssGSEA, GSVA, mean-z — are routinely computed and then treated as ordinary variables: compared between groups, entered into Cox models, correlated with stage or survival. PubMed returns 518 such papers, rising from 2 in 2019 to roughly 100 per year since 2022.

Of five I read in full, **none reported any correction for inter-gene correlation**, and most reported no multiple-testing correction either. One is a published tool that pre-computes survival analyses for 13,434 gene sets across 238 datasets and 51 cancer types.

The p-values these analyses produce assume genes are independent. They are not.

## What I did

I pre-registered a pan-cancer test of an unrelated biological hypothesis (whether LKB1 loss relaxes lineage constraint), with a control built in: each gene set's association was compared against 100 random gene sets matched on size and expression decile. Twelve dated amendments record every analysis choice before the data were seen.

## Four numbers

**1. 65% of significant results fail the control.** Across 99 per-program tests in eight TCGA cohorts, 43 were significant after Benjamini–Hochberg. **28 of those 43 failed empirical calibration.** No result ever survived the control while failing BH — the filters nest perfectly.

The clearest single case: LUAD endometrium, nominal p = 6.9×10⁻⁶, BH p = 3.0×10⁻⁵, empirical p = 0.58.

**2. An established correction agrees.** `limma::camera` on the same data agreed with the empirical control on 90 of 99 tests with **zero contradictions** in either direction (Spearman 0.74 between p-values). CAMERA is strictly more conservative.

**3. The control is itself anti-conservative for coherent sets.** In simulation with background ρ = 0.05 and set ρ = 0.15, type I error is **0.125 ± 0.023 at 250 genes and 0.255 ± 0.031 at 900 genes** (200 reps). Random draws are less internally correlated than the set being tested, so the null is too narrow.

**4. And it cannot be fixed by matching on correlation.** In TCGA LUAD, the fourteen tissue programs reach mean inter-gene correlation up to **0.245**. Random draws of the same size reach at most **0.021** — twelve-fold short, and even the least coherent program exceeds the random maximum. There is no candidate pool to match from, because coherence is what makes a gene set a gene set.

```
mean inter-gene correlation, TCGA LUAD

  lung  ████████████████████████  0.245
 pansq  ███████████████  0.153
 endom  ███████████  0.115
 ovary  ██████████  0.109
 stom.  █████████  0.094
   ...
  pros  ██  0.028
─────────────────────────────────────
random draws (n=50, m=250):
  max   ██  0.021
  med   █  0.013
```

Rescaling the null by the variance-inflation ratio was attempted at five exponents across four (m, ρ) configurations. **No single exponent works** — two cells need heavy correction, two need none and are broken by it.

## What is correct instead, and where it also fails

Rotation testing (`limma::roast`) preserves the observed correlation structure by construction. In the same simulation it gives type I error **0.060 at m = 250 and 0.065 at m = 900**, where the draw-based null gives 0.125 and 0.255. It is also 17× faster.

But ROAST **over-rejects at m = 75: 0.135 ± 0.024**, excluding 0.05. Rotation count (999 vs 4999) makes no difference, and alternative set statistics are worse (floormean 0.46, mean50 0.75).

**No method is universally correct.** Small gene sets are the hard regime for all three, for three different reasons — and this converges with the real-data result, where CAMERA rejected sets with m ≤ 231 that the empirical null passed.

## Replication outside TCGA

GSE72094 (Affymetrix array, 442 lung adenocarcinomas, STK11 status from sequencing: 68 mutant / 374 wild-type). Different platform, patients, institution and processing.

Standardized floors **4.66–5.81 against a theoretical 1.96** across all 14 programs. Four programs reach nominal significance; all four die at the empirical control. **Lung ρ = 0.245 — identical to the TCGA value on a different platform.**

## Relation to prior work

Gordon Smyth confirmed the underlying phenomenon by email: *"Randomizing gene sets is extremely anti-conservative because it ignores inter-gene correlations."* He has made the point on Bioconductor since 2024 regarding pre-ranked GSEA. **This is not presented as a discovery.**

What appears to be new: the workflow (per-sample scores as regression outcomes, where no correction is reported anywhere in the audit), the quantification, the impossibility result for draw-matching, and the ROAST small-set behaviour.

## What I am asking

Whether the reasoning holds; whether it is worth writing up given CAMERA, ROAST and Goeman & Bühlmann already exist; and whether the competitive vs self-contained framing is the right one.

I am also looking for a mentor for the next phase — plasmode simulation on real expression, a regime map across collections and cohorts, and a causal test using public LKB1 re-expression data.
