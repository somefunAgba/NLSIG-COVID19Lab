
%% Data
clc;clear *;
solp.shape{1} = 1;
solp.base{1} = "nat";
% required
solp.n{1} = 2;
solp.lambda{1} = [1; 6];
% full -4 to 4
solp.xmin{1} = [-9; -4];
solp.xpks{1} = [-2.5; 2];
solp.xmax{1} = [-1; 4];
% full: 0 to 5
solp.ymin{1} = [0; 3];
solp.ymax{1} = [3; 5];
solp.p{1} = 6;

solp.shape{2} = -1;
solp.base{2} = 20;
% required
solp.n{2} = 3;
solp.lambda{2} = [1; 2.5; 6];
% full -5 to 5
solp.xmin{2} = [-5; -2.5; 0];
solp.xpks{2} = [-3; -0.9; 2];
solp.xmax{2} = [-2.5; 0; 5];
% full: 0 to 10
solp.ymin{2} = [0; 3; 6];
solp.ymax{2} = [3; 6; 10];
solp.p{2} = 6;

% input space
dx = 0.1;
lo = -5; up = 5;
x_data = -9+lo:dx:9+up;

%
% LNNET simulate realistic
lnnreal = lnn;
% setup arch
J = numel(solp.n);
eq = 0; np = 1;
lnnreal.archdims(eq,np,1,J,numel(x_data));
lnnreal.archtype(1,1,0,0);
% collate data
lnnreal.collate(x_data);
% use solp structure to predict
lnnreal.predict(solp);

rng default;
y_data = lnnreal.Yout;% + rand(size(lnnreal.Yout));
dy_data = zeros(size(y_data));
for id = 1:lnnreal.J
    tmp = y_data(:,id);
    dy_data(:,id) = gradient(tmp,dx);
end


%%
% INITIAL GUESS from data
% solp.shape{1} = 1;
% solp.base{1} = "nat";
% % required
% solp.n{1} = 2;
% solp.lambda{1} = [1; 6];
% % full -4 to 4
% solp.xmin{1} = [-9; -4];
% solp.xpks{1} = [-2.5; 2];
% solp.xmax{1} = [-1; 4];
% % full: 0 to 5
% solp.ymin{1} = [0; 3];
% solp.ymax{1} = [3; 5];
% 
% solp.shape{2} = -1;
% solp.base{2} = 20;
% % required
% solp.n{2} = 3;
% solp.lambda{2} = [1; 2.5; 6];
% % full -5 to 5
% solp.xmin{2} = [-5; -2.5; 0];
% solp.xpks{2} = [-3; -0.9; 2];
% solp.xmax{2} = [-2.5; 0; 5];
% % full: 0 to 10
% solp.ymin{2} = [0; 3; 6];
% solp.ymax{2} = [3; 6; 10];

% optimization solver
% p = 6;
% eq = 0;
% base = "nat";
% % Solver Options
% % est.params bounds options 
% sbounds = true;
% lubnds = true;
% % optimization-solver type
% % optsolver = "lsqnonlin-tr";
% optsolver = "lsqnonlin-lm";
% % optsolver = "fmincon-tr";
% % optsolver = "fmincon-ipt";

% lnnf = solvopts(x_data,y_data,...
%     optsolver,solp,sbounds,lubnds);

%% Passes

% inflections finder
tpassno = 3;
p = 6;
eq = 0;
base = "nat";
% Solver Options
% est.params bounds options 
sbounds = true;
lubnds = true;
% optimization-solver type
% optsolver = "lsqnonlin-tr";
optsolver = "lsqnonlin-lm";
% optsolver = "fmincon-tr";
% optsolver = "fmincon-ipt";

[lnnf_passes,infl_passes] = lnn_infl_opts(x_data,y_data,...
    p,eq,base,...
    tpassno,optsolver,...
    sbounds,lubnds);

%%
lnnetfit = lnnf_passes{1};

stats_fit = lnnetfit.fitstatsO;
stats_fitLB = lnnetfit.fitstatsLB;
stats_fitUB = lnnetfit.fitstatsUB;
% solpvecfit = lnnetfit.solpvec;

% use solp structure to predict
lnnetfit.predict(lnnetfit.solpO);
Y_fit = lnnetfit.Yout;
DY_fit = lnnetfit.DYDx;
lnnetfit.predict(lnnetfit.solpL);
Y_fitlb = lnnetfit.Yout;
DY_fitlb = lnnetfit.DYDx;
lnnetfit.predict(lnnetfit.solpH);
Y_fitub = lnnetfit.Yout;
DY_fitub = lnnetfit.DYDx;

% GRAPH-PLOT
close all;
% plot(x_data,y_data,'o'); hold on; plot(x_data,Y_fit)

% Colours
pick_colours;

% Plots
figure;
tiledlayout(2,lnnetfit.J,'TileSpacing','compact');
for j = 1:lnnetfit.J 
nexttile(j);
plot(x_data,y_data(:,j),'MarkerSize',3,'Color',lightgrey1); 
hold on;
plot(x_data,lnnreal.Yout(:,j),'Color',lightgrey1,'LineWidth',1.5); 
plot(x_data,Y_fit(:,j),'LineWidth',1.5);
plot(x_data,Y_fitlb(:,j),'-.','Color',khaki4,'LineWidth',1); 
plot(x_data,Y_fitub(:,j),'-.','Color',khaki3,'LineWidth',1); 
%
nexttile(j+2);
plot(x_data,dy_data(:,j),'MarkerSize',3,'Color',lightgrey1); 
hold on;
plot(x_data,lnnreal.DYDx(:,j),'Color',lightgrey1,'LineWidth',1.5); 
plot(x_data,DY_fit(:,j),'LineWidth',1.5);
plot(x_data,DY_fitlb(:,j),'-.','Color',khaki4,'LineWidth',1); 
plot(x_data,DY_fitub(:,j),'-.','Color',khaki3,'LineWidth',1); 
end

