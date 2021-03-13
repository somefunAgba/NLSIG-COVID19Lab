clc;clear *;
[this_filepath,this_filename,~]= fileparts(mfilename('fullpath'));
rootpath = this_filepath;
if ~isfile(this_filename)
    current_userfp = cd(rootpath);
else
    current_userfp = cd(rootpath);
end
addpath(genpath(rootpath));
if isfolder(fullfile(rootpath,'bin'))
    rmpath(fullfile(rootpath,"bin"))
end
cd(current_userfp);
