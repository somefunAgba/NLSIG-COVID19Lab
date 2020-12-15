function [x_data,y_data,ig_opts,ips_adata,ips_vdata,ips_pdata, time_data] ...
    = xy_ipsort(spass,x,y,n_ips,iplist_idx,ips_valley,ips_peak,time)
%XY_IPSORT sort peak and valley inflection points to their x and y values
%  
%   Transfer Inflection points to represent
%   initial guess values for 
%   xmin-ymin, xmax-ymax, xpks value
%   in the Data

% Determines 
% estimated final ymax and xmax, and xpk

% 3 CASES
% 1. exists: xmin, xpk and xmax
% ACTION: no estimation
% 2. exists: xmin, xpk only.
% ACTION: using ypk, estimate ymax, xmax
% 3. exists: xmin only.
% ACTION: Estimate x(end) xpk, find ypk, then estimate ymax and xmax

xmins = zeros(n_ips,1);
xmaxs = zeros(n_ips,1);
xpks = zeros(n_ips,1);
ymins = zeros(n_ips,1);
ymaxs = zeros(n_ips,1);


for id = 1:n_ips
    % debug: disp(id)
    % CASE 1.
    xmins(id) = x(ips_valley(id));
    ymins(id) = y(ips_valley(id));
    try
        xpks(id) = x(ips_peak(id));
        xmaxs(id) = x(ips_valley(id+1));
        ymaxs(id) = y(ips_valley(id+1));
    catch
        % CASE 2.
        try
            xpks(id) = x(ips_peak(id));
            ymaxs(id) = (2.^1)*y(ips_peak(id)) - y(ips_valley(id));
%             xmaxs(id) = x(ips_peak(id))*ymaxs(id)/(y(ips_peak(id)));
            xmaxs(id) =  xmins(id) + ...
                ((x(ips_peak(id))-xmins(id))*(ymaxs(id)-ymins(id))/(y(ips_peak(id))-ymins(id)));
            if isnan(xmaxs(id))
                xmaxs(id) = x(end);
            end
            if (ymaxs(id) == ymins(id))
                ymaxs(id) = y(end);
            end
        catch
            % CASE 3.
            try
                xpks(id) = x(end)+5;
                ypk = 2*y(end);
               % ypk = (1/(2*0.2))*(y(end) - y(ips_valley(id))) + y(ips_valley(id));
                ymaxs(id) = (2.^1)*ypk - y(ips_valley(id));
               %  xmaxs(id) = xpks(id)*ymaxs(id)/(ypk);
                xmaxs(id) =  xmins(id) + ...
                    ((xpks(id)-xmins(id))*(ymaxs(id)-ymins(id))/(ypk-ymins(id)));
            catch
                error("Bad...something wrong occured!")
            end
        end
    end
end


% resize all x-y parameters to reference start from 
% the first valley inflection-point of 0.
xmins = xmins - ips_valley(1);
xmaxs = xmaxs - ips_valley(1);
xpks = xpks - ips_valley(1);
% Set up fit options structure
ig_opts = struct('n', n_ips, 'xmin', xmins, 'xmax', xmaxs,...
    'ymin', ymins,'ymax', ymaxs, ...
    'xpks', xpks ...
    );

% readjust x-axis: to start from 0.
if spass == false
x_data = x(ips_valley(1):end)- ips_valley(1);

y_data = y(ips_valley(1):end);
ips_vdata = ips_valley - (ips_valley(1)-1);
ips_pdata = ips_peak - (ips_valley(1)-1);
ips_adata = iplist_idx - (ips_valley(1)-1);

time_data = datetime(datestr(time(1) + x-1));
time_data = time_data(ips_valley(1):end);
else
x_data = x(ips_valley(1):end);

y_data = y(ips_valley(1):end);
ips_vdata = ips_valley;
ips_pdata = ips_peak;
ips_adata = iplist_idx;

time_data = datetime(datestr(time(1) + x-1));          
end


end
