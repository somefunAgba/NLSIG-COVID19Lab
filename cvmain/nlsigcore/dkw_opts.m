function [solp,stats_fit] = ...
    dkw_opts(lnnet,type,optsolver,newoptins,lbsolp,ubsolp,sbounds,lubnds)

%Adapted-DKW CI TEST on Yout of LNN.
% Compute uncertainty on data to LNN fit/prediction


lnnet = lnnet.predict(lnnet.solpO);
Yref = lnnet.Yout;
DYref = lnnet.DYDx; %#ok<NASGU>
fitstats = lnnet.fitstatsO;
solp = lnnet.solpO;
av = 0.01;

if type == -1 % LB
    dE = type.*fitstats.ciE;
elseif type == 1 % UB
    dE = type.*fitstats.ciE;
end

y_data = Yref + dE;
% y_data(1,:) = Yref; 
lnnet = lnnet.setR(y_data);

% Set up ymin and ymax options to reflect lb/ub bnds
for j = 1:lnnet.J
    
    % ymin
    for i = 1:solp.n{j}
%         if i ~=1
            solp.ymin{j}(i) = solp.ymin{j}(i) + dE(j);
%         end
        if i==1 && sbounds == true
            lbsolp.ymin{j}(i) = solp.ymin{j}(i);
            ubsolp.ymin{j}(i) = solp.ymin{j}(i) + av;
        end
        if i > 1 && lubnds == true
            lbsolp.ymin{j}(i) = solp.ymin{j}(i);
            ubsolp.ymin{j}(i) = solp.ymin{j}(i) + av;
        end
        
    end
      
    % ymax
    for i = 1:solp.n{j}
%         if i ~=1
            solp.ymax{j}(i) = solp.ymax{j}(i) + dE(j);
%         end
        if i < solp.n{j} && lubnds == true
            lbsolp.ymax{j}(i) = solp.ymax{j}(i);
            ubsolp.ymax{j}(i) = solp.ymax{j}(i) + av;
        end
        if i == solp.n{j}
            if solp.ymax{j}(i) >= 0
                lbsolp.ymax{j}(i) = 0.5*solp.ymax{j}(i);
                ubsolp.ymax{j}(i) = 1.2*solp.ymax{j}(i);
            else
                ubsolp.ymax{j}(i) = 0.5*solp.ymax{j}(i);
                lbsolp.ymax{j}(i) = 1.2*solp.ymax{j}(i);
            end
        end
    end
    
end

% Solver-based optimization

% set solp structure
lnnet = lnnet.setopts(solp,1);
% unroll solp and its bounds
[lbvec, ubvec] = lnnet.sol_unroll(lbsolp,ubsolp);
x0vec = lnnet.solpvec;


% define objective function
% type: 0:E | 1:SSE
if optsolver == "lsqnonlin-tr" || optsolver == "lsqnonlin-lm"
    objfun = @(solpvec) lnnet.objfeval2(solpvec,0);
elseif optsolver == "fmincon-tr" || optsolver == "fmincon-ipt"
    objfun = @(solpvec) lnnet.objfeval3(solpvec,1);
end

if optsolver == "lsqnonlin-tr" || optsolver == "lsqnonlin-lm"
    if optsolver == "lsqnonlin-tr"
        solpvec_fit = ...
            lsqnonlin(objfun,x0vec,...
            lbvec,ubvec,newoptins);
    elseif optsolver == "lsqnonlin-lm"
        solpvec_fit = ...
            lsqnonlin(objfun,x0vec,...
            [],[],newoptins);
    end
elseif optsolver == "fmincon-tr" || optsolver == "fmincon-ipt"
    solpvec_fit = ...
        fmincon(objfun,x0vec,[],[],[],[],...
        lbvec,ubvec,[],newoptins);
end

% Predict using the model's optimized parameters
lnnet = lnnet.sol_roll(solpvec_fit);
lnnet = lnnet.predict();
% Compute fitness stats
lnnet = lnnet.stats();
%
solp = lnnet.solp;
stats_fit = lnnet.fitstats;

end