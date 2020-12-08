function [y,dy_dx] = nlsig(x,eq,iopts)
%nLOGISTIC-SIGMOID function
% logistic-sigmoid function for 
% multiple peak inflection points, i = 1, ..., n.
% $$ y = f(x) $$
%
%% Syntax
%
% [y,dy_dx] = nlsig(x,eq,iopts)
%
% Inputs: 
% x: scalar | vector 
% eq: 0 or 1
% iopts: struct,
%
% if eq = 1 : all struct elements are scalar
% else :
% scalar size: 1 by 1 
% iopts.n = 1;
% iopts.shape = 's';
%
% vector size: n by 1
% iopts.base
% iopts.lambda
% iopts.xmax
% iopts.xpks
% iopts.xmin
% iopts.ymax
% iopts.ymin
% 
% Outputs:
% y: scalar | vector
% dy_dx: scalar | vector
%
% Copyright:
% |oasomefun@futa.edu.ng| 2020.

if eq == 1
    [y,dy_dx] = nlsig_eq(x,iopts);
elseif eq == 0
    [y,dy_dx] = nlsig(x,iopts);
else
    err_msg = sprintf("Try again! syntax: [y,dy_dx] = nlsig(x,eq,iopts),\n"+...
                    "Note: ensure eq is either 0 or 1!");
    error(err_msg);
end

%% general (equal|unequal) interval
function [y,dy_dx] = nlsig(x,iopts)
%nLOGISTIC-SIGMOID
% logistic-sigmoid function for 
% multiple inflection points, i = 1, ..., n.
% arbitrarily divided intervals.
%
%% Syntax
%
% [y,dy_dx] = nlsig(x,iopts)
%
% Inputs: 
% x: scalar | vector 
% iopts: struct,
%
% scalar size: 1 by 1 
% iopts.n = 1;
% iopts.shape = 's';
%
% vector size: n by 1
% iopts.base
% iopts.lambda
% iopts.xmax
% iopts.xpks
% iopts.xmin
% iopts.ymax
% iopts.ymin
% 
% Outputs:
% y: scalar | vector
% dy_dx: scalar | vector
%
% Copyright:
% |oasomefun@futa.edu.ng| 2020.

veclen_x = numel(x);
% fixed parameters, always unity
cigma = 1;
beta = 1;
gamma = 2^beta - cigma;

%% Validate Arguments
try % number of peak inflection points
n = iopts.n; 
assert(isnumeric(n) && (n > 0), "You should make n > 0 and an integer.");
catch
    % >=1, 1 (default)
    e_msg = "n undefined. falling back to n = 1.\n";
    fprintf(e_msg);  
    
    n = 1;
end
try % shape
shape = iopts.shape; 
% exponential input direction logic
if (shape=='z')
    c = 1;
elseif (shape == 's')
    c = -1;
else
    warning('invalid sigmoid shape.');
end
catch
    % "s" (default), "z"
    e_msg = "sigmoid shape undefined. falling back to shape = 's'.\n";
    fprintf(e_msg);  
    
    shape = 's'; %#ok<NASGU>
    c = -1;
end
try % base
base = iopts.base; 
if isnumeric(base)
    if ~any((base > 1)==0)
        b_i = base;
        base = "numeric";
    else
        error("Oops! using number, ensure the base is a positive real or integer number.")
    end
else
    if base=="nat"
    elseif base~="nat"
        if base == "bin"
            b_i = 2;
        elseif base == "oct"
            b_i = 8;
        elseif base == "dec"
            b_i = 10;
        elseif base == "hex"
            b_i = 16;
        elseif base == "vig"
            b_i = 20;
        else
            error("Oops! the base entered is not a valid one...");
        end
    else
        error("Oops! the base entered is not a valid one...");
    end
end
if base~="nat"
    if numel(b_i) == 1
        b_i = b_i*ones(n,1);
    end
end
catch
    base = "nat";     
    e_msg = "base undefined or invalid. falling back to the natural exponential function.\n";
    fprintf(e_msg); 
    % "nat" (default), "bin", "dec", "hex", "oct", "vig"
    % nat = natural exponential
    % bin = binary, or meji, base 2   
    % oct = octal, or mejo  base 8 
    % dec = decimal, or mewa, base 10
    % hex = hexadecimal or merindinlogun, base 16
    % vig = vigesimal, or ogun, base 20   
