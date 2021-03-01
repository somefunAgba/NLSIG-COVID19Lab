function [x,ys,dys,d2ys] = smoothspline(finer,y,dy,knots_val)
%SMOOTHSPLINE  Smooth Data by Fitting Cubic Spline to Noisy Data
%
% Inputs:
% y: noisy data
% knots_val: 13-15 (recommended) for spline fit
%
% Outputs:
% x: indices
% ys: smoothed data
% dys: smoothed first derivative
% d2ys: smoothed second derivative
%
x = (1:numel(y))'; % starts from 1.
ys = y;

if finer == true
    dys =  dy;
%     d2ys = diff(y,2); 
    d2ys = gradient(y);
    d2ys = gradient(d2ys);
else
    % ys = makima(x,y,(0:.1:numel(y)-1));
    
    % shape language modelling engine for cummulative data
    % for kn = 13:15
    % reduce knots to determine smaller sized waves.
    prescription=slmset('plot','off','knots',knots_val,'leftminvalue',0,'increasing','on',...
        'degree',3,'rightmaxvalue',max(ys),...
        'verbosity',0);
    slm = slmengine(x,ys,prescription);
    
    % smoothed data values
    % data
    ys = slmeval(x,slm);
    % first derivative
    dys = slmeval(x,slm,1);
    % second derivative
    d2ys = slmeval(x,slm,2);
end

end