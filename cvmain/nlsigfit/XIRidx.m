function XIR = XIRidx(x,sol)
%XIR
% Logistic Sigmoid Curve Indices
% XIR: X to Inflection Ratio

% Given the x peak inflection-points and max-min intervals in a nlsig curve
% At any x value, find the x to inflection ratio.

% For many cases, x can be interpreted as time
% so, XIR, means input time (X) to Inflection Ratio ((X)IR)

% at x < xpks_i, XIR < 1;
% at x > xpks_i, XIR > 1;
% at x = xpks_i, XIR = 1;

% useful for indicating the distance between an input x
% and the inflection points in the cummulative curve's interval. 

% disp(xpks_i); % debug
% 

if isrow(x)
    x = x';
end

% shape_i = sol.shape;
base_i = sol.base;
lambda_i = sol.lambda;
xpks_i = sol.xpks;
xmax_i = sol.xmax;
xmin_i = sol.xmin;


% if shape_i == 's'
%     c = -1;
% elseif shape_i == 'z'
%     c = 1;
% else
%     c = -1;
% end

ips_id = x >= xmin_i';
c = sum(ips_id,2);
c(c==0) = 1;

min = xmin_i(c);
pks = xpks_i(c);
max = xmax_i(c);
lambd = lambda_i(c);

XIR = (lambd./(max-min)).*(x-pks);
%XIR = ((lambda_i')./(xmax_i'- xmin_i')).*(x - xpks_i');

if ~any(isnumeric(base_i))
    XIR = exp(1.*XIR);
else
    if numel(base_i) > 1
        bases = base_i(c);
    else
        bases = base_i;
    end
    XIR = bases'.^(1.*XIR);
end

if isrow(XIR)
    XIR = XIR';
end

% oasomefun@futa.edu.ng 2020
end