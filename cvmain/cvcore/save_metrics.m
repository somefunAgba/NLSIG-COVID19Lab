
function save_metrics(focus,new_rows,query_ccode,time_data)
[this_filepath,this_filename,~]= fileparts(mfilename('fullpath')); %#ok<ASGLU>
rootpath = strrep(this_filepath, [filesep 'cvmain' filesep 'cvcore'], '');
cd(rootpath);
old_dir = rootpath;
thisfolder =  string(time_data(end));

if focus == 'i'
    mkstore('measures');
    cd('measures');
    mkstore('infs');
    cd('infs')
    thisfolder =  string(time_data(end));
    mkstore(thisfolder);
    cd(thisfolder)
    metricsfile = "imetrics_df.xlsx";
elseif focus == 'd'
    mkstore('measures');
    cd('measures');
    mkstore('dths');
    cd('dths');
    mkstore(thisfolder);
    cd(thisfolder)
    metricsfile = "dmetrics_df.xlsx";
end

% does file exist? if not, create it
if ~isfile(metricsfile)
    Tm = new_rows;
    Tm.Properties.VariableNames = {'QueryDate','R2','XIR','XIRLB','XIRUB','YIR','YIRLB','YIRUB'};
    writetable(Tm, metricsfile,"Sheet",query_ccode,"WriteMode","overwritesheet");
else
    sheets = sheetnames(metricsfile);
    % check if the sheet for a country code exists
    sheet_exists = any(strcmpi(query_ccode,sheets));
    if sheet_exists
        % write or append new data on new line
        % if date-entry does overwrite with new data
        
        %     opts = detectImportOptions(metricsfile);
        %     % selects ccode sheet
        %     opts.Sheet = query_ccode;
        %     % selects all variables
        %     opts.SelectedVariableNames = 1:8;
        %     meas_rows = readtable(metricsfile,opts);
        new_rows.Properties.VariableNames = {'QueryDate','R2','XIR','XIRLB','XIRUB','YIR','YIRLB','YIRUB'};
        writetable(new_rows, metricsfile,"Sheet",query_ccode,"WriteMode","overwritesheet");
    else
        % append ccode as new sheet in metricsfile
        % write data on new line.
        Tm = new_rows;
        Tm.Properties.VariableNames =  {'QueryDate','R2','XIR','XIRLB','XIRUB','YIR','YIRLB','YIRUB'};
        writetable(Tm, metricsfile,"Sheet",query_ccode,"WriteMode","overwritesheet");
    end
end
cd(old_dir);

end