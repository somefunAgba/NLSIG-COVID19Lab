function [sol,fval,exitflag,output,fitstats,...
    y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins] ...
    = set_probopts(x_data, y_data, dy_data, nlsigfit_opts,sbounds,lubnds)
%% custom options

% sbounds enforces starting min value constraint on the x-axis.

% empty struct for best_sol and fit found
% using an ensemble grid of lambda growth-rates.
best_sol = struct([]);
best_fit = struct([]);
for trys = 1:6
% len_sol
% len_sol = 6 (default) or 7 or 2 or 3
% 6 : more robust, since it uses an even base, gives room to optimize other variables
% 7 : to also optimizes the exponential base
len_sol = nlsigfit_opts.len_sol;

% imposeconstr, valid for len_sol = 6 or 7
% imposeconstr = 0 (default),
% 0 : no ineq. constraints, uses lsqnonlin,
% 1 : apply constraints, uses fmincon
imposeconstr = nlsigfit_opts.imposeconstr;

% chngsolver = 0 (default),
% 1 : use lsqcurvefit, if imposeconstr == 0 or
% use fmincon with Algorithm set to 'sqp' if imposeconstr == 0
% Table:
% imposeconstr|chngsolver|intent
% 0|0| lsqnonlin
% 0|1| lsqcurvefit
% 1|0| fmincon using default 'interior-point' algorithm
% 1|1| fmincon using 'sqp' algorithm
chngsolver = nlsigfit_opts.chngsolver;

% nboot = 100 (default);
% number of bootstraps
% nboot = nlsigfit_opts.nboot;

%% nlsig variables
n_ips = nlsigfit_opts.n;
shape = nlsigfit_opts.shape;

% Create optimization variables

if len_sol == 2 || len_sol == 6
    base =  "nat"; %iopts.base;
elseif len_sol == 3 || len_sol == 7
    base = optimvar('base',n_ips);
    base.LowerBound = 2*ones(n_ips,1);
    base.UpperBound = 20*ones(n_ips,1);
    x0.base = 10*ones(n_ips,1);
else
    error('Oops, nlsig expects 6 or 7 variables for optimization!');
end

lambda = optimvar('lambda',n_ips);
lambda.LowerBound = 1e-3*ones(n_ips,1);
lambda.UpperBound = 16*ones(n_ips,1);
if trys == 1
nlsigfit_opts.lambda = 1*ones(n_ips,1);
elseif trys == 2
nlsigfit_opts.lambda = 3*ones(n_ips,1);    
elseif trys == 3
nlsigfit_opts.lambda = 0.1*ones(n_ips,1);    
elseif trys == 4
nlsigfit_opts.lambda = 0.5*ones(n_ips,1);    
elseif trys == 5
nlsigfit_opts.lambda = 6*ones(n_ips,1); 
elseif trys == 6
nlsigfit_opts.lambda = 12*ones(n_ips,1);  
end
x0.lambda = nlsigfit_opts.lambda;

% for i = 1:n_ips
%     lambda.LowerBound(i) = 1e-6;
%     lambda.UpperBound(i) = 20;
% end

xpks = optimvar('xpks',n_ips);
x0.xpks = nlsigfit_opts.xpks;

% peaks bounds.
if lubnds == true
    for  i = 1:n_ips-1
        xpks.LowerBound(i) = 0.5*nlsigfit_opts.xpks(i);
        xpks.UpperBound(i) = 1.2*nlsigfit_opts.xpks(i);
    end
    for  i = n_ips:n_ips
        xpks.LowerBound(i) = 0.5*nlsigfit_opts.xpks(i);
        xpks.UpperBound(i) = 1.2*nlsigfit_opts.xpks(i);
    end
end


