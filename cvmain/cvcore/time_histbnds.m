function [Tbnds] = time_histbnds(country_code,app)
%TIME_HISTLOG Get time history so-far for the logged COVID-19 data
%       Get the bounds of the time-sequence so far for the logged
%       WHO COVID-19 data for a country_code.
%
%INPUTS
% (Optional)
% country_code : "WD" is default
% app : app handle
%
%OUTPUTS
% Tbnds : struct holding the min and max time so-far.
%
%Usecase: 
%CMD
%   [Tbnds] = time_histbnds("GB");
%APP
%   [Tbnds] = time_histbnds("WD",app);
%
%Copyright:
% <mailto:oasomefun@futa.edu.ng |oasomefun@futa.edu.ng|>|, 2020.|

assert(nargin<=2," Expected at most 2 argument!")
%

is_app = true;
if nargin < 2 % not an applet
    is_app = false;
end

if is_app == true
    TT = get_cdata_applet(country_code,0,app);
else
    TT = get_cdata_applet(country_code,0);
end
dt = datetime(TT.Date_reported);
%
Tbnds.begin = dt(1);
Tbnds.end = dt(end);

end