end

% Assert conditions
constrchk = iopts.check_constraints;
req_size = [n, 1];
% do they meet the expected vector size
reqsz_msg = "Hi! correct your inputs."+...
    "Array size for x(min, max), y(min, max) "+...
    "and lambda should be "+num2str(n)+" by 1.";
assert(isequal(size(iopts.ymax),req_size), reqsz_msg)
assert(isequal(size(iopts.xmax),req_size), reqsz_msg)
assert(isequal(size(iopts.ymin),req_size), reqsz_msg)
assert(isequal(size(iopts.xmin),req_size), reqsz_msg)
assert(isequal(size(iopts.lambda),req_size), reqsz_msg)
assert(isequal(size(iopts.xpks),req_size), reqsz_msg)
% are they numbers?
isnum_msg = "Hi! check your 'ymax', 'ymin', "+...
    "'xmax', 'xmin', 'lambda' and 'xpks' inputs."+...
    "possible non-numeric values detected.";
if constrchk == 1
    assert(isnumeric(iopts.ymax), isnum_msg)
    assert(isnumeric(iopts.xmax), isnum_msg)
    assert(isnumeric(iopts.ymin), isnum_msg)
    assert(isnumeric(iopts.xmin), isnum_msg)
    assert(isnumeric(iopts.lambda), isnum_msg)
    assert(isnumeric(iopts.xpks), isnum_msg)
end
% x-y max-min boundaries/intervals
xmax_i = iopts.xmax; 
xmin_i = iopts.xmin; 
ymax_i = iopts.ymax; 
ymin_i = iopts.ymin; 
% growth-rate
lambda_i = iopts.lambda;
% x (peak) inflection points of each i
delta_x_i = iopts.xpks;

%% Constraints for arbitrarily-divided intervals
% optional: 
%   xmin_1 == fixed non-negative point
%   xmax_n == fixed positive point
%   ensures all xmin and xmax > 0,  for non-negative time-series
% 0. lambda > 0, b > 1
% 1. % xmin_i < xmax_i; if i > 1: xmin_i == xmax_i-1 && < xmax_i
% 2. % xpks_i < xpks_i+1 ; xmin_i < xpks_i < xmax_i
% 3. % ymin_i < ymax_i; if i > 1: ymin_i == ymax_i-1 && < ymax_i
cx_msg = "Oops, x-constraints check failed. check your inputs!";
cy_msg = "Oops, y-constraints check failed. check your inputs!";
cxp_msg = "Oops, peak inflection points (x-axis) constraints "+ ...
    "check failed. check your inputs!";
lmd_msg = "growth-rate must be real-valued and greater than 0.";
base_msg = "numeric exponential base should be greater than 1.";
if constrchk == 1
    for i = 1:n
        % lambda constraints
        assert( lambda_i(i) > 0, lmd_msg)
        % base constraints
        if base~="nat"
            assert( b_i(i) > 1, base_msg)
        end
        % x- constraints.
        assert ( xmin_i(i) < xmax_i(i), cx_msg);
        if i > 1
            assert ( xmin_i(i) == xmax_i(i-1), cx_msg);
        end
        % peaks constraints.
        assert ( (xmin_i(i) < delta_x_i(i)) && ...
            (delta_x_i(i) < xmax_i(i)), cxp_msg);
        if i > 1
            assert ( delta_x_i(i-1) < delta_x_i(i), cxp_msg);
        end
        % y- constraints.
        assert ( ymin_i(i) < ymax_i(i), cy_msg);
        if i > 1
            assert ( ymin_i(i) == ymax_i(i-1), cy_msg);
        end
    end
end

%% Main
% set x-y i-th input-output interval differences
Dy_i = ymax_i-ymin_i;
Dx_i = xmax_i-xmin_i;

% set alpha as a function of input space
alpha_i = lambda_i.*(2./Dx_i);

% partial output and partial output derivative of each i w.r.t x
% v_i = zeros(n,veclen_x);
% dv_i = zeros(n,veclen_x);

