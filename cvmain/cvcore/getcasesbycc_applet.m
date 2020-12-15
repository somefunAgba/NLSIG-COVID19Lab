function [t,y,dy,status,ccs] = getcasesbycc_applet(app, country_code,update,focus)
%GETCASES Process Cases by country code
%
% Inputs:
% country_code = 'NG';
% update: 0 (default) | 1
% focus: 'i' (default) | 'd'
%
% Outputs:
% t : time (calendar date)
% y : cummulative cases
% dy : incident cases
% status (optional) : 0 or 1 , query success
% ccs (optional): country names
[T,status,ccs] = get_cdata_applet(app, country_code, update);

if focus == "i"
    y = T.Cumulative_cases;
    dy = T.New_cases;
elseif focus == "d"
    y = T.Cumulative_deaths;
    dy = T.New_deaths;
end
t = T.Date_reported;

if focus == "i" || focus == "d"
    idx_select_end = find(app.xbnds.end==T.Date_reported);
    y = y(1:idx_select_end);
    dy = dy(1:idx_select_end);
    t = t(1:idx_select_end);
end

end