% nlsig fit problem-based optimization
% uses lsqnonlin/lsqcurvefit or fmincon search(optimization) solver
function [sol,fval,exitflag,output,newoptins] = fitnlsig(nlsigprob,x0,imposeconstr,chngsolver,newoptins)
if chngsolver == 0
    [sol,fval,exitflag,output] = solve(nlsigprob,x0,'Options',newoptins);
elseif chngsolver == 1
    if imposeconstr == 1
        mysolver = 'fmincon';
    elseif imposeconstr == 0
        mysolver = 'lsqcurvefit';
    end
    newoptins = optimoptions(mysolver,newoptins);
    if strcmp(mysolver,'fmincon')
        newoptins.Algorithm = 'sqp';
        %newoptins.Algorithm = 'trust-region-reflective';
        newoptins.SpecifyObjectiveGradient= false;
        %newoptins.Algorithm = 'interior-point';
    end
    [sol,fval,exitflag,output] = solve(nlsigprob,x0,'Options',newoptins,'Solver',mysolver);
end
end
