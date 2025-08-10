#1.3 The parameters of interest for Stan
get_pars <- function(par_names){
  #regressors= list('Uc'=2,'Ui'=2) #from Go/NoGo examples
  pars <- character()
  pars <- c(pars, paste0("mu_", par_names), "sigma")
  pars <- c(pars, par_names)
  pars <- c(pars, "log_lik")
  # the following will be added up for the best model
  # pars <- c(pars, "y_pred")
  # pars <- c(pars, "ev_c") #model regressors
  # pars <- c(pars, "ev_nc") #model regressors
  # pars <- c(pars, "pe_c") #model regressors
}