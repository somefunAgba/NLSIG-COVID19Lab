function [Tstruct, ccs] = allcc_view_applet(app)
[~,status,ccs] = get_cdata_applet(app,"ALL",0);  %#ok<ASGLU>


t = getcasesbycc_applet(app,"WD",0,'o');
t = datetime(t);

Tstruct.begin = t(1);
Tstruct.end = t(end);


end