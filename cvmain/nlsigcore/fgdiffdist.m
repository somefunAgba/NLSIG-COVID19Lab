function DYDx = fgdiffdist(Y,dx)
% forward difference sum (integration)

% DYdx: incident data samples of a signal or system
% usually noisy.

% dx: difference between samples
% sampling-time 

% assumes DYdx is of size: D x J
%D num of data samples 
%J num of channels or outputs
sz = size(Y);
% J = sz(2);
D = sz(1);

if nargin < 2
    dx = 1;
end

DYDx = Y;

DYDx(1,:) = (Y(2,:) - Y(1,:))./(dx);    
for d=2:D-1
    DYDx(d,:) = 0.5*(Y(d+1,:) - Y(d-1,:))./(dx);    
end
DYDx(D,:) = (Y(D,:) - Y(D-1,:))./(dx);    

end