%% Bounded Time-History API Example:
% The following single Frontend API can be called from the
% command-line directly.
% Only, ensure you call the path fix first

su; % path fix

%% Front-end for viewing the finite bounds of the 
%% available COVID-19 data time history of a country-code
ccode = "WD";
dTime = time_histbnds(ccode);

% the output, dTime is a struture holding: 
% the begin date and last date of the logged data

fprintf("Min Date:%s\n",dTime.begin);
fprintf("Max Date:%s\n",dTime.end);
