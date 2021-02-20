function [y,dydx_np,JH] = nlsig(x,eq,iopts,np,ry)
%nLOGISTIC-SIGMOID function
% logistic-sigmoid function for
% multiple peak inflection points, i = 1, ..., n.
% $$ y = f(x) $$
%
%% Syntax
%
% [y,dydx_np,JH] = nlsig(x,eq,iopts,np,ry)
%
% Inputs:
% x: scalar | vector
% eq: 0 or 1
% iopts: struct,
% derivative order to compute from 1:np
% np: min: 1 max: large number
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
% iopts.p; number of est. params to vary
%
% Outputs:
% y: scalar | vector
% dy_dx: scalar | vector
%
% Copyright:
% |oasomefun@futa.edu.ng| 2020.

if nargin < 4
    np = 1; % min. first-order output-derivative
    ry = false;
end
assert(isnumeric(np) && (np > 0),...
    "You should make np > 0 and an integer.");
if nargin < 5
    ry = false;
end


if eq == 1
    if nargout == 1
        y = nlsig_eq(x,iopts,np,ry);
    elseif nargout == 2
        [y,dydx_np] = nlsig_eq(x,iopts,np,ry);
    elseif nargout == 3
        [y,dydx_np,JH] = nlsig_eq(x,iopts,np,ry);
    end
elseif eq == 0
    if nargout == 1
        y = nlsig(x,iopts,np,ry);
    elseif nargout == 2
        [y,dydx_np] = nlsig(x,iopts,np,ry);
    elseif nargout == 3
        [y,dydx_np,JH] = nlsig(x,iopts,np,ry);
    end
else
    err_msg = sprintf("Try again! syntax: [y,dy_dx] = nlsig(x,eq,iopts),\n"+...
        "Note: ensure eq is either 0 or 1!");
    error(err_msg);
end

