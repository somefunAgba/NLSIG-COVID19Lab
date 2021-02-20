%% Update API Examples:
% The following Frontend APIs can be called from the
% command-line directly.
% Only, ensure you call the path fix first

su; % path fix

%% 1. Front-end to update data for all country-code
status = upd_status("ALL");

%% 2. Front-end to update data for only one country-code
% status = upd_status("US");