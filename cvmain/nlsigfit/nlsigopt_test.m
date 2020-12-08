
%% Data
clc;

iopts.check_constraints = 0;
iopts.shape = 's';
iopts.base = "nat";
% required
iopts.n = 2;
iopts.lambda = [1; 6];
% full -4 to 4
iopts.xmin = [-4; -1];
iopts.xpks = [-2.5; 2];
iopts.xmax = [-1; 4];
% full: 0 to 5
iopts.ymin = [0; 3];
iopts.ymax = [3; 5];
% input space
dx = 0.05;
xmin = -5; xmax = 5;
x_data = -1+xmin:dx:1+xmax;
%
[y_real,dy_dx_data] = nlsig(x_data,0,iopts);
rng default;
y_data = y_real + rand(size(y_real));

%%
clc; 
opengl software;

% required
nlsigfit_opts.n = 2;
nlsigfit_opts.shape = 's';

% initial guess
% nlsigfit_opts.lambda = [1; 6];
nlsigfit_opts.xmin = [-3; -1.2];
nlsigfit_opts.xpks = [-2; 1.2];
nlsigfit_opts.xmax = [-2; 3];
nlsigfit_opts.ymin = [0; 4];
nlsigfit_opts.ymax = [3.2; 6];
nlsigfit_opts.len_sol = 6;
nlsigfit_opts.imposeconstr = 0;
nlsigfit_opts.chngsolver = 0;
nlsigfit_opts.nboot = 10;
nlsigfit_opts.plotfit = 1;
%
sbounds = false;
lubnds = false;
[sol,fval,exitflag,output,fitstats,...
    y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins] ...
    = set_probopts(x_data, y_data, dy_dx_data, nlsigfit_opts,sbounds,lubnds);
[y_sol] = nlsig(x_data,0,sol);

% Bootstrap uncertainty CI bounds 
% on finding a best fit solution
nboot = nlsigfit_opts.nboot;
len_sol = nlsigfit_opts.len_sol;
imposeconstr = nlsigfit_opts.imposeconstr;
chngsolver = nlsigfit_opts.chngsolver;
[y_sollb,dy_sollb,sol_lb,y_solub,dy_solub,sol_ub,...
    fitstatslb,fitstatsub] ...
    = nsligfp_bootstrap(x_data,y_data,sol,y_sol,len_sol,...
    imposeconstr,chngsolver,nboot,fitstats,...
    y_mdlfun,dy_dx_mdlfun,nlsigprob,x0,n_ips,newoptins); %#ok<ASGLU>

%% 
% Predict using 'sol', the obtained 'best'-fitting solution 
% with the nlsig function
[y_sollb] = nlsig(x_data,0,sol_lb);
[y_solub] = nlsig(x_data,0,sol_ub);
% Colours
khaki1 = [0.7 0.7 0.2]; %#ok<*NASGU>
khaki2 = [0.7 0.7 0.5];
khaki3 = [0.5 0.5 0.2];
khaki4 = [0.22 0.7 0.7];
darkgrey1 = [0.5 0.5 0.5];
darkgrey2 = [0.7 0.7 0.7];
lightgrey1 = [0.8 0.8 0.8];
lightgrey2 = [0.9 0.9 0.9];
red1 = [0.9 0.2 0.2];
red2 = [0.9 0.2 0.5];
red3 = [0.9 0.5 0.5];
figure;
plot(x_data,y_data,'+','MarkerSize',3,'Color',lightgrey1); 
hold on;
plot(x_data,y_sollb,'-.','Color',khaki4,'LineWidth',1); 
plot(x_data,y_solub,'-.','Color',khaki3,'LineWidth',1); 
plot(x_data,y_sol);