%% general (equal|unequal) interval
    function [y,dydx_np,JH] = nlsig(x,iopts,np,ry)
        %nLOGISTIC-SIGMOID
        % logistic-sigmoid function for
        % multiple inflection points, i = 1, ..., n.
        % arbitrarily divided intervals.
        %
        %% Syntax
        %
        % [y,dydx_np,JH] = nlsig(x,iopts,np,ry)
        %
        % Inputs:
        % x: scalar | vector
        % iopts: struct,
        %
        % scalar size: 1 by 1
        % iopts.n = 1;
        % 
        %
        % vector size: n by 1
        % iopts.shape = 's';
        % iopts.base
        % iopts.lambda
        % iopts.xmax
        % iopts.xpks
        % iopts.xmin
        % iopts.ymax
        % iopts.ymin
        %
        % Outputs:
        % y: scalar | vector, veclen_x (d) x 1
        % dy_dx: scalar | vector, d x 1
        % d2y_dx2 : scalar | vector, d x 1
        %
        % JH: Jacobian-Hessian dat. structure
        % jacobian ordering structure
        % [dbase_i dlambda_i dxmax_i dxmin_i ddelta_x_i dymax_i dymin_i];
        %
        % jacob_i[y,e,E]_d | tensor, (d x p x n)
        % jacob[y,e,E] | matrix, (n x p)
        % hess[y,e,E] | tensor (n x p x p)
        
        % Copyright:
        % |oasomefun@futa.edu.ng| 2020.
        
        errcomp = true;
        if ry == false
            ry = 0;
            errcomp = false;
        end
        
        if isrow(x)
            % make it column vector
            x = x';
        end
        veclen_x = numel(x);
        vecsize_x = size(x);
        % fixed parameters, always unity
        cigma = 1;
        % beta = 1;
        gamma = 1; %2^beta - cigma;
        
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
            assert(isnumeric(shape),...
                "shape should be of value: either increasing (1) or decreasing (-1).");
            % exponential input direction logic
            if numel(shape) == 1
                shape = shape.*ones(n,1);
            end
            c = zeros(n,1);
            for id = 1:n
                if shape(id) >= 0
                    shape(id) = 1; % shape == 's'
                else
                    shape(id) = -1; % shape == 'z'
                end
                c(id) = -shape(id);
            end 
            req_size = [n, 1];
            % do they meet the expected vector size
            reqsz_msg = "Hi! correct your inputs."+...
                "Array size for shape"+...
                "and lambda should be "+num2str(n)+" by 1.";
            assert(isequal(size(c),req_size), reqsz_msg)
        catch
            % "s" (default), "z"
            e_msg = "sigmoid shape erroneous. falling back to increasing shape.\n";
            fprintf(e_msg);         
            % shape = 's';
            c = -1*ones(n,1);
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
        y = ymin_i(1)*ones(vecsize_x); %ymin_i(1)*ones(veclen_x,1);
        if errcomp == true
            e = zeros(vecsize_x);
        end
        dy_dx = zeros(vecsize_x);
        
        % output-derivatives array
        dydx_np = zeros(veclen_x,np);
        
        fpdy_dymax_i = zeros(veclen_x,n);
        fpdy_dymin_i  = zeros(veclen_x,n);
        fpdy_ci = zeros(veclen_x,n);
        fpdy_ddelta_x_i = zeros(veclen_x,n);
        fpdy_dalpha_i = zeros(veclen_x,n);
        fpdy_dlambda_i = zeros(veclen_x,n);
        fpdy_dxmax_i = zeros(veclen_x,n);
        fpdy_dxmin_i = zeros(veclen_x,n);
        fpdy_db_i = zeros(veclen_x,n);
        
        p = iopts.p;
        assert( p<=8 && p>=6, 'p is either 6,7 or 8 params.' )
        
        jacob_iy_d = zeros(veclen_x,p,n);
        if errcomp == true
            jacob_ie_d = zeros(veclen_x,p,n);
            jacob_iess_d = zeros(veclen_x,p,n);
        end
        jacoby = zeros(n,p);
        jacobe = jacoby;
        jacobess = jacoby;
        hessy = zeros(n,p,p);
        hesse = hessy;
        hessess = hessy;
        
        for i=1:n
            % input to base exponential-function
            u_i = c(i,1).*alpha_i(i,1).*(x - delta_x_i(i,1));
            
            % output = sum of each ith partial outputs
            if base == "nat"
                %v_i(i,:)
                v = Dy_i(i,1)./(cigma + gamma.*exp(u_i));
            elseif base~="nat"
                %v_i(i,:)
                v = Dy_i(i,1)./(cigma + gamma.*b_i(i).^(u_i));
            end
            y = y + v;
            if errcomp == true
                % error = true - estimated
                e = ry - y;
            end
            
            if nargout > 1
                % output-derivative = sum of each ith partial output-derivatives
                ki = c(i,1).*alpha_i(i,1);
                if base~="nat"
                    ki = log(b_i(i)).*ki;
                end
                
                % output 1st to np-th derivatives
                % pacakage Output-Derivatives
                
                % First output-derivative
                pd = 1;
                vDyi = (v./Dy_i(i,1));
                dv = ki.*v.*( vDyi  - 1 );
                dy_dx = dy_dx + dv;
                % de_dx = de_dx - dv;
                
                dv_np = dv;
                dydx_np(:,pd) = dydx_np(:,pd) + dv_np;
                
                % output-second-derivatives
                %d2v = ki.*dv.*( 2.*vDyi - 1 );
                %d2y_dx2 = d2y_dx2 + d2v;
                %d2e_dx2 = d2e_dx2 - d2v;
                
                if np > 1
                    % output 2nd to np-th derivatives
                    dv_np_min_one = dv;
                    for pd = 2:np
                        px = (pd-2);
                        tx = ((2.*(v+px))./Dy_i(i,1));
                        dv_np = ki.*dv_np_min_one.*( tx  - 1);
                        dydx_np(:,pd) = dydx_np(:,pd) + dv_np;
                        dv_np_min_one = dv_np;
                    end
                end
            end
            
            if nargout > 2
                % first-order partial derivatives
                fpdy_dymax_i(:,i) = v./Dy_i(i,1);
                fpdy_dymin_i(:,i)  = -v./Dy_i(i,1);
                if i == 1
                    fpdy_dymin_i(:,i)  = 1 - (v./Dy_i(i,1));
                end
                ri = c(i,1).*v.*((v./Dy_i(i,1)) - 1);
                ti = ri;
                if base~="nat"
                    ti = log(b_i(i)).*ti;
                end
                ai = (x - delta_x_i(i,1)).*ti;
                fpdy_ci(:,i) = c(i,1).*ai;
                fpdy_ddelta_x_i(:,i) = -alpha_i(i,1).*ti;
                fpdy_dalpha_i(:,i) = ai;
                fpdy_dlambda_i(:,i) = (2./Dx_i(i,1)).*ai;
                fpdy_dxmax_i(:,i) = (-alpha_i(i,1)./Dx_i(i,1)).*ai;
                fpdy_dxmin_i(:,i) = (alpha_i(i,1)./Dx_i(i,1)).*ai;
                if base~="nat"
                    fpdy_db_i(:,i) = (alpha_i(i,1).*ri)./b_i(i);
                else
                    fpdy_db_i(:,i) = (alpha_i(i,1).*ri)./exp(1);
                end
                if p == 8
                jacob_iy_d(:,:,i) = [fpdy_ci(:,i) fpdy_db_i(:,i) fpdy_dlambda_i(:,i) ...
                    fpdy_dxmax_i(:,i) fpdy_dxmin_i(:,i) fpdy_ddelta_x_i(:,i) ...
                    fpdy_dymax_i(:,i) fpdy_dymin_i(:,i)];
                elseif p == 7
                    jacob_iy_d(:,:,i) = [fpdy_db_i(:,i) fpdy_dlambda_i(:,i) ...
                        fpdy_dxmax_i(:,i) fpdy_dxmin_i(:,i) fpdy_ddelta_x_i(:,i) ...
                        fpdy_dymax_i(:,i) fpdy_dymin_i(:,i)];
                elseif p == 6
                    jacob_iy_d(:,:,i) = [fpdy_dlambda_i(:,i) ...
                        fpdy_dxmax_i(:,i) fpdy_dxmin_i(:,i) fpdy_ddelta_x_i(:,i) ...
                        fpdy_dymax_i(:,i) fpdy_dymin_i(:,i)];
                end
            end
        end
        if errcomp == true
            for i = 1:n
                jacob_ie_d(:,:,i) = -jacob_iy_d(:,:,i);
                jacob_iess_d(:,:,i) = (e).* jacob_ie_d(:,:,i);
            end
        end
        
        if nargout > 2
            % 1 x p x n = n x p
            tmpy = sum(jacob_iy_d);
            tmpe = sum(jacob_ie_d);
            tmpess = sum(jacob_iess_d);
            for i = 1:n
                jacoby(i,:) = tmpy(1,:,i);
                jacobe(i,:) = tmpe(1,:,i);
                jacobess(i,:) = tmpess(1,:,i);
            end
            
            %n: p x p == n x p x p
            for i =1:n
                hessy(i,:,:) = jacoby(i,:)'*jacoby(i,:);
                hesse(i,:,:) = jacobe(i,:)'*jacobe(i,:);
                hessess(i,:,:) = jacobess(i,:)'*jacobess(i,:);
            end
            
            % pacakage Jacobians and Hessians
            JH.e = e;
            JH.jacob_iy_d = jacob_iy_d;
            JH.jacob_ie_d = jacob_ie_d;
            JH.jacob_iess_d = jacob_iess_d;
            JH.jacoby = jacoby;
            JH.jacobe = jacobe;
            JH.jacobess = jacobess;
            JH.hessy = hessy;
            JH.hesse = hesse;
            JH.hessess = hessess;
        end
        
        % convert to column-vector: n x 1,
        % if in row-vector form
        if isrow(y)
            y = y';
        end
        
        
        % |oasomefun@futa.edu.ng| 2020.
    end

