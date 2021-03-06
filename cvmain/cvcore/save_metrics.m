function save_metrics(focus,new_rows,query_ccode,time_data)
%SAVE_METRICS
% private function

%% 1. Path operation
if ~(ismcc || isdeployed)
    [thisfp,thisfn,~]= fileparts(which('save_metrics.m'));
    rootfp = strrep(thisfp, [filesep 'cvmain' filesep 'cvcore'], '');
    if isfile(fullfile(thisfp,thisfn+".m"))
        current_userfp = cd(rootfp);
        % old_dir = rootfp;
    end
else
    % we don't need to do anything
    % since its a deployed code.
end
datefd =  string(time_data(end));

%% 2. File name for metrics
if ~(ismcc || isdeployed)
    if focus == 'i'
        try
            cd(fullfile(rootfp,'measures','infs'))
        catch
            try
                cd(fullfile(rootfp,'measures'))
                mkstore("infs");
                cd(fullfile(rootfp,'measures','infs'));               
            catch
                cd(fullfile(rootfp));
                mkstore("measures");
                cd(fullfile(rootfp,'measures'));
                mkstore("infs");
                cd(fullfile(rootfp,'measures','infs'));
            end
        end
        mkstore(datefd);
        metricsfile = fullfile(rootfp, 'measures', 'infs', ...
            datefd,'imetrics_df.xlsx');
        focusPath = fullfile(rootfp, 'measures', 'infs', datefd);
        addpath(genpath(focusPath));
    elseif focus == 'd'
        try
            cd(fullfile(rootfp,'measures','dths'))
        catch
            try
                cd(fullfile(rootfp,'measures'))
                mkstore("dths");
                cd(fullfile(rootfp,'measures','dths'));               
            catch
                cd(fullfile(rootfp));
                mkstore("measures");
                cd(fullfile(rootfp,'measures'));
                mkstore("dths");
                cd(fullfile(rootfp,'measures','dths'));
            end
        end
        mkstore(datefd);
        metricsfile = fullfile(rootfp, 'measures', 'dths', ...
            datefd,'dmetrics_df.xlsx');
        focusPath = fullfile(rootfp, 'measures', 'dths', datefd);
        addpath(genpath(focusPath));
    end
else
    if focus == 'i'
        metricsfile = fullfile(ctfroot, 'measures', 'infs', ...
            datefd,'imetrics_df.xlsx');
    elseif focus == 'd'
        metricsfile = fullfile(ctfroot, 'measures', 'dths', ...
            datefd,'dmetrics_df.xlsx');
    end    
end


%% 3. Save metrics to metricfile
% does file exist? if not, create it
try
    if ~isfile(metricsfile)
        new_rows.Properties.VariableNames = {'QueryDate','R2','XIR','XIRLB','XIRUB','YIR','YIRLB','YIRUB'};
        writetable(new_rows, metricsfile,'Sheet',query_ccode,'WriteMode','overwritesheet');
    else
        sheets = sheetnames(metricsfile);
        % check if the sheet for a country code exists
        sheet_exists = any(strcmpi(query_ccode,sheets)); %#ok<NASGU>
        % write or overwrite sheet with new data
        new_rows.Properties.VariableNames = {'QueryDate','R2','XIR','XIRLB','XIRUB','YIR','YIRLB','YIRUB'};
        writetable(new_rows, metricsfile,'Sheet',query_ccode,'WriteMode','overwritesheet');
    end
catch ME
    if ~(ismcc || isdeployed)
        cd(current_userfp);
    end
    rethrow(ME);
end

%% 4. End.
if ~(ismcc || isdeployed)
    cprintf('[0.3, 0.5, 0.5]','Query successful!\n');
    %rmpath(genpath(focusPath));
    cd(current_userfp);
end

end