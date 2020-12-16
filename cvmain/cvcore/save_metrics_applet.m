function save_metrics_applet(focus,new_rows,query_ccode,time_data)
%SAVE_METRICS

%% 1. Path operation
if ~(ismcc || isdeployed)
    [thisfp,thisfn,~]= fileparts(which('save_metrics_applet.m'));
    rootfp = strrep(thisfp, [filesep 'cvmain' filesep 'cvcore'], '');
    if isfile(fullfile(thisfp,thisfn+".m"))
        cd(rootfp);
        old_dir = rootfp;
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
            cd(fullfile(rootfp,'measures'));
            mkstore("infs");
            cd(fullfile(rootfp,'measures','infs'));
        end
        mkstore(datefd);
        metricsfile = fullfile(rootfp, 'measures', 'infs', ...
            datefd,'imetrics_df.xlsx');
    elseif focus == 'd'
        try
            cd(fullfile(rootfp,'measures','dths'))
        catch
            cd(fullfile(rootfp,'measures'));
            mkstore("infs");
            cd(fullfile(rootfp,'measures','dths'));
        end
        mkstore(datefd);
        metricsfile = fullfile(rootfp, 'measures', 'dths', ...
            datefd,'dmetrics_df.xlsx');
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
if ~isfile(metricsfile)
    new_rows.Properties.VariableNames = {'QueryDate','R2','XIR','XIRLB','XIRUB','YIR','YIRLB','YIRUB'};
    writetable(new_rows, metricsfile,"Sheet",query_ccode,"WriteMode","overwritesheet");
else
    sheets = sheetnames(metricsfile);
    % check if the sheet for a country code exists
    sheet_exists = any(strcmpi(query_ccode,sheets)); %#ok<NASGU>
    % write or overwrite sheet with new data
    new_rows.Properties.VariableNames = {'QueryDate','R2','XIR','XIRLB','XIRUB','YIR','YIRLB','YIRUB'};
    writetable(new_rows, metricsfile,"Sheet",query_ccode,"WriteMode","overwritesheet");
end

%% 4. End.
if ~(ismcc || isdeployed)
    cprintf('[0.3, 0.5, 0.5]','Query successful!\n');
    cd(old_dir);
end

end