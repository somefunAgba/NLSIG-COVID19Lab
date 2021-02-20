function status = query_all
%QUERY_ALL commadline ui for nlsig modelling 
% COVID-19 WHO data of all country-codes
%
% Inputs: none
% Outputs:
% status : 0 (fail) or 1 (success)
%
% USAGE:
% status = query_all;
%
%
% Copyright:
% |oasomefun@futa.edu.ng| 2020.


assert(nargin==0,'Expecting no arguments!')

status = 0; % default err state

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
frange = 1:2;

% get all country codes
ccin = get_cc;
clen = height(ccin);

for ix = 1:clen
    search_code = string(ccin{ix,1});
    
    for id = frange
        % focus is either: 'i' or 'd'
        try
          [~,time_data,sol,fitstats,...
              ymets,xmets,new_mts] = ...
            cov19_nlsigquery_applet(search_code,update,...
            focus{id},nboot,boots,finer); %#ok<ASGLU>
            status = 1; % success
        catch ME
            cid = find(ccin{:,1}==search_code);
            cprintf('r',string(ccin{cid,2})+' : '+ME.message) %#ok<FNDSB>
        end
    end
    
end