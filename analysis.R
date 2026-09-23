# analysis.R — run after setup.R:  source("analysis.R")
# Defines the analysis layer. Loads defensively, so it works whether or not
# setup.R has been updated with the later objects.

suppressPackageStartupMessages({ library(GSVA); library(msigdbr) })

# ---- objects that may or may not be loaded by setup.R ------------------------
if (!exists("scored_sets"))   scored_sets   <- readRDS("scored_programs.rds")
if (!exists("t2c"))           t2c           <- readRDS("tier2_hallmark_purged.rds")
if (!exists("tier1"))         tier1         <- readRDS("tier1_draws.rds")
if (!exists("stromal_m"))     stromal_m     <- readRDS("stromal_markers.rds")
if (!exists("cu_restricted")) cu_restricted <- readRDS("coadread_ucec_restricted.rds")
if (!exists("stad_keep"))     stad_keep     <- readRDS("stad_complete_samples.rds")
if (!exists("esca_split"))    esca_split    <- readRDS("esca_histology_split.rds")
if (!exists("cesc_keep"))     cesc_keep     <- readRDS("cesc_histology_filter.rds")
if (!exists("calls"))         calls         <- readRDS("lkb1_calls.rds")
if (!exists("pur"))           pur <- read.delim("TCGA_mastercalls.abs_tables_JSedit.fixed.txt",
                                                check.names = FALSE)

sig_ez <- as.character(sym2ez[sig$symbol_current])

# ---- Tier 2, immune-purged only (the "unpurged" arm of Amendment 6) ----------
# t2c has lineage-shared genes removed; t2 does not. Both share the immune purge.
imm2       <- unique(AnnotationDbi::select(org.Hs.eg.db, keys = "GO:0045321",
                                           keytype = "GOALL", columns = "SYMBOL")$SYMBOL)
ig         <- grep("^IG[HKL][VDJC]|^IGH[ADEGM]|^JCHAIN", rownames(lmat_std), value = TRUE)
purge_list <- union(imm2, ig)
hm         <- msigdbr(species = "Homo sapiens", collection = "H")
t2_names   <- c("HALLMARK_E2F_TARGETS","HALLMARK_G2M_CHECKPOINT","HALLMARK_HYPOXIA",
                "HALLMARK_OXIDATIVE_PHOSPHORYLATION","HALLMARK_MYC_TARGETS_V1",
                "HALLMARK_INTERFERON_GAMMA_RESPONSE")
t2 <- setNames(lapply(t2_names, function(n)
  setdiff(hm$gene_symbol[hm$gs_name == n], purge_list)), t2_names)

# ---- analysis entities -------------------------------------------------------
entities <- list(
  luad = list(cd = "luad"),
  stad = list(cd = "stad", keep = stad_keep),
  lusc = list(cd = "lusc"), hnsc = list(cd = "hnsc"),
  coadread = list(cd = "coadread"), brca = list(cd = "brca"), ucec = list(cd = "ucec"),
  escc = list(cd = "esca", keep = esca_split$sampleId[esca_split$histology == "ESCC"]),
  eac  = list(cd = "esca", keep = esca_split$sampleId[esca_split$histology == "EAC"]),
  cesc = list(cd = "cesc", keep = cesc_keep$sampleId[cesc_keep$keep]))

# foreign = 14 scoreable programs - native - masked (Appendix A consolidated table)
foreign <- list(
  luad     = setdiff(names(scored_sets), "lung"),
  stad     = setdiff(names(scored_sets), c("stomach","intestine","pancreas")),
  coadread = setdiff(names(scored_sets), c("intestine","stomach")),
  eac      = setdiff(names(scored_sets), c("stomach","intestine","pan_squamous")),
  escc     = setdiff(names(scored_sets), "pan_squamous"),
  lusc     = setdiff(names(scored_sets), "pan_squamous"),
  hnsc     = setdiff(names(scored_sets), "pan_squamous"),
  cesc     = setdiff(names(scored_sets), c("pan_squamous","endometrium")),
  ucec     = setdiff(names(scored_sets), c("endometrium","pan_squamous")),
  brca     = setdiff(names(scored_sets), "breast"))

