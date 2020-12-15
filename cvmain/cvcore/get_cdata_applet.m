function [TT,status,ccs] = get_cdata_applet(app, search_ccode, update)
%  GET_CDATA Get a country's COVID-19 data via its country code and specify whether to
% update existing data, update = 1 or 0
% Usecase:
%   [TT,status,ccs] = get_cdata("NG",0);
%   [TT,status,ccs] = get_cdata("US",1);
%   [~,status,ccs] = get_cdata("ALL",1);
%
% Copyright
% <mailto:oasomefun@futa.edu.ng |oasomefun@futa.edu.ng|>|, 2020.|


%% 1. ensure we are at the project's root
if ~(ismcc || isdeployed)
    [thisfp,thisfn,~]= fileparts(which('get_cdata_applet.m'));
    rootfp = strrep(thisfp, [filesep 'cvmain' filesep 'cvcore'], '');
    if isfile(fullfile(thisfp,thisfn+".m"))
        other_dir = cd(rootfp);
    end
else
    % we don't need to do anything
    % since its a deployed code.
end
e_msg = sprintf("Please check either of the files:\n"+ ...
    "'country_code_name.xlsx' or 'country_code_name.csv'\n"+ ...
    "for valid two-letter country codes.");
assert(isstring(search_ccode), e_msg);

%clc;
%add the root location of this file to matlab's path if not on matlab's path
%[this_filepath,this_filename,~]= fileparts(mfilename('fullpath'));
% save or create a new file
%save(fullfile(ctfroot, 'afile.mat'))
%fullfile(ctfroot,'work')
% instead of cd dir/subdir to access a file
% use x = fullfile(ctfroot, 'dir','subdir', 'file.m')


%% 2. Call update on WHO's CV19 data
upd_cdata_applet(app, update, search_ccode);

e_msg = sprintf("Possible corrupted dir structure. local files missing.\n" + ...
        "you might have to re-download the local folder from source.");
    
%% 3. Obtain available country codes and names
% check if the 'ccn_file' exists in data folder, otherwise fallback to
% local folder
if ~(ismcc || isdeployed)
    ccn_filed = fullfile(rootfp, "data", "country_code_name.xlsx");
    ccn_filel = fullfile(rootfp, "local", "country_code_name.xlsx");
else
    ccn_filed = fullfile(ctfroot, "data", "country_code_name.xlsx");
    ccn_filel = fullfile(ctfroot, "local", "country_code_name.xlsx");
end
state = isfile(ccn_filed);
if ~state
    state = isfile(ccn_filel);
    assert(state==1, e_msg);
end
ccs = readtable(ccn_filel);

%% 4. Check if the 'cbc_CV19datafile' exists in data folder
%       else fallback to local folder
if ~(ismcc || isdeployed)
    cbc_CV19datafiled = fullfile(rootfp, "data", "cbc_CV19_data.xlsx");
    world_CV19datafiled = fullfile(rootfp, "data", "world_CV19_data.xlsx");
    cbc_CV19datafilel = fullfile(rootfp, "local", "cbc_CV19_data.xlsx");
    world_CV19datafilel = fullfile(rootfp, "local", "world_CV19_data.xlsx");
else
    cbc_CV19datafiled = fullfile(ctfroot, "data", "cbc_CV19_data.xlsx");
    world_CV19datafiled = fullfile(ctfroot, "data", "world_CV19_data.xlsx");
    cbc_CV19datafilel = fullfile(ctfroot, "local", "cbc_CV19_data.xlsx");
    world_CV19datafilel = fullfile(ctfroot, "local", "world_CV19_data.xlsx");
end
state = isfile(cbc_CV19datafiled) && isfile(world_CV19datafiled);
if ~state
    state = isfile(cbc_CV19datafilel) && isfile(world_CV19datafilel);
    app.StatusLabel.Text = "Error: Directory Corrupted!";
    app.StatusLabel.FontColor = [1,0, 0]; %red;
    assert(state==1, e_msg);
end

%% 5. Obtain country code data
status = 0;
% in the world data file
if search_ccode == "WD"
    if state
        opts = detectImportOptions(world_CV19datafiled);
    else
        opts = detectImportOptions(world_CV19datafilel);
    end
    % selects ccode sheet
    opts.Sheet = search_ccode;
    % selects only 4 variables, the first, and fifth to eigth variable
    opts.SelectedVariableNames = [1,5:8];
    if state
        TT = readtable(world_CV19datafiled,opts);
    else
        TT = readtable(world_CV19datafilel,opts);
    end
    status = 1;
end

% in country-by-country file
if ~strcmp(search_ccode, "WD") &&  ~strcmpi("ALL",search_ccode)  
    sheets = sheetnames(cbc_CV19datafiled);
    % check if country code is valid or exists
    sheet_exists = any(strcmpi(search_ccode,sheets));
    if sheet_exists
        % in the cbc data file
        if state
            opts = detectImportOptions(cbc_CV19datafiled);
        else
            opts = detectImportOptions(cbc_CV19datafilel);
        end
        % selects ccode sheet
        opts.Sheet = search_ccode;
        % selects only 4 variables, the first, and fifth to eigth variable
        opts.SelectedVariableNames = [1,5:8];
        if state
            TT = readtable(cbc_CV19datafiled,opts);
        else
            TT = readtable(cbc_CV19datafilel,opts);
        end
        status = sheet_exists;
    else
        warning("attempt to load a non-existent country code");
        e_msg = sprintf("Please check either of the files:\n"+ ...
            "'country_code_name.xlsx' or 'country_code_name.csv'\n"+ ...
            "for valid two-letter country codes.");
        app.StatusLabel.Text = "Error: Directory Corrupted!";
        app.StatusLabel.FontColor = [1, 0, 0]; % red
        error(e_msg);
    end
    
end
if strcmpi("ALL",search_ccode)  
    TT = [];
    status = 1;
end

%% 6. End.
if ~(ismcc || isdeployed)
    
    app.StatusLabel.Text = "Query successful!";
    app.StatusLabel.FontColor = [0.3, 0.5, 0.5];
    cd(other_dir);
    
end


end