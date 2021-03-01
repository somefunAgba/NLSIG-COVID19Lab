function [lnnet] = ...
    solvopts(x_data,y_data,optsolver,solp,sbounds,lubnds)

fprintf("Fit In Progress: ...");
% INIT. LNNET
lnnet = lnn;
% setup arch
J = numel(solp.n);
eq = 0; np = 1;
% expects D x L
szx = size(x_data);
szy = size(y_data);

if szy(1)==szx(1)
    lnnet.archdims(eq,np,szx(2),J,szx(1));
else
    lnnet.archdims(eq,np,szx(1),J,szx(2));
end
lnnet.archtype(1,1,0,0);
% collate data
lnnet.collate(x_data,y_data);


% sbounds:
% startingbounds enforces starting x-y:min value constraint.

% Create initial guess and bounds
% of the nlsig/lnn optimization variables

% empty struct for best_sol and fit found
% using an ensemble grid of lambda growth-rates.
bsolpvec_fit = struct([]);
bfitstats = struct([]);

av = 0.01;

for trys = 1:7 % 6: days of creation
    
    basevar = false;
    shapevar = false;
    
    
    for j = 1:lnnet.J
                
        % shape
        if numel(solp.shape{j}) == 1 && solp.n{j} > 1
            solp.shape{j} = solp.shape{j}*ones(solp.n{j},1);
        end
        if shapevar == false
            for  i = 1:solp.n{j}
                lbsolp.shape{j} = solp.shape{j}(i)-av;
                ubsolp.shape{j} = solp.shape{j}(i)+av;
            end
        else
            lbsolp.shape{j} = -1.2*ones(solp.n{j},1);
            ubsolp.shape{j} = 1.2*ones(solp.n{j},1);
        end
        
        % base
        if basevar == false
            solp.base{j} = "nat";
            lbsolp.base{j} = exp(1)-av;
            ubsolp.base{j} = exp(1)+av;
        else
            lbsolp.base{j} = 2*ones(solp.n{j},1);
            ubsolp.base{j} = 20*ones(solp.n{j},1);
            solp.base{j} = 10*ones(solp.n{j},1);
        end
        
        % lambda
        b = 16;
        a = 1e-6;
        lbsolp.lambda{j} = a*ones(solp.n{j},1);
        ubsolp.lambda{j} = b*ones(solp.n{j},1);
        solp.lambda{j} = a + (b-a).*rand(solp.n{j},1);
  
        % xpks       
        % peaks bounds.
        % lubnds imply:
        if lubnds == true && eq == 0
            for  i = 1:solp.n{j}
                if  i == solp.n{j}
                    if solp.xpks{j}(i) >= 0
                        lbsolp.xpks{j}(i) = 0.5*solp.xpks{j}(i);
                        ubsolp.xpks{j}(i) = 1.2*solp.xpks{j}(i);
                    else
                        ubsolp.xpks{j}(i) = 0.5*solp.xpks{j}(i);
                        lbsolp.xpks{j}(i) = 1.2*solp.xpks{j}(i);
                    end
                else
                    if solp.xpks{j}(i) >= 0
                        lbsolp.xpks{j}(i) = 0.5*solp.xpks{j}(i);
                        ubsolp.xpks{j}(i) = 1.2*solp.xpks{j}(i);
                    else
                        ubsolp.xpks{j}(i) = 0.5*solp.xpks{j}(i);
                        lbsolp.xpks{j}(i) = 1.2*solp.xpks{j}(i);
                    end
                end
            end
        end
        
        % xmin
        % sbounds: starting bounds
        for i = 1:solp.n{j}
            if i==1 && sbounds == true
                lbsolp.xmin{j}(i) = solp.xmin{j}(i);
                ubsolp.xmin{j}(i) = solp.xmin{j}(i) + av;
            end
            if i > 1 && lubnds == true
                lbsolp.xmin{j}(i) = solp.xmin{j}(i);
                ubsolp.xmin{j}(i) = solp.xmin{j}(i) + av;
            end
        end
        
        % xmax
        for i = 1:solp.n{j}
            if i < solp.n{j}  && lubnds == true
                lbsolp.xmax{j}(i) = solp.xmax{j}(i);
                ubsolp.xmax{j}(i) = solp.xmax{j}(i) + av;
            end
            if i == solp.n{j}
                if solp.xmax{j}(i) >= 0
                    lbsolp.xmax{j}(i) = 0.5*solp.xmax{j}(i);
                    ubsolp.xmax{j}(i) = 1.2*solp.xmax{j}(i);
                else
                    ubsolp.xmax{j}(i) = 0.5*solp.xmax{j}(i);
                    lbsolp.xmax{j}(i) = 1.2*solp.xmax{j}(i);
                end
            end
        end
        
        % ymin
        for i = 1:solp.n{j}
            if i==1 && sbounds == true
                lbsolp.ymin{j}(i) = solp.ymin{j}(i);
                ubsolp.ymin{j}(i) = solp.ymin{j}(i) + av;
            end
            if i > 1 && lubnds == true
                lbsolp.ymin{j}(i) = solp.ymin{j}(i);
                ubsolp.ymin{j}(i) = solp.ymin{j}(i) + av;
            end
            
        end
        
        
        % ymax
        for i = 1:solp.n{j}
            if i < solp.n{j} && lubnds == true
                lbsolp.ymax{j}(i) = solp.ymax{j}(i);
                ubsolp.ymax{j}(i) = solp.ymax{j}(i) + av;
            end
            if i == solp.n{j}
                if solp.ymax{j}(i) >= 0
                    lbsolp.ymax{j}(i) = 0.5*solp.ymax{j}(i);
                    ubsolp.ymax{j}(i) = 1.2*solp.ymax{j}(i);
                else
                    ubsolp.ymax{j}(i) = 0.5*solp.ymax{j}(i);
                    lbsolp.ymax{j}(i) = 1.2*solp.ymax{j}(i);
                end
            end
        end
        
    end
    
    % Solver-based optimization
    
    % set solp structure
    lnnet = lnnet.setopts(solp,2);
    % unroll solp and its bounds
    [lbvec, ubvec] = lnnet.sol_unroll(lbsolp,ubsolp);
    x0vec = lnnet.solpvec;
    
    
    % define objective function
    % type: 0:E | 1:SSE
    if optsolver == "lsqnonlin-tr" || optsolver == "lsqnonlin-lm"
        objfun = @(solpvec) lnnet.objfeval2(solpvec,0);
    elseif optsolver == "fmincon-tr" || optsolver == "fmincon-ipt"
        objfun = @(solpvec) lnnet.objfeval3(solpvec,1);
    end
    
    
    % Setup Solver
    if optsolver == "lsqnonlin-tr" || optsolver == "lsqnonlin-lm"
        % debug:
        %         newoptins.CheckGradients = false;
        %         newoptins.FiniteDifferenceType = 'forward';
        %         newoptins.FunctionTolerance = 1e-2;
        %         newoptins.OptimalityTolerance = 1e-6;
        %         newoptins.StepTolerance = 1e-6;
        newoptins = optimoptions(@lsqnonlin);
        newoptins.Display = 'off'; % debug: 'iter'
        newoptins.SpecifyObjectiveGradient = true;
        if optsolver == "lsqnonlin-tr"
            newoptins.Algorithm = 'trust-region-reflective';
        elseif optsolver == "lsqnonlin-lm"
            newoptins.Algorithm = 'levenberg-marquardt';
        else
            error('Oops!: use either: lsqnonlin-tr OR lsqnonlin-lm');
        end
        newoptins.UseParallel = true;     
        newoptins.Diagnostics = 'off';
    elseif optsolver == "fmincon-tr" || optsolver == "fmincon-ipt"
        newoptins = optimoptions('fmincon');
        newoptins.Display = 'off'; % debug: 'iter'
        newoptins.SpecifyObjectiveGradient= true;
        if optsolver == "fmincon-tr"
            % MATLAB's FMINCON TR: does not support equal lb and ub
            newoptins.Algorithm = 'trust-region-reflective';
            newoptins.HessianFcn = 'objective';
        elseif optsolver == "fmincon-ipt"
            newoptins.Algorithm = 'interior-point';
            newoptins.HessianFcn = @hessianfcn;
        else
            error('Oops!: use either: fmincon-tr OR fmincon-ipt');
        end
        newoptins.UseParallel = true;
        % debug:
        % newoptins.CheckGradients = false;
    end
    
    
    if optsolver == "lsqnonlin-tr" || optsolver == "lsqnonlin-lm"
        if optsolver == "lsqnonlin-tr"
            [solpvec_fit,errnorm,~,~,~,~,~] = ...
                lsqnonlin(objfun,x0vec,...
                lbvec,ubvec,newoptins); %#ok<ASGLU>
        elseif optsolver == "lsqnonlin-lm"
            [solpvec_fit,errnorm,~,~,~,~,~] = ...
                lsqnonlin(objfun,x0vec,...
                [],[],newoptins); %#ok<ASGLU>
        end
    elseif optsolver == "fmincon-tr" || optsolver == "fmincon-ipt"
        [solpvec_fit,errnorm,~,~,lambda,grad,hessian] = ...
            fmincon(objfun,x0vec,[],[],[],[],...
            lbvec,ubvec,[],newoptins);%#ok<ASGLU>
    end
    
    % Predict using the model's optimized parameters
    lnnet = lnnet.sol_roll(solpvec_fit);
    lnnet = lnnet.predict();
    % Compute fitness stats
    lnnet = lnnet.stats();
    
    % check for best fit by using 
    % a ensemble of multi-start lambdas.
    % wrt to the maximum error/distance.
    if trys == 1
        bsolpvec_fit = solpvec_fit;
        bfitstats = lnnet.fitstats;
    else
        if max(lnnet.fitstats.normDc) < max(bfitstats.normDc)
            bsolpvec_fit = solpvec_fit;
            bfitstats = lnnet.fitstats;
        end