% output and derivative of each i w.r.t x
y = ymin_i(1)*ones(size(veclen_x)); %ymin_i(1)*ones(1,veclen_x);
dy_dx = zeros(size(veclen_x));

for i=1:n
    % input to base exponential-function
    u_i = c.*alpha_i(i,1).*(x - delta_x_i(i,1));
    
    % output = sum of each ith partial outputs 
    if base == "nat"
        %v_i(i,:) 
        v = Dy_i(i,1)./(cigma + gamma.*exp(u_i));
    elseif base~="nat"
        %v_i(i,:) 
        v = Dy_i(i,1)./(cigma + gamma.*b_i(i).^(u_i));
    end
    y = y + v;

    % output-derivative = sum of each ith partial output-derivatives
    %dv_i(i,:)
     dv = -c.*alpha_i(i,1).*( v .* ( 1 - (v./Dy_i(i,1)) ) );
    if base~="nat"
        %dv_i(i,:) 
        dv = log(b_i(i)).*dv;
    end
    % dy_dx(1,:) 
    dy_dx = dy_dx + dv;
end

% convert to column-vector: n*1,
% if in row-vector form
if isrow(y)
y = y';
dy_dx = dy_dx';
end


% |oasomefun@futa.edu.ng| 2020.
end

%% equal Interval
function [y,dy_dx] = nlsig_eq(x,iopts)
%nLOGISTIC-SIGMOID
% logistic-sigmoid function for 
% multiple inflection points, i = 1, ..., n.
% equally divided intervals.
%
%% Syntax
%
% [y,dy_dx] = nlsig(x,iopts)
%
% Inputs: 
% x: scalar | vector 
% iopts: struct, each element is scalar
%
% iopts.shape = 's';
% iopts.base = "nat";
% iopts.n = 1;
% iopts.lambda = 6;
% iopts.epsil = 0;
% iopts.xmax =  1;
% iopts.xmin = -1;
% iopts.ymax =  1;
% iopts.ymin = -1;
% 
% Outputs:
% y: scalar | vector
% dy_dx: scalar | vector
%
% Copyright:
% |oasomefun@futa.edu.ng| 2020.

veclen_x = numel(x);
% fixed parameters, always unity
cigma = 1;
beta = 1;
gamma = 2^beta - cigma;

%% Validate Arguments
try % shape
shape = iopts.shape; 
% exponential input direction logic
if (shape=='z')
    c = 1;
elseif (shape == 's')
    c = -1;
else
    warning('invalid sigmoid shape.');
end
catch
    % "s" (default), "z"
    e_msg = "sigmoid shape undefined. falling back to shape = 's'.\n";
    fprintf(e_msg);     
    
    shape = 's'; %#ok<NASGU>
    c = -1;
end
try % base
base = iopts.base; 
if isnumeric(base)
    if (numel(base) == 1) && (base > 1)
        b_i = base;
        base = "numeric";
    else
        error("Oops! using number, ensure the base is a positive real or integer number.")
    end
else
    if base=="nat"
    elseif base~="nat"
        if base == "bin"
            b_i = 2;
        elseif base == "oct"
            b_i = 8;
        elseif base == "dec"
            b_i = 10;
        elseif base == "hex"
            b_i = 16;
        elseif base == "vig"
            b_i = 20;
        else
            error("Oops! the base entered is not a valid one...");
        end
    else
        error("Oops! the base entered is not a valid one...");
    end
end
catch
    base = "nat";     
    e_msg = "base undefined or invalid. falling back to the natural exponential function.\n";
    fprintf(e_msg); 
    % "nat" (default), "bin", "dec", "hex", "oct", "vig"
    % nat = natural exponential
    % bin = binary, or meji, base 2   
    % oct = octal, or mejo  base 8 
    % dec = decimal, or mewa, base 10
    % hex = hexadecimal or merindinlogun, base 16
    % vig = vigesimal, or ogun, base 20   
end
try % number of peak inflection points
n = iopts.n; 
assert(isnumeric(n) && (n > 0), "You should make n > 0 and an integer.");
catch
    % >=1, 1 (default)
    e_msg = "n undefined. falling back to n = 1.\n";
    fprintf(e_msg);  
    
    n = 1;
end

