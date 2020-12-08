function plot_fitnlsig(x_data,y_data,y_est,dy_dx_est, ...
    y_estlb,dy_dx_estlb,y_estub,dy_dx_estub)

%% Colours
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

%% Plots
% close all;
figure('Name','nlsigFitPlot');
t = tiledlayout("flow");
ax_t = nexttile;
plot(ax_t, x_data,y_data,'+','MarkerSize',3,'Color',lightgrey1);
%
hold on;
plot(ax_t,x_data,y_est,'-','Color',red2,'LineWidth',1.2); 
plot(ax_t,x_data,y_estlb,'-.','Color',khaki4,'LineWidth',1); 
plot(ax_t,x_data,y_estub,'-.','Color',khaki3,'LineWidth',1); 
hold off;
box on;
xlabel('\fontsize{9} \sl x','Interpreter','tex')
ylabel('\fontsize{9} \sl y','Interpreter','tex')

%
ax_t = nexttile;
hold on;
plot(ax_t,x_data,dy_dx_est,'-','Color',red2,'LineWidth',1.2); 
plot(ax_t,x_data,dy_dx_estlb,'-.','Color',khaki4); 
plot(ax_t,x_data,dy_dx_estub,'-.','Color',khaki3); 
hold off;
box on;
xlabel('\fontsize{9} \sl x','Interpreter','tex')
ylabel('\fontsize{9} \sl {dy}_{x}','Interpreter','tex')
%
%TODO: option to save fig to format

end
