function exportplots(gcf,country_code,focus,time_data)
%EXPORTPLOTS Save Prediction Plots for Later Use

[this_filepath,this_filename,~]= fileparts(mfilename('fullpath')); %#ok<ASGLU>
rootpath = strrep(this_filepath, [filesep 'cvmain' filesep 'plotter'], '');

thisfolder =  string(time_data(end));

try
    old_dir = cd(rootpath+'/assets');
    mkstore(thisfolder);
    cd(thisfolder);
catch
    old_dir = cd(rootpath);
    mkstore("assets");
    cd("assets");
    mkstore(thisfolder);
    cd(thisfolder);
end
% addpath(genpath(rootpath));
% rmpath(fullfile(rootpath,"bin"))

exportgraphics(gcf, country_code+focus+".eps",'Resolution',300)
exportgraphics(gcf, country_code+focus+".pdf",'Resolution',300)
exportgraphics(gcf, country_code+focus+".png",'Resolution',300)
cd(old_dir);

end

