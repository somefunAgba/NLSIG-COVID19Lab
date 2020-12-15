% Copyright:
% |oasomefun@futa.edu.ng| 2020.
%
clear all; %#ok<CLALL>

% get all country codes
ccs = allcc_view;
ccin = ccs;
clen = height(ccin);

for ix = 1:clen
    search_code = string(ccin{ix,1});
    
    % update is either: 0 or 1
    % use to get updated data when connected to the internet
    % processing via internet may be slow for multiple countries.
    update = 0;
    
    % optional
    finer = true; 
    boots = true;% irrelevant if finer is true
    % number of bootstrap samples to take
    nboot = 30;
   

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