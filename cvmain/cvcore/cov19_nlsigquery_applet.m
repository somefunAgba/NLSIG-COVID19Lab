function [app,time_data,gsol,gbest_fitstats,ymets,xmets,new_mts] = ...
    cov19_nlsigquery_applet(country_code,update,focus,nboot,boots,smooth,app)
%COV19_NLSIGQUERY_APPLET obtains local COVID-19 data and model with the NLSIG
% Query and model local COVID-19 data on a focus category of cases 
% from a specified country-code using the NLSIG function.
%
% private function
% 
%INPUTS:
% country_code
% update
% focus
% nboot
% boots
% finer
% app
%
%OUTPUTS:
% app,
% time_data,
% gsol,
% gbest_fitstats,
% ymets,
% xmets,
% new_mts
%
% Copyright:
% |oasomefun@futa.edu.ng| 2020.%

% input validation
assert(nargin<=7," Expected at most 7 arguments!")

is_app = true;
if nargin < 7 % not an applet
    is_app = false;
    if nargin < 6
        smooth = false;
    end
    if nargin < 4
        nboot = 512;
    end
end

% initial setting
spass = false;

if smooth == true 
    % enforce always
    boots = false; % only valid if smooth == false
end

assert(update == 0 || update == 1, "update is either: 0 or 1!")
assert(focus == 'i' || focus == 'd', "focus is either: 'i' or 'd'!")
assert(nboot > 0, "number of boot should be positive integer!")
nboot = ceil(nboot);


% (fixed) nlsig optimization options
len_sol= 6; 
imposeconstr = 	0;
chngsolver = 0;


%% Fetch Data

if is_app == true
    app.StatusLabel.Text =  "Querying ...";
    app.StatusLabel.FontColor = [0.88,0.08,0.38];
    [t,y,dy,~] = cases_cc(country_code,update,focus,app);
else
    fprintf("Querying ...\n");
    [t,y,dy,~] = cases_cc(country_code,update,focus);
end

pause('on');
% depreceated
% for globaltrys=1:4
% 
% 
% if globaltrys == 1
%     knots_val = 13;
% elseif globaltrys == 2
%     knots_val = 14;
% elseif globaltrys == 3
%     knots_val = 15;
% elseif globaltrys == 4
%     knots_val = 12;
% end
% Smooth Data by Fitting Cubic Spline to Data
% for kn = 8:16 % for least-squares regression 8,9,10,12,13,14,15
% reduce knots to determine smaller sized waves.
% knots_val = 13;
% [xid,ys,dys,d2ys] = smoothspline(smooth,y,dy,knots_val); %#ok<ASGLU>

if is_app == true
    app.StatusLabel.Text = "Searching i.ps ...";
    app.StatusLabel.FontColor = [0.88,0.08,0.38];
    pause(1);
else
    fprintf("Searching i.ps ...\n");
end

[xid,y,dys,d2ys] = zfs_diff(y,dy);

% Find Peaks and Valleys (Inflection-Points)
if smooth == false
%   cpt_dists = [7 25];   
    cpt_dists = [1 7]; 
end
if smooth == true
    cpt_dists = [1 7]; 
end

[iplist_idx] = findips(y,dy,dys,d2ys,cpt_dists,smooth);
% Categorize inflections into peaks and valleys
[ips_valley,ips_peak,n_ips,phase,iplist_idx] = groupips(y,dy,iplist_idx);

% Transfer Inflection points to represent proper input structures
% for the nlsig function
[x_data,y_data,ig_opts,ips_adata,ips_vdata,ips_pdata,time_data] = ...
    xy_ipsort(spass,xid,y,n_ips,iplist_idx,ips_valley,ips_peak,t);
dy_data = dy(ips_valley(1):end);

if is_app == true
    app.StatusLabel.Text = "Search done! Optimizing ...";
    app.StatusLabel.FontColor = [0.88,0.08,0.38];
    pause(1);
else
    fprintf("Search done! Optimizing ...\n");
end

% depreceated
% Optional Plot of Initial Guesses
% figplt1 = plotsmoothipfinder(figplt1, country_code,t,xid,y,dy,dys,...
%     iplist_idx,ips_peak,ips_valley,phase);

% Optimization problem
startingbounds = true;
lubnds = true;
[y_sol,dy_sol,sol,fitstats,fval,exitflag,output,...
    y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins,fitopts] ...
    = nsligfp(x_data,y_data,dy_data,ig_opts,startingbounds,lubnds,...
    len_sol,imposeconstr,chngsolver);  %#ok<ASGLU>

gsol = sol;
gbest_fitstats = fitstats;
gy_sol = y_sol;
gdy_sol = dy_sol;
gips_adata = ips_adata;
gips_vdata = ips_vdata;
gips_pdata = ips_pdata;
gphase = phase; 
gn_ips = n_ips;
gy_mdlfun = y_mdlfun;
gdy_dx_mdlfun = dy_dx_mdlfun;
gx0 = x0;
gnlsigprob = nlsigprob;
gnewoptins = newoptins;

