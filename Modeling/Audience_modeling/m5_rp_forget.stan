//The RW model using diff LR for pos. and neg. outcomes + forgeting

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
}


transformed data {
    // Default value for (re-)initializing parameter vectors
  matrix[2, 6] initV;
  initV = rep_matrix(0.0,2,6); // 6 stimuli in total, 2 choices per stimulus. value is the mean of the outcome:(-1+1)/2
}

parameters {
// Declare all parameters as vectors for vectorizing
  // Hyper(group)-parameters
  vector[4] mu_pr; //mean of the parameters,4 paras (2 learning rates, forget parameter and inverse temperature)
  vector<lower=0>[4] sigma; //variance of the parameters, 4 paras

  // Subject-level raw parameters (for Matt trick)
  vector[Ns] etar_pr;   // etar: learning rate for reward
  vector[Ns] etap_pr;  // etar: learning rate for punishment
  vector[Ns] fp_pr;   // forgetting parameter
  vector[Ns] tau_pr; // tau: Inverse temperature
}

transformed parameters {
  // Transform subject-level raw parameters
  real<lower=0, upper=1> etar[Ns];
  real<lower=0, upper=1> etap[Ns];
  real<lower=0, upper=1> fp[Ns];
  real<lower=0, upper=10> tau[Ns];

  for (i in 1:Ns) {
    etar[i]     = Phi_approx(mu_pr[1] + sigma[1] * etar_pr[i]);
    etap[i]     = Phi_approx(mu_pr[2] + sigma[2] * etap_pr[i]);
    fp[i]       = Phi_approx(mu_pr[3] + sigma[3] * fp_pr[i]);
    tau[i]      = Phi_approx(mu_pr[4] + sigma[4] * tau_pr[i]) * 10;
  }
}

model {
  // Hyperparameters
  mu_pr  ~ normal(0, 1.0);
  sigma  ~ normal(0, 0.5);

  // individual parameters
  etar_pr   ~ normal(0, 1.0);
  etap_pr   ~ normal(0, 1.0);
  fp_pr     ~ normal(0, 1.0);
  tau_pr    ~ normal(0, 1.0);
  
  for (i in 1:Ns) {
    for (bIdx in 1:Bsubj[i]) {  // new
      // Define values
      matrix[2, 6] ev;       // expected value
      vector[2] prob;       // probability
      real prob_1_;        // a temporal variable

      real PE;       // prediction error
      
      real tev1;       // temporal value 1
      real tev2;       // temporal value2

      // Initialize values
      ev = initV; // initial ev values

      for (t in 1:(Tsubj[i, bIdx])) {  // new
      
         // value decaying with delay, for WM processes
         tev1                   = ev[1,cond[i,bIdx,t]];
         tev2                   = ev[2,cond[i,bIdx,t]];
         
         ev[1,cond[i,bIdx,t]]   = tev1*(fp[i]^delay[i,bIdx,t]);   //choice 1
         ev[2,cond[i,bIdx,t]]   = tev2*(fp[i]^delay[i,bIdx,t]);   //choice 2
        
        // compute action probabilities
        prob[1] = 1 / (1 + exp(tau[i] * (ev[2,cond[i,bIdx,t]] - ev[1,cond[i,bIdx,t]]))); // according to softmax, MUST BE U2-U1 here!!!!
        prob_1_ = prob[1];
        prob[2] = 1 - prob_1_;
        
        choice[i, bIdx, t] ~ categorical(prob);
        //choice[i, t] ~ bernoulli(prob);

        // prediction error
        PE   =  outcome[i, bIdx, t] - ev[choice[i, bIdx, t],cond[i,bIdx,t]];  //new

        // value updating (learning)
        if (outcome[i, bIdx, t] > 0){ // a pos outcome
          ev[choice[i, bIdx, t],cond[i,bIdx,t]]   += etar[i] * PE;   //new
          } else { // a neg outcome
          ev[choice[i, bIdx, t],cond[i,bIdx,t]]   += etap[i] * PE;   //new}
        }
        
        
      } // end of t loop
    } // end of bIdx loop
  } // end of i loop
      
} // end of model





generated quantities {
  
  // For group level parameters
  real<lower=0, upper=1> mu_etar;
  real<lower=0, upper=1> mu_etap;
  real<lower=0, upper=1> mu_fp;
  real<lower=0, upper=10> mu_tau;


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
  
  mu_etar    = Phi_approx(mu_pr[1]); // must define mu_eta here
  mu_etap    = Phi_approx(mu_pr[2]); // must define mu_eta here
  mu_fp      = Phi_approx(mu_pr[3]);
  mu_tau     = Phi_approx(mu_pr[4]) * 10;
  
  
   { // local section, this saves time and space
    for (i in 1:Ns) {

      log_lik[i] = 0;

      for (bIdx in 1:Bsubj[i]) {
        // Define values
        matrix[2, 6] ev;       // expected value
        vector[2] prob;       // probability
        real prob_1_;        // a temporal variable

        real PE;       // prediction error
        
        real tev1;       // temporal value 1
        real tev2;       // temporal value2

        // Initialize values
        ev = initV; // initial ev values

        for (t in 1:(Tsubj[i, bIdx])) {
          
          
          // value decaying with delay, for WM processes
          tev1                   = ev[1,cond[i,bIdx,t]];
          tev2                   = ev[2,cond[i,bIdx,t]];
         
          ev[1,cond[i,bIdx,t]]   = tev1*(fp[i]^delay[i,bIdx,t]);   //choice 1
          ev[2,cond[i,bIdx,t]]   = tev2*(fp[i]^delay[i,bIdx,t]);   //choice 2
          
          
          // compute action probabilities
          prob[1] = 1 / (1 + exp(tau[i] * (ev[2,cond[i,bIdx,t]] - ev[1,cond[i,bIdx,t]]))); // according to softmax, MUST BE U2-U1 here!!!!
          prob_1_ = prob[1];
          prob[2] = 1 - prob_1_;

          log_lik[i] += categorical_lpmf(choice[i, bIdx, t] | prob);  //new

          // // generate posterior prediction for current trial
          // y_pred[i, bIdx, t] = categorical_rng(prob[1:2,cond[i,bIdx,t]]);

          // prediction error
          PE   =  outcome[i, bIdx, t] - ev[choice[i, bIdx, t],cond[i,bIdx,t]];  //new

          // // Store values for model regressors
          // ev_c[i, bIdx, t]   = ev[choice[i, bIdx, t],cond[i,bIdx,t]];
          // ev_nc[i, bIdx, t]  = ev[3 - choice[i, bIdx, t],cond[i,bIdx,t]];
          // 
          // pe_c[i, bIdx, t]   = PE[cond[i,bIdx,t]];

          // value updating (learning)
        if (outcome[i, bIdx, t] > 0){ // a pos outcome
          ev[choice[i, bIdx, t],cond[i,bIdx,t]]   += etar[i] * PE;   //new
          } else { // a neg outcome
          ev[choice[i, bIdx, t],cond[i,bIdx,t]]   += etap[i] * PE;   //new}
        }
          
        } // end of t loop
      } // end of bIdx loop
    }  // end of i loop
  } // end of local
}  // end of generated quantities