%% equal Interval
    function [y,dydx_np,JH] = nlsig_eq(x,iopts,np,ry)
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
        % iopts: struct, each element can be scalar
        %
        % vector
        % iopts.shape = 1;
        % iopts.lambda = 6; 
        % 
        % scalar
        % iopts.n = 1;
        % iopts.base = "nat";
        % iopts.epsil = 0;
        % iopts.xmax =  1;
        % iopts.xmin = -1;
        % iopts.ymax =  1;
        % iopts.ymin = -1;
        %
        % Outputs:
        % y: scalar | vector, veclen_x x 1
        % dy_dx: scalar | vector, veclen_x x 1
        % d2y_dx2 : scalar | vector, veclen_x x 1
        %
        % JH: Jacobian-Hessian dat. structure
        % jacobian ordering structure
        % [dbase_i dlambda_i dxmax_i dxmin_i ddelta_x_i dymax_i dymin_i];
        %
        % jacob_i[y,e,E]_d | tensor, (d x p xn)
        % jacob[y,e,E] | matrix, (n x p)
        % hess[y,e,E] | tensor (n x p x p)
        
        
        % Copyright:
        % |oasomefun@futa.edu.ng| 2020.
        
        errcomp = true;
        if nargin < 4
            ry = 0;
            errcomp = false;
        end
        
        if isrow(x)
            % make it column vector
            x = x';
        end
        veclen_x = numel(x);
        vecsize_x = size(x);
        
        % fixed parameters, always unity
        cigma = 1;
        % beta = 1;
        gamma =  1; % 2^beta - cigma;
        
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
            assert(isnumeric(shape),...
                "shape is either increasing(1) or decreasing(-1).");
            if numel(shape) == 1
                shape = shape.*ones(n,1);
            end
            % exponential input direction logic
            c = zeros(n,1);
            for id = 1:n
                if shape(id) >= 0
                    shape(id) = 1; % shape == 's'
                else
                    shape(id) = -1; % shape == 'z'
                end
                c(id) = -shape(id);
            end
            req_size = [n, 1];
            % do they meet the expected vector size
            reqsz_msg = "Hi! correct your inputs."+...
                "Array size for shape"+...
                "and lambda should be "+num2str(n)+" by 1.";
            assert(isequal(size(c),req_size), reqsz_msg)
        catch
            % "s" (default), "z"
            e_msg = "sigmoid shape erroneous. falling back to increasing shape.\n";
            fprintf(e_msg);
            % shape = 's';
            c = -1*ones(n,1);
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

        
        try % fixed/adaptive growth-rate constant
            lambda = iopts.lambda;
            if numel(lambda) == 1
                lambda = lambda*ones(n,1);
            end
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
        req_size2 = [n 1];
        constrchk = iopts.check_constraints;
        % do they meet the expected vector size
        reqsz_msg = "Hi! correct your inputs."+...
            "Array size for x(min, max), y(min, max) "+...
            "and lambda should be "+num2str(n)+" by 1.";
        
        assert(isequal(size(iopts.ymax),req_size), reqsz_msg)
        assert(isequal(size(iopts.xmax),req_size), reqsz_msg)
        assert(isequal(size(iopts.ymin),req_size), reqsz_msg)
        assert(isequal(size(iopts.xmin),req_size), reqsz_msg)
        assert(isequal(size(iopts.lambda),req_size)...
            || isequal(size(iopts.lambda),req_size2), reqsz_msg)
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
        end
        
        %% Main
        % quantize or partition the input-output space
        % into equally divided n intervals.
        Dy =(ymax-ymin)/n; % = Dy_i
        Dx =(xmax-xmin)/n; % = Dx_i
        
        % set alpha and delta as a function of input space
        alpha_i = lambda.*(2/Dx);
        
        % x inflection points (peak) of each i
        delta_x_i=zeros(n,1);
        
        % partial output and partial output derivative of each i w.r.t x
        % v_i = zeros(n,veclen_x);
        % dv_i = zeros(n,veclen_x);
        
        % output and derivative of each i w.r.t x
        y = ymin*ones(vecsize_x); %ymin_i(1)*ones(veclen_x,1);
        if errcomp == true
            e = zeros(vecsize_x);
        end
        dy_dx = zeros(vecsize_x);
        % output-derivatives array
        dydx_np = zeros(veclen_x,np);
        
        fpdy_dymax = zeros(vecsize_x);
        fpdy_dymin = zeros(vecsize_x); %#ok<PREALL>
        fpdy_ddelta_x_i = zeros(veclen_x,n);
        fpdy_dalpha_i = zeros(veclen_x,n);
        fpdy_ci = zeros(veclen_x,n);
        fpdy_dlambda_i = zeros(veclen_x,n);
        fpdy_db = zeros(vecsize_x);
        fpdy_dxmax = zeros(vecsize_x);
        fpdy_dxmin = zeros(vecsize_x); %#ok<PREALL>
        
        p = iopts.p;
        assert( p<=7 && p>=5, 'p is either 5, 6 or 7 params.' )
        jacob_iy_d = zeros(veclen_x,p,n);
        if errcomp == true
            jacob_ie_d = zeros(veclen_x,p,n);
            jacob_iess_d = zeros(veclen_x,p,n);
        end
        jacoby = zeros(n,p);
        jacobe = jacoby;
        jacobess = jacoby;
        hessy = zeros(n,p,p);
        hesse = hessy;
        hessess = hessy;
        
        for i=1:n
            delta_x_i(i,1) = xmin + (Dx*(i-0.5));
            
            % input to base exponential-function
            u_i = c(i,1).*alpha_i(i,1).*(x-delta_x_i(i,1));
            
            % output = sum of each ith partial outputs
            if base == "nat"
                v = Dy./(cigma + gamma.*exp(u_i));
            elseif base~="nat"
                v = Dy./(cigma + gamma.*b_i.^(u_i));
            end
            % debug
            % fprintf("%g\n",v);
            y = y + v;
            if errcomp == true
                e = ry - y;
            end
            
            if nargout > 1
                % output-derivative = sum of each ith partial output-derivatives
                ki = c(i,1).*alpha_i(i,1);
                if base~="nat"
                    ki = log(b_i).*ki;
                end
                
                % output 1st to np-th derivatives
                % pacakage Output-Derivatives
                
                % First output-derivative
                pd = 1;
                vDy = (v./Dy);
                dv = ki.*v.*( vDy  - 1 );
                dy_dx = dy_dx + dv;
                % de_dx = de_dx - dv;
                
                dy_dx = dy_dx + dv;
                dv_np = dv;
                dydx_np(:,pd) = dydx_np(:,pd) + dv_np;
                
                % output-second-derivatives
                %d2v = ki.*dv.*( 2.*vDy - 1 );
                %d2y_dx2 = d2y_dx2 + d2v;
                %d2e_dx2 = d2e_dx2 - d2v;
                
                if np > 1
                    % output 2nd to np-th derivatives
                    dv_np_min_one = dv;
                    for pd = 2:np
                        px = (np-2);
                        tx = ((2.*(v+px))./Dy);
                        dv_np = ki.*dv_np_min_one.*( tx  - 1);
                        dydx_np(:,pd) = dydx_np(:,pd) + dv_np;
                        dv_np_min_one = dv_np;
                    end
                end
            end
            
            if nargout > 2
                % first-order partial derivatives
                fpdy_dymax = fpdy_dymax + (v);
                % fpdy_dymin = fpdy_dymin + -(v./Dy);
                ri = c(i,1).*v.*((v./Dy) - 1);
                ti = ri;
                if base~="nat"
                    ti = log(b_i).*ti;
                end
                ai = (x - delta_x_i(i,1)).*ti;
                
                fpdy_ci(:,i) = c(i,1).*ai; 
                fpdy_ddelta_x_i(:,i) = -1.*alpha_i(i,1).*ti;
                fpdy_dalpha_i(:,i) = ai;
                fpdy_dlambda_i(:,i) = (2./Dx).*ai;
                
                fpdy_dxmax = fpdy_dxmax  +  ...
                    ((-1).*(alpha_i(i,1)).*ai);
                % fpdy_dxmin = fpdy_dxmin + ...
                % ((1).*(alpha_i(i,1)./(n.*Dx)).*ai);
                
                fpdy_db = fpdy_db + (alpha_i(i,1).*ai);
                
            end
            
        end
        
        if nargout > 2
            fpdy_dymax = fpdy_dymax./(n*Dy);
            fpdy_dymin  = 1 - fpdy_dymax;
            fpdy_dxmax =  fpdy_dxmax./(n*Dx);
            fpdy_dxmin =  -fpdy_dxmax;
            if base~="nat"
                fpdy_db = (fpdy_db./(b_i.*log(b_i)));
            else
                fpdy_db = (fpdy_db./(exp(1)));
            end
            
            for i =1:n
                if p == 7
                    jacob_iy_d(:,:,i) = [fpdy_ci(:,i) fpdy_db fpdy_dlambda_i(:,i) ...
                        fpdy_dxmax fpdy_dxmin ...
                        fpdy_dymax fpdy_dymin];
                elseif p == 6
                    jacob_iy_d(:,:,i) = [fpdy_db fpdy_dlambda_i(:,i) ...
                        fpdy_dxmax fpdy_dxmin ...
                        fpdy_dymax fpdy_dymin];
                elseif p == 5
                    jacob_iy_d(:,:,i) = [fpdy_dlambda_i(:,i) ...
                        fpdy_dxmax fpdy_dxmin ...
                        fpdy_dymax fpdy_dymin];
                end
                
                jacob_ie_d(:,:,i) = -jacob_iy_d(:,:,i);
                % assumes Ess is 0.5*Ess
                jacob_iess_d(:,:,i) = (e).*jacob_ie_d(:,:,i);
            end
            % 1 x p x n = n x p
            tmpy = sum(jacob_iy_d);
            tmpe = sum(jacob_ie_d);
            tmpess = sum(jacob_iess_d);
            for i = 1:n
                jacoby(i,:) = tmpy(1,:,i);
                jacobe(i,:) = tmpe(1,:,i);
                jacobess(i,:) = tmpess(1,:,i);
            end
            
            %n: p x p == n x p x p
            for i =1:n
                hessy(i,:,:) = jacoby(i,:)'*jacoby(i,:);
                hesse(i,:,:) = jacobe(i,:)'*jacobe(i,:);
                hessess(i,:,:) = jacobess(i,:)'*jacobess(i,:);
            end
            
            % pacakage Jacobians and Hessians
            JH.e = e;
            JH.jacob_iy_d = jacob_iy_d;
            JH.jacob_ie_d = jacob_ie_d;
            JH.jacob_iess_d = jacob_iess_d;
            JH.jacoby = jacoby;
            JH.jacobe = jacobe;
            JH.jacobess = jacobess;
            JH.hessy = hessy;
            JH.hesse = hesse;
            JH.hessess = hessess;
        end
        
        % convert to column-vector: n*1,
        % if in row-vector form
        if isrow(y)
            y = y';
        end
        
        
        % |oasomefun@futa.edu.ng| 2020.
    end

% |oasomefun@futa.edu.ng| 2020.
end