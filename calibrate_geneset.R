calibrate_geneset <-
function(expr, sets, group, covariates = NULL,
                              n_null = 100, seed = 1, score_fn = NULL) {
    stopifnot(ncol(expr) == length(group))
    expr <- expr[apply(expr, 1, sd) > 0, ]
    if (is.null(score_fn)) score_fn <- function(m, s)
        GSVA::gsva(GSVA::ssgseaParam(m, s, normalize = FALSE), verbose = FALSE)
    z <- function(x) (x - mean(x)) / sd(x)
    
    gm   <- rowMeans(expr)
    dec  <- cut(gm, quantile(gm, 0:10/10), include.lowest = TRUE, labels = FALSE)
    names(dec) <- rownames(expr)
    univ <- setdiff(rownames(expr), unlist(sets))
    pool <- split(univ, dec[univ])
    
    set.seed(seed)
    obs <- score_fn(expr, lapply(sets, intersect, rownames(expr)))
    dat <- data.frame(grp = group, covariates)
    
    out <- lapply(names(sets), function(p) {
        g <- intersect(sets[[p]], rownames(expr))
        need <- table(dec[g])
        draws <- replicate(n_null,
                           unlist(lapply(names(need), function(k) sample(pool[[k]], need[[k]]))), simplify = FALSE)
        S <- score_fn(expr, setNames(draws, paste0("n", seq_len(n_null))))
        f <- if (is.null(covariates)) "y ~ grp" else
            paste("y ~ grp +", paste(names(covariates), collapse = " + "))
        bet <- function(y) coef(lm(as.formula(f), data = cbind(dat, y = z(y))))[2]
        b_obs <- bet(obs[p, ]); nb <- apply(S, 1, bet)
        data.frame(set = p, beta = b_obs,
                   p_nominal = coef(summary(lm(as.formula(f), data = cbind(dat, y = z(obs[p, ])))))[2, 4],
                   p_empirical = mean(abs(nb) >= abs(b_obs)),
                   floor_95 = quantile(abs(nb), 0.95))
    })
    do.call(rbind, out)
}
