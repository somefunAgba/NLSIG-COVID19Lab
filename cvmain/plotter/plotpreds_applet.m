function plotpreds_applet(app,country_code,time_data,x_data,y_data,dy_data,...
    y_sol,y_sollb,y_solub,dy_sol,dy_sollb,dy_solub,...
    focus,ips_adata,ips_vdata,ips_pdata,phase)
%PLOTPREDS nlsig Predictions Plots

try
    % opengl software; % safety  
    pick_colours;  
catch
end

if country_code == "WD"
    country_code = "WORLD";
end
% PLOT 1
iplines = (ips_adata)'*ones(size(y_data))';
tmsg = " \fontsize{10} \fontname{Consolas}"+country_code+": \color[rgb]{0.2 0.5 0.9} "...
    +string(time_data(1))+" \fontname{Arial}to \fontname{Consolas} "...
    +string(time_data(end))+"\color{black} | \color{gray}\fontsize{10} Phase: "+phase;


title(app.UIAxes,tmsg);


hold(app.UIAxes,'on');box on;

plot(app.UIAxes,time_data(iplines), y_data,'LineWidth',0.15, 'Color',[0.9 0.9 0.9]);
iplines = (ips_adata(1))'*ones(size(y_data))';
plot(app.UIAxes,time_data(iplines), y_data,'k','LineWidth',0.15)
plot(app.UIAxes,time_data(ips_vdata),y_data(ips_vdata),'s')
plot(app.UIAxes,time_data(ips_pdata),y_data(ips_pdata),'+')


plot(app.UIAxes,time_data,y_data,'MarkerSize',3,'Color',lightgrey1,'LineWidth',0.5);
plot(app.UIAxes,time_data,y_sollb,'-.','Color',khaki4,'LineWidth',1);
plot(app.UIAxes,time_data,y_solub,'-.','Color',khaki3,'LineWidth',1);
plot(app.UIAxes,time_data,y_sol,'Color',red2,'LineWidth',1.2);


app.UIAxes.XTickLabelRotation = 60;
app.UIAxes.FontName = 'Consolas';
app.UIAxes.FontSize = 8;
axis(app.UIAxes,'tight')
if focus == "i"
    ylabel(app.UIAxes,'\fontsize{8} \fontname{Consolas} Infected')
elseif focus == "d"
    ylabel(app.UIAxes,'\fontsize{8} \fontname{Consolas} Deaths')
end
xlabel(app.UIAxes,'\fontsize{8} \fontname{Consolas} Time (days (in months) since first reported case)')
hold(app.UIAxes,'off');

% PLOT 2
iplines = (ips_adata)'*ones(size(dy_data))';

title(app.UIAxes2,tmsg);
hold(app.UIAxes2,'on');
box(app.UIAxes2,'on');

area(app.UIAxes2, dy_data,'EdgeColor',0.8*ones(1,3),...
    'FaceColor',0.9*ones(1,3),'FaceAlpha',0,'AlignVertexCenters','on');
bar(app.UIAxes2, dy_data,0.5,'EdgeColor','none',...
    'FaceColor',0.65*ones(1,3),'FaceAlpha',0.1);

plot(app.UIAxes2,iplines,dy_data,'LineWidth',0.15,'Color',[0.9 0.9 0.9]);
plot(app.UIAxes2,x_data, dy_sollb,'-.','Color',khaki4,'LineWidth',1);
plot(app.UIAxes2,x_data, dy_solub,'-.','Color',khaki3,'LineWidth',1);
plot(app.UIAxes2,x_data, dy_sol,'Color',red2,'LineWidth',1.2);


app.UIAxes2.FontName = 'Consolas';
app.UIAxes2.FontSize = 8;
axis(app.UIAxes2,'tight')
if focus == "i"
    ylabel(app.UIAxes2,'\fontsize{8} \fontname{Consolas} Infected per day')
elseif focus == "d"
    ylabel(app.UIAxes2,'\fontsize{8} \fontname{Consolas} Deaths per day')
end
xlabel(app.UIAxes2,'\fontsize{8} \fontname{Consolas} Time (days since first reported case)')

hold(app.UIAxes2,'off');

try
    close all;
catch
end

end

