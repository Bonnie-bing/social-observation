function data = abs_fit_m7c2(param,design,subn,sampn)
%simulate the choice for the RL task,using the absolute fit method (see also Steingroever et al., Decision, 2014)
% parameters:1=etar;2=etap;3=tau;4=etack;5=tauck;6=fp;7=alpha.
% design:%
% 1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay,9=ACC
rng('shuffle')
%% parameters
etar        = param.etar(sampn,subn);       % etar,learning rate of pos. outcome
etap        = param.etap(sampn,subn);       % etar,learning rate of neg. outcome
tau         = param.tau(sampn,subn);        % tau,temperature parameter of RW value
etack       = param.etack(sampn,subn);      % etar,learning rate of CK
tauck       = param.tauck(sampn,subn);      % tau,temperature parameter of CK value
fp          = param.fp(sampn,subn);         % fp,forgetting parameter
kapa(1)     = param.kapa1(sampn,subn);      % decay of learning rate, 100%
kapa(2)     = param.kapa2(sampn,subn);      % decay of learning rate, 80%
kapa(3)     = param.kapa3(sampn,subn);      % decay of learning rate, 50%

%% initialisation
actions = [1,0;0,1];
initV   = zeros(2,6); % initial values for each choice of each picture
initCV  = repmat(0.5,2,6); % initial CK value for each choice of each picture

blocks = 5; % number of blocks
data   = zeros(length(design),17);% 1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay,9=ACC, 10=choice_sim,11=choice_prob_sim,12=PE,13=PE1,14=PE2,15=ev1,16=ev2,17=evck1,18=evck2

%% generate choices
t=0;
design_new=[];
for nb = 1:blocks %loop over each block
    %% initial setup for each block
    bData = design(design(:,2)==nb,:); % data of the current block
    ev      = initV;
    evck    = initCV;
    
    cond          = bData(:,3);
    feedback      = bData(:,4);
    choice        = bData(:,5);
    trial_perC    = bData(:,6);
    probab        = bData(:,7);
    delay         = bData(:,8);
    
    for nt=1:length(bData) % loop over each trial of the block
        
        %% value decaying with delay, for WM processes,only forgeting RW value,not CK value.
        tev1                   = ev(1,cond(nt));
        tev2                   = ev(2,cond(nt));
        
        ev(1,cond(nt))         = tev1*(fp^delay(nt));   %%choice 1
        ev(2,cond(nt))         = tev2*(fp^delay(nt));   %%choice 2
        
        %% calculating probabilites
        cprob(1) = 1/(1+exp(tau*(ev(2,cond(nt))-ev(1,cond(nt))) + tauck*(evck(2,cond(nt))-evck(1,cond(nt)))));
        cprob(2) = 1- cprob(1);
        
        %% generate choice
        t=t+1;
        c(t)     = find(rand < cumsum(cprob(:)),1); % 1 or 2
        c_pro(t) = cprob(choice(nt));
        
        %% calculating PE for each choice
        PE(t)       = feedback(nt) - ev(choice(nt),cond(nt));    % outcome - ev; here we use the feeback and choice observed in the experiment
        PE1(t)      = actions(1,choice(nt)) - evck(1,cond(nt)); % actions - ck; here we use the choice observed in the experiment
        PE2(t)      = actions(2,choice(nt)) - evck(2,cond(nt)); % actions - ck; here we use the choice observed in the experiment
        
        ev1(t)      = ev(1,cond(nt));
        ev2(t)      = ev(2,cond(nt));
        evck1(t)      = evck(1,cond(nt));
        evck2(t)      = evck(2,cond(nt));
        
        %% update values of RW and CK
        if feedback(nt) >0 % a pos outcome
            ev(choice(nt),cond(nt))      = ev(choice(nt),cond(nt)) + etar*(exp(-kapa(probab(nt))*(trial_perC(nt)-1)/10))*PE(t); % here we use the choice observed in the experiment
        else % a neg outcome
            ev(choice(nt),cond(nt))      = ev(choice(nt),cond(nt)) + etap*(exp(-kapa(probab(nt))*(trial_perC(nt)-1)/10))*PE(t); % here we use the choice observed in the experiment
        end
        
        evck(1,cond(nt))   = evck(1,cond(nt)) + etack*PE1(t);
        evck(2,cond(nt))   = evck(2,cond(nt)) + etack*PE2(t);
        
        clear cprob
    end % nt
    design_new = [design_new;bData]; % for correct alignment
    clear bData ev evck cond feedback choice delay
end % nb

%% write c and r into output variable 'data'
% 1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay,9=ACC, 10=choice_sim,11=choice_prob_sim,12=PE,13=PE1,14=PE2,15=ev1,16=ev2,17=evck1,18=evck2

data(:,1:9)  = design_new;
data(:,10)    = c;
data(:,11)    = c_pro;
data(:,12)   = PE;
data(:,13)   = PE1;
data(:,14)   = PE2;
data(:,15)   = ev1;
data(:,16)   = ev2;
data(:,17)   = evck1;
data(:,18)   = evck2;