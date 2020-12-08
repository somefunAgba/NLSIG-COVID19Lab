close all;clc;

% global figure handles
global figplt1; 
global figplt2;

% *Help*: |country_code| is available in |dir:*local*, see the "country_code_name.xlsx"|
% or |"country_code_name.csv" files.|
% pull data

%% Fetch Data

% GB, CA, FR, ES, IT, AF, IN, IL
%
% NG, US, CN, KR
% [~,status,ccs] = get_cdata("ALL",1); 
%%
country_code = "US";
focus = 'i';
update = 0;
[t,y,dy,status,ccs] = getcasesbycc(country_code,update,focus);

% Smooth Data by Fitting Cubic Spline to Data
% for kn = 8:16 % for least-squares regression 8,9,10,12,13,14,15
% reduce knots to determine smaller sized waves.
% range: start from 14; 14 - 13
% NG, US, CN, KR = 13;
% GB, CA, FR, ES, IT, AF, IN, IL = 14;
knots_val = 13;
[xid,ys,dys,d2ys] = smoothspline(y,knots_val);

% Find Peaks and Valleys (Inflection-Points)
cpt_dists = [7 25];
[iplist_idx] = findips(y,dys,d2ys,cpt_dists);
% Categorize inflections into peaks and valleys
[ips_valley,ips_peak,n_ips,phase] = groupips(y,dy,iplist_idx);

% Transfer Inflection points to represent proper input structures
% for the nlsig function
[x_data,y_data,ig_opts,ips_adata,ips_vdata,ips_pdata,time_data] = ...
    xy_ipsort(xid,y,n_ips,iplist_idx,ips_valley,ips_peak,t);
dy_data = dy(ips_valley(1):end);

% Optional Plot of Initial Guesses
figplt1 = plotsmoothipfinder(figplt1, country_code,t,xid,y,dy,dys,...
    iplist_idx,ips_peak,ips_valley,phase);

% Optimization problem
% clc; 
len_sol = 6;
nboot = 16;
imposeconstr = 0;
chngsolver = 0;
[y_sol,dy_sol,sol,...
    y_sollb,dy_sollb,sol_lb,...
    y_solub,dy_solub,sol_ub,...
    fitstats,fitstatslb,fitstatsub,...
    fval,exitflag,output] ...
    = nsligfp(x_data,y_data,dy_data,ig_opts,len_sol,imposeconstr,chngsolver,nboot);

% nlogistic curve indices
YIR = YIRidx(y_sol,sol.ymax,sol.ymin);
XIR = XIRidx(x_data,sol.xpks,sol.xmax,sol.xmin);

%% Prediction Plots

figplt2 = plotpreds(figplt2, country_code,time_data,x_data,y_data,dy_data,...
    y_sol,y_sollb,y_solub,dy_sol,dy_sollb,dy_solub,...
    focus,ips_adata,ips_vdata,ips_pdata,phase);

% Export Graphics
exportplots(gcf,country_code,focus);


%