try % fixed/adaptive growth-rate constant
lambda = iopts.lambda; 
catch
    % > 0, 6 (default)
    e_msg = "lambda undefined. falling back to lambda = 6.\n";
    fprintf(e_msg);  
    
    lambda = 6;
end
try % epsil for rescaling limits
epsil = iopts.epsil; 
catch
     % -100 < epsil < 100, 0 (default)
     epsil = 0;
     epsil = min(100,max(-100,epsil)) / 100;
end

% max-min support constraints
try % xmax
xmax = iopts.xmax; 
catch
    e_msg = "x_max undefined. falling back to x_max = 1.\n";
    fprintf(e_msg);
    % 1 (default)
    xmax = 1;
end
try % xmin
xmin = iopts.xmin; 
catch
    e_msg = "x_min undefined. falling back to x_min = -1.\n";
    fprintf(e_msg);
    % -1 (default)
    xmin = -1;
end
try % ymax
ymax = iopts.ymax; 
ymax = (1-epsil)*ymax;
catch
    e_msg = "y_max undefined. falling back to y_max = 1.\n";
    fprintf(e_msg);    
    % 1 (default)
    
    ymax =  1;

end
try % ymin
ymin = iopts.ymin; 
ymin = (1-epsil)*ymin;
catch
    e_msg = "y_min undefined. falling back to y_min = -1.\n";
    fprintf(e_msg);     
    % -1 (default)
    
    ymin = -1;
end

% Assert conditions
req_size = [1 1];
% do they meet the expected vector size
reqsz_msg = "Hi! correct your inputs."+...
    "Array size for x(min, max), y(min, max) "+...
    "and lambda should be "+num2str(n)+" by 1.";
assert(isequal(size(iopts.ymax),req_size), reqsz_msg)
assert(isequal(size(iopts.xmax),req_size), reqsz_msg)
assert(isequal(size(iopts.ymin),req_size), reqsz_msg)
assert(isequal(size(iopts.xmin),req_size), reqsz_msg)
assert(isequal(size(iopts.lambda),req_size), reqsz_msg)
% are they numbers?
isnum_msg = "Hi! check your 'ymax', 'ymin', "+...
    "'xmax', 'xmin', 'lambda' and 'xpks' inputs."+...
    "possible non-numeric values detected.";
assert(isnumeric(iopts.ymax), isnum_msg)
assert(isnumeric(iopts.xmax), isnum_msg)
assert(isnumeric(iopts.ymin), isnum_msg)
assert(isnumeric(iopts.xmin), isnum_msg)
assert(isnumeric(iopts.lambda), isnum_msg)

%% Main
% quantize or partition the input-output space 
% into equally divided n intervals. 
Dy =(ymax-ymin)/n; % = Dy_i
Dx =(xmax-xmin)/n; % = Dx_i

% set alpha and delta as a function of input space
alpha = lambda.*(2/Dx);

% x inflection points (peak) of each i
delta_x_i=zeros(n,1);

% partial output and partial output derivative of each i w.r.t x
% v_i = zeros(n,veclen_x);
% dv_i = zeros(n,veclen_x);

% output and derivative of each i w.r.t x
y = ymin*ones(size(veclen_x)); %ymin_i(1)*ones(1,veclen_x);
dy_dx = zeros(size(veclen_x));

for i=1:n
    delta_x_i(i,1) = xmin + (Dx*(i-0.5));

    % input to base exponential-function
    u_i = c.*alpha.*(x-delta_x_i(i,1));
    
    % output = sum of each ith partial outputs
    if base == "nat"
        v = Dy./(cigma + gamma.*exp(u_i));
    elseif base~="nat"
        v = Dy./(cigma + gamma.*b_i.^(u_i));
    end
    % debug
    fprintf("%g\n",v);
    y = y + v;

    % output-derivative = sum of each ith partial output-derivatives
    dv = -c.*alpha.*( v .* (1 - (v./Dy)) );
    if base~="nat"
        dv = log(b_i).*dv;
    end
    dy_dx = dy_dx + dv;
end

% convert to column-vector: n*1,
% if in row-vector form
if isrow(y)
y = y';
dy_dx = dy_dx';
end


% |oasomefun@futa.edu.ng| 2020.
end

% |oasomefun@futa.edu.ng| 2020.
end