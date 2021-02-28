function row_mets = ...
    get_metrics(query_ccode, time_query, focus, time_data)
%GET_METRICS 
% private function

%% Copyright
% <mailto:oasomefun@futa.edu.ng |oasomefun@futa.edu.ng|>|, 2020.|



%% 1. Path operation
if ~(ismcc || isdeployed)
    [thisfp,thisfn,~]= fileparts(which('save_metrics.m'));
    rootfp = strrep(thisfp, [filesep 'cvmain' filesep 'cvcore'], '');
    if isfile(fullfile(thisfp,thisfn+".m"))
        current_userfp = cd(rootfp);
%         cd(rootfp);
%         old_dir = rootfp;
    end
else
    % we don't need to do anything
    % since its a deployed code.
end
datefd =  string(time_data(end));

%% 2. Metrics File name
if ~(ismcc || isdeployed)
    if focus == 'i'
        metricsfile = fullfile(rootfp, 'measures', 'infs', ...
            datefd,'imetrics_df.xlsx');
    elseif focus == 'd'
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

%% 3. Get metrics from metricfile
try
sheets = sheetnames(metricsfile);
% check if the sheet for a country code exists
sheet_exists = any(strcmpi(query_ccode,sheets));
if sheet_exists
    % write or append new data on new line
    % if date-entry does overwrite with new data
    
    opts = detectImportOptions(metricsfile);
    % selects ccode sheet
    opts.Sheet = query_ccode;
    % selects all variables
    opts.SelectedVariableNames = 1:8;
    tabdf = readtable(metricsfile,opts);
    row_idx = time_query == tabdf{:,1};
    row_mets = tabdf(row_idx,2:8);
    row_mets = table2array(row_mets);
    %'R2','XIR','XIRLB','XIRUB','YIR','YIRLB','YIRUB'
end
catch ME
    if ~(ismcc || isdeployed)
        cd(current_userfp);
    end
    rethrow(ME);    
end

if ~(ismcc || isdeployed)
    cprintf('[0.3, 0.5, 0.5]','Query successful!\n');
    cd(current_userfp);
end
end