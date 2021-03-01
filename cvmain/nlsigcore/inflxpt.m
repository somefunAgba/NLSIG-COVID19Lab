classdef inflxpt < handle
    %INFLXPT Inflection Point Finder
    %   A group of functions to estimate a guess of inflection-points
    %   both minima and maxima
    %   from a given signal/data (usually noisy.)
    
    properties
        Xid;
        X;
        Y;
        Ycumm;
        
        DY;
        D2Y;
        
        CPD;
        iscdf;
        count;
        startmin;
        D; J;
        
        idlist_ips;
        idvalley_ips;
        idpeak_ips;
        
        list_ips;
        valley_ips;
        peak_ips;
        
        N_ips;
        est_phase;
        shape;
        
        x_data;
        y_data;
        
        solp;
        tpassno = 1;
        cpassno = 0;
        
    end
    
    methods
        
        function obj = incrpass(obj)
            obj.cpassno = obj.cpassno + 1;
        end
        
        function obj = setprops(obj,tpassno,iscdf,shape,Y,X)
            %SETPROPS set properties
            
            obj.iscdf = iscdf;
            obj.shape = shape;
            % set total pass if current pass count is 0
            if obj.cpassno == 0
                obj.tpassno = tpassno;
            end
            % increase pass count by 1
            obj = obj.incrpass;
            
            % set the data of interest
            % expects D x J
            obj.Y = Y;
            sz = size(Y);
            obj.D = sz(1);
            obj.J = sz(2);
            if nargin < 6
                X = (1:obj.D)';
            end
            if isrow(X)
                X = X';
            end
            obj.X = X;
            obj.Xid = (1:obj.D)';
            
            % set the consecutive point difference bounds;
            % the cpd is like a bounding-box
            % cpd(1): number of X points after last confirmed ip
            % cpd(2): number of X points considered with a current queried
            % point. It is sort of like a bounding box,
            % to some-how remove false positives
            % of detected ips in a noisy signal.
            % that is, in a way, we expect that no significant ip change
            % can occur during this period.
            cpd = [1 7];
            % cpd = [2 2];
%             cpd = [7 25];
            obj.CPD = cpd;
            
            % - start by confirming if the data/signal is a cummulative signal
            % this means an all interval increasing or decreasing data
            % - if not cummulative, make cummulative
            
            
            % count represents number of cummulations done
            % so that later, it can be used to
            % recover the signal from the cummulation
            counts = zeros(obj.J,1);
            if obj.cpassno == 1
                for j = 1:obj.J
                    if obj.D > 1
                        %% 
                        obj.Ycumm(:,j) = Y(:,j);
