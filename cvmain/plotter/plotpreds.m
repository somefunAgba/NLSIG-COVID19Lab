function fig = plotpreds(fig,country_code,time_data,x_data,y_data,dy_data,...
    y_sol,y_sollb,y_solub,dy_sol,dy_sollb,dy_solub,...
    focus,ips_adata,ips_vdata,ips_pdata,phase)
%PLOTPREDS nlsig Predictions Plots

try
    opengl software; % safety  
    pick_colours;
    chkfig = exist('fig','var');
    if chkfig==1 
        close(fig);
    end
catch
end

if country_code == "WD"
    country_code = "WORLD";
end
% PLOT 1
iplines = (ips_adata)'*ones(size(y_data))';
tmsg = " \fontsize{8} \fontname{Consolas}"+country_code+": \color[rgb]{0.5 0.7 0.7} "...
    +string(time_data(1))+" \fontname{Arial}to \fontname{Consolas} "...
    +string(time_data(end))+"\color{black} | \color{gray}\fontsize{8} Phase: "+phase;


fig = figure('Name','FitCmp','NumberTitle','off');
fig.Visible = 'off';
fig.WindowState = 'minimized';
t2 = tiledlayout(2,1);
ax_t2 = nexttile(t2);

title(tmsg);
hold(ax_t2,'on');box on;

plot(time_data(iplines), y_data,'LineWidth',0.1, 'Color',[0.9 0.9 0.9]);
iplines = (ips_adata(1))'*ones(size(y_data))';
plot(time_data(iplines), y_data,'k','LineWidth',0.1);
plot(time_data(ips_vdata),y_data(ips_vdata),'s')
plot(time_data(ips_pdata),y_data(ips_pdata),'+')

plot(time_data,y_data,'MarkerSize',3,'Color',lightgrey1,'LineWidth',0.5);
plot(time_data,y_sollb,'-.','Color',khaki4,'LineWidth',1);
plot(time_data,y_solub,'-.','Color',khaki3,'LineWidth',1);
plot(time_data,y_sol,'Color',red2,'LineWidth',1.2);




ax_t2.XTickLabelRotation = 60;
ax_t2.FontName = 'Consolas';
ax_t2.FontSize = 8;
axis(ax_t2,'tight')
if focus == "i"
    ylabel('\fontsize{8} \fontname{Consolas} Infected')
elseif focus == "d"
    ylabel('\fontsize{8} \fontname{Consolas} Deaths')
end
xlabel('\fontsize{8} \fontname{Consolas} Time (days (in months) since first reported case)')

% PLOT 2
iplines = (ips_adata)'*ones(size(dy_data))';

ax_t2 = nexttile(t2);
hold(ax_t2,'on');box(ax_t2,'on');

area(ax_t2, dy_data,'EdgeColor',0.8*ones(1,3),...
    'FaceColor',0.9*ones(1,3),'FaceAlpha',0,'AlignVertexCenters','on');
bar(ax_t2, dy_data,0.5,'EdgeColor','none',...
    'FaceColor',0.65*ones(1,3),'FaceAlpha',0.1);

plot(iplines,dy_data,'LineWidth',0.1, 'Color',[0.9 0.9 0.9]);

plot(x_data, dy_sollb,'-.','Color',khaki4,'LineWidth',1);
plot(x_data, dy_solub,'-.','Color',khaki3,'LineWidth',1);
plot(x_data, dy_sol,'Color',red2,'LineWidth',1.2);

hold(ax_t2,'off');
axis(ax_t2,'tight')

if focus == "i"
    ylabel('\fontsize{8} \fontname{Consolas} Infected/day')
elseif focus == "d"
    ylabel('\fontsize{8} \fontname{Consolas} Deaths/day')
end
xlabel('\fontsize{8} \fontname{Consolas} Time (days since first reported case)')
ax_t2.FontName = 'Consolas';
ax_t2.FontSize = 8;



end

