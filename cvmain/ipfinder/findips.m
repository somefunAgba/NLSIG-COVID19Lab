function [iplist_idx] = findips(y,dys,d2ys,cpt_dists)
%FINDIPS Find possible inflection points (peaks and valleys)
%   Uses the mathematical necessary condition for
%   finding inflection points (ips)
%
%   Outputs:
%   iplist_idx : index list of ips
%
%   Inputs:
%   y:  data
%   dy: first derivative
%   d2ys: second derivative
%   cpt_dists: (2-by-1 array) realistic consecutive difference bounds

% signs of second derivative:
% useful to finding zero-crossing.
sgns = sign(d2ys);

% hard algorithm for finding inflection-points
% of a smoothed sigmoid curve (assumes a non-negative time or (x)- axis)

iplist_idx = [];
% start index
k = 1;

% realistic start-point of curve
z = find(y==0);
% this is the first valley ip
firstip = z(end);
iplist_idx(k) = firstip;
k = k+1;

lastin = firstip;

% cpt_dist1: number of points (e.g: days) after last ip
cpt_dists1 = cpt_dists(1);
for J = 2:numel(d2ys)
    % cpt_dist2: number of points to consider with the current point
    % sort of like a bounding box, to remove false positives
    % deafult here is 25 days.
    % that is, we expect that no significant ip change 
    % can occur during this period.
    if k > 1 && (mod(k,2)==0) % and k is even
        cpt_dists2 = cpt_dists(2);
    else %else: and k is odd
        cpt_dists2 = cpt_dists(2); % same as when k is even, can be made different
    end
    if (sgns(J)~=sgns(J-1)) && (abs(y(J)) > 1) && (J - firstip > cpt_dists2)
%         fprintf('possible id: %g\n',J);
        
        % peak check
        if (k > 2) && (J <= numel(dys)-4) && (mod(k,2)==0)
            % 1. check if possible detected peak point J is less than
            % the last immediate detected valley point in the list:
            % useful for points relatively close to each other.
            % ACTION: this cannot be a peak point,
            % remove the last point, which is also the last valley point
            if (mean(dys(J-3:J+3)) - mean(dys(lastin-3:lastin+3)) <= 0)
                k = k - 1;
                % debug
%                 disp(num2str(iplist_idx(k)) + " removed");
                iplist_idx(k) = [];
                lastin = iplist_idx(k-1);
            end
            % 2. check if possible detected peak is less than
            % previous detected peak in the list
            if ( mean(dys(J-3:J+3)) - mean(dys(lastin-3:lastin+3)) <= 0)
                % debug:
%                 disp(num2str(J)+' cannot be a peak');
                continue;
            end
        end       
        % valley check
        if (k > 2) && (J <= numel(dys)-4) && (mod(k,2)~=0)
            % 1. check if possible detected valley point J is greater than
            % the last immediate detected peak point in the list:
            % useful for points relatively close to each other.
            % ACTION: this cannot be a valley point,
            % remove the last point, which is also the last peak point
            if (mean(dys(J-3:J+3)) - mean(dys(lastin-3:lastin+3)) > 0 )
                k = k - 1;
%                 disp(num2str(iplist_idx(k)) + " removed");
                iplist_idx(k) = [];
                lastin = iplist_idx(k-1);
            end
            % 2. check if possible detected valley is greater than
            % previous detected valley in the list
%             if ( abs(mean(dys(J-3:J+3)) - mean(dys(lastin-3:lastin+3))) > 0)
%                 % debug:
%                 fprintf('%d cannot be a valley\n',J);
%                 continue;
%             end
        end
        
        % lb and ub, bounds for checking the d2ys signs
        rem_len = numel(d2ys) - J;
        lb = J;
        if rem_len >= cpt_dists2
            ub = (J+cpt_dists2);
        else
            % close to the end-point, use remaining length
            ub = (J+rem_len);
        end
        cs = sgns(lb:ub);
        uniquecs = unique(cs);
        if (numel(uniquecs) <= 2)
            if k>1
                % CHECK: is this new detected point
                % lesser than cpt_dists1 value
                % ACTION: don't add to list
                if (J-lastin > cpt_dists1)
                    iplist_idx(k) = J;
                    k = k+1;
%                     disp("last_jin = "+lastin);
                    lastin = J;
                else
%                     disp(num2str(J)+' failed the consecutive point distance test');
                end
            else
                % add second ip to list
                % second ip is a peak point
                % then increment k to show that 
                % we are looking for a valley (odd) or peak point (even)
                iplist_idx(k) = J;
                k = k+1;
                lastin = J;
            end
        else
%             disp(num2str(J)+' not unique, other zero-crossings detected!');
        end
    end
end
%
% Deal with Last detected point
% CHECK: 
% if last detected point is a peak (means the value of k is odd), 
% but the d2ys value at the end points is bigger.
% ACTION: remove that peak point.
if (mod(k,2)~=0) && ...
        (mean(dys(J-4:J)) - dys(iplist_idx(k-1)) > 0)
    k = k - 1;
%     disp(num2str(iplist_idx(k-1)) + " point removed. Can't be a peak!");
    iplist_idx(k) = [];
end

%% check for: no motion

ed = numel(y);
count = 0;
for idx = ed:ed-7
    if y(idx) == y(idx-1)
        count = count + 1;
        if (mod(k,2)==0)
            iplist_idx(k) = idx-1;
        end
        
    end
end

end