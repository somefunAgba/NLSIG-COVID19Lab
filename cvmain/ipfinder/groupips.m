function [ips_valley,ips_peak,n_ips,phase,iplist_idx] = groupips(y,dy,iplist_idx)
%GROUPIPS Categorize inflections into peaks and valleys
%
%   Inputs:
%   iplist_idx : inflection-points (ips) indices
%   Outputs:
%   ips_peak : where even indices of iplist_idx are peaks
%   ips_valley : where odd indices of iplist_idx are valleys
%   n_ips : number of ips
%   phase : cummulative phase state

% Group by Even/Odd Indices
if ~isempty(iplist_idx)
    zodd = 1:2:numel(iplist_idx);
    ips_valley = iplist_idx(zodd);
    if numel(iplist_idx) > 1
        zeven = 2:2:numel(iplist_idx);
        ips_peak = iplist_idx(zeven);
    else
        ips_peak = [];
    end
    
    % Check for possible end occurrence (no increase or decrease at endpoint)
    ed = numel(y);
    mkid = ed;
    count = 0;
    for idx = ed:-1:1
        if y(idx) == y(idx-1)
            mkid = idx-1;
            count = count + 1;
        else
            break;
        end
    end
    
    if numel(iplist_idx) > 1 && numel(ips_valley) == numel(ips_peak) && count > 0
        ips_valley(end+1) = mkid;
        iplist_idx(end) = mkid;
        %         if ips_peak(end) >= mkid
        %             ips_peak(end) = round(0.5*(mkid + ips_valley(end-1)));
        %             iplist_idx(end-1) = ips_peak(end);
        %         end
    elseif numel(iplist_idx) > 1 && numel(ips_valley) > numel(ips_peak) && count > 0
        ips_valley(end) = mkid;
        iplist_idx(end) = mkid;
        
        %         ips_valley(end+1) = mkid;
        %         ypk = 0.5*(y(ips_valley(end)) + y(ips_valley(end-1)));
        %         xdiff = (ips_valley(end) - ips_valley(end-1));
        %         ydiv = (ypk - y(ips_valley(end-1)) )/(  y(ips_valley(end))- y(ips_valley(end-1)) );
        %         ips_peak(end+1) = round( ips_valley(end-1) + (xdiff*ydiv) );
        %
        %         iplist_idx(end+1) = ips_peak(end);
        %         iplist_idx(end+1) = ips_valley(end);
    end
    
    
    % Estimate cummulative final phase detected in the data y
    phase = "pre-peak";
    if numel(ips_valley) == numel(ips_peak)
        phase = "possible post-peak";
    elseif (numel(ips_valley) > numel(ips_peak) ) && (dy(end-1) < 1) && (y(end-1) == y(end))
        phase = "possible end";
    end
    % Estimate the detected number of sigmoids detected in the data
    if numel(ips_valley) == numel(ips_peak)
        n_ips = numel(ips_valley);
    elseif numel(ips_valley) > numel(ips_peak)
        if y(end-1) > y(ips_valley(end))
            n_ips = numel(ips_valley);
        else
            n_ips = numel(ips_valley) - 1;
        end
    end
end

end

