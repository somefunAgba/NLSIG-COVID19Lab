function [TT,status,ccs] = get_cdata(search_ccode, update)
%  GET_CDATA Get a country's COVID-19 data via its country code and specify whether to 
% update existing data, update = 1 or 0
%% Usecase: 
%%
% 
%   [TT,status,ccs] = get_cdata("NG",0); 
%   [TT,status,ccs] = get_cdata("US",1); 
%   [~,status,ccs] = get_cdata("ALL",1); 
%
%% Copyright
% <mailto:oasomefun@futa.edu.ng |oasomefun@futa.edu.ng|>|, 2020.|
clc;
% add the root location of this file to matlab's path if not on matlab's path
% p = mfilename('fullpath');c = strrep(p,"get_cdata","");
[this_filepath,this_filename,~]= fileparts(mfilename('fullpath'));
this_filename = this_filename+".m";
rootpath = strrep(this_filepath, [filesep 'cvmain' filesep 'cvcore'], '');
if ~isfile(this_filename)
    other_dir = cd(rootpath);
else
    other_dir = cd(rootpath);
end
addpath(genpath(rootpath));
if isfolder(fullfile(rootpath,'bin'))
    rmpath(fullfile(rootpath,"bin"))
end
%% 
% 
% call update on WHO's CV19 data
upd_cdata(update, search_ccode);

% obtain available country codes and names
% check if the 'ccn_file' exists in data folder
ccn_file = "data/country_code_name.xlsx";
state = isfile(ccn_file);
if ~state
    ccn_file = "local/country_code_name.xlsx";
    state = isfile(ccn_file);
    e_msg = sprintf("Possible corrupted dir structure. local files missing.\n" + ...
        "you might have to re-download the local folder from source.");
    assert(state==1, e_msg);
end
ccs = readtable("local/country_code_name.xlsx");
%
e_msg = sprintf("Please check either of the files:\n"+ ...
    "'country_code_name.xlsx' or 'country_code_name.csv'\n"+ ...
    "for valid two-letter country codes.");
assert(isstring(search_ccode), e_msg);
%% 
% 
% check if the 'cbc_CV19datafile' exists in data folder
cbc_CV19datafile = "data/cbc_CV19_data.xlsx";
world_CV19datafile = "data/world_CV19_data.xlsx";
state = isfile(cbc_CV19datafile) && isfile(world_CV19datafile);
if ~state
    cbc_CV19datafile = "local/cbc_CV19_data.xlsx";
    world_CV19datafile = "local/world_CV19_data.xlsx";
    state = isfile(cbc_CV19datafile) && isfile(world_CV19datafile);
    e_msg = sprintf("Possible corrupted dir structure. local files missing.\n" + ...
        "you might have to re-download the local folder from source.");
    assert(state==1, e_msg);
end
%% 
% 
% obtain country code data
status = 0;
if search_ccode == "WD"
    % in the world data file
    opts = detectImportOptions(world_CV19datafile);
    % selects ccode sheet
    opts.Sheet = search_ccode;
    % selects only 4 variables, the first, and fifth to eigth variable
    opts.SelectedVariableNames = [1,5:8];
    TT = readtable(world_CV19datafile,opts);
    status = 1; 
else
sheets = sheetnames(cbc_CV19datafile);
% check if country code is valid or exists
if ~strcmpi("ALL",search_ccode)   
    sheet_exists = any(strcmpi(search_ccode,sheets));
    if sheet_exists
        % in the cbc data file
        opts = detectImportOptions(cbc_CV19datafile);
        % selects ccode sheet
        opts.Sheet = search_ccode;
        % selects only 4 variables, the first, and fifth to eigth variable
        opts.SelectedVariableNames = [1,5:8];
        TT = readtable(cbc_CV19datafile,opts);
        status = sheet_exists;
    else
        warning("attempt to load a non-existent country code");
        e_msg = sprintf("Please check either of the files:\n"+ ...
            "'country_code_name.xlsx' or 'country_code_name.csv'\n"+ ...
            "for valid two-letter country codes.");
        error(e_msg);
    end
else    
    TT = [];
    status = 1;
end
end
cd(other_dir);
cprintf('[0.3, 0.5, 0.5]','Query successful!\n');
end