%                         yf = obj.Ycumm(:,j);
%                         dnvec = direction_finder(yf);
%                         tmpvec = dnvec(dnvec~=0);
%                         if tmpvec(1)~=0
%                             tmpvec = [dnvec(1); tmpvec]; %#ok<*AGROW>
%                         end
%                         dnvec_chk = unique(tmpvec);
%                         % leaves it with 3 possibilities: -1, 0, 1
%                         if sum(dnvec_chk) == 0
%                             %[-1 0 1]
%                             obj.iscdf(j) = false;
%                         else
%                             % [1 0 1] or [-1 0 -1]
%                             obj.iscdf(j) = true;
%                         end
                        
                        % TODO  recheck for noisy data
                        %% 
                        while (~obj.iscdf(j))
                            obj.Ycumm(:,j) = fcumdist(obj.Ycumm(:,j));
                            dnvec = direction_finder(obj.Ycumm(:,j));
                            tmpvec = dnvec(dnvec~=0);
                            if tmpvec(1)~=0
                                tmpvec = [dnvec(1); tmpvec]; %#ok<*AGROW>
                            end
                            dnvec_chk = unique(tmpvec);
                            % leaves it with 3 possibilities: -1, 0, 1
                            if sum(dnvec_chk) == 0
                                %[-1 0 1]
                                obj.iscdf(j) = false;
                            else
                                % [1 0 1] or [-1 0 -1]
                                obj.iscdf(j) = true;
                            end
                            counts(j) = counts(j) + 1;                   
                            
                            if (tmpvec(2) == 1) && (tmpvec(end) == 1)
                                obj.shape(j) = 1;
                            elseif (tmpvec(2) == -1) && (tmpvec(end) == -1)
                                obj.shape(j) = -1;
                            end
                        end
                        
                    end
                    
                    if (obj.iscdf(j) == false || obj.iscdf(j) == 0)
                        error('Oops...cummulative dataform missing. Fix it!');
                    end
                    
                end
            end
            
            % to reach this line: iscdf must be true
            if all(obj.iscdf) == true
                obj.count = counts;
                % quick differencing to find DY, D2Y
                obj.DY = fdiffdist(obj.Ycumm);
                obj.D2Y = fdiffdist(obj.DY);
            else
                error("Ouch! something wrong with the inputs.")
            end
            
        end

        function obj = find(obj)
            %FIND find inflection-points defined by a noisy signal
            %   search for valid inflection-points on a noisy path
            
            % signs of second derivative:
            % useful to finding zero-crossing.
            %             sgns = sign(obj.D2Y);
            sgnsf2 = direction_finder(obj.DY);
            % second-derivative test for concavity -- ips
            
            % debug
            % disp(sgnsf2)
            
            
            firstip_idx = zeros(obj.J,1);
            
            
            for j=1:obj.J
                % run the startmin check for only the first-pass;
                if obj.cpassno == 1
                    %%
                    % using the second index, since the first index is
                    % the start point of motion
                    sgnsf1 = direction_finder(obj.Ycumm);
                    
                    tmpsf1 = sgnsf1(:,j);
                    tmpsf1 = tmpsf1(tmpsf1~=0);
                    tmpsf2 = sgnsf2(:,j);
                    tmpsf2 = tmpsf2(tmpsf2~=0);
                    if tmpsf1(1) == -1 && tmpsf2(2)  == -1
                        obj.startmin(j) = false;
                        % then first index point is a peak
                    elseif tmpsf1(1) == 1 && tmpsf2(2) == -1
                        obj.startmin(j) = false;
                        % then first index point is a peak
                    elseif tmpsf1(1) == 1 && tmpsf2(2) == 1
                        obj.startmin(j) = true;
                        % first index point is a valley
                    elseif tmpsf1(1) == -1 && tmpsf2(2) == 1
                        obj.startmin(j) = true;
                        % first index point is a valley
                    end
                end
                
                % algorithm for finding inflection-points
                % of a cummulative sigmoidal curve
                % (assumes a non-negative time or (x)- axis)
                
                obj.idlist_ips{j} = [];
                
                % index of the confirmed ip idlist
                k = 1; % start index
                % realistic start-point of curve
                if obj.shape(j) == 1
                    fip = find(obj.Ycumm(:,j)==min(obj.Ycumm(:,j)));
                else
                    fip = find(obj.Ycumm(:,j)==max(obj.Ycumm(:,j)));
                end
                if isempty(fip)
                    fip = 1;
                end
                
                % fip if more than 1 found, note the fip(end) position
                % this is taken as the first zero-crossing
                % and the first ip
                % if startmin ==true, it is the first valley ip position
                % else: it is the first peak ip position
                firstip_idx(j) = fip(end);
                obj.idlist_ips{j}(k) = firstip_idx(j);
                
                lastconfirmed_ip = firstip_idx(j);
                k = k+1;
                % increased to detect a peak ip.
                
                if obj.startmin(j) == true
                    
                    % so, valleys are odd idx 1,...
                    % while peaks are even idx 2,...
                    
                    for idx = 2:obj.D
                        if ((sgnsf2(idx,j)~=sgnsf2(idx-1,j)) && sgnsf2(idx-1,j)~=0) && ...
                                (idx - lastconfirmed_ip > obj.CPD(1))
                            % debug
                            % fprintf('possible ip-location index: %g\n', idx);
                            
                            % valley check
                            mval = round(obj.CPD(2)/2);
                            if (k > 2) && (mod(k,2)~=0) && (idx <= (obj.D-(mval+1)))
                                % - check if possible valley point is greater than
                                % the last immediate confirmed peak point in the list:
                                % * useful for points relatively close to each other.
                                
                                % action: if true,
                                % - then this point cannot be a valley,
                                % - remove the last point index in the list,
                                %   which is also the last confirmed peak point
                                %   index
                                
                                lchk = lastconfirmed_ip-mval;
                                if lchk < lastconfirmed_ip
                                    lchk = lastconfirmed_ip;
                                end
                                uchk = lastconfirmed_ip+mval;
                                if (mean(obj.DY(idx-3:idx+3,j)) - ...
                                        mean(obj.DY(lchk:uchk,j)) > 0 )
                                    % decrement k.
                                    k = k - 1;
                                    % debug
                                    % disp(num2str(obj.idlist_ips(k)) + " out!");
                                    obj.idlist_ips{j}(k) = [];
                                    lastconfirmed_ip = obj.idlist_ips{j}(k-1);
                                end
                            end
                            
                            % bounding box for second-derivative zero-crossing
                            % signs
                            rem_len = obj.D - idx;
                            lb = idx;
                            if rem_len >= obj.CPD(2)
                                ub = (idx+obj.CPD(2));
                            else
                                % idx is close to the end-point,
                                % so, use remaining length
                                ub = (idx+rem_len);
                            end
                            
                            % check if more than one zero-crossing occurs
                            chksgns = sgnsf2(lb:ub,j);
                            uniquecs = unique(chksgns);
                            if (numel(uniquecs) <= 2)
                                if k > 1
                                    % check:
                                    % - is this new detected point
                                    %   lesser than CPD(1)
                                    % action:
                                    % - skip this index. do not list it.
                                    if (idx-lastconfirmed_ip > obj.CPD(1))
                                        obj.idlist_ips{j}(k) = idx;
                                        % then increment k to show that
                                        % we are looking for a valley (k is now odd)
                                        % or peak point (k is now even)
                                        k = k+1;
                                        % debug
                                        % disp("last_in = " + idx);
                                        lastconfirmed_ip = idx;
                                    else
                                        % debug
                                        % disp(num2str(idx)+' failed CPD test');
                                    end
                                end
                            else
                                % debugl
                                % disp(num2str(idx)+' not a unique zero-crossing!');
                            end
                        end
                    end
                    
                    %
                    
                    % idx is now == obj.D
                    
                    % recheck last confirmed point index
                    % check:
                    % - if last confirmed point is a peak (that is current k is odd),
                    %   but the DY value at the end points is bigger.
                    % action: remove that confirmed peak point.
                    if (mod(k,2)~=0) && ...
                            (mean(obj.DY(idx-2:idx,j))-...
                            obj.DY(obj.idlist_ips{j}(k-1)) > 0)
                        k = k - 1;
                        %  disp(num2str(obj.iplist_idx(k)) + " removed. invalid!");
                        obj.idlist_ips{j}(k) = [];
                    end
                    
                    % check
                    % - if last valley point (max/min) was detected
                    %   but the DY value at the end points is smaller.
                    %   action: replace that confirmed valley point.
                    %                     if (mod(k,2)==0) && ...
                    %                             (mean(obj.DY(idx-2:idx,j))-...
                    %                             obj.DY(obj.idlist_ips{j}(k-1)) < 0)
                    %                         endloc = obj.idlist_ips{j}(k-1);
                    %                         for ff = obj.idlist_ips{j}(k-1)+1:idx
                    %                             if obj.DY(ff,j) < obj.DY(ff-1,j)
                    %                                 endloc = ff;
                    %                             end
                    %                         end
                    %                         if endloc ~= idx
                    %                             endloc = endloc + 1;
                    %                         end
                    %                         k = k - 1;
                    %                         %  disp(num2str(obj.iplist_idx(k)) + " shifted!");
                    %                         obj.idlist_ips{j}(k) = endloc;
                    %                         k = k+1;
                    %                     end
                    
                    % estimated phase
                    % - est_phase = 0 (pre-peak), 1(around-peak),
                    % 2(post-peak), 3(post-peak end)
                    if mod(k,2)~=0
                        obj.est_phase(j) = 2;
                    elseif mod(k,2)==0
                        obj.est_phase(j) = 0;
                    end
                    % todo: how to estimate exact around-peak phase
                    
                    % check:
                    % - for possible max: final saturation at the end.
                    tick = obj.idlist_ips{j}(k-1);
                    for idx = obj.idlist_ips{j}(k-1)+1:obj.D-1
                        if abs(obj.Ycumm(idx,j)-obj.Ycumm(obj.D,j)) < 1e-6
                            % obj.DY(idx) == obj.DY(idx-1), may be numerically less
                            % Ycumm reliable to probe for 0. i.e: no change
                            tick = [tick; idx]; %#ok<*AGROW>
                        end
                    end
                    if numel(tick) > 1
                        if (mod(k,2)~=0)
                            % if last confirmed point was a peak,
                            % then add this new point as the last-confirmed
                            % valley
                            obj.idlist_ips{j}(k) = tick(2);
                            % post-peak end
                            obj.est_phase(j) = 3;
                        else
                            % if last confirmed point was a valley,
                            % just replace with this new point index
                            obj.idlist_ips{j}(k-1) = tick(2);
                            obj.est_phase(j) = 3;
                        end
                    end
                    
                elseif obj.startmin(j) == false
                    
                    % so, valleys are even idx 2,...
                    % while peaks are odd idx 1,...
                    
                    for idx = 2:obj.D
                        if (sgnsf2(idx,j)~=sgnsf2(idx-1,j) && sgnsf2(idx-1,j)~=0) && ...
                                (idx - lastconfirmed_ip > obj.CPD(1))
                            % debug
                            % fprintf('possible ip-location index: %g\n', idx);
                            
                            % valley check
                            mval = round(obj.CPD(2)/2);
                            if (k > 2) && (mod(k,2)==0) && (idx <= (obj.D-(mval+1)))
                                % - check if possible valley point is greater than
                                % the last immediate confirmed peak point in the list:
                                % * useful for points relatively close to each other.
                                
                                % action: if true,
                                % - then this point cannot be a valley,
                                % - remove the last point index in the list,
                                %   which is also the last confirmed peak point
                                %   index
                                
                                lchk = lastconfirmed_ip-mval;
                                uchk = lastconfirmed_ip+mval;
                                if (mean(obj.DY(idx-3:idx+3,j)) - ...
                                        mean(obj.DY(lchk:uchk,j)) > 0 )
                                    % decrement k.
                                    k = k - 1;
                                    % debug
                                    % disp(num2str(obj.idlist_ips(k)) + " out!");
                                    obj.idlist_ips{j}(k) = [];
                                    lastconfirmed_ip = obj.idlist_ips{j}(k-1);
                                end
                            end
                            
                            % bounding box for second-derivative zero-crossing
                            % signs
                            rem_len = obj.D - idx;
                            lb = idx;
                            if rem_len >= obj.CPD(2)
                                ub = (idx+obj.CPD(2));
                            else
                                % idx is close to the end-point,
                                % so, use remaining length
                                ub = (idx+rem_len);
                            end
                            
                            % check if more than one zero-crossing occurs
                            chksgns = sgnsf2(lb:ub,j);
                            uniquecs = unique(chksgns);
                            if (numel(uniquecs) <= 2)
                                if k > 1
                                    % check:
                                    % - is this new detected point
                                    %   lesser than CPD(1)
                                    % action:
                                    % - skip this index. do not list it.
                                    if (idx-lastconfirmed_ip > obj.CPD(1))
                                        obj.idlist_ips{j}(k) = idx;
                                        % then increment k to show that
                                        % we are looking for a peak (k is now odd)
                                        % or valley point (k is now even)
                                        k = k+1;
                                        % debug
                                        % disp("last_in = " + idx);
                                        lastconfirmed_ip = idx;
                                    else
                                        % debug
                                        % disp(num2str(idx)+' failed CPD test');
                                    end
                                end
                            else
                                % debugl
                                % disp(num2str(idx)+' not a unique zero-crossing!');
                            end
                        end
                    end
                    
                    % idx is now == obj.D
                    % recheck last confirmed point index
                    % check:
                    % - if last confirmed point is a peak (that is current k is odd),
                    %   but the DY value at the end points is bigger.
                    % action: remove that confirmed peak point.
                    if (mod(k,2)==0) && ...
                            (mean(obj.DY(idx-2:idx,j))-...
                            obj.DY(obj.idlist_ips{j}(k-1)) > 0)
                        k = k - 1;
                        %  disp(num2str(obj.iplist_idx(k)) + " removed. invalid!");
                        obj.idlist_ips{j}(k) = [];
                    end
                    
                    %                     % check
                    %                     % - if last valley point (max/min) was detected
                    %                     %  but the DY value at the end points is smaller.
                    %                     % action: remove that confirmed valley point.
                    %                     if (mod(k,2)~=0) && ...
                    %                             (mean(obj.DY(idx-2:idx,j))-...
                    %                             obj.DY(obj.idlist_ips{j}(k-1)) < 0)
                    %                         endloc = obj.idlist_ips{j}(k-1);
                    %                         for ff = obj.idlist_ips{j}(k-1)+1:idx
                    %                             if obj.DY(ff,j) < obj.DY(ff-1,j)
                    %                                 endloc = ff;
                    %                             end
                    %                         end
                    %                         if endloc ~= idx
                    %                             endloc = endloc + 1;
                    %                         end
                    %                         k = k - 1;
                    %                         %  disp(num2str(obj.iplist_idx(k)) + " shifted!");
                    %                         obj.idlist_ips{j}(k) = endloc;
                    %                         k = k+1;
                    %                     end
                    
                    % estimated phase
                    % - est_phase = 0 (pre-peak), 1(around-peak),
                    % 2(post-peak), 3(post-peak end)
                    if mod(k,2)~=0
                        obj.est_phase(j) = 2;
                    elseif mod(k,2)==0
                        obj.est_phase(j) = 0;
                    end
                    % todo: how to estimate exact around-peak phase
                    
                    % check:
                    % - for possible max: final saturation at the end.
                    tick = obj.idlist_ips{j}(k-1);
                    for idx = obj.idlist_ips{j}(k-1)+1:obj.D-1
                        if abs(obj.Ycumm(idx,j)-obj.Ycumm(obj.D,j)) < 1e-6
                            % obj.DY(idx) == obj.DY(idx-1), may be numerically less
                            % Ycumm reliable to probe for 0. i.e: no change
                            tick = [tick; idx]; %#ok<*AGROW>
                        end
                    end
                    if numel(tick) > 1
                        if (mod(k,2)~=0)
                            % if last confirmed point was a peak,
                            % then add this new point as the last-confirmed
                            % valley
                            obj.idlist_ips{j}(k) = tick(2);
                            % post-peak end
                            obj.est_phase(j) = 3;
                        else
                            % if last confirmed point was a valley,
                            % just replace with this new point index
                            obj.idlist_ips{j}(k-1) = tick(2);
                            obj.est_phase(j) = 3;
                        end
                    end
                    
                end
                
            end
            
        end
        
        function [obj,phase] = group(obj)
            %GROUP Categorize found inflections into peaks and valleys
            
            %   Inputs:
            
            %   idlist_ips : inflection-points (ips) indices
            
            %   Outputs:
            
            %   idpeak_ips : where even indices of idlist_ips are mid
            %   interval points
            
            %   idvalley_ips : where odd indices of iplist_ips are min-max
            %   interval points
            
            %   N_ips : number of ips partition
            %   phase : current cummulative phase state
            
            phase = strings(obj.J,1);
            obj.N_ips = zeros(obj.J,1);
            for j = 1:obj.J
                % Group by Even/Odd Indices
                if ~isempty(obj.idlist_ips{j})
                    lenoflist = numel(obj.idlist_ips{j});
                    oddindex_ids = 1:2:lenoflist;
                    evenindex_ids = 2:2:lenoflist;
                    
                    if obj.startmin(j) == true
                        % here: increasing curve start
                        % valleys: are the min and max ips of the
                        % x-y axis, odd indexed in the idlist_ips
                        % peaks: are the mid ips w.r.t x-axis,
                        % even indexed in the idlist_ips
                        obj.idvalley_ips{j} = ...
                            obj.idlist_ips{j}(oddindex_ids);
                        if lenoflist > 1
                            obj.idpeak_ips{j} = ...
                                obj.idlist_ips{j}(evenindex_ids);
                        else
                            obj.idpeak_ips{j} = [];
                        end
                        
                        % estimated current phase
                        % - est_phase = 0 (pre-peak), 1(around-peak),
                        % 2(post-peak), 3(post-peak end)
                        if obj.est_phase(j) == 0
                            phase(j) = "pre-peak";
                        elseif obj.est_phase(j) == 2
                            phase(j) = "post-peak";
                        elseif obj.est_phase(j) == 3
                            phase(j) = "post-peak (possible end)";
                        else
                            phase(j) = "undetermined!";
                            warning("estimated phase is: "+phase(j));
                        end
                        
                    elseif obj.startmin(j) == false
                        % here: decreasing curve start
                        % valleys: are the min and max ips of the
                        % x-y axis, odd indexed in the idlist_ips
                        % they are peaks in reality
                        % peaks: are the mid ips w.r.t x-axis,
                        % even indexed in the idlist_ips
                        % they are valleys in reality
                        
                        % nomenclature retained for uniformity
                        % instead of reversing.
                        
                        obj.idvalley_ips{j} = ...
                            obj.idlist_ips{j}(oddindex_ids);
                        if lenoflist > 1
                            obj.idpeak_ips{j} = ...
                                obj.idlist_ips{j}(evenindex_ids);
                        else
                            obj.idpeak_ips{j} = [];
                        end
                        
                        % estimated current phase
                        % - est_phase = 0 (pre-minima), 1(around-minima),
                        % 2(post-minima), 3(post-minima end)
                        if obj.est_phase(j) == 0
                            phase(j) = "pre-minima";
                        elseif obj.est_phase(j) == 2
                            phase(j) = "post-minima";
                        elseif obj.est_phase(j) == 3
                            phase(j) = "post-minima (possible end)";
                        else
                            phase(j) = "undetermined!";
                            warning("estimated phase is: "+phase(j));
                        end
                        
                    end
                    
                    % Estimate the detected number of
                    % sigmoids detected in the data
                    if obj.est_phase(j) == 3
                        obj.N_ips(j) = numel(obj.idvalley_ips{j}) - 1;
                        % or numel(obj.idpeak_ips{j})
                    elseif obj.est_phase(j) == 2
                        obj.N_ips(j) = numel(obj.idvalley_ips{j});
                    elseif obj.est_phase(j) == 0
                        obj.N_ips(j) = numel(obj.idvalley_ips{j});
                    end
                    
                end
                
            end
            
        end
        
        function [obj,solp] = sort(obj,spass,p,eq,base)
            %SORT Sort grouped: valleys and peaks to a
            %     solution structure format.
            %     min, max, mid and transforms to the real x,y values
            %     as initial guess
            %
            % [x_data,y_data,ig_opts,ips_adata,ips_vdata,ips_pdata, time_data] ...
            %  = xy_ipsort(spass,x,y,n_ips,iplist_idx,ips_valley,ips_peak,time)
            
            % Note: xpk is xmid, since for case where srartmin is false
            % it is not a peak but a minima.
            
            % Determines
            % estimated final ymax and xmax, and xpk
            
            % 3 CASES
            % a.) end: post-peak or post-minima => exists: xmin, xpk and xmax
            % - action: no estimation
            % b.) post-peak or post-minima => exists: xmin, xpk only.
            % - action: using ypk, estimate ymax, xmax of the last-phase
            % c.) pre-peak or pre-minima => exists: xmin only.
            % - action: estimate x(end) for xpk, find ypk,
            %     then use them to: estimate ymax and xmax
            
            
            xmins = cell(obj.J,1);
            xmaxs = cell(obj.J,1);
            xpks = cell(obj.J,1);
            ymins = cell(obj.J,1);
            ymaxs = cell(obj.J,1);
            
            % logistic scaling constant
            C = 2;
            
            for j = 1:obj.J
                
                xmins{j} = zeros(obj.N_ips(j),1);
                xmaxs{j} = zeros(obj.N_ips(j),1);
                xpks{j} = zeros(obj.N_ips(j),1);
                ymins{j} = zeros(obj.N_ips(j),1);
                ymaxs{j} = zeros(obj.N_ips(j),1);
                
                
                for id = 1:obj.N_ips(j)
                    % debug:
                    % disp(id)
                    
                    % CASE 1. end post-peak or minima
                    xmins{j}(id) = obj.Xid(obj.idvalley_ips{j}(id), 1);
                    ymins{j}(id) = obj.Ycumm(obj.idvalley_ips{j}(id), j);
                    try
                        
                        xpks{j}(id) = obj.Xid(obj.idpeak_ips{j}(id), 1);
                        xmaxs{j}(id) = obj.Xid(obj.idvalley_ips{j}(id+1),1);
                        ymaxs{j}(id) = obj.Ycumm(obj.idvalley_ips{j}(id+1),j);
                        
                    catch
                        % CASE 2. post-peak or minima
                        try
                            xpks(id) = obj.Xid(obj.idpeaks_ips{j}(id),1);
                            ymaxs{j}(id) = ...
                                C.*obj.Ycumm(obj.idpeaks_ips{j}(id),j) ...
                                - obj.Ycumm(obj.idvalley_ips{j}(id),j);
                            
                            % xmaxs{j}(id) = ( obj.Xid(obj.idpeaks_ips{j}(id),1) ...
                            %   *ymaxs{j}(id) ) ...
                            %   /( obj.Ycumm(obj.idpeaks_ips{j}(id),j) );
                            xmaxs{j}(id) =  xmins{j}(id) + ...
                                ( ( (obj.Xid(obj.idpeaks_ips{j}(id),1) ...
                                -xmins{j}(id))*(ymaxs{j}(id)-ymins{j}(id)) )...
                                / (y(obj.idpeaks_ips{j}(id))-ymins{j}(id)) ...
                                );
                            % some numerical fixes
                            if isnan(xmaxs{j}(id))
                                xmaxs{j}(id) = obj.Xid(end,1);
                            end
                            if (ymaxs{j}(id) == ymins{j}(id))
                                ymaxs{j}(id) = obj.Ycumm(end);
                            end
                        catch
                            % CASE 3. pre-peak or minima
                            try
                                xpks{j}(id) = obj.Xid(end,1)+5;
                                ypk = C.*obj.Ycumm(end,j);
                                ymaxs{j}(id) = (C.*ypk) - ...
                                    obj.Ycumm(obj.idvalley_ips{j}(id),j);
                                % xmaxs{j}(id) = xpks{j}(id)*ymaxs{j}(id)/(ypk);
                                xmaxs{j}(id) =  xmins{j}(id) + ( ...
                                    ( (xpks{j}(id)-xmins{j}(id))*...
                                    (ymaxs{j}(id)-ymins{j}(id)) )...
                                    / (ypk-ymins{j}(id)) );
                            catch
                                error("Ah! was Sorting, but something Bad occured!")
                            end
                        end
                    end
                end
                
                % readjust all xmax,xmin,xpks reference start from
                % the first confirmed valley inflection-point.
                offset = (obj.idvalley_ips{j}(1)-1);
                if spass == false
                    xid = obj.Xid(obj.idvalley_ips{j}(1):end, 1);
                    %% 
                    obj.x_data(:,1)  = obj.X(xid, 1);
                    obj.y_data(:,j) = obj.Ycumm(obj.idvalley_ips{j}(1):end, j);
                    
                    obj.valley_ips{j} = obj.idvalley_ips{j} - offset;
                    obj.peak_ips{j} = obj.idpeak_ips{j} - offset;
                    obj.list_ips{j} = obj.idlist_ips{j} - offset;
                else
                    xid = obj.Xid(obj.idvalley_ips{j}(1):end, 1);
                    %% 
                    obj.x_data(:,1)  = obj.X(xid, 1);
                    obj.y_data(:,j) = obj.Ycumm(obj.idvalley_ips{j}(1):end, j);
                    
                    obj.valley_ips{j} = obj.idvalley_ips{j};
                    obj.peak_ips{j} = obj.idpeak_ips{j};
                    obj.list_ips{j} = obj.idlist_ips{j};
                end
                
                % fill up solp
                solp.n{j} = obj.N_ips(j);
                solp.shape{j} = obj.shape(j);
                
                % get real xmax,xmin,xpk using the x_data
                this_xdat = obj.x_data(:,1);
                idsx = xmaxs{j} - offset;
                inrange = []; outrange = [];
                for it = 1:numel(idsx)
                    if idsx(it) <= numel(this_xdat)
                        inrange = [inrange;this_xdat(idsx(it))]; %#ok<*AGROW>
                    else
                        in = idsx(it)*this_xdat(idsx(1))/idsx(1);
                        outrange = [outrange; in];
                    end
                end
                solp.xmax{j} = [inrange; outrange];
                %
                idsx = xmins{j} - offset;
                inrange = []; outrange = [];
                for it = 1:numel(idsx)
                    if idsx(it) <= numel(this_xdat)
                        inrange = [inrange;this_xdat(idsx(it))];
                    else
                        in = idsx(it)*this_xdat(idsx(1))/idsx(1);
                        outrange = [outrange; in];
                    end
                end
                solp.xmin{j} = [inrange; outrange];
                %
                if eq == 0
                    idsx = xpks{j} - offset;
                    inrange = []; outrange = [];
                    for it = 1:numel(idsx)
                        if idsx(it) <= numel(this_xdat)
                            inrange = [inrange;this_xdat(idsx(it))];
                        else
                            in = idsx(it)*this_xdat(idsx(1))/idsx(1);
                            outrange = [outrange; in];
                        end
                    end
                    solp.xpks{j} = [inrange; outrange];
                end
                %
                solp.base{j} = base;
                solp.ymax{j} = ymaxs{j};
                solp.ymin{j} = ymins{j};
                solp.p{j} = p;
                
            end
           
            obj.solp = solp;
        end
        
    end
    
end

