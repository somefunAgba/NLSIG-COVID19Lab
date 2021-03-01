%% Modelling API Examples:
% The following Frontend APIs can be called from the
% command-line directly.
% Only, ensure you call the path fix first

su; % path fix

%% 1.  Front-end to model one valid country-code
ccode = "WD";
status = query_one(ccode, 0);

%% 2.  Front-end to model a batch of valid country-codes
% ccodes = ["WD","GB","IT","FR","SE","TR","RU",...
%     "CN","JP","KR","IN","IL","IR","AE",...
%     "US","CA","AU","CU","MX","BR",...
%     "NG","GH","EG","ZA","ZW","KE"]';
% status = query_batch(ccodes, 1);

%% 3.  Front-end to model all available and valid country-codes
% status = query_all;