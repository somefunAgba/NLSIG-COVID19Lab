function [x,ys,dys,d2ys] = zfs_diff(y,dy)
%ZFS_DIFF Zero-First-Second Differences  
% A helper function to process zero to second differences of
% a noisy cummulative data y.
%
% Inputs:
% y: noisy cummulative data
%
% Outputs:
% x: indices
% ys: smoothed data
% dys: smoothed first derivative
% d2ys: smoothed second derivative
%
% Copyright: oasomefun@futa.edu.ng

% input validation
assert(nargin<=2," Expected at most 2 arguments!")
if nargin < 2
    dy = fdiffdist(y);
end

% starts from 1.
x = (1:numel(y))'; 

ys = y;
dys = dy ; %fdiffdist(y);


% difference fda (finer, close to exact)
% d2ys= fdiffdist(y);
% d2ys = fdiffdist(d2ys);

% d2ys = fdiffdist(dy);

% gradient cda (smoother approximation)
d2ys= fgdiffdist(y);
d2ys = fgdiffdist(d2ys);

%d2ys = fgdiffdist(dy);



% ys = y;
% dys =  dy;
% %     d2ys = diff(y,2);
% d2ys = gradient(y);
% d2ys = gradient(d2ys);


end