% depreceated
% else
%     if fitstats.R2 > gbest_fitstats.R2
%         gsol = sol;
%         gbest_fitstats = fitstats;
%         gy_sol = y_sol;
%         gdy_sol = dy_sol;
%         gips_adata = ips_adata;
%         gips_vdata = ips_vdata;
%         gips_pdata = ips_pdata;
%         gphase = phase;
%         gn_ips = n_ips;
%         gy_mdlfun = y_mdlfun;
%         gdy_dx_mdlfun = dy_dx_mdlfun;
%         gx0 = x0;
%         gnlsigprob = nlsigprob;
%         gnewoptins = newoptins;
%     end
%end
% 
% if (1 - gbest_fitstats.R2) <= 1e-4
%     break;
% end
% 
% end

%% Bootstrap uncertainty CI bounds on best fit solution
if is_app == true
    if boots == true
        [app,gy_sollb,gdy_sollb,gsol_lb,gy_solub,gdy_solub,gsol_ub,...
            gbest_fitstatslb,gbest_fitstatsub] ...
            = nsligfp_bootstrap_applet(app,x_data,y_data,dy_data,gsol,gy_sol,gdy_sol,len_sol,...
            imposeconstr,chngsolver,nboot,gbest_fitstats,...
            gy_mdlfun,gdy_dx_mdlfun,gnlsigprob,gx0,gn_ips,gnewoptins); %#ok<ASGLU>
    else
        [app,gy_sollb,gdy_sollb,gsol_lb,gy_solub,gdy_solub,gsol_ub,...
            gbest_fitstatslb,gbest_fitstatsub] ...
            = nsligfp_dkw_applet(app,x_data,gy_sol,gdy_sol,fitstats,...
            fitopts,startingbounds,lubnds); %#ok<ASGLU>
    end
else
    if boots == true
        [gy_sollb,gdy_sollb,gsol_lb,gy_solub,gdy_solub,gsol_ub,...
            gbest_fitstatslb,gbest_fitstatsub] ...
            = nsligfp_bootstrap(x_data,y_data,dy_data,gsol,gy_sol,gdy_sol,len_sol,...
            imposeconstr,chngsolver,nboot,gbest_fitstats,...
            gy_mdlfun,gdy_dx_mdlfun,gnlsigprob,gx0,gn_ips,gnewoptins); %#ok<ASGLU>
    else
        [gy_sollb,gdy_sollb,gsol_lb,gy_solub,gdy_solub,gsol_ub,...
            gbest_fitstatslb,gbest_fitstatsub] ...
            = nsligfp_dkw(x_data,gy_sol,gdy_sol,fitstats,...
            fitopts,startingbounds,lubnds); %#ok<ASGLU>
    end
    
end
pause('on');


%% Second-Pass 
% Uses smoothed solution data to ensures metrics are correct
while (smooth == true)
    spass = true;
    smooth  = false;
    
    if is_app == true
        boldgreen = [0.5 0.9 0.5];
        app.StatusLabel.Text =  "Second Pass!";
        app.StatusLabel.FontColor = boldgreen;
        pause(1);
    else
        boldgreen = '*[0.5 0.9 0.5]';
        cprintf(boldgreen,'Second Pass! ');
    end
    
    [xid,~,dys,d2ys] = zfs_diff(gy_sol,gdy_sol);
    [iplist_idx] = findips(gy_sol,gdy_sol,dys,d2ys,cpt_dists,smooth);
    % Categorize inflections into peaks and valleys
    [ips_valley,ips_peak,n_ips,gphase,iplist_idx] ...
        = groupips(gy_sol,gdy_sol,iplist_idx);
    
    % Transfer Inflection points to represent proper input structures
    % for the nlsig function
    t = time_data(1);
    [x_data,sy_data,ig_opts,gips_adata,gips_vdata,gips_pdata,time_data] = ...
        xy_ipsort(spass,xid,gy_sol,n_ips,iplist_idx,ips_valley,ips_peak,t);
     sdy_data = gdy_sol(ips_valley(1):end);
    
    % disp(n_ips); % debug
    [y_sol,dy_sol,sol,best_fitstats,fval,exitflag,output,...
        y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,gnewoptins,fitopts] ...
        = nsligfp(x_data,sy_data,sdy_data,ig_opts,startingbounds,lubnds,...
        len_sol,imposeconstr,chngsolver); %#ok<ASGLU>

    if is_app == true
        if boots == true
            [app,y_sollb,dy_sollb,sol_lb,y_solub,dy_solub,sol_ub,...
                best_fitstatslb,best_fitstatsub] ...
                = nsligfp_bootstrap_applet(app,x_data,sy_data,sdy_data,sol,dy_sol,y_sol,len_sol,...
                imposeconstr,chngsolver,nboot,best_fitstats,...
                y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins); %#ok<ASGLU>
        else
            [app,y_sollb,dy_sollb,sol_lb,y_solub,dy_solub,sol_ub,...
                best_fitstatslb,best_fitstatsub] ...
                = nsligfp_dkw_applet(app,x_data,y_sol,dy_sol,gbest_fitstats,...
                fitopts,startingbounds,lubnds); %#ok<ASGLU>
            
        end
    else
        if boots == true
            [y_sollb,dy_sollb,sol_lb,y_solub,dy_solub,sol_ub,...
                best_fitstatslb,best_fitstatsub] ...
                = nsligfp_bootstrap(x_data,sy_data,sdy_data,sol,y_sol,dy_sol,len_sol,...
                imposeconstr,chngsolver,nboot,best_fitstats,...
                y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins); %#ok<ASGLU>
        else
            [y_sollb,dy_sollb,sol_lb,y_solub,dy_solub,sol_ub,...
                best_fitstatslb,best_fitstatsub] ...
                = nsligfp_dkw(x_data,y_sol,dy_sol,gbest_fitstats,...
                fitopts,startingbounds,lubnds); %#ok<ASGLU>
        end
     
    end
    
