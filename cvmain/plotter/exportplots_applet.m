function exportplots_applet(gcf,country_code,focus,time_data)
%EXPORTPLOTS Save Prediction Plots for Later Use


datefd =  string(time_data(end));

if ~(ismcc || isdeployed)
    [thisfp,thisfn,~]= fileparts(which('exportplots_applet.m'));
    rootfp = strrep(thisfp, [filesep 'cvmain' filesep 'plotter'], '');
    if isfile(fullfile(thisfp,thisfn+".m"))
        try           
        current_userfp = cd(fullfile(rootfp,'assets'));
        catch
            current_userfp = cd(fullfile(rootfp));
            mkstore("assets");
            cd(fullfile(rootfp,'assets'));
        end
        mkstore(datefd);
        ffname = fullfile(rootfp,'assets',datefd);
        
        focusPath = ffname;
        addpath(genpath(focusPath));
    end
else
    % we don't need to do anything
    % since its a deployed code.
end



% try
%     old_dir = cd(rootpath+'/assets');
%     mkstore(datefd);
%     cd(datefd);
% catch
%     old_dir = cd(rootpath);
%     mkstore("assets");
%     cd("assets");
%     mkstore(datefd);
%     cd(datefd);
% end


gfname = fullfile(ffname,country_code+focus+".pdf");
exportgraphics(gcf, gfname,'Resolution',300)

gfname = fullfile(ffname,country_code+focus+".eps");
exportgraphics(gcf, gfname,'Resolution',300)

gfname = fullfile(ffname,country_code+focus+".png");
exportgraphics(gcf, gfname,'Resolution',300)


if ~(ismcc || isdeployed)
    %rmpath(genpath(focusPath));
    cd(current_userfp);
else
    % we don't need to do anything
    % since its a deployed code.
end




end

