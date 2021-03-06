% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_ci_survreg.R
\name{add_ci.survreg}
\alias{add_ci.survreg}
\title{Confidence Intervals for the Mean Survival Time of Accelerated
Failure Time Models.}
\usage{
\method{add_ci}{survreg}(tb, fit, alpha = 0.1, names = NULL,
  yhatName = "mean_pred", ...)
}
\arguments{
\item{tb}{A tibble or data frame of new data on which to form
predictions and confidence intervals.}

\item{fit}{An object of class \code{survreg}. Predictions are made
with this object.}

\item{alpha}{A number between 0 and 1. 1 - \code{alpha} is the
confidence level of the intervals.}

\item{names}{\code{NULL} or a string of length 2. If \code{NULL}, quantiles
automatically will be named by \code{add_quantile}, otherwise,
they will be named \code{names}.}

\item{yhatName}{A string. Name of the vector of predictions. The
default name is \code{mean_pred}.}

\item{...}{Additional arguments.}
}
\value{
A tibble, \code{tb}, with predicted expected values and
    level \emph{1 - alpha} level confidence levels attached.
}
\description{
This function is one of the methods for \code{add_ci}, and is
called automatically when \code{add_ci} is used on a \code{fit} of
class \code{survreg}.
}
\details{
\code{add_ci.survreg} calculates confidence intervals for the mean
survival time of several accelerated failure time (AFT) models
including exponential, lognormal, weibull, and loglogistic
models. AFT models must be fit with the \code{survreg} function in
the \code{survival} package. Confidence intervals are formed
parametrically via the Delta method.

\code{add_ci.survreg} will compute confidence intervals for the
following mean survival time point estimates:

Exponential: \eqn{E[Y|X] = \exp{X\beta}}

Weibull: \eqn{E[Y|X] = \exp{X\beta}\Gamma(1 + \sigma)}

Lognormal: \eqn{E[Y|X] = \exp{X\beta + \frac{\sigma^2}{2}}}

Loglogistic: \eqn{E[Y|X] = \exp{X\beta}\Gamma(1 + \sigma)(1 - \sigma)}

Traditionally, survival time predictions are made with the median
survival time. For forming confidence intervals for the median
survival time (or any quantile of the survival time distribution),
see \code{\link{add_quantile.survreg}}.

Note: The expected survival time of a loglogistic model with scale
>= 1 does not exist. Otherwise, expected survival times exist for
each of the four AFT models considered in \code{add.ci_survreg}.

Note: Due to a limitation, the \code{Surv} object must be specified in
\code{survreg} function call. See the examples section for one way
to do this.

Note: \code{add_ci.survreg} cannot inspect the convergence of
\code{fit}. Poor maximum likelihood estimates will result in poor
confidence intervals. Inspect any warning messages given from
\code{survreg}.
}
\examples{
## Define a data set.
tb <- survival::stanford2
## remove a covariate with missing values.
tb <- tb[, 1:4]
## next, create the Surv object inside the survreg call:
fit <- survival::survreg(survival::Surv(time, status) ~ age + I(age^2),
                         data = tb, dist = "lognormal")
add_ci(tb, fit, alpha = 0.1, names = c("lwr", "upr"))

## Try a different model:
fit2 <- survival::survreg(survival::Surv(time, status) ~ age + I(age^2),
                          data = tb, dist = "weibull")
add_ci(tb, fit2, alpha = 0.1, names = c("lwr", "upr"))

}
\references{
For descriptions of the log-location scale models supported:
Meeker, William Q., and Luis A. Escobar. Statistical methods for reliability data. John Wiley & Sons, 2014. (Chapter 4)

For a description of the multivariate Delta method:
Meeker, William Q., and Luis A. Escobar. Statistical methods for reliability data. John Wiley & Sons, 2014. (Appendix B.2)
}
\seealso{
\code{\link{add_quantile.survreg}} for quantiles of the
    survival time distribution of \code{survreg} objects,
    \code{\link{add_pi.survreg}} for prediction intervals of
    \code{survreg} objects, and \code{\link{add_probs.survreg}} for
    survival probabilities of \code{survreg} objects.
}
