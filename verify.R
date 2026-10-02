# verify.R — regenerates the headline numbers from scratch.
# Run: setwd("~/lkb1-functional-loss"); source("verify.R")
source("setup.R"); source("analysis.R")
library(limma); library(msigdbr); library(rSEA)
hm_all <- split(msigdbr(species="Homo sapiens", collection="H")$gene_symbol,
                msigdbr(species="Homo sapiens", collection="H")$gs_name)
zz <- function(x) (x-mean(x))/sd(x)

cat("\n=== 1. Signature reproduction (expect LUAD AUROC 0.889) ===\n")
au <- function(nm) {
  b0 <- build(nm); d0 <- b0$d
  s <- d0$score; g <- d0$genomic_loss
  if (sum(g) < 3) return(NA)
  r <- rank(s); n1 <- sum(g); n0 <- sum(!g)
  (sum(r[g]) - n1*(n1+1)/2) / (n1*n0)
}
for (nm in c("luad","lusc","hnsc")) cat(nm, round(au(nm), 3), "n")

cat("\n=== 2. Native loss, LUAD (expect beta -0.0507, p 5.6e-24) ===\n")
b <- build("luad"); d <- b$d
mm <- get_expr("luad")[, d$sampleId]; mm <- mm[apply(mm,1,sd)>0, ]
g <- setdiff(intersect(scored_sets$lung, rownames(mm)), sig$symbol_current)
d$y <- colMeans(t(scale(t(mm[g, ]))))
print(round(summary(lm(y ~ score + purity + fib + endo + adi, data=d))$coef[2,], 4))

cat("\n=== 3. Separation index (expect median|t| 2.350, floor ~7.70) ===\n")
print(gscalibrate::sep_index(mm, d$deficient))

cat("\n=== 4. Floor, LKB1 vs random (expect ~7.0 vs ~1.4) ===\n")
set.seed(2); rnd <- sample(c(TRUE,FALSE), nrow(d), TRUE, c(0.25,0.75))
fl <- function(v) median(sapply(names(hm_all)[1:15], function(p) {
  gg <- intersect(hm_all[[p]], rownames(mm)); if (length(gg)<15) return(NA)
  nb <- replicate(50, coef(lm(zz(colMeans(mm[sample(rownames(mm), length(gg)), ])) ~ v))[2])
  quantile(abs(nb), .95)/sqrt(1/sum(v)+1/sum(!v)) }), na.rm=TRUE)
cat("LKB1:", round(fl(d$deficient),2), " random:", round(fl(rnd),2), "\n")

cat("\n=== 5. Hallmark attrition, LUAD (expect 38 BH, 6 Tier1) ===\n")
set.seed(1)
sc <- do.call(rbind, lapply(names(hm_all), function(p) {
  gg <- intersect(hm_all[[p]], rownames(mm)); if (length(gg) < 15) return(NULL)
  f <- function(i) colMeans(mm[i, , drop=FALSE])
  bq <- coef(lm(zz(f(gg)) ~ deficient + purity + fib + endo + adi, data=d))[2]
  nb <- replicate(100, coef(lm(zz(f(sample(rownames(mm), length(gg)))) ~
          deficient + purity + fib + endo + adi, data=d))[2])
  nom <- coef(summary(lm(zz(f(gg)) ~ deficient + purity + fib + endo + adi, data=d)))[2,4]
  data.frame(p_nom=nom, t1=(sum(abs(nb)>=abs(bq))+1)/101)
}))
sc$bh <- p.adjust(sc$p_nom, "BH")
cat("BH significant:", sum(sc$bh < 0.05), " Tier 1 survive:", sum(sc$t1 <= 0.05), "n")
cat("\nDone. Compare against FINDINGS_SUMMARY.md\n")
