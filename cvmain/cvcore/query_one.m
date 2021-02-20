
function status = query_one(search_code, qid)
%QUERY_ONE commadline api for nlsig modelling 
% COVID-19 WHO data of a single country-code.
%
% Inputs:
% search_code : country-code, e.g: 'US'
% qid : 0 (infections and death), 
%        1 (infections), 2 (deaths)
%
% Outputs:
% status : 0 (fail) or 1 (success)
%
% USAGE:
% status = query_one("WD", 2)
%
% Copyright:
% |oasomefun@futa.edu.ng| 2020.


assert(qid >= 0 && qid <=3, "qid can be 0, 1 or 2!")
status = 0; % default err state

% select one country code or use 'WD' for worldwide code
% search_code = "GB";
%
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
if qid == 0
    frange = 1:2;
elseif qid == 1 || qid == 2
    frange = qid:qid;
end

for id = frange
    
    try
        [~,time_data,sol,fitstats,ymets,xmets,new_mts] = ...
            cov19_nlsigquery_applet(search_code,update,focus{id},...
            nboot,boots,finer); %#ok<ASGLU>
        
        fprintf("R_2 = %g\n", fitstats.R2);
        fprintf("R_2a = %g\n", fitstats.R2a);
        fprintf("YIR = %g [%g, %g]\n",...
            median(ymets(end,:)),min(ymets(end,:)),max(ymets(end,:)));
        fprintf("XIR = %g [%g, %g]\n",...
            median(xmets(end,:)),min(xmets(end,:)),max(xmets(end,:)));
    
        status = 1; % success   
    
    catch ME
        if status == 0
        rethrow(ME)
        end
        %continue;
    end
end

end