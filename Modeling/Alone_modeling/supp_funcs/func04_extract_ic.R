#1.4 extract LOOIC and WAIC
extract_ic <- function(model_fit = NULL,
                       ic        = "looic",
                       ncore     = 2) {
  if (!(ic %in% c("looic", "waic", "both")))
    stop("Set 'ic' as 'looic', 'waic' or 'both' \n")
  
  # Access fit within model_data
  stan_fit  <- model_fit
  n_chains <- length(stan_fit@stan_args)
  
  # extract LOOIC and WAIC, from Stanfit
  IC <- list()
  
  lik     <- loo::extract_log_lik(
    stanfit = stan_fit,
    parameter_name = "log_lik")
  
  rel_eff <- loo::relative_eff(
    exp(lik),
    chain_id = rep(1:n_chains, each = nrow(lik) / n_chains),
    cores = getOption("mc.cores", ncore))
  
  if (ic %in% c("looic", "both"))
    IC$LOOIC <- loo::loo(lik, r_eff = rel_eff,
                         cores = getOption("mc.cores", ncore))
  
  if (ic %in% c("waic", "both"))
    IC$WAIC <- loo::waic(lik)
  
  return(IC)
}