# ---- helpers -----------------------------------------------------------------
z <- function(x) (x - mean(x)) / sd(x)

get_expr <- function(nm) {
  e <- entities[[nm]]; w <- readRDS(paste0("expr_", e$cd, "_raw.rds"))
  if (!is.null(e$keep)) w <- w[w$sampleId %in% e$keep, ]
  g <- setdiff(names(w), "sampleId")
  m <- t(as.matrix(w[, g, with = FALSE])); colnames(m) <- w$sampleId
  m <- m[rowSums(is.na(m)) == 0, ]
  rownames(m) <- names(sym2ez)[match(as.integer(rownames(m)), sym2ez)]
  log2(m[!is.na(rownames(m)) & !duplicated(rownames(m)), ] + 1)
}

# ssGSEA with normalize = FALSE so scores do not depend on what else is in the call
ss <- function(m, sets) gsva(ssgseaParam(m, lapply(sets, function(s) intersect(s, rownames(m))),
                                         normalize = FALSE), verbose = FALSE)

build <- function(nm) {
  sc <- readRDS(paste0("scores/", nm, ".rds"))
  d  <- calls[calls$entity == nm, ]
  d$purity <- pur$purity[match(d$sampleId, pur$array)]
  d <- d[!is.na(d$purity), ]
  L <- t(sc$lineage)[d$sampleId, foreign[[nm]], drop = FALSE]
  d$composite <- rowMeans(apply(L, 2, z))
  T2 <- apply(t(sc$tier2)[d$sampleId, ], 2, z)
  pc <- prcomp(T2); d$t2pc1 <- pc$x[, 1]
  st <- sc$stromal[d$sampleId, ]
  d$fib <- st[, "fibroblast"]; d$endo <- st[, "endothelial"]; d$adi <- st[, "adipocyte"]
  list(d = d, sc = sc, L = L, t2_var = summary(pc)$importance[2, 1])
}

fit2 <- function(nm, mode = "primary") {
  b <- build(nm); d <- b$d
  if (mode == "wt") { d <- d[d$genomic_loss == 0, ]; d$deficient <- d$sig_pos_wt }
  if (mode == "called") {
    called <- pur$array[pur$`call status` == "called"]; d <- d[d$sampleId %in% called, ]
  }
  ids <- d$sampleId
  m0 <- lm(composite ~ deficient + purity + fib + endo + adi, data = d)
  m1 <- lm(composite ~ deficient + purity + fib + endo + adi + t2pc1, data = d)
  c0 <- coef(summary(m0))["deficientTRUE", ]; c1 <- coef(summary(m1))["deficientTRUE", ]
  nb <- sapply(1:100, function(i) {
    y <- rowMeans(sapply(foreign[[nm]], function(p) z(b$sc$tier1[[p]][i, ids])))
    coef(lm(y ~ deficient + purity + fib + endo + adi + t2pc1, data = d))["deficientTRUE"]
  })
  data.frame(entity = nm, mode = mode, n = nrow(d), n_def = sum(d$deficient),
             beta = round(c1[1], 3), p = signif(c1[4], 3),
             attenuation = round(1 - c1[1]/c0[1], 2), tier1_p = mean(abs(nb) >= abs(c1[1])))
}

per_prog <- function(nm) {
  b <- build(nm); d <- b$d; ids <- d$sampleId
  out <- do.call(rbind, lapply(foreign[[nm]], function(p) {
    y  <- z(b$L[, p])
    cf <- coef(summary(lm(y ~ deficient + purity + fib + endo + adi + t2pc1,
                          data = d)))["deficientTRUE", ]
    nb <- sapply(1:100, function(i) coef(lm(z(b$sc$tier1[[p]][i, ids]) ~
                                              deficient + purity + fib + endo + adi + t2pc1, data = d))["deficientTRUE"])
    data.frame(entity = nm, program = p, beta = round(cf[1], 3), p = cf[4],
               tier1_p = mean(abs(nb) >= abs(cf[1])))
  }))
  out$p_bh <- signif(p.adjust(out$p, "BH"), 3); out$p <- signif(out$p, 3)
  out[order(out$p), ]
}

cat("analysis layer loaded:", length(entities), "entities,",
    length(scored_sets), "scored programs\n")