if len_sol == 6 || len_sol == 7
    
    xmin = optimvar('xmin',n_ips);
    for i = 1:n_ips
        if i==1 && sbounds == true
            xmin.LowerBound(i) = nlsigfit_opts.xmin(i);
            xmin.UpperBound(i) = nlsigfit_opts.xmin(i);
        end
        if i > 1 && lubnds == true
            xmin.LowerBound(i) = nlsigfit_opts.xmin(i);
            xmin.UpperBound(i) = nlsigfit_opts.xmin(i);
        end       
    end
    x0.xmin = nlsigfit_opts.xmin;
    
    ymin = optimvar('ymin',n_ips);
    for i = 1:n_ips
        if i==1 && sbounds == true
            ymin.LowerBound(i) = nlsigfit_opts.ymin(i);
            ymin.UpperBound(i) = nlsigfit_opts.ymin(i);
        end
        if i > 1 && lubnds == true
            ymin.LowerBound(i) = nlsigfit_opts.ymin(i);
            ymin.UpperBound(i) = nlsigfit_opts.ymin(i);
        end
        
    end
    x0.ymin = nlsigfit_opts.ymin;
    
    xmax = optimvar('xmax',n_ips);
    for i = 1:n_ips
        if i < n_ips && lubnds == true
            xmax.LowerBound(i) = nlsigfit_opts.xmax(i);
            xmax.UpperBound(i) = nlsigfit_opts.xmax(i);
        end
        if i == n_ips
            xmax.LowerBound(i) = 0.5*nlsigfit_opts.xmax(i);
            xmax.UpperBound(i) = 1.2*nlsigfit_opts.xmax(i);
        end
    end
    x0.xmax = nlsigfit_opts.xmax;
 
    ymax = optimvar('ymax',n_ips);
    for i = 1:n_ips
        if i < n_ips && lubnds == true
            ymax.LowerBound(i) = nlsigfit_opts.ymax(i);
            ymax.UpperBound(i) = nlsigfit_opts.ymax(i);
        end
        if i == n_ips
            ymax.LowerBound(i) = 0.5*nlsigfit_opts.ymax(i);
            ymax.UpperBound(i) = 1.2*nlsigfit_opts.ymax(i);
        end
    end
    x0.ymax = nlsigfit_opts.ymax;

elseif len_sol == 2 || len_sol == 3
    xmin = nlsigfit_opts.xmin;
    
    xmax = nlsigfit_opts.xmax;
    
    ymin = nlsigfit_opts.ymin;
    
    ymax = nlsigfit_opts.ymax;
    
end

%% problem-based optimization constructor
% create objective function as an optimization expression

if len_sol == 6
    objfun = @(lambda,xmax,xmin,ymax,ymin,xpks)...
        nlsigeval(x_data,n_ips,shape,base,lambda,xmax,xmin,ymax,ymin,xpks);
    [y_mdlfun, dy_dx_mdlfun] = fcn2optimexpr(objfun,lambda,xmax,xmin,ymax,ymin,xpks,...
        'ReuseEvaluation',false,...
        'OutputSize', {[length(x_data) 1],[length(x_data) 1]});
elseif len_sol == 7
    objfun = @(base,lambda,xmax,xmin,ymax,ymin,xpks)...
        nlsigeval(x_data,n_ips,shape,base,lambda,xmax,xmin,ymax,ymin,xpks);
    [y_mdlfun, dy_dx_mdlfun] = fcn2optimexpr(objfun,base,lambda,xmax,xmin,ymax,ymin,xpks,...
        'ReuseEvaluation',false,...
        'OutputSize', {[length(x_data) 1],[length(x_data) 1]});
elseif len_sol == 2
    objfun = @(lambda,xpks)...
        nlsigeval(x_data,n_ips,shape,base,lambda,xmax,xmin,ymax,ymin,xpks);
    [y_mdlfun, dy_dx_mdlfun] = fcn2optimexpr(objfun,lambda,xpks,...
        'ReuseEvaluation',false,...
        'OutputSize', {[length(x_data) 1],[length(x_data) 1]});
elseif len_sol == 3
    objfun = @(base,lambda,xpks)...
        nlsigeval(x_data,n_ips,shape,base,lambda,xmax,xmin,ymax,ymin,xpks);
    [y_mdlfun, dy_dx_mdlfun] = fcn2optimexpr(objfun,base,lambda,xpks,...
        'ReuseEvaluation',false,...
        'OutputSize', {[length(x_data) 1],[length(x_data) 1]});
end

% Convert objfun to an optimization expression
% to an explicit sum of squares of the fitting error
objsse = sum((y_mdlfun - y_data).^2) + sum((dy_dx_mdlfun - dy_data).^2); 
% dfobjsse =  sum((dy_dx_mdlfun - dy_data).^2); %#ok<NASGU> unused

