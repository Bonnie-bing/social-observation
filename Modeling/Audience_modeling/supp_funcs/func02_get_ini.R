#1.2 Initial values for the parameters
get_ini <- function(inits,stanmodel_arg,par_names,data_list){
  #input for the function: inits-'vb','random','fixed'; stanmodel_arg-name of the stan model; parameters to estimate:
  gen_init <- NULL
  if (inits[1] == "vb") {
    #not using vb inference, i.e., using MCMC inference.
    cat("\n")
    cat("****************************************\n")
    cat("** Use VB estimates as initial values **\n")
    cat("****************************************\n")
    
    make_gen_init_from_vb <- function() {
      fit_vb <- rstan::vb(object = stanmodel_arg, data = data_list)
      m_vb <- colMeans(as.data.frame(fit_vb))
      
      function() {
        ret <- list(
          mu_pr = as.vector(m_vb[startsWith(names(m_vb), "mu_pr")]),
          sigma = as.vector(m_vb[startsWith(names(m_vb), "sigma")])
        )
        
        for (p in par_names) {
          ret[[paste0(p, "_pr")]] <-
            as.vector(m_vb[startsWith(names(m_vb), paste0(p, "_pr"))])
        }
        
        return(ret)
      }
    }
    
    gen_init <- tryCatch(make_gen_init_from_vb(), error = function(e) {
      cat("\n")
      cat("******************************************\n")
      cat("** Failed to obtain VB estimates.       **\n")
      cat("** Use random values as initial values. **\n")
      cat("******************************************\n")
      
      return("random")
    })
    
  } else if (inits[1] == "random") {
    cat("\n")
    cat("*****************************************\n")
    cat("** Use random values as initial values **\n")
    cat("*****************************************\n")
    gen_init <- "random"
  }
  
  return(gen_init)
}