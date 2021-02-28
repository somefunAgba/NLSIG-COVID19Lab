function [app,y_sollb,dy_sollb,sol_lb,y_solub,dy_solub,sol_ub,...
    fitstatslb,fitstatsub] ...
    = nsligfp_bootstrap_applet(app,x_data,y_data,dy_data,...
    sol,y_sol,dy_sol,len_sol,imposeconstr,chngsolver,nboot,...
    fitstats, y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins)
%NLSIGFP_BOOTSTRAP Compute uncertainty on data to nlsig fit/prediction

if nboot <= 1
    nboot = 2;
end
y_est = y_sol;
dy_est = dy_sol;


% display bootstrapping progress
skyblue = [0.5,0.7,0.9];
boldgreen = [0.35 0.8 0.15];
% fprintf('\n');
% cprintf(boldgreen,'May take some time! ');
app.StatusLabel.Text = "Bootstrapping ...";
app.StatusLabel.FontColor = skyblue;
pause('on')

% bootstrap

% boot_countid = 1;
boot_sol = bootstrp(nboot, ...
    @(bootry,bootrdy)bootregs_applet(y_est + bootry, dy_est + bootrdy,...
    y_mdlfun,dy_dx_mdlfun,x0,nlsigprob,...
    imposeconstr,chngsolver,newoptins,nboot,app),...
    fitstats.residuals,fitstats.dresiduals);    
pause('off');
clear bootregs_applet;

% using bootstrap, estimate 95% confidence intervals CI
% on the fitted solution
% percentiles 2.5 and 97.5: range (97.5-2.5) implies a 95% CI
[sol_lb, sol_ub] = sol_bootci2(boot_sol,nboot,n_ips,len_sol);
app.StatusLabel.Text =  "Done.";
app.StatusLabel.FontColor = boldgreen;


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
sol_lb.shape = 1;
sol_lb.p = 6;

% UB
sol_ub.check_constraints = 0;
sol_ub.n = n_ips;
sol_ub.shape = 1; %'s'
sol_ub.p = 6;

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
