function [gsol,gbest_fitstats,ymets,xmets,new_mts] = cov19_nlsigquery(country_code,update,focus,nboot)
close all;clc;

% global figure handles
% persistent figplt1;  
persistent figplt2;
% the above seems unuseful.

% entry options
if nargin < 4
    nboot = 512;
end
len_sol= 6; 
imposeconstr = 	0;
chngsolver = 0;



% if country_code == "WD"
% imposeconstr = 1;
% chngsolver = 0;
% end

% *Help*: |country_code| is available in |dir:*local*, see the "country_code_name.xlsx"|
% or |"country_code_name.csv" files.|
% pull data

%% Fetch Data

% GB, CA, FR, ES, IT, AF, IN, IL
%
% NG, US, CN, KR
% [~,status,ccs] = get_cdata("ALL",1); 
%%
% country_code = "US";
% focus = 'i';
% update = 0;
[t,y,dy,status,ccs] = getcasesbycc(country_code,update,focus); %#ok<ASGLU>


for globaltrys=1:4


if globaltrys == 1
    knots_val = 13;
elseif globaltrys == 2
    knots_val = 14;
elseif globaltrys == 3
    knots_val = 15;
elseif globaltrys == 4
    knots_val = 12;
end

% Smooth Data by Fitting Cubic Spline to Data
% for kn = 8:16 % for least-squares regression 8,9,10,12,13,14,15
% reduce knots to determine smaller sized waves.
% range: start from 14; 14 - 13
% NG, US, CN, KR = 13;
% GB, CA, FR, ES, IT, AF, IN, IL = 14;
% knots_val = 12;
[xid,ys,dys,d2ys] = smoothspline(y,knots_val); %#ok<ASGLU>

% Find Peaks and Valleys (Inflection-Points)
cpt_dists = [7 25];
[iplist_idx] = findips(y,dys,d2ys,cpt_dists);
% Categorize inflections into peaks and valleys
[ips_valley,ips_peak,n_ips,phase,iplist_idx] = groupips(y,dy,iplist_idx);

% Transfer Inflection points to represent proper input structures
% for the nlsig function
[x_data,y_data,ig_opts,ips_adata,ips_vdata,ips_pdata,time_data] = ...
    xy_ipsort(xid,y,n_ips,iplist_idx,ips_valley,ips_peak,t);
dy_data = dy(ips_valley(1):end);

% Optional Plot of Initial Guesses
% figplt1 = plotsmoothipfinder(figplt1, country_code,t,xid,y,dy,dys,...
%     iplist_idx,ips_peak,ips_valley,phase);

% Optimization problem
 
% len_sol = 6;
% nboot = 16;
% imposeconstr = 0;
% chngsolver = 0;
startingbounds = true;
lubnds = true;
[y_sol,dy_sol,sol,fitstats,fval,exitflag,output,...
    y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins,fitopts] ...
    = nsligfp(x_data,y_data,dy_data,ig_opts,startingbounds,lubnds,...
    len_sol,imposeconstr,chngsolver); %#ok<ASGLU>


if globaltrys == 1
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
else
    if fitstats.R2 > gbest_fitstats.R2
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
    end
end

if (1 - gbest_fitstats.R2) <= 1e-4
    break;
end

end

% Bootstrap uncertainty CI bounds 
% on finding a best fit solution
[gy_sollb,gdy_sollb,gsol_lb,gy_solub,gdy_solub,gsol_ub,...
    gbest_fitstatslb,gbest_fitstatsub] ...
    = nsligfp_bootstrap(x_data,y_data,gsol,gy_sol,len_sol,...
    imposeconstr,chngsolver,nboot,gbest_fitstats,...
    gy_mdlfun,gdy_dx_mdlfun,gnlsigprob,gx0,gn_ips,gnewoptins); %#ok<ASGLU>



% nlogistic curve metrics
YIR = YIRidx(gy_sol,gsol.ymax,gsol.ymin);
XIR = XIRidx(x_data,gsol);
%
YIRlb = YIRidx(gy_sollb,gsol_lb.ymax,gsol_lb.ymin);
XIRlb = XIRidx(x_data,gsol_lb);
%
YIRub = YIRidx(gy_solub,gsol_ub.ymax,gsol_ub.ymin);
XIRub = XIRidx(x_data,gsol_ub);

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

save_metrics(focus,new_mts,country_code,time_data);

%% Prediction Plots

figplt2 = plotpreds(figplt2, country_code,time_data,x_data,y_data,dy_data,...
    gy_sol,gy_sollb,gy_solub,gdy_sol,gdy_sollb,gdy_solub,...
    focus,gips_adata,gips_vdata,gips_pdata,gphase);

% Export Graphics
exportplots(gcf,country_code,focus,time_data);

end
%
