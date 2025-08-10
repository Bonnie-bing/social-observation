##1.6 convert to modeldata
modeldata <- function(fit_mX,modelname,par_names,multp_par_names=NULL,indPars="mean",raw_data,colnames_raw_data,n_subjs,subj_id,tn,bn){
  # Extract from the Stan fit object
  parVals <- rstan::extract(fit_mX, permuted = TRUE)
  
  # Trial-level posterior predictive simulations
  postpreds = "y_pred"
  for (pp in postpreds) {
    parVals[[pp]][parVals[[pp]] == -1] <- NA
  }
  
  
  # Define measurement of individual parameters
  #indPars <- "mean" #extracting mean of parameters
  measure_indPars <- switch(indPars, mean = mean, median = median, mode = estimate_mode)
  
  # Define which individual parameters to measure
  #par_names <- c("alpha","omega_a","omega_i","tau")#para names of the best model
  which_indPars <- par_names
  
  multp_which_indPars <- multp_par_names
  
  # Measure all individual parameters (per subject)
  allIndPars <- as.data.frame(array(NA, c(n_subjs, length(which_indPars))))
  m_allIndPars <- as.data.frame(array(NA, c(n_subjs, 50)))
  m_names  <- rep(NULL,50)
  # PPC_data   <- as.data.frame(array(NA, c(n_subjs, bn*tn,length(postpreds))))
  for (i in 1:n_subjs) {
    
    allIndPars[i, ] <- mapply(function(x) measure_indPars(parVals[[x]][, i]), which_indPars)
    
    if (length(multp_which_indPars)>0){  # for parameters in the matrix form
      count <-0
      for (nm in 1: length(multp_which_indPars)){
        for (ds in 1:dim(parVals[[multp_which_indPars[nm]]])[3]){
          count <- count + 1
          m_allIndPars[i, count] <- sapply(list(parVals[[multp_which_indPars[nm]]][, i,ds]),function(x) measure_indPars(x))
          m_names[count] <- paste0(multp_which_indPars[nm],ds)
        }
      }
      
    }
    
    # for (b in 1:bn){
    #   for(t in 1:tn){##for posterior preditive check
    #     if (length(postpreds)==1){
    #       PPC_data[i,(b-1)*tn+t] <- mapply(function(x) measure_indPars(parVals[[x]][, i,b,t]), postpreds)
    #     } else{
    #       PPC_data[i,(b-1)*tn+t,] <- mapply(function(x) measure_indPars(parVals[[x]][, i,b,t]), postpreds)
    #     }
    #   }
    # }
  }
  
  if (length(multp_which_indPars)>0){
    m_allIndPars <- m_allIndPars[,1:count]
    m_allIndPars <- as.data.frame(m_allIndPars)
    m_names      <- m_names[1:count]
    
    allIndPars <- cbind(subj_id, allIndPars,m_allIndPars)
    colnames(allIndPars) <- c("subjid", which_indPars,m_names)
  } else {
    allIndPars <- cbind(subj_id, allIndPars)
    colnames(allIndPars) <- c("subjid", which_indPars) 
  }
  
  # PPC_data <- cbind(subj_id, PPC_data)
  # colnames(PPC_data) <- c("subjid", names(PPC_data)[2:ncol(PPC_data)])
  # 
  # #model regressors
  # regressors= list('ev_c'=2,'ev_nc'=2,'pe_c'=2) #from Go/NoGo examples
  # for (pp in names(regressors)) {
  #   parVals[[pp]][parVals[[pp]] == -999] <- NA
  # }
  # model_regressor <- list()
  # for (r in names(regressors)) {
  #   model_regressor[[r]] <- apply(parVals[[r]], c(1:regressors[[r]]) + 1, measure_indPars)
  # }
  
  
  # Give back initial colnames and revert data.table to data.frame
  colnames(raw_data) <- colnames_raw_data
  raw_data <- as.data.frame(raw_data)
  
  # Wrap up data into a list
  modelData                   <- list()
  modelData$model             <- modelname
  modelData$allIndPars        <- allIndPars
  # modelData$PPC_data          <- PPC_data
  modelData$parVals           <- parVals
  modelData$fit               <- fit_mX
  modelData$rawdata           <- raw_data
  # modelData$modelRegressor    <- model_regressor
  
  # Object class definition
  class(modelData) <- "hBayesDM"
  return(modelData)
}