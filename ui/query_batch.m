% Copyright:
% |oasomefun@futa.edu.ng| 2020.
%
clear all; %#ok<CLALL>

% get all country codes
% ccs = allcc_view;
% ccin = ccs;
% clen = height(ccin);

ccq = ["WD","GB","IT","FR","SE","TR","RU",...
    "CN","JP","KR","IN","IL","IR","AE",...
    "US","CA","AU","CU","MX","BR",...
    "NG","GH","EG","ZA","ZW","KE"]';
clen = numel(ccq);
ccin = ccq;

for ix = 1:clen
%     search_code = string(ccin{ix,1});
    search_code = ccin(ix);
    
    % update is either: 0 or 1
    % use to get updated data when connected to the internet
    % processing via internet may be slow for multiple countries.
    update = 0;
    
    % optional
    %number of bootstrap samples to take
    nboot = 70;
    focus = {'i','d'};
    idx = 1:2;
    for id = idx
        % focus is either: 'i' or 'd'
        try
            [sol,fitstats,ymets,xmets,new_mts] = ...
                cov19_nlsigquery(search_code,update,focus{id},nboot);
%             fprintf("R_2 = %g\n", fitstats.R2);
%             fprintf("R_2a = %g\n", fitstats.R2a);
%             fprintf("YIR = %g [%g, %g]\n",...
%                 median(ymets(end,:)),min(ymets(end,:)),max(ymets(end,:)));
%             fprintf("XIR = %g [%g, %g]\n",...
%                 median(xmets(end,:)),min(xmets(end,:)),max(xmets(end,:)));
            
        catch ME
            cid = find(ccs{:,1}==search_code);
            cprintf('r',string(ccs{cid,2})+' : '+ME.message)
        end
    end
    
end