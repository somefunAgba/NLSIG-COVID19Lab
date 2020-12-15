function fig = plotsmoothipfinder(fig, country_code,time,xid,y,dy,dys,...
    iplist_idx,ips_peak,ips_valley,phase)
%PLOTSMOOTIPFINDER Initial Guess Plot of Data with IPs
%

try
    opengl software; % safety
    run('pick_colours.m');
    chkfig = exist('fig','var');
%     if chkfig==1 
%         close(fig);
%     end   
catch
end

%   PLOT 1
time0 = time(1);
taxis = datetime(datestr(time0 + xid));
iplines = iplist_idx'*ones(1,numel(y));

fig = figure('Name','SplineCmp');
t1 = tiledlayout(2,1);
ax = nexttile(t1);
%
hold(ax,'on');
plot(ax,taxis,y,'Color',skyblue);
plot(ax,taxis(ips_peak),y(ips_peak),'+')
plot(ax,taxis(ips_valley),y(ips_valley),'s')
plot(ax,taxis(iplines),y,':k','LineWidth',0.5);
ylim([min(y)-100, max(y)+100]);
axis('tight')
ax.XTickLabelRotation = 60; ax.FontSize = 8;
tmsg = country_code+": "+string(phase)+" waves, "+phase;
title(tmsg);
hold off;

% PLOT 2
iplines = iplist_idx'*ones(1,numel(dy));

ax = nexttile(t1);

hold(ax,'on'); box on;
area(ax,dy,'EdgeColor',0.85*ones(1,3),...
    'FaceColor',0.9*ones(1,3),'FaceAlpha',0,'AlignVertexCenters','on');
bar(ax,dy,'FaceColor',0.9*ones(1,3),'FaceAlpha',0.1);
plot(ax,iplines,dy,':k','LineWidth',0.5);
plot(ax,dys);
axis('tight')
ylim([min(dy)-1, max(dy)]);
ax.FontSize = 8;
hold(ax,'off');

% yt = ax.YTickLabel;
% ytnew = strcat(yt,' ^{\circ}')
% ax.YTickLabel = ytnew


end