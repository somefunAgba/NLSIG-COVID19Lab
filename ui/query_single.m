% Copyright:
% |oasomefun@futa.edu.ng| 2020.
%
clear all; %#ok<CLALL>
rng(1);

% select one country code or use 'WD' for worldwide code
search_code = "US";
% update is either: 0 or 1
% use to get updated data when connected to the internet
% processing via internet may be slow for multiple countries.
update = 0;
% optional
finer = true;
boots = true; % irrelevant if finer is true
% number of bootstrap samples to take
nboot = 30;


% idx = 2:2;
idx = 1:2;
% idx = 1:1;

focus = {'i','d'};
for id = idx
    % focus is either: 'i' or 'd'
    try
        [sol,fitstats,ymets,xmets,new_mts] = ...
            cov19_nlsigquery(search_code,update,focus{id},nboot,boots,finer);
        fprintf("R_2 = %g\n", fitstats.R2);
        fprintf("R_2a = %g\n", fitstats.R2a);
        fprintf("YIR = %g [%g, %g]\n",...
            median(ymets(end,:)),min(ymets(end,:)),max(ymets(end,:)));
        fprintf("XIR = %g [%g, %g]\n",...
            median(xmets(end,:)),min(xmets(end,:)),max(xmets(end,:)));
        
    catch ME
        rethrow(ME)
        %continue;
    end
end