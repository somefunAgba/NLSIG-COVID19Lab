function status = upd_status(search_ccode)
%UPD_STATUS Update a countrycode's COVID-19 data 
% Update existing data apecified by search_ccode
%
% USAGE: status = upd_status("ALL");
%   status = upd_status("WD");
%   status = upd_status("NG");

%
%% Copyright
% <mailto:oasomefun@futa.edu.ng |oasomefun@futa.edu.ng|>|, 2020.|

%clc;

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

 
% call update on WHO's CV19 data
status = upd_cdata_applet(search_ccode,1);

%
cd(other_dir);
cprintf('[0.3, 0.5, 0.5]','Update successful!\n');
end