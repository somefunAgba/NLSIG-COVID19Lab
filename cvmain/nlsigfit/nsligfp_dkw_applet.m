function [app,y_sollb,dy_sollb,sol_lb,y_solub,dy_solub,sol_ub,...
    fitstatslb,fitstatsub] ...
    = nsligfp_dkw_applet(app,x_data,y_sol,dy_sol,fitstats,fitopts,sbounds,lubnds)
%NLSIGFP_BOOTSTRAP Compute uncertainty on data to nlsig fit/prediction

% display bootstrapping progress
skyblue = [0.5,0.7,0.9];
boldgreen = [0.5 0.9 0.5];

app.StatusLabel.Text = "DKWing!";
app.StatusLabel.FontColor = skyblue;
pause(1);

yref = y_sol;
% yref = y_data;
dyref = dy_sol;


% LB
y_lb = yref - fitstats.ciE;
dy_lb = dyref - fitstats.dciE;
% bt_objsse = sum((y_mdlfun - y_lb).^2) + sum((dy_dx_mdlfun - dy_lb).^2);
% nlsigprob.Objective = bt_objsse;

% Set up fit options structure
fitoptslb = fitopts;
fitoptslb.ymin = fitopts.ymin - fitstats.ciE;
fitoptslb.ymin(1) = fitopts.ymin(1);
fitoptslb.ymax = fitopts.ymax - fitstats.ciE;
% Fit
[sol_lb,~,~,~,fitstatslb] = ...
    set_probopts(x_data, y_lb, dy_lb, fitoptslb, sbounds,lubnds);


% UB
y_ub = yref + fitstats.ciE ;
dy_ub = dyref + fitstats.dciE;
% bt_objsse = sum((y_mdlfun - y_ub).^2) + sum((dy_dx_mdlfun - dy_ub).^2);
% nlsigprob.Objective = bt_objsse;

% Set up fit options structure
fitoptsub = fitopts;
fitoptsub.ymin = fitopts.ymin + fitstats.ciE;
fitoptsub.ymin(1) = fitopts.ymin(1);
fitoptsub.ymax = fitopts.ymax + fitstats.ciE;
% Fit
[sol_ub,~,~,~,fitstatsub] ... 
    = set_probopts(x_data, y_ub, dy_ub, fitoptsub, sbounds,lubnds);

% Predict CIs
[y_sollb,dy_sollb] = nlsig(x_data,0,sol_lb);
[y_solub,dy_solub] = nlsig(x_data,0,sol_ub);

app.StatusLabel.Text =  " Done.";
app.StatusLabel.FontColor = boldgreen;




end
