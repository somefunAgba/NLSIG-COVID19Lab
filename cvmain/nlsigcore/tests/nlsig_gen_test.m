clc; clear iopts;
%
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
iopts.check_constraints = 0;
% constraints
% 1. % xmin_i < xmax_i; if i > 1: xmin_i+1 == xmax_i && < xmax_i
% 2. % xpks_i < xpks_i+1 ; xmin_i < xpks_i < xmax_i
% 3. % ymin_i < ymax_i; if i > 1: ymin_i+1 == ymax_i && < ymax_i

%
% input space
dx = 0.01;
xmin = -5; xmax = 5;
x = -1+xmin:dx:1+xmax;
%
[y,dy_dx,d2y_dx2,jacob_iy_d,jacoby,hessy] = nlsig(x',0,iopts);

%%
% [xx,dx_dy] = inv_nlsig_gen(y,iopts);
% dx_dy_inv = 1./dx_dy;
% [xx,idxx] = sort(xx); 
%%
close all;
tiledlayout("flow");

ax = nexttile;
line(ax, x,y); hold on
line(ax, x,dy_dx);
line(ax, x,d2y_dx2);
grid on;
axis('tight')
% 
% ax = nexttile;
% line(ax, xx,y); hold on
% line(ax, xx,dx_dy_inv);
% grid on;
% axis('tight')
%%