end
pause('on');
%% NLSIG curve metrics
if spass == false
    YIR = YIRidx(gy_sol,gsol.ymax,gsol.ymin);
    XIR = XIRidx(x_data,gsol);
    %
    YIRlb = YIRidx(gy_sollb,gsol_lb.ymax,gsol_lb.ymin);
    XIRlb = XIRidx(x_data,gsol_lb);
    %
    YIRub = YIRidx(gy_solub,gsol_ub.ymax,gsol_ub.ymin);
    XIRub = XIRidx(x_data,gsol_ub);
else
    YIR = YIRidx(y_sol,sol.ymax,sol.ymin);
    XIR = XIRidx(x_data,sol);
    %
    YIRlb = YIRidx(y_sollb,sol_lb.ymax,sol_lb.ymin);
    XIRlb = XIRidx(x_data,sol_lb);
    %
    YIRub = YIRidx(y_solub,sol_ub.ymax,sol_ub.ymin);
    XIRub = XIRidx(x_data,sol_ub);
end

% debug
% disp(YIR(end))
% disp(XIR(end))

ymets = [YIR, YIRlb, YIRub];
xmets = [XIR, XIRlb, XIRub];
gfit_R2 = (fitstats.R2a)*ones(length(x_data),1); 
xmetmid = median(xmets,2);
xmetmin = min(xmets,[],2);
xmetmax = max(xmets,[],2);
ymetmid = median(ymets,2);
ymetmin = min(ymets,[],2);
ymetmax = max(ymets,[],2);
new_mts = table(time_data,gfit_R2,...
    xmetmid,xmetmin,xmetmax,ymetmid,ymetmin,ymetmax);

% yph = [min(ymets(end,:)), median(ymets(end,:)), max(ymets(end,:))];
xph = [min(xmets(end,:)), median(xmets(end,:)), max(xmets(end,:))];
if xph(2) > 1
    gphase = "post-peak";
elseif abs(xph(2) - 1) < 0.03
    gphase = "possible peak";
elseif xph(2) < 1
    gphase = "pre-peak";
    if (xph(2) - 0) < 1e-4
        gphase = "post-peak";
    end
end

save_metrics(focus,new_mts,country_code,time_data);

%% Prediction Plots

if is_app == true
    plotpreds_applet(app, ...
        country_code,time_data,x_data,y_data,dy_data,...
        gy_sol,gy_sollb,gy_solub,gdy_sol,gdy_sollb,gdy_solub,...
        focus,gips_adata,gips_vdata,gips_pdata,gphase);
    
    % Export Graphics
    figsv = plotpreds(gcf,country_code,time_data,x_data,y_data,dy_data,...
        gy_sol,gy_sollb,gy_solub,gdy_sol,gdy_sollb,gdy_solub,...
        focus,gips_adata,gips_vdata,gips_pdata,gphase,is_app);
    exportplots_applet(figsv,country_code,focus,time_data);
    close(figsv);
else
    % figure handles
    figsv = figure;
    figsv = plotpreds(figsv,country_code,time_data,x_data,y_data,dy_data,...
        gy_sol,gy_sollb,gy_solub,gdy_sol,gdy_sollb,gdy_solub,...
        focus,gips_adata,gips_vdata,gips_pdata,gphase,is_app);
    
    % Export Graphics
    exportplots(figsv,country_code,focus,time_data);
    app = null(1);
    
end
pause('off');
end
%
