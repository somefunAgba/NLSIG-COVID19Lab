% Copyright:
% |oasomefun@futa.edu.ng| 2020.
%
clear all; %#ok<CLALL>

% selected country codes

ccq = ["WD","GB","IT","FR","SE","TR","RU",...
    "CN","JP","KR","IN","IL","IR","AE",...
    "US","CA","AU","CU","MX","BR",...
    "NG","GH","EG","ZA","ZW","KE"]';
clen = numel(ccq);
ccin = ccq;

for ix = 1:clen
    search_code = ccin(ix);
    
    % update is either: 0 or 1
    % use to get updated data when connected to the internet
    % processing via internet may be slow for multiple countries.
    update = 0;
    
    % optional
    finer = true; 
    boots = true;% irrelevant if finer is true
    %number of bootstrap samples to take
    nboot = 70;
    focus = {'i','d'};
    idx = 1:2;
    for id = idx
        % focus is either: 'i' or 'd'
        try
            [sol,fitstats,ymets,xmets,new_mts] = ...
                cov19_nlsigquery(search_code,update,focus{id},nboot,boots,finer);
            
        catch ME
            cid = find(ccs{:,1}==search_code);
            cprintf('r',string(ccs{cid,2})+' : '+ME.message)
        end
    end
    
end