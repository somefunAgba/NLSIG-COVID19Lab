function status = querymdl_status(search_code, idx)
% private function to support tests for modelling 
% COVID-19 WHO data using the NLSIG.
%
% Inputs:
% search_code : country-code
% idx : 1 (infections) or 2 (deaths)
%
% Outputs:
% status : 0 (fail) or 1 (pass)
%
% Copyright:
% |oasomefun@futa.edu.ng| 2020.

rng(1);

status = 0; % default err state

% select one country code or use 'WD' for worldwide code
%search_code = "WD";
% update is either: 0 or 1
% use to get updated data when connected to the internet
% processing via internet may be slow for multiple countries.
update = 0;

% optional
finer = true;
boots = true; % irrelevant if finer is true
% number of bootstrap samples to take
nboot = 30; % irrelevant if finer is true

% focus is either: 'i' or 'd'
focus = {'i','d'};
for id = idx:idx
    
    try
        [~,time_data,sol,fitstats,ymets,xmets,new_mts] = ...
            cov19_nlsigquery_applet(search_code,update,...
            focus{id},nboot,boots,finer); %#ok<ASGLU>

        fprintf("R_2 = %g\n", fitstats.R2);
        fprintf("R_2a = %g\n", fitstats.R2a);
        fprintf("YIR = %g [%g, %g]\n",...
            median(ymets(end,:)),min(ymets(end,:)),max(ymets(end,:)));
        fprintf("XIR = %g [%g, %g]\n",...
            median(xmets(end,:)),min(xmets(end,:)),max(xmets(end,:)));
    
        status = 1; % passed
    
    catch ME
        if status == 0 % failed;
            rethrow(ME)
        end
        return;
    end
end

end