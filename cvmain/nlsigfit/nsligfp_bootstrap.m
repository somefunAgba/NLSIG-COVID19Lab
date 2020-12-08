function [y_sollb,dy_sollb,sol_lb,y_solub,dy_solub,sol_ub,...
    fitstatslb,fitstatsub] ...
    = nsligfp_bootstrap(x_data,y_data,sol,y_sol,len_sol,imposeconstr,chngsolver,nboot,...
    fitstats, y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins)
%NLSIGFP_BOOTSTRAP Compute uncertainty on data to nlsig fit/prediction

if nboot <= 1
    nboot = 2;
end
y_est = y_sol;


% display bootstrapping progress
skyblue = [0.5,0.7,0.9];
boldgreen = '*[0.5 0.9 0.5]';
fprintf('\n');
cprintf(boldgreen,'May take some time! ');
cprintf(skyblue,"Bootstrapping... ");
pause('on');
%

% Build up 'nboot' bootstrap distributions
% [~, bootids] = bootstrp(nboot, [], fitstats.residuals);
% boot_residuals = fitstats.residuals(bootids);
% % apply resampled residuals to initial model function fit
% y_bs = repmat(y_est, 1, nboot) + boot_residuals;
% % fit each bootstrap dataset distribution and extract parameter estimates
% boot_sol = cell(nboot,1);
% for id=1:nboot
%     boot_objsse = sum((y_mdlfun - y_bs(:,id)).^2);
%     nlsigprob.Objective = boot_objsse;
%     boot_sol{id} = fitnlsig(nlsigprob,x0,imposeconstr,chngsolver,newoptins);
%     %
%     % Add Display Progress
%     cprintf(skyblue,"%d",id);
%     if id ~= nboot
%         % refresh rate (wait time ~ 30ms)
%         pause(0.02);
%         fprintf(repmat('\b',1,length(num2str(id))));
%     end
%     %
% end
% pause('off');
% cprintf(boldgreen,' Done.\n');
% using bootstrap, estimate 95% confidence intervals CI
% on the fitted solution
% [sol_lb, sol_ub] = sol_bootci(boot_sol,nboot,n_ips,len_sol);


% bootstrap

% boot_countid = 1;
boot_sol = bootstrp(nboot, @(bootr)bootregs(y_est + bootr,y_mdlfun,...
    x0,nlsigprob,imposeconstr,chngsolver,newoptins,nboot,skyblue), fitstats.residuals);    
pause('off');
% using bootstrap, estimate 95% confidence intervals CI
% on the fitted solution
% percentiles 2.5 and 97.5: range (97.5-2.5) implies a 95% CI
[sol_lb, sol_ub] = sol_bootci2(boot_sol,nboot,n_ips,len_sol);
cprintf(boldgreen,' Done.\n');



% LB_CI
y_estlb = evaluate(y_mdlfun,sol_lb);
dy_dx_estlb = evaluate(dy_dx_mdlfun, sol_lb); %#ok<NASGU>
fitstatslb = calc_stats(y_data,y_estlb,len_sol,n_ips);

% UB_CI
y_estub = evaluate(y_mdlfun,sol_ub);
dy_dx_estub = evaluate(dy_dx_mdlfun, sol_ub); %#ok<NASGU>
fitstatsub = calc_stats(y_data,y_estub,len_sol,n_ips);

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
