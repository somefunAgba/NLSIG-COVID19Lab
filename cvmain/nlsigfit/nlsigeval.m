%% defs
% redefinitions for nlsig evaluation with MATLAB's Optimization Toolbox 
function [y_out, dy_dx_out] = nlsigeval(x_data,n_ips,shape,base,lambda,...
    xmax,xmin,ymax,ymin,xpks)
% nlsigeval
% nlsig function handle for MATLAB's
% optimization problem creation

optsin.shape = shape;
optsin.base = base;
optsin.n = n_ips;

optsin.lambda = lambda;

optsin.xmin = xmin;
optsin.xpks = xpks;
optsin.xmax = xmax;

optsin.ymin = ymin;
optsin.ymax = ymax;

optsin.check_constraints = 0;

% set to 0. it will likely be checked during optimization
if nargout < 2
    y_out = nlsig(x_data,0,optsin);
else
[y_out, dy_dx_out] = nlsig(x_data,0,optsin);
end

end


