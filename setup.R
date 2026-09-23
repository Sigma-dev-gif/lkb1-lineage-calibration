# setup.R — run at the start of every session:  source("setup.R")
# Restores everything from files on disk. Nothing here depends on the old workspace.

setwd("~/lkb1-functional-loss")

suppressPackageStartupMessages({
  library(httr); library(jsonlite); library(data.table); library(arrow)
  library(AnnotationDbi); library(org.Hs.eg.db)
})

# ---- signature ---------------------------------------------------------------
sig <- read.csv("lkb1_signature_mapped.csv")          # gene (legacy), coef, direction, symbol_current

# ---- lineage sets and gate provenance ----------------------------------------
sets_list    <- readRDS("hpa_tissue_sets_v25.1.rds")   # unpurged HPA sets
sets_purged2 <- readRDS("hpa_sets_purged_v25.1.rds")   # GO:0045321 + IG purge applied
prov         <- readRDS("gate_provenance.rds")
map <- prov$map
lcm <- prov$lcm_excluded
# correct the underscore/space mismatch that silently dropped three programs
names(map)[names(map) == "thyroid_gland"]  <- "thyroid gland"
names(map)[names(map) == "fallopian_tube"] <- "fallopian tube"
names(map)[names(map) == "adrenal_gland"]  <- "adrenal gland"
stopifnot(length(setdiff(names(map), names(sets_purged2))) == 0)

# ---- GTEx reference (for gate and Tier 1 deciles) ----------------------------
gtex_file <- "~/Downloads/GTEx_Analysis_2025-08-22_v11_RNASeQCv2.4.3_gene_median_tpm.gct.gz"
if (file.exists(gtex_file)) {
  gtex <- read.delim(gtex_file, skip = 2, check.names = FALSE)
  mat  <- as.matrix(gtex[, 3:ncol(gtex)]); rownames(mat) <- gtex$Description
  mat  <- mat[!duplicated(rownames(mat)), ]
  lmat_std <- log2(mat[, setdiff(colnames(mat), lcm)] + 1)
  rm(gtex, mat)
} else message("GTEx file not found in Downloads — gate functions unavailable")

score_prog <- function(genes, M = lmat_std) {
  gg <- intersect(genes, rownames(M))
  if (length(gg) < 15) return(NULL)
  colMeans(M[gg, , drop = FALSE])
}

# ---- sample labels ------------------------------------------------------------
status <- read.csv("data/derived/stk11_sample_status.csv")

# ---- cBioPortal gene registry and fetch list ----------------------------------
if (file.exists("cbio_genes.rds")) {
  all_genes <- readRDS("cbio_genes.rds")
} else {
  all_genes <- fromJSON(rawToChar(GET(
    "https://www.cbioportal.org/api/genes?projection=SUMMARY&pageSize=100000")$content))
  saveRDS(all_genes, "cbio_genes.rds")
}
sym2ez <- setNames(all_genes$entrezGeneId, all_genes$hugoGeneSymbol)
pc     <- all_genes[all_genes$type == "protein-coding", ]
nc     <- all_genes$hugoGeneSymbol[all_genes$type != "protein-coding"]

lin_all   <- unique(unlist(sets_purged2))
need      <- unique(c(lin_all, sig$symbol_current))
fetch_ids <- union(all_genes$entrezGeneId[all_genes$hugoGeneSymbol %in% need], pc$entrezGeneId)

# ---- functions ---------------------------------------------------------------
auroc <- function(s, y) {
  r <- rank(s); n1 <- sum(y == 1); n0 <- sum(y == 0)
  (sum(r[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

fetch_cohort <- function(code) {
  study <- paste0(code, "_tcga_pan_can_atlas_2018")
  get_ids <- function(sl) fromJSON(rawToChar(GET(paste0(
    "https://www.cbioportal.org/api/sample-lists/", study, "_", sl, "/sample-ids"))$content))
  rna <- get_ids("rna_seq_v2_mrna"); seq <- get_ids("sequenced")
  keep <- intersect(rna, seq)
  cat(code, ": rna", length(rna), "seq", length(seq), "intersect", length(keep), "\n")
  invisible(list(study = study, prof = paste0(study, "_rna_seq_v2_mrna"), samples = keep))
}

fetch_expr <- function(co, entrez_ids, chunk = 500, tries = 8) {
  chunks <- split(entrez_ids, ceiling(seq_along(entrez_ids) / chunk))
  out <- vector("list", length(chunks))
  for (i in seq_along(chunks)) {
    r <- NULL
    for (k in seq_len(tries)) {
      r <- try(POST(paste0("https://www.cbioportal.org/api/molecular-profiles/",
                           co$prof, "/molecular-data/fetch"),
                    body = toJSON(list(entrezGeneIds = chunks[[i]],
                                       sampleListId = paste0(co$study, "_rna_seq_v2_mrna")),
                                  auto_unbox = TRUE),
                    content_type_json(), timeout(900),
                    config(http_version = 2)), silent = TRUE)   # 2 = HTTP/1.1 in libcurl
      if (!inherits(r, "try-error") && status_code(r) == 200) break
      Sys.sleep(min(60, 5 * 2^(k - 1)))
    }
    if (inherits(r, "try-error") || status_code(r) != 200) { cat("chunk", i, "GAVE UP\n"); next }
    j <- fromJSON(rawToChar(r$content))
    if (!is.data.frame(j) || nrow(j) == 0) next
    out[[i]] <- j[, c("sampleId", "entrezGeneId", "value")]
    cat("chunk", i, "of", length(chunks), "\n")
    Sys.sleep(2)
  }
  do.call(rbind, out)
}

fetch_and_save <- function(cd) {
  co <- fetch_cohort(cd)
  d  <- fetch_expr(co, fetch_ids)
  wc <- dcast(as.data.table(d), sampleId ~ entrezGeneId, value.var = "value")
  wc <- wc[wc$sampleId %in% co$samples, ]
  saveRDS(wc, paste0("expr_", cd, "_raw.rds"))
  cat(cd, "saved:", nrow(wc), "x", ncol(wc) - 1, "\n")
  rm(d, wc); invisible(gc())
}

gap_fill <- function(cd) {
  f  <- paste0("expr_", cd, "_raw.rds"); wc <- readRDS(f)
  gap <- setdiff(fetch_ids, as.integer(colnames(wc)[-1]))
  if (length(gap) == 0) { cat(cd, "complete\n"); return(invisible(0)) }
  cat(cd, "refetching", length(gap), "genes\n")
  d <- fetch_expr(fetch_cohort(cd), gap)
  if (is.null(d)) { cat(cd, "nothing returned — remaining genes absent from profile\n"); return(invisible(length(gap))) }
  wg <- dcast(as.data.table(d), sampleId ~ entrezGeneId, value.var = "value")
  wc <- merge(wc, wg, by = "sampleId")
  saveRDS(wc, f)
  cat(cd, "now", nrow(wc), "x", ncol(wc) - 1, "\n")
  invisible(length(setdiff(fetch_ids, as.integer(colnames(wc)[-1]))))
}

cohorts <- c("luad","stad","lusc","hnsc","coadread","esca","brca","cesc","ucec")

check_files <- function() {
  for (cd in cohorts) {
    f <- paste0("expr_", cd, "_raw.rds")
    if (file.exists(f)) { x <- readRDS(f); cat(sprintf("%-9s %5d x %5d\n", cd, nrow(x), ncol(x) - 1)) }
    else cat(sprintf("%-9s MISSING\n", cd))
  }
}

cat("setup complete.", length(fetch_ids), "genes in fetch list\n")