% Create an optimization problem with objsse
% as the explicit objective function.
nlsigprob = optimproblem("Objective",objsse);
    

if imposeconstr == 1
    
    if len_sol >=6
        %     Specify problem constraints to be imposed
        %     in fitting the nlsig model to the given data
        constr_xminmax1=optimconstr(n_ips);
        constr_xminmax2=optimconstr(n_ips-1);
        constr_xminxpks=optimconstr(n_ips);
        constr_xpksxmax=optimconstr(n_ips);
        constr_xpks=optimconstr(n_ips-1);
%         constr_yminmax1=optimconstr(n_ips);
%         constr_yminmax2=optimconstr(n_ips-1);
        epsileq = 0.1; %#ok<NASGU>
        epsileq2 = 1;
        epsileq3 = 2;
        for i = 1:n_ips
            %         x- constraints.
            constr_xminmax1(i) = xmin(i)+epsileq3 <= xmax(i);
            if i > 1
                constr_xminmax2(i) = xmin(i) == xmax(i-1);
            end
            %         peaks constraints.
            constr_xminxpks(i) = xmin(i)+epsileq2 <= xpks(i);
            constr_xpksxmax(i) = xpks(i)+epsileq2 <= xmax(i);
            if i > 1
                constr_xpks(i) = xpks(i-1)+epsileq2 <= xpks(i);
            end
            %         y- constraints.
%             constr_yminmax1(i) = ymin(i)+epsileq3 <= ymax(i);
%             if i > 1
%                 constr_yminmax2(i) = ymin(i) == ymax(i-1);
%             end
        end  
        nlsigprob.Constraints.constr_xminmax1=constr_xminmax1;
        nlsigprob.Constraints.constr_xminmax2=constr_xminmax2;
        nlsigprob.Constraints.constr_xminxpks=constr_xminxpks;
        nlsigprob.Constraints.constr_xpksxmax=constr_xpksxmax;
        nlsigprob.Constraints.constr_xpks=constr_xpks;
%         nlsigprob.Constraints.constr_yminmax1=constr_yminmax1;
%         nlsigprob.Constraints.constr_yminmax2=constr_yminmax2;      
    end
end

%% show(nlsigprob);

%TODO: Make in solver-based form, use multi-start et.al.
% see prob2struct include derivatives in solver.
% problem = prob2struct(nlsigprob);
% debug; idx = varindex(nlsigprob)

% Setup default solver
newoptins = optimoptions(nlsigprob);
newoptins.Display = 'off'; % debug: 'iter'
newoptins.UseParallel = false;

% Solve the data-fitting problem using the selected solver.
% freq = 1;
[sol,fval,exitflag,output,newoptins] = fitnlsig(nlsigprob,x0,...
    imposeconstr,chngsolver,newoptins);
% Apply the model for estimation using the optimized variables
y_est = evaluate(y_mdlfun,sol);
dy_dx_est = evaluate(dy_dx_mdlfun, sol);

% Compute residuals and other gof statistics
fitstats = calc_stats(y_data,y_est,dy_data,dy_dx_est,len_sol,n_ips);

% check for best fit by using an ensemble of lambdas.
if trys == 1
best_sol = sol;
best_fit = fitstats;
else
    if fitstats.R2 > best_fit.R2
        best_sol = sol;
        best_fit = fitstats;
    end
end

% check if fit is significant
% if fitstats.R2 > 0.97
%     break;
% end

end
sol = best_sol;
fitstats = best_fit;

%% Augment un-optimized parameters with the optimized solutions struct
sol.check_constraints = 0;
sol.n = n_ips;
sol.shape = 1;

if len_sol == 2 || len_sol == 6
    sol.base = base;
end

if len_sol == 2 || len_sol == 3
    sol.xmin = xmin;
    sol.xmax = xmax;
    sol.ymin = ymin;
    sol.ymax = ymax;
end

sol.p = 6;

%% Plot Fitting Solution and 95% CIs
% if nlsigfit_opts.plotfit == 1 
%     plot_fitnlsig(x_data,y_data,y_est,dy_dx_est, ...
%         y_estlb,dy_dx_estlb,y_estub,dy_dx_estub)
% end

end