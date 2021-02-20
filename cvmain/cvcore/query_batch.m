% selected country codes
% search_codes = ["WD","GB","IT","FR","SE","TR","RU",...
%     "CN","JP","KR","IN","IL","IR","AE",...
%     "US","CA","AU","CU","MX","BR",...
%     "NG","GH","EG","ZA","ZW","KE"]';
function status = query_batch(search_codes, qid)
%QUERY_BATCH commadline ui for nlsig modelling 
% COVID-19 WHO data of a batch of country-codes
%
% Inputs:
% search_codes : string array of country codes, 
%            e.g: ["WD","GB","IT","FR","SE","TR","RU"]
% qid : 0 (infections and death), 
%       1 (infections), 2 (deaths)
%
% Outputs:
% status : 0 (fail) or 1 (success)
%
% USAGE:
% status = query_batch(["WD","US"], 1);
%
% Copyright:
% |oasomefun@futa.edu.ng| 2020.


assert(nargin==2,'Expecting exactly 2 arguments!')
assert(qid >= 0 && qid <=3, "qid can be 0, 1 or 2!")

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
if qid == 0
    frange = 1:2;
elseif qid == 1 || qid == 2
    frange = qid:qid;
end

% collect batch country_code
ccin = search_codes;
clen = numel(ccin);

for ix = 1:clen
    search_code = ccin(ix);
    for id = frange
        % focus is either: 'i' or 'd'
        try
          [~,time_data,sol,fitstats,...
              ymets,xmets,new_mts] = ...
            cov19_nlsigquery_applet(search_code,update,...
            focus{id},nboot,boots,finer); %#ok<ASGLU>
            status = 1; % success;
        catch ME
            ccs = get_cc;
            cid = find(ccs{:,1}==search_code);
            cprintf('r',string(ccs{cid,2})+' : '+ ME.message) %#ok<FNDSB>
            %rethrow(ME);
        end
    end
    
end