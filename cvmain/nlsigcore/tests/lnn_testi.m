clc; clear solp;

% input space
dx = 0.1;
lo = -10; up = 10;
x = -1+lo:dx:1+up;

eq = 1;
if eq == 0
    % Gen
    % solp.shape{1} = 1;
    solp.shape{1} = [-1;-1];
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
    solp.p{1} = 8; % 8:6
    
    lbsolp.shape{1} = solp.shape{1};
    ubsolp.shape{1} = solp.shape{1};
    lbsolp.base{1} = "nat";
    ubsolp.base{1} = "nat";
    lbsolp.lambda{1} = 1e-4*ones(solp.n{1},1);
    ubsolp.lambda{1} = 20*ones(solp.n{1},1);
    lbsolp.xpks{1} = solp.xpks{1};
    ubsolp.xpks{1} = solp.xpks{1};
    lbsolp.xmin{1} = solp.xmin{1};
    ubsolp.xmin{1} = solp.xmin{1};
    lbsolp.xmax{1} = solp.xmax{1};
    ubsolp.xmax{1} = solp.xmax{1};
    lbsolp.ymin{1} = solp.ymin{1};
    ubsolp.ymin{1} = solp.ymin{1};
    lbsolp.ymax{1} = solp.ymax{1};
    ubsolp.ymax{1} = solp.ymax{1};
    
    
    solp.shape{2} = [-1; 1; -1];
    % solp.shape{2} = -1;
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
    solp.p{2} = 8; % 8:6
    
    lbsolp.shape{2} = solp.shape{2}-0.1;
    ubsolp.shape{2} = solp.shape{2}+0.1;
    
    lbsolp.base{2} = 20;
    ubsolp.base{2} = 20;
    
    lbsolp.lambda{2} = 1e-4*ones(solp.n{2},1);
    ubsolp.lambda{2} = 20*ones(solp.n{2},1);
    
    lbsolp.xpks{2} = solp.xpks{2};
    ubsolp.xpks{2} = solp.xpks{2};
    lbsolp.xmin{2} = solp.xmin{2};
    ubsolp.xmin{2} = solp.xmin{2};
    lbsolp.xmax{2} = solp.xmax{2};
    ubsolp.xmax{2} = solp.xmax{2};
    lbsolp.ymin{2} = solp.ymin{2};
    ubsolp.ymin{2} = solp.ymin{2};
    lbsolp.ymax{2} = solp.ymax{2};
    ubsolp.ymax{2} = solp.ymax{2};
    
elseif eq == 1
    
    % Equal
    %
    solp.shape{1} = [1; -1];
    solp.base{1} = "nat";
    % required
    solp.n{1} = 2;
    solp.lambda{1} = 3;
    % full -4 to 4
    solp.xmin{1} = -4;
    solp.xmax{1} = 2;
    % full: 0 to 5
    solp.ymin{1} = -3;
    solp.ymax{1} = 3;
    solp.p{1} = 7; %
    
    lbsolp.shape{1} = solp.shape{1};
    ubsolp.shape{1} = solp.shape{1};
    
    lbsolp.base{1} = 20;
    ubsolp.base{1} = 20;
    
    lbsolp.lambda{1} = 1e-4*ones(solp.n{1},1);
    ubsolp.lambda{1} = 20*ones(solp.n{1},1);
    
    lbsolp.xmin{1} = solp.xmin{1};
    ubsolp.xmin{1} = solp.xmin{1};
    lbsolp.xmax{1} = solp.xmax{1};
    ubsolp.xmax{1} = solp.xmax{1};
    lbsolp.ymin{1} = solp.ymin{1};
    ubsolp.ymin{1} = solp.ymin{1};
    lbsolp.ymax{1} = solp.ymax{1};
    ubsolp.ymax{1} = solp.ymax{1};
    
    solp.shape{2} = [1;-1; 1];
    solp.base{2} = 20;
    % required
    solp.n{2} = 3;
    solp.lambda{2} = 3;
    % full -5 to 5
    solp.xmin{2} = -5;
    solp.xmax{2} = 5;
    % full: 0 to 10
    solp.ymin{2} = 0;
    solp.ymax{2} = 10;
    solp.p{2} = 7; %
    
    lbsolp.shape{2} = solp.shape{2};
    ubsolp.shape{2} = solp.shape{2};
    
    lbsolp.base{2} = 20;
    ubsolp.base{2} = 20;
    
    lbsolp.lambda{2} = 1e-4*ones(solp.n{2},1);
    ubsolp.lambda{2} = 20*ones(solp.n{2},1);
    
    lbsolp.xmin{2} = solp.xmin{2};
    ubsolp.xmin{2} = solp.xmin{2};
    lbsolp.xmax{2} = solp.xmax{2};
    ubsolp.xmax{2} = solp.xmax{2};
    lbsolp.ymin{2} = solp.ymin{2};
    ubsolp.ymin{2} = solp.ymin{2};
    lbsolp.ymax{2} = solp.ymax{2};
    ubsolp.ymax{2} = solp.ymax{2};
end

% constraints
% 1. % xmin_i < xmax_i; if i > 1: xmin_i+1 == xmax_i && < xmax_i
% 2. % xpks_i < xpks_i+1 ; xmin_i < xpks_i < xmax_i
% 3. % ymin_i < ymax_i; if i > 1: ymin_i+1 == ymax_i && < ymax_i

% LNNET
lnnet = lnn;
% setup arch
np = 2;
lnnet.archdims(eq,np,1,2,numel(x));
lnnet.archtype(1,1,0,1);
% collate data
lnnet.collate(x);
% use solp structure to predict
lnnet.predict(solp);
Ydata = lnnet.Yout;

lnnet.setR(Ydata);
% set solp structure
lnnet.setopts(solp);
% unroll solp and its bounds
[lbsolpvec, ubsolpvec] = lnnet.sol_unroll(lbsolp,ubsolp);
% use unrolled solp and bounds to compute the objective function
% to be minimized.
[F,J,H] = lnnet.objfun_unroll(lnnet.solpvec,0);
%[F,J,H] = lnnet.objfun_unroll(lnnet.solpvec,1);

%lnnet.sol_roll();

close all;
T=tiledlayout(3,lnnet.J, 'TileSpacing','normal');
for j = 1:lnnet.J
    na = j;
    nexttile(T,j);
    line(x,lnnet.Yout(:,j),'LineWidth',1.5);
    hold on;
    %
    na = na+lnnet.J;
    nexttile(T,na);
    line(x,lnnet.DYDxnp(:,1,j),'LineWidth',1.5);
    %
    na = na+lnnet.J;
    nexttile(T,na);
    line(x,lnnet.DYDxnp(:,2,j),'LineWidth',1.5);
end


