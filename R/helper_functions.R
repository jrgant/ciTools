# Copyright (C) 2017 Institute for Defense Analyses
#
# This file is part of ciTools.
#
# ciTools is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ciTools is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ciTools. If not, see <http://www.gnu.org/licenses/>.

get_x_matrix_mermod <- function(tb, fit){

    ## This function is necessary to avoid cases where the new data
    ## upon which CIs are generated does not contain all levels for
    ## one or more factors from the original data set. New and old
    ## data sets are appended, the model matrix is generated, and the
    ## function returns only the rows corresponding to the new data.

    ## Check for rank deficieny and correct the model matrix if
    ## necessary

    if (is.null(attr(fit@pp$X, "msgRankdrop"))){
        mm <- fit@frame
        terms <- attributes(terms(fit))$term.labels
    } else {
        terms_all <- attributes(terms(fit))$term.labels
        dropped <- attr(fit@pp$X, "col.dropped")
        mm <- fit@frame[, -dropped]
        dropped_terms <- names(dropped)
        terms <- setdiff(terms_all, dropped_terms)
    }

    rv <- names(mm)[1]
    mm[[rv]] <- as.numeric(mm[[rv]])

    for(i in names(mm)){
        if(is.factor(mm[[i]])) mm[[i]] <- as.character(mm[[i]])
    }
    suppressWarnings(mat <- model.matrix(reformulate(attributes(terms(fit))$term.labels),
                                         dplyr::bind_rows(mm, tb))[-(1:nrow(fit@frame)), ])
    if (dim(tb)[1] == 1)
        mat <- t(as.matrix(mat))
    mat
}



get_prediction_se_mermod <- function(tb, fit){

    X <- get_x_matrix_mermod(tb, fit)
    vcovBetaHat <- vcov(fit) %>%
        as.matrix
    X %*% vcovBetaHat %*% t(X) %>%
        diag %>%
            sqrt
}

make_formula <- function(fixedEffects, randomEffects, rvName = "y"){
    fixedPart <- paste(fixedEffects, collapse = "+")
    randomPart <- paste("+ (1|", randomEffects, ")")
    formula(paste(c(rvName, " ~ ", fixedPart, randomPart), collapse = ""))

}


add_predictions2 <- function (data, model, var = "pred", ...) {
    data[[var]] <- stats::predict(model, data, ...)
    data
}


get_resid_df_mermod <- function(fit){
    nrow(model.matrix(fit)) - length(fixef(fit)) -
        (length(attributes(summary(fit)$varcor)$names) + 1)
}

get_pi_mermod_var <- function(tb, fit, includeRanef){
    seFixed <- get_prediction_se_mermod(tb, fit)
    seG <- arm::se.ranef(fit)[[1]][1,]
    sigmaG <- as.data.frame(VarCorr(fit))$sdcor[1]
    se_residual <- sigma(fit)

    if(includeRanef)
        return(sqrt(seFixed^2 + seG^2 + se_residual^2))
    else
        return(sqrt(seFixed^2 + sigmaG^2 + se_residual^2))
}

calc_prob <- function(x, quant, comparison){
    if (comparison == "<")
        mean(x < quant)
    else if (comparison == ">")
        mean(x > quant)
    else if (comparison == "<=")
        mean(x <= quant)
    else if (comparison == "=<")
        mean(x <= quant)
    else if (comparison == ">=")
        mean(x >= quant)
    else if (comparison == "=>")
        mean(x >= quant)
    else if (comparison == "=")
        mean (x == quant)
    else
        stop ("Malformed probability statement, comparison must be <, >, =, <=, or >=")
}

my_pred_full <- function(fit) {
    predict(fit, newdata = ciTools_data$tb_temp, re.form = NULL)
}

my_pred_fixed <- function(fit) {
    predict(fit, newdata = ciTools_data$tb_temp, re.form = NA)
}

my_pred_full_glmer_response <- function(fit, lvl) {
    predict(fit, newdata = ciTools_data$tb_temp, re.form = NULL, family = fit@resp$family$family, type = "response")
}

my_pred_fixed_glmer_response <- function(fit, lvl) {
    predict(fit, newdata = ciTools_data$tb_temp, re.form = NA, family = fit@resp$family$family, type = "response")
}

my_pred_full_glmer_linear <- function(fit, lvl) {
    predict(fit, newdata = ciTools_data$tb_temp, re.form = NULL, family = fit@resp$family$family, type = "link")
}

my_pred_fixed_glmer_linear <- function(fit, lvl) {
    predict(fit, newdata = ciTools_data$tb_temp, re.form = NA, family = fit@resp$family$family, type = "link")
}

boot_quants <- function(merBoot, alpha) {
    return(
        data.frame(fit = apply(merBoot$t, 2, quantile, probs = 0.5),
                   lwr = apply(merBoot$t, 2, quantile, probs = alpha / 2),
                   upr = apply(merBoot$t, 2, quantile, probs = 1 - alpha / 2)))
}

.onAttach <- function(libname, pkgname) {
    packageStartupMessage(
        paste("ciTools version", packageVersion("ciTools"),"(C) Institute for Defense Analyses", sep = " "))
}
