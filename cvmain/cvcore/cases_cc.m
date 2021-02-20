function [t,y,dy,status] = ...
    cases_cc(country_code,update,focus,app)
%CASES_CC Obtain Cases of a country-code
% Query and get data on a focus category of cases 
% from a specified country-code
%
%INPUTS
% country_code : e.g: 'US'
% update: 0 | 1
% focus: 'i' | 'd'
%
%OUTPUTS
% t : time (calendar date)
% y : cummulative cases
% dy : incident cases
% status : 0 or 1 , query success
%
%CMD
%   [t,y,dy,status] = cases_cc("US",0,"i")
%   [t,y,dy,status] = cases_cc("US",1,"d")
%
%APP
%   [t,y,dy,status] = cases_cc("US",0,"i",app)
%   [t,y,dy,status] = cases_cc("US",1,"d",app)
%
%Copyright:
% <mailto:oasomefun@futa.edu.ng |oasomefun@futa.edu.ng|>|, 2020.|
assert(nargin<=4," Expected at most 4 arguments!")

is_app = true;
if nargin < 4 % not an applet
    is_app = false;
end
assert(update == 0 || update == 1, "update is either: 0 or 1!")
assert(focus == "i" || focus == "d", "focus is either: 'i' or 'd'!")

%
if is_app == true
    [TT,status] = get_cdata_applet(country_code, update, app);
else
    [TT,status] = get_cdata_applet(country_code, update);
end

%
if focus == "i"
    y = TT.Cumulative_cases;
    dy = TT.New_cases;
elseif focus == "d"
    y = TT.Cumulative_deaths;
    dy = TT.New_deaths;
end
t = TT.Date_reported;

% Move back and forth in time experienced
% by selecting an end-time within bounds of the max. last logged date
if is_app == true
    idx_select_end = find(app.xbnds.end==TT.Date_reported);
    y = y(1:idx_select_end);
    dy = dy(1:idx_select_end);
    t = t(1:idx_select_end);
end


end