# Call preparation

## The two-minute version, out loud

> I was testing a biological hypothesis — whether LKB1 loss lets tumours express lineage programs foreign to their tissue — and I pre-registered it with a control: every result had to beat random gene sets matched on size and expression level.
>
> The hypothesis failed. But the control killed 65% of my own results that had already survived Benjamini–Hochberg correction. One had a BH p of 3×10⁻⁵ and random gene sets beat it 58% of the time.
>
> So I stress-tested the control itself, and found it's anti-conservative when the gene set is internally coherent — type I error 0.255 at 900 genes. Then I found out why it can't be fixed: real tissue programs reach mean inter-gene correlation of 0.245, and random draws of the same size max out at 0.021. You can't match what you can't reach.
>
> Rotation testing handles that case correctly, but over-rejects for small sets. So no method works everywhere, and which one you should use depends on set size and coherence.
>
> It replicates on a different platform in an independent cohort, and I've released it as an R package that runs the check and refuses to vouch for its own answer when the set is too coherent.

**Practise this until it takes 90 seconds without notes.** Then stop talking.

## Four slides, if screen-sharing

1. **The attrition.** 99 tests → 43 BH-significant → 15 survive empirical → 6 survive CAMERA too.
2. **The impossibility.** Bar chart: 14 real program coherences against the random-draw maximum of 0.021.
3. **The regime map.** Type I error table, Tier 1 vs ROAST, across m and ρ.
4. **The replication.** GSE72094 floors 4.66–5.81 against theoretical 1.96.

## The ask, at the end

Pick one, don't stack them:
- "Does the reasoning hold?"
- "Is this worth writing up, given CAMERA and ROAST?"
- "Is there someone in your group I could work with?"

## Papers to read before any call

| Paper | Why it matters | What to be able to say |
|---|---|---|
| **Goeman & Bühlmann 2007**, *Bioinformatics* | The competitive vs self-contained distinction | My nominal regression p-values are self-contained tests; the random-set comparison is an attempt at a competitive test. The random-split control (floor 1.50, below theoretical 1.96) fits that reading exactly. |
| **Wu & Smyth 2012**, *NAR* (CAMERA) | The correction the field considers necessary | Estimates ρ from the set itself and inflates the variance. My empirical null is a cruder route to the same place, which is why they agree 90/99. |
| **Efron & Tibshirani 2007**, *Ann Appl Stat* (GSA) | Restandardization combines gene randomization with sample permutation | May be the principled fix for my coherence problem — I plan to test it. **Read carefully before emailing Tibshirani.** |
| **Li et al. 2022**, *Genome Biology* | DESeq2 and edgeR FDR exceeded 20% at a 5% target on large human population samples; they recommend Wilcoxon | Same shape of finding: a trusted method, audited by permutation, with a striking failure rate. |
| **Tamayo et al. 2016** | Limits of assuming gene independence in gene set analysis | Verify the exact claim before citing. |
| **Venet, Dumont & Detours 2011**, *PLoS Comput Biol* | Random gene signatures predicted breast cancer outcome about as well as published ones | **Probably my closest ancestor. Read this first.** |
| **Geistlinger et al. 2021** | Benchmarking standard for enrichment methods; GSEABenchmarkeR has random-set evaluation | The compendium I would test against at scale. |
| **Phipson & Smyth 2010** | Permutation p-values should never be zero | I had this bug; (b+1)/(n+1) now. |

## A live disagreement to know about

**Li et al. 2022 used permutation of sample labels as their null.** In his first reply to me, Smyth called precisely that a fallacy — permuting labels on a cancer dataset whose real groups differ produces data with higher dispersion and often genuine DE, and he says it has caused published false conclusions.

Two people on my contact list disagree about a foundational point. Worth asking each of them directly, and worth not taking a side until I understand both arguments.

## Hard questions, and honest answers

**"Why not just use CAMERA?"**
You should, and I say so. My contribution is quantifying what happens when people don't, in a workflow where nobody reports doing it, plus showing the obvious alternative can't be repaired.

**"Isn't this Venet 2011?"**
Venet showed random signatures predict outcome as well as published ones. Mine is about the null distribution for testing a score, not about predictive performance. But it's close and I cite it as the ancestor. *(Verify by reading it.)*

**"Isn't your simulation the problem?"**
It was, twice. My first grid induced correlation with a single latent factor, making set and background equally correlated — that result reflected the design, not CAMERA, and I threw it out. The second grid separates them. I report both.

**"Why does your coherence flag fire on true positives?"**
Because a real effect creates coherence. The flag can't distinguish "coherent because it's a real gene set" from "coherent because the effect is real." Computing coherence on residuals after regressing out the group should separate them — that's next.

**"Is HNSC confounded?"**
Deficient HNSC tumours have higher purity, p = 5×10⁻⁴. But all four programs stay positive across all three purity terciles, so it isn't purity. It's also exploratory and unanticipated, and I report it as such.

**"Your novelty claim has shrunk repeatedly. What's actually new?"**
Five times, and I found each one myself by searching. What's left: the workflow, the quantification, the impossibility result, and the ROAST small-set behaviour. I'd rather state that precisely than overclaim.
