function [ccs,status] = get_cc(app)
%GET_CC Get list of country-codes for COVID-19 data
%       Get available two-letter country-codes for WHO COVID-19 data
%
%INPUTS
% (Optional)
% app : app handle
%
%OUTPUTS
% status : success or failure, 1 or 0
% ccs : Table list of available country-codes
%
%Usecase: 
%CMD
%   [ccs,status] = get_cc;
%   ccs = get_cc;
%   [~,status] = get_cc;
%APP
%   [ccs,status] = get_cc(app)
%   ccs = get_cc(app)
%   [~,status] = get_cc(app)
%
%Copyright:
% <mailto:oasomefun@futa.edu.ng |oasomefun@futa.edu.ng|>|, 2020.|

assert(nargin<=1," Expected at most 1 argument!")

is_app = false;
if nargin == 1 % an applet
    is_app = true;
end

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
e_msg = sprintf("Possible corrupted dir structure. local files missing.\n" + ...
        "you might have to re-download the local folder from source.");
    
%% 2. Obtain available country codes and names
% check if the 'ccn_file' exists in data folder, otherwise fallback to
% local folder
try
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
status = 1; %success
if ~(ismcc || isdeployed)
    if is_app == true
        app.StatusLabel.Text = "Query successful!";
        app.StatusLabel.FontColor = [0.3, 0.5, 0.5];
    else
        cprintf('[0.3, 0.5, 0.5]','Query successful!\n');
    end
    cd(other_dir);    
end

catch ME
    status = 0; % err
    % ME
    fprintf("Error Identifier: %s\n",ME.identifier);
    fprintf("Error Message: %s\n",ME.message);
    %fprintf("Error Cause: %s\n",ME.cause);
    %fprintf("Error Trace: %s\n",ME.stack)
end

end