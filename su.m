clc;clear *;
[this_filepath,this_filename,~]= fileparts(mfilename('fullpath'));
rootpath = this_filepath;
if ~isfile(this_filename)
    other_dir = cd(rootpath);
else
    other_dir = cd(rootpath);
end
addpath(genpath(rootpath));
if isfolder(fullfile(rootpath,'bin'))
    rmpath(fullfile(rootpath,"bin"))
end