#1.1. pre-processing function
prepro_func <- function(d_df, general_info) {
  # Currently class(d_df) == "data.table"
  
  # Use general_info of d_df
  subjs   <- general_info$subjs
  n_subj  <- general_info$n_subj
  b_subjs <- general_info$b_subjs # number of blocks for each sub
  b_max   <- general_info$b_max
  t_subjs <- general_info$t_subjs # number of trials for each sub and block
  t_max   <- general_info$t_max
  
  # Initialize (model-specific) data arrays
  choice   <- array(-1, c(n_subj, b_max, t_max)) # choice
  outcome  <- array( 0, c(n_subj, b_max, t_max)) # feedback
  cond     <- array( 0, c(n_subj, b_max, t_max)) # condition
  probab   <- array( 0, c(n_subj, b_max, t_max)) # probability
  tn_perC  <- array( 0, c(n_subj, b_max, t_max)) # trial number for each stimulus per block(1-25)
  delay    <- array( -1, c(n_subj, b_max, t_max)) # delay number for each stimulus
  ACC      <- array( -1, c(n_subj, b_max, t_max)) # accuracy
  data_new <- data.frame('subid'=rep(-1,n_subj*b_max*t_max),'block'=rep(-1,n_subj*b_max*t_max),'cond'=rep(-1,n_subj*b_max*t_max),'feedback'=rep(-1,n_subj*b_max*t_max),'choice'=rep(-1,n_subj*b_max*t_max),'trial_perC2'=rep(-1,n_subj*b_max*t_max),'probab'=rep(-1,n_subj*b_max*t_max),'delay'=rep(-1,n_subj*b_max*t_max),'ACC'=rep(-1,n_subj*b_max*t_max))
  
  # Write from d_df to the data arrays
  for (i in 1:n_subj) {
    subj <- subjs[i]
    DT_subj <- d_df[d_df$subid == subj]          #all data of subj
    blocks_of_subj <- unique(DT_subj$block)      # block numbers of subj
    
    for (b in 1:b_subjs[i]) {                   # for each block  
      curr_block <- blocks_of_subj[b]           # block id
      DT_curr_block <- DT_subj[DT_subj$block == curr_block] #get the data for the current block of the current subject
      t <- t_subjs[i, b]                        # get the trial number for the current block of the current subject
      
      choice[i, b, 1:t]   <- DT_curr_block$choice # get the choice data
      outcome[i, b, 1:t]  <- sign(DT_curr_block$feedback)  # get the feedback, and then use sign to convert them to -1 (all neg numbers) 0 (all 0s) or 1 (all pos numbers)
      cond[i, b, 1:t]     <- DT_curr_block$cond  # get the condition
      probab[i, b, 1:t]   <- DT_curr_block$probab  # get the probability
      tn_perC[i, b, 1:t]  <- DT_curr_block$trial_perC2  # get the trial number per cond: trial_perC2 is the correct one.
      delay[i, b, 1:t]    <- DT_curr_block$delay
      ACC[i, b, 1:t]      <- DT_curr_block$ACC
      
    }
  }
  
  # Wrap into a list for Stan
  data_list <- list(
    Ns      = n_subj,
    Bs      = b_max,
    Bsubj   = b_subjs,
    Ts      = t_max,
    Tsubj   = t_subjs,
    choice  = choice,
    outcome = outcome,
    cond    = cond,
    probab  = probab,
    tn_perC = tn_perC,
    delay   = delay
    
  )
  
  # write into a data frame for PPC
  data_new$subid         <- rep(subjs,each=b_max*t_max)
  data_new$block         <- rep(rep(1:b_max,each=t_max),times=n_subj)
  data_new$cond          <- as.vector(aperm(cond, c(3,2,1))) #change the order of arrary and then transfer to a vector
  data_new$feedback      <- as.vector(aperm(outcome, c(3,2,1)))
  data_new$choice        <- as.vector(aperm(choice, c(3,2,1)))
  data_new$trial_perC2   <- as.vector(aperm(tn_perC, c(3,2,1)))
  data_new$ probab       <- as.vector(aperm(probab, c(3,2,1)))
  data_new$delay         <- as.vector(aperm(delay, c(3,2,1)))
  data_new$ACC           <- as.vector(aperm(ACC, c(3,2,1)))
  
  if (general_info$gen_file==1){  #only generate the data file for the main analysis
    write.csv(data_new,file='data_for_cm_all.csv',row.names = FALSE)
  }
  
  # Returned data_list will directly be passed to Stan
  return(data_list)
}
