% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core.R
\name{nsgpPredict}
\alias{nsgpPredict}
\title{Posterior prediction for the NSGP}
\usage{
nsgpPredict(
  model,
  samples,
  coords.predict,
  predict.process = TRUE,
  constants,
  seed = 0,
  ...
)
}
\arguments{
\item{model}{A NSGP nimble object; the output of \code{nsgpModel}.}

\item{samples}{A matrix of \code{J} rows, each is an MCMC sample of the 
parameters corresponding to the specification in \code{nsgpModel}.}

\item{coords.predict}{M x d matrix of prediction coordinates.}

\item{predict.process}{Logical; determines whether the prediction corresponds to 
the y(·) process (\code{TRUE}) or z(·) (\code{FALSE}; this would likely 
only be used for, e.g., cross-validation).}

\item{constants}{An optional list of contants to use for prediction; 
alternatively, additional arguments can be passed to the function via the
... argument.}

\item{seed}{An optional random seed argument for reproducibility.}

\item{...}{Additional arguments can be passed to the function; for example,
as an alternative to the \code{constants} list, items can be passed directly
via this argument.}
}
\value{
The output of the function is a list with two elements: \code{obs},
a matrix of \code{J} posterior predictive samples for the N observed 
locations (only for \code{likelihood = "SGV"}, which produces predictions 
for the observed locations by default; this element is \code{NULL} 
otherwise); and \code{pred}, a corresponding matrix of posterior predictive 
samples for the prediction locations. Ordering and neighbor selection
for the prediction coordinates in the SGV likelihood are conducted 
internally, as with \code{nsgpModel}.
}
\description{
\code{nsgpPredict} conducts posterior prediction for MCMC samples generated
using nimble and nsgpModel.
}
\examples{
\donttest{
# Generate some data: stationary/isotropic
N <- 100
coords <- matrix(runif(2*N), ncol = 2)
alpha_vec <- rep(log(sqrt(1)), N) # Log process SD
delta_vec <- rep(log(sqrt(0.05)), N) # Log nugget SD
Sigma11_vec <- rep(0.4, N) # Kernel matrix element 1,1
Sigma22_vec <- rep(0.4, N) # Kernel matrix element 2,2
Sigma12_vec <- rep(0, N) # Kernel matrix element 1,2
mu_vec <- rep(0, N) # Mean
nu <- 0.5 # Smoothness
dist_list <- nsDist(coords)
Cor_mat <- nsCorr( dist1_sq = dist_list$dist1_sq, dist2_sq = dist_list$dist2_sq, 
                   dist12 = dist_list$dist12, Sigma11 = Sigma11_vec, 
                   Sigma22 = Sigma22_vec, Sigma12 = Sigma12_vec, nu = nu )
Cov_mat <- diag(exp(alpha_vec)) \%*\% Cor_mat \%*\% diag(exp(alpha_vec))
D_mat <- diag(exp(delta_vec)^2) 
set.seed(110)
data <- as.numeric(mu_vec + t(chol(Cov_mat + D_mat)) \%*\% rnorm(N))
# Set up constants
constants <- list( nu = 0.5, Sigma_HP1 = 2 )
# Defaults: tau_model = "constant", sigma_model = "constant", mu_model = "constant",
# and Sigma_model = "constant"
Rmodel <- nsgpModel(likelihood = "fullGP", constants = constants, coords = coords, data = data )
conf <- configureMCMC(Rmodel)
Rmcmc <- buildMCMC(conf)
Cmodel <- compileNimble(Rmodel)
Cmcmc <- compileNimble(Rmcmc, project = Rmodel)
samples <- runMCMC(Cmcmc, niter = 200, nburnin = 100)
# Prediction
predCoords <- as.matrix(expand.grid(seq(0,1,l=10),seq(0,1,l=10)))
postpred <- nsgpPredict( model = Rmodel, samples = samples, coords.predict = predCoords )
}

}
