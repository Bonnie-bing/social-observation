// The combined model: Reward/punishment model + forget parameters + choice kernel model

data {
  int<lower=1> Ns;                          // Number of subjects

  int<lower=1> Bs;                          // Max number of blocks across subjects
  int<lower=1> Bsubj[Ns];                   // Number of blocks for each subject

  int<lower=1> Ts;                          // Max number of trials across subjects
  int<lower=1, upper=Ts> Tsubj[Ns, Bs];       // Number of trials/block for each subject

  int<lower=-1, upper=2> choice[Ns, Bs, Ts];  // Choice for each subject-block-trial,-1 for allowing for missing values
  
  real outcome[Ns, Bs, Ts];                   // Outcome (reward/loss) for each subject-block-trial
  
  int<lower=0, upper=6> cond[Ns, Bs, Ts];  // Choice for each subject-block-trial, 0 for allowing for missing values
  
  real<lower=-1> delay[Ns, Bs, Ts];      // delay for each subject-block-trial,-1 for missing values
  
  int<lower=0, upper=3> probab[Ns, Bs, Ts];  // prob for each subject-block-trial, 0 for allowing for missing values
}


transformed data {
    // Default value for (re-)initializing parameter vectors
    matrix[2, 2] actions = [[1,0],[0,1]]; // defines action values, if chosen, val=1; else val=0
    
    matrix[2, 6] initV = rep_matrix(0.0,2,6); // 6 stimuli in total, 2 choices per stimulus. (-1+1)/2=0.0

    matrix[2, 6] initCV = rep_matrix(0.5,2,6); // 6 stimuli in total, 2 choices per stimulus. (1+0)/2=0.5

}

parameters {
// Declare all parameters as vectors for vectorizing
  // Hyper(group)-parameters
  vector[8] mu_pr; //mean of the parameters,6 paras (2 learning rates and inverse temperature) + (1 LR and it for CK) + forget para
  vector<lower=0>[8] sigma; //variance of the parameters, 2 paras

  // Subject-level raw parameters (for Matt trick)
  vector[Ns] etar_pr;  // etar: learning rate for reward
  vector[Ns] etap_pr;  // etap: learning rate for punishment
  vector[Ns] tau_pr;    // tau: Inverse temperature
  
  vector[Ns] etack_pr;  // etack: learning rate for ck
  vector[Ns] tauck_pr;    // tauck: Inverse temperature for ck
  
  vector[Ns] fp_pr1;    // tau: Inverse temperature
  vector[Ns] fp_pr2;    // tau: Inverse temperature
  vector[Ns] fp_pr3;    // tau: Inverse temperature
}

transformed parameters {
  // Transform subject-level raw parameters
  real<lower=0, upper=1> etar[Ns];
  real<lower=0, upper=1> etap[Ns];
  real<lower=0, upper=10> tau[Ns];
  
  real<lower=0, upper=1> etack[Ns];
  real<lower=0, upper=10> tauck[Ns];
  
  real<lower=0, upper=1> fp[Ns,3];

  for (i in 1:Ns) {
    etar[i]      = Phi_approx(mu_pr[1] + sigma[1] * etar_pr[i]);
    etap[i]      = Phi_approx(mu_pr[2] + sigma[2] * etap_pr[i]);
    tau[i]       = Phi_approx(mu_pr[3] + sigma[3] * tau_pr[i]) * 10;
	
	  etack[i]     = Phi_approx(mu_pr[4] + sigma[4] * etack_pr[i]);
    tauck[i]     = Phi_approx(mu_pr[5] + sigma[5] * tauck_pr[i]) * 10;
    
    fp[i,1]      = Phi_approx(mu_pr[6] + sigma[6] * fp_pr1[i]);
    fp[i,2]      = Phi_approx(mu_pr[7] + sigma[7] * fp_pr2[i]);
    fp[i,3]      = Phi_approx(mu_pr[8] + sigma[8] * fp_pr3[i]);
  }
  
}

