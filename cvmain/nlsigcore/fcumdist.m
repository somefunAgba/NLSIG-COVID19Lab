function Y = fcumdist(DYdx,dx)
% forward cummulative sum (integration)

% DYdx: incident data samples of a signal or system
% usually noisy.

% dx: difference between samples
% sampling-time 
if nargin < 2
    dx = 1;
end

% assumes DYdx is of size: D x J
%D num of data samples 
%J num of channels or outputs
sz = size(DYdx);
% J = sz(2);
D = sz(1);

Y = DYdx;
for d=2:D
    Y(d,:) = (DYdx(d,:).*dx) + Y(d-1,:);    
end

end



% USECASE:
% SIGNAL RECOVERY. OR TREND RECOVERY FROM NOISY CORRUPTED DATA
%
% DYDx is a noisy signal., could be time-series
% dx is the sample-time 
% (optional for scaling to correct Fcum. values)
% can be skipped, since it does not affec the recovery
%
% obtain cum.sum-dist of DYdx which is more smooth;
% Y = fcummulate(DYdx,dx)
% then model Y with the LNN;
% then modelled DY is the filtered DYDx.
%
% DATA - FCUM - LNN - FILT.DATA 

% EECG
% ELECTRIC ENERGY

% In short: we should be able to filter any incident data, 
% so-far we know its cummulative sum.
