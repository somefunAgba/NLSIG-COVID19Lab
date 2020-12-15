function [y_sollb,dy_sollb,sol_lb,y_solub,dy_solub,sol_ub,...
    fitstatslb,fitstatsub] ...
    = nsligfp_dkw(x_data,y_data,dy_data,sol,y_sol,dy_sol,len_sol,...
    imposeconstr,chngsolver,fitstats, ...
    y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins)
%NLSIGFP_BOOTSTRAP Compute uncertainty on data to nlsig fit/prediction

% display bootstrapping progress
skyblue = [0.5,0.7,0.9];
boldgreen = '*[0.5 0.9 0.5]';
cprintf(boldgreen,'May take some time! ');
cprintf(skyblue,"DKWing ... ");

yref = y_sol;
% yref = y_data;
dyref = dy_sol;

y_lb = yref - fitstats.ciE;
dy_lb = dyref - fitstats.dciE;
bt_objsse = sum((y_mdlfun - y_lb).^2) + sum((dy_dx_mdlfun - dy_lb).^2);
nlsigprob.Objective = bt_objsse;
x0lb = x0;
x0lb.ymin = x0.ymin - fitstats.ciE;
x0lb.ymax = x0.ymax - fitstats.ciE;
sol_lb = fitnlsig(nlsigprob,x0lb,imposeconstr,chngsolver,newoptins);

y_ub = yref + fitstats.ciE ;
dy_ub = dyref + fitstats.dciE;
bt_objsse = sum((y_mdlfun - y_ub).^2) + sum((dy_dx_mdlfun - dy_ub).^2);
nlsigprob.Objective = bt_objsse;
x0ub = x0;
x0ub.ymin = x0.ymin + fitstats.ciE;
x0ub.ymax = x0.ymax + fitstats.ciE;
sol_ub = fitnlsig(nlsigprob,x0ub,imposeconstr,chngsolver,newoptins);

cprintf(boldgreen,' Done.\n');

% LB_CI
y_estlb = evaluate(y_mdlfun,sol_lb);
dy_dx_estlb = evaluate(dy_dx_mdlfun, sol_lb);
fitstatslb = calc_stats(y_data,y_estlb,dy_data,dy_dx_estlb,len_sol,n_ips);

% UB_CI
y_estub = evaluate(y_mdlfun,sol_ub);
dy_dx_estub = evaluate(dy_dx_mdlfun, sol_ub);
fitstatsub = calc_stats(y_data,y_estub,dy_data,dy_dx_estub,len_sol,n_ips);

%% Augment un-optimized parameters with the optimized solutions struct

% LB
sol_lb.check_constraints = 0;
sol_lb.n = n_ips;
sol_lb.shape = 's';

% UB
sol_ub.check_constraints = 0;
sol_ub.n = n_ips;
sol_ub.shape = 's';

if len_sol == 2 || len_sol == 6
    sol_lb.base = sol.base;
    sol_ub.base = sol.base;
end

if len_sol == 2 || len_sol == 3
    sol_lb.xmin = sol.xmin;
    sol_lb.xmax = sol.xmax;
    sol_lb.ymin = sol.ymin;
    sol_lb.ymax = sol.ymax;
    sol_ub.xmin = sol.xmin;
    sol_ub.xmax = sol.xmax;
    sol_ub.ymin = sol.ymin;
    sol_ub.ymax = sol.ymax;
end

% Predict CIs
[y_sollb,dy_sollb] = nlsig(x_data,0,sol_lb);
[y_solub,dy_solub] = nlsig(x_data,0,sol_ub);


end