model {
  // Hyperparameters
  mu_pr  ~ normal(0, 1.0);
  sigma ~ normal(0, 0.5);

  // individual parameters
  etar_pr  ~ normal(0, 1.0);
  etap_pr  ~ normal(0, 1.0);
  tau_pr   ~ normal(0, 1.0);
  
  etack_pr  ~ normal(0, 1.0);
  tauck_pr   ~ normal(0, 1.0);
  
  fp_pr1   ~ normal(0, 1.0);
  fp_pr2   ~ normal(0, 1.0);
  fp_pr3   ~ normal(0, 1.0);
  
  for (i in 1:Ns) {
    for (bIdx in 1:Bsubj[i]) {  // new
      // Define values
      matrix[2, 6] ev;       // expected value
	    matrix[2, 6] evck;       // expected value for CK
      vector[2] prob;       // probability
      real prob_1_;        // a temporal variable

      real PE;       // prediction error
	    real PE1;       // prediction error, for choice 1,for CK
      real PE2;       // prediction error, for choice 2,for CK
      
      real tev1;       // temporal value 1
      real tev2;       // temporal value2

      // Initialize values
      ev   = initV; // initial ev values
	    evck = initCV; // initial ev values, for CK

      for (t in 1:(Tsubj[i, bIdx])) {  // new
      
         // value decaying with delay, for WM processes,only forgeting RW value,not CK value.
         tev1                   = ev[1,cond[i,bIdx,t]];
         tev2                   = ev[2,cond[i,bIdx,t]];
         
         ev[1,cond[i,bIdx,t]]   = tev1*(fp[i,probab[i,bIdx,t]]^delay[i,bIdx,t]);   //choice 1
         ev[2,cond[i,bIdx,t]]   = tev2*(fp[i,probab[i,bIdx,t]]^delay[i,bIdx,t]);   //choice 2
        
         // compute action probabilities
         prob[1] = 1 / (1 + exp(tau[i] * (ev[2,cond[i,bIdx,t]] - ev[1,cond[i,bIdx,t]]) + tauck[i] * (evck[2,cond[i,bIdx,t]] - evck[1,cond[i,bIdx,t]]))); // according to softmax, MUST BE U2-U1 here!!!!
         prob_1_ = prob[1];
         prob[2] = 1 - prob_1_;
        
         choice[i, bIdx, t] ~ categorical(prob);
         //choice[i, t] ~ bernoulli(prob);

         // prediction error
         PE    =  outcome[i, bIdx, t] - ev[choice[i, bIdx, t],cond[i,bIdx,t]];  //new
		     PE1   =  actions[1,choice[i, bIdx, t]] - evck[1,cond[i,bIdx,t]];  // for ck
         PE2   =  actions[2,choice[i, bIdx, t]] - evck[2,cond[i,bIdx,t]];  // for ck

         // value updating (learning)
         if (outcome[i, bIdx, t] > 0){ // a pos outcome
          ev[choice[i, bIdx, t],cond[i,bIdx,t]]   += etar[i] * PE;   //new
           } else { // a neg outcome
           ev[choice[i, bIdx, t],cond[i,bIdx,t]]   += etap[i] * PE;   //new
         }
		
		     evck[1,cond[i,bIdx,t]]   += etack[i] * PE1;   //new
         evck[2,cond[i,bIdx,t]]   += etack[i] * PE2;   //new

      } // end of t loop
    } // end of bIdx loop
  } // end of i loop
      
} // end of model





generated quantities {
  
  // For group level parameters
  real<lower=0, upper=1> mu_etar;
  real<lower=0, upper=1> mu_etap;
  real<lower=0, upper=10> mu_tau;
  
  real<lower=0, upper=1> mu_etack;
  real<lower=0, upper=10> mu_tauck;
  
  real<lower=0, upper=1> mu_fp[3];


  // For log likelihood calculation
  real log_lik[Ns];
  
  

  // // For model regressors
  // real ev_c[Ns, Bs, Ts];           // Expected value of the chosen option
  // real ev_nc[Ns, Bs, Ts];           // Expected value of the unchosen option
  // 
  // real pe_c[Ns, Bs, Ts];          //Prediction error of the chosen option
  // 
  // // For posterior predictive check
  // real y_pred[Ns, Bs, Ts];
  // 
  // // Set all posterior predictions, model regressors to 0 (avoids NULL values)
  // for (i in 1:Ns) {
  //   for (b in 1:Bs) {
  //     for (t in 1:Ts) {
  //       
  //       ev_c[i, b, t]    = -999;
  //       ev_nc[i, b, t]   = -999;
  //       pe_c[i, b, t]    = -999;
  //       y_pred[i, b, t]  = -1;
  //     }
  //   }
  // }
  
  mu_etar        = Phi_approx(mu_pr[1]); // must define mu_eta here
  mu_etap        = Phi_approx(mu_pr[2]); // must define mu_eta here
  mu_tau         = Phi_approx(mu_pr[3]) * 10;
  
  mu_etack       = Phi_approx(mu_pr[4]);
  mu_tauck       = Phi_approx(mu_pr[5]) * 10;
  
  mu_fp[1]       = Phi_approx(mu_pr[6]);
  mu_fp[2]       = Phi_approx(mu_pr[7]);
  mu_fp[3]       = Phi_approx(mu_pr[8]);
  
  
   { // local section, this saves time and space
     for (i in 1:Ns) {

        log_lik[i] = 0;

       for (bIdx in 1:Bsubj[i]) {  // new
        // Define values
        matrix[2, 6] ev;       // expected value
	      matrix[2, 6] evck;       // expected value for CK
        vector[2] prob;       // probability
        real prob_1_;        // a temporal variable

        real PE;       // prediction error
	      real PE1;       // prediction error, for choice 1,for CK
        real PE2;       // prediction error, for choice 2,for CK
      
        real tev1;       // temporal value 1
        real tev2;       // temporal value2

        // Initialize values
        ev   = initV; // initial ev values
	      evck = initCV; // initial ev values, for CK

        for (t in 1:(Tsubj[i, bIdx])) {  // new
      
           // value decaying with delay, for WM processes,only forgeting RW value,not CK value.
           tev1                   = ev[1,cond[i,bIdx,t]];
           tev2                   = ev[2,cond[i,bIdx,t]];
         
           ev[1,cond[i,bIdx,t]]   = tev1*(fp[i,probab[i,bIdx,t]]^delay[i,bIdx,t]);   //choice 1
           ev[2,cond[i,bIdx,t]]   = tev2*(fp[i,probab[i,bIdx,t]]^delay[i,bIdx,t]);   //choice 2
        
          // compute action probabilities
           prob[1] = 1 / (1 + exp(tau[i] * (ev[2,cond[i,bIdx,t]] - ev[1,cond[i,bIdx,t]]) + tauck[i] * (evck[2,cond[i,bIdx,t]] - evck[1,cond[i,bIdx,t]]))); // according to softmax, MUST BE U2-U1 here!!!!
           prob_1_ = prob[1];
           prob[2] = 1 - prob_1_;

           log_lik[i] += categorical_lpmf(choice[i, bIdx, t] | prob);  //new

            // // generate posterior prediction for current trial
           // y_pred[i, bIdx, t] = categorical_rng(prob[1:2,cond[i,bIdx,t]]);

           // prediction error
           PE    =  outcome[i, bIdx, t] - ev[choice[i, bIdx, t],cond[i,bIdx,t]];  //new
		       PE1   =  actions[1,choice[i, bIdx, t]] - evck[1,cond[i,bIdx,t]];  // for ck
           PE2   =  actions[2,choice[i, bIdx, t]] - evck[2,cond[i,bIdx,t]];  // for ck

           // value updating (learning)
           if (outcome[i, bIdx, t] > 0){ // a pos outcome
             ev[choice[i, bIdx, t],cond[i,bIdx,t]]   += etar[i] * PE;   //new
             } else { // a neg outcome
             ev[choice[i, bIdx, t],cond[i,bIdx,t]]   += etap[i] * PE;   //new
           }
		
		       evck[1,cond[i,bIdx,t]]   += etack[i] * PE1;   //new
           evck[2,cond[i,bIdx,t]]   += etack[i] * PE2;   //new

            // // Store values for model regressors
            // ev_c[i, bIdx, t]   = ev[choice[i, bIdx, t],cond[i,bIdx,t]];
            // ev_nc[i, bIdx, t]  = ev[3 - choice[i, bIdx, t],cond[i,bIdx,t]];
            // 
            // pe_c[i, bIdx, t]   = PE[cond[i,bIdx,t]];
          
          } // end of t loop
        } // end of bIdx loop
      }  // end of i loop
   } // end of local
}  // end of generated quantities