%         if max(lnnet.fitstats.R2a) > max(bfitstats.R2a)
%             bsolpvec_fit = solpvec_fit;
%             bfitstats = lnnet.fitstats;
%         end
    end   
end

% SAVE best-fit est. params
lnnet = lnnet.sol_roll(bsolpvec_fit);
lnnet.solpO = lnnet.solp;
% Predict using best-fit est. params
lnnet = lnnet.predict();
% Compute best-fitness stats
lnnet = lnnet.stats();
lnnet.fitstatsO = lnnet.fitstats;
fprintf(" Done.\n");

% DKW CI on BEST-FIT SOLUTION OF EST. PARAMS

fprintf("DKW_LB: ...");
[solpLB,stats_fitLB] = ...
    dkw_opts(lnnet,-1,optsolver,newoptins,lbsolp,ubsolp,sbounds,lubnds);
lnnet.solpL = solpLB;
lnnet.fitstatsLB = stats_fitLB;
fprintf(" Completed.\n");

fprintf("DKW_UB: ...");
[solpUB,stats_fitUB] = ...
    dkw_opts(lnnet,1,optsolver,newoptins,lbsolp,ubsolp,sbounds,lubnds);
lnnet.solpH = solpUB;
lnnet.fitstatsUB = stats_fitUB;
fprintf(" Completed.\n");

% disp(x0vec); % debug


% FMINCON-IPT HESSIAN FCN HANDLE
    function Hout = hessianfcn(solpvec,~)  %#ok<INUSD>
        % Hessian of objective
        % Hessian of nonlinear inequality constraint
        H = lnnet.Hout;
        % Hg = 2*eye(2);
        Hout = H; % + lambda.ineqnonlin*Hg;
    end

end
%