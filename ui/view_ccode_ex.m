%% Country-codes View API Example:
% The following single Frontend API can be called from the
% command-line directly.
% Only, ensure you call the path fix first
%

su; % path fix

%% Front-end for viewing country-codes
ccs = get_cc;

disp(ccs);
fprintf("For combined worldwide query, use 'WD'.\n");
% ccs is a table list of 
% country-codes with its respective countries