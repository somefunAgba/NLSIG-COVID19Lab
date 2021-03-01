classdef lnn < handle
    %LNN Logistic Neural Network
    %   General SISO/MISO to SIMO/MIMO case of the NLSIG neural pipeline
    
    properties
        % data: explanatory input patterns: L x D
        Xin;
        % data: actual outcomes: J x D
        RYout;
        % lnn: inferred outcomes: J x D
        Yout;
        % lnn: input layer weights/critics: J x (L+1)
        Win;
        
        % lnn: tune weight bias, w0 can be false (default) or true
        tune_wbias = 0;
        % tune input weight can be false (0) or true (1)
        tune_win = 0;
        
        % lnn: mode for supervised learning, "s" | 1
        % or unsupervised learning, "us" | 0
        lrnmode;
        
        % lnn: mode for regression or classification-based regression
        % : "genreg" | 1 , "classreg" | 0
        fitmode;
        
        %
        L; % number of explanatory inputs
        J; % number of categorical outcomes
        D; % length of data
        N; % array of ns.
        
        %
        batch_size; % default is 1
        type_train; % training type - stochastic (online), batch or mixed
        optimtype; % optimization type (typically gradient-descent)
        isshuffle = false;
        
        % nlsig
        np; % max. order of output derivatives
        eq; % equal or general intervals
        % nlsig neuron options
        nlsigopts;
        p; % number of estimated parameters in each ith partition
        % input est.parameters structure
        solp;
        % fitted solp
        solpO;
        % dkw lower-bnd solp
        solpL;
        % dkw upper-bnd solp
        solpH;
        % vectorized est.parameters structure
        % version 1
        % assumes 1:nj for each p=1:P in each j
        % version 2
        % assumes 1:pi for each i=1:nj in each j
        solpvec;
        % unroll version
        urollvs;
        
        % state placeholder
        x; % input data
        u; % temporal input data
        ry; % correct output data
        
        % D x J
        E; % error output at logistic layer
        Ess; % sum of square error objective at logistic layer
        DYDx; % first derivative of the output of each logistic layer
        DYDxnp;% 1:np-th derivative of the output of each logistic layer
        % JH: jacobian-hessian ds
        JH;
        
        % dj x pnj
        JACLY1; JACLE1; JACLEss1;
        % pnj x pnj
        HESLY1; HESLE1; HESLEss1;
        % j x pnj
        JACLY2; JACLE2; JACLEss2;
        % pnj x pnj
        HESLY2; HESLE2; HESLEss2;
        % 1 x pnj
        JACLY3; JACLE3; JACLEss3;
        % pnj x pnj
        HESLY3; HESLE3; HESLEss3;
        %
        Fout
        Jout;
        Hout;
        
        % D X (L+1) X J
        pDYDW1;pDEDW1;pDEssDW1;
        % J * (L+1)
        pDYDW2; pDEDW2;pDEssDW2;
        % (L+1) x (L+1)
        HESWY;HESWE,HESWEss
        % (L+1) x (J)
        GRADWEss;
        
        % D X J
        pDEssDY;
        pDEssDx;
        
        % dj x lj
        JACWY1; JACWE1; JACWEss1;
        % lj x lj
        HESWY1; HESWE1; HESWEss1;
        % j x lj
        JACWY2; JACWE2; JACWEss2;
        % lj x lj
        HESWY2; HESWE2; HESWEss2;
        % 1 x lj
        JACWY3; JACWE3; JACWEss3;
        % lj x lj
        HESWY3; HESWE3; HESWEss3;
        
        
        % inference frequency;
        chkfreq_validate;
        chkfreq_train;
        
        % fitness stats
        fitstats;
        fitstatsO;
        fitstatsLB;
        fitstatsUB;
        
        % x-Y metrics
        XIR;
        YIR;
        
    end
    
    methods
        
        function obj = archdims(obj,eq,np,L,J,D)
            %ARCHDIMS specify the dimensions of the
            %         lnn input-output architecture
            
            % type of nlsig interval eq;
            % max. order of output derivatives to compute np;
            % number of explanatory inputs L;
            % number of categorical outcomes J;
            % length of data D;
            
            
            obj.eq = eq;
            obj.np = np;
            obj.L = L;
            obj.J = J;
            obj.D = D;
            
            % initialize weights at the input-layer.
            obj.Win = ones((obj.L+1),obj.J);
            obj.Win(1,:) = 0.*ones(1,obj.J);
            
            % initialize nlsig opts
            % Set up options structure
            if obj.eq == 0
                opts = ...
                    struct('n', 1,'shape', 's',...
                    'base', "nat",'lambda', 6,...
                    'xmax', 2, 'xmin', -2,...
                    'xpks', 0, ...
                    'ymax', 1,'ymin', 0, ...
                    'p', 8, 'check_constraints', 0 ...
                    );
            else
                opts = ...
                    struct('n', 1,'shape', 's',...
                    'base', "nat",'lambda', 6,...
                    'xmax', 2, 'xmin', -2,...
                    'ymax', 1,'ymin', 0, ...
                    'p', 7, 'check_constraints', 0 ...
                    );
            end
            obj.p = zeros(obj.J,1);
            obj.nlsigopts = opts;
            for j = 2:obj.J
                obj.nlsigopts(j) = opts;
            end
        end
        
        function obj = archtype(obj,lmode,fmode,tunewbias,tunewin)
            %ARCHTYPE specify further details on lnn architecture type
            
            % tune_wbias: tune weight bias,
            % can be false (0) or true (1)
            % false by default: w0 = 0.
            
            % tune_win: tune input weights,
            % can be false (0) (fixed) or true (1) (optimize/train)
            % false by default: wl = 1.
            
            % lrnmode: mode for supervised learning, "s" | 1
            % or unsupervised learning, "us" | 0
            
            % fitmode: mode for general regression or
            % classification-based regression
            % : "genreg" | 1 , "classreg" | 0
            
            obj.lrnmode = lmode;
            obj.fitmode = fmode;
            obj.tune_wbias = tunewbias;
            obj.tune_win = tunewin;
            
        end
        
        function obj = collate(obj,X,Y)
            %COLLATE collect in-out data for any task
            % for example: training/testing
            
            sizeX = size(X); % expects: (D) x (L)
            if sizeX == size(zeros(obj.L, obj.D))
                X = X';
                sizeX = size(X); % expects: (D) x (L)
            end
            assert(sizeX(2)==obj.L,...
                "column-dims mismatch for input data.")
            assert(sizeX(1)==obj.D,...
                "row-dims mismatch for input data.")
            obj.Xin = X;
            X0 = ones(obj.D,1);
            obj.Xin = [X0 obj.Xin]; % makes (D) x (L+1)
            
            if nargin > 2
                sizeY = size(Y); % expects: (D) x (J)
                if sizeY == size(zeros(obj.J, obj.D))
                    Y = Y';
                    sizeY = size(Y); % expects: (D) x (J)
                end
                assert(sizeY(2)==obj.J,...
                    "column-dims mismatch for input data.")
                assert(sizeY(1)==obj.D,...
                    "row-dims mismatch for input data.")
                assert(sizeX(1)==sizeY(1),...
                    "size-mismatch for input X and ouput Y data.")
                
                if strcmpi(obj.lrnmode,"s") || obj.lrnmode == 1
                    obj.RYout = Y;
                elseif strcmpi(obj.lrnmode,"us") || obj.lrnmode == 0
                    obj.RYout = obj.Xin;
                else
                    error('You made a wrong input!')
                end
            end
            
            obj.Yout = zeros(obj.D,obj.J);
        end
        
        function obj = setopts(obj,solp,urollvs)
            % SETOPTS  set the options of the nlsig:logistic layer
            % input arguments: cell array
            
            % solp should be in this format:
            % the solp DataStructure(DS) used here is
            % a structure of cell arrays:
            % where each j-th cell array represent an output node.
            % an each nodes represent a matrix array of i=1:nj options
            %
            % for compulsorily:
            % n, shape, base, xmin, xmax, xpks, ymin, ymax, lambda
            % and optionally:
            %
            % check_constraints
            
            % est.param solution structure
            obj.solp = solp;
            % vector form of est.param solution structure
            obj.urollvs = 1;
            if nargin > 2
                assert(urollvs==1 || urollvs==2,...
                    "invalid unroll form: valid value is: 1 or 2");
                obj.urollvs = urollvs;
            end
        
            % mimo type: general or equal
%             if obj.eq == 0
%                 obj.p = 8;
%             elseif obj.eq == 1
%                 obj.p = 7;
%             end
            
            
            for j = 1:obj.J
                % Set up options structure
                if obj.eq == 0
                    obj.nlsigopts(j) = ...
                        struct('n', solp.n{j},'shape', solp.shape{j},...
                        'base', solp.base{j},'lambda', solp.lambda{j},...
                        'xmax', solp.xmax{j}, 'xmin', solp.xmin{j},...
                        'xpks', solp.xpks{j}, ...
                        'ymax', solp.ymax{j},'ymin', solp.ymin{j}, ...
                        'p', solp.p{j}, 'check_constraints', 0 ...
                        );
                    obj.p(j) = solp.p{j};
                else
                    obj.nlsigopts(j) = ...
                        struct('n', solp.n{j}, 'shape', solp.shape{j},...
                        'base', solp.base{j}, 'lambda', solp.lambda{j},...
                        'xmax', solp.xmax{j}, 'xmin', solp.xmin{j},...
                        'ymax', solp.ymax{j},'ymin', solp.ymin{j}, ...
                        'p', solp.p{j},'check_constraints', 0 ...
                        );
                    obj.p(j) = solp.p{j};
                end
            end
            
        end
        
        function obj = mimo(obj,skip)
            %SIMO/MIMO = LNN
            
            if skip == false
                obj.E = zeros(obj.D,obj.J);
            end
            obj.Yout =zeros(obj.D,obj.J);
            obj.DYDx = zeros(obj.D,obj.J);
            obj.DYDxnp = zeros(obj.D,obj.np,obj.J);
            
            % compute input derivatives w.r.t y
            obj.pDYDW1 = zeros(obj.D,obj.L+1,obj.J);
            obj.pDEDW1 = zeros(obj.D,obj.L+1,obj.J);
            obj.pDEssDW1 = zeros(obj.D,obj.L+1,obj.J);
            obj.pDEssDx = zeros(obj.D,obj.J);
            
            % IN-OUT PROCESSING
            
            % input layer : D x J
            obj.x = obj.Xin*obj.Win;
            
            % n:logistic layer : D x J
            for j = 1:obj.J
                if skip == false
                    [y,dydx_np,jh] = ...
                        nlsig(obj.x(:,j),obj.eq,...
                        obj.nlsigopts(j),obj.np,obj.RYout(:,j));
                elseif skip == true
                    [y,dydx_np] = ...
                        nlsig(obj.x(:,j),obj.eq,...
                        obj.nlsigopts(j),obj.np);
                end
                
                % append outputs.
                obj.Yout(:,j) = y;
                obj.DYDx(:,j) = dydx_np(:,1);
                obj.DYDxnp(:,:,j) = dydx_np;
                
                if skip == false
                    % error: obj.RYout - obj.Yout;
                    obj.E(:,j) = jh.e;
                    % JH DS.
                    obj.JH{j} = jh;
                end
                
            end
            
            
            % JACOBIAN-HESSIAN PROCESSING
            
            if skip == false
                
                % scalar SSE output
                % D x J to 1 x J to 1 x 1
                obj.Ess = 0.5.*sum(sum(obj.E.^2));
                % D x J
                obj.pDEssDY = -obj.E;
                % D * J
                obj.pDEssDx = obj.pDEssDY.*obj.DYDx;
                % n:logistic-layer J-H w.r.t y, e and ess
                
                % total number of output components
                Dj = obj.D*obj.J;
                
                % total number of est. parameters
                if obj.eq == 0
                    PNj = sum(obj.N.*obj.p);
                elseif obj.eq == 1
                    PNj = 0;
                    for j = 1:obj.J
                        if obj.p(j) == 7
                            PNj = PNj + (obj.p(j)-2) + (2*obj.N(j));
                        elseif obj.p(j) == 6
                            PNj = PNj + (obj.p(j)-1) + (1*obj.N(j));
                        elseif obj.p(j) == 5
                            PNj = PNj + obj.p(j);
                        end
                        % Pnj = (obj.p-2) + (2*sum(obj.N));
                    end
                end
                
                % dj x pnj
                obj.JACLY1 = zeros(Dj, PNj);
                obj.JACLE1 = zeros(Dj, PNj);
                obj.JACLEss1 = zeros(Dj, PNj);
                % j x pnj
                obj.JACLY2 = zeros(obj.J, PNj);
                obj.JACLE2 = zeros(obj.J, PNj);
                obj.JACLEss2 = zeros(obj.J, PNj);
                % 1 x pnj
                obj.JACLY3 = zeros(1, PNj);
                obj.JACLE3 = zeros(1, PNj);
                obj.JACLEss3 = zeros(1, PNj);
                
                if obj.urollvs == 1
                    % assumes 1:nj ordering for each p=1:P in each j
                    ex = 0;
                    for j = 1:obj.J
                        fp = (j-1)*obj.D + 1;
                        lp = j*obj.D;
                        
                        sx = ex + 1;
                        ex = ex + obj.N(j);
                        for id = 1:obj.p(j)
                            obj.JACLY1(fp:lp,sx:ex) = ...
                                obj.JH{1,j}.jacob_iy_d(:,id,1:obj.N(j));
                            obj.JACLE1(fp:lp,sx:ex) = ...
                                obj.JH{1,j}.jacob_ie_d(:,id,1:obj.N(j));
                            obj.JACLEss1(fp:lp,sx:ex) = ...
                                obj.JH{1,j}.jacob_iess_d(:,id,1:obj.N(j));
                            %
                            obj.JACLY2(j,sx:ex) = ...
                                obj.JH{1,j}.jacoby(:,id)';
                            obj.JACLE2(j,sx:ex) = ...
                                obj.JH{1,j}.jacobe(:,id)';
                            obj.JACLEss2(j,sx:ex) = ...
                                obj.JH{1,j}.jacobess(:,id)';
                            %
                            if id < obj.p(j)
                                sx = sx + obj.N(j);
                                ex = ex + obj.N(j);
                            end
                        end
                    end
                elseif obj.urollvs == 2
                    % assumes 1:pi ordering for each i=1:nj in each j
                    sx = 1; ex = obj.p(1);
                    for j = 1:obj.J
                        fp = (j-1)*obj.D + 1;
                        lp = j*obj.D;
                        for id = 1:obj.nlsigopts(j).n
                            obj.JACLY1(fp:lp,sx:ex) = ...
                                obj.JH{1,j}.jacob_iy_d(:,:,id);
                            obj.JACLE1(fp:lp,sx:ex) = ...
                                obj.JH{1,j}.jacob_ie_d(:,:,id);
                            obj.JACLEss1(fp:lp,sx:ex) = ...
                                obj.JH{1,j}.jacob_iess_d(:,:,id);
                            %
                            obj.JACLY2(j,sx:ex) = ...
                                obj.JH{1,j}.jacoby(id,:);
                            obj.JACLE2(j,sx:ex) = ...
                                obj.JH{1,j}.jacobe(id,:);
                            obj.JACLEss2(j,sx:ex) = ...
                                obj.JH{1,j}.jacobess(id,:);
                            %
                            sx = sx + obj.p(j);
                            if id == obj.nlsigopts(j).n && j~=obj.J
                                ex = ex + obj.p(j+1);
                            else
                                ex = ex + obj.p(j);
                            end
                        end
                    end
                end
                % 1 x pnj
                obj.JACLY3 = sum(obj.JACLY1);
                obj.JACLE3 = sum(obj.JACLE1);
                obj.JACLEss3 = sum(obj.JACLEss1);
                
                % pnj x pnj
                obj.HESLY1 = obj.JACLY1'*obj.JACLY1;
                obj.HESLE1 = obj.JACLE1'*obj.JACLE1;
                obj.HESLEss1 = obj.JACLEss1'*obj.JACLEss1;
                
                % pnj x pnj
                obj.HESLY2 = obj.JACLY2'*obj.JACLY2;
                obj.HESLE2 = obj.JACLE2'*obj.JACLE2;
                obj.HESLEss2 = obj.JACLEss2'*obj.JACLEss2;
                
                % pnj x pnj
                obj.HESLY3 = obj.JACLY3'*obj.JACLY3;
                obj.HESLE3 = obj.JACLE3'*obj.JACLE3;
                obj.HESLEss3 = obj.JACLEss3'*obj.JACLEss3;
                
                
                % in:weight-layer J-H w.r.t y, e and ess
                % de_dx = de_dy x dy_dx;
                % de_dy = -e; dx_dw = xin;
                % de_dw = de_dx .* dx_dw
                
                % total number of est. w parameters
                Lj = (obj.J)*(obj.L+1);
                
                for j = 1:obj.J
                    % D x (L+1) x J : jacobian
                    for l = 1:obj.L+1
                        obj.pDYDW1(:,l,j) = obj.DYDx(:,j).*obj.Xin(:,l);
                        obj.pDEDW1(:,l,j) = -obj.pDYDW1(:,l,j);
                        obj.pDEssDW1(:,l,j) = obj.pDEssDx(:,j).*obj.Xin(:,l);
                    end
                end
                
                % (L+1) x J : gradient
                for j = 1:obj.J
                    % ((L+1) x D) * (D x J)
                    obj.GRADWEss(:,j) = obj.pDEssDW1(:,:,j)'*obj.E(:,j);
                end
                
                % J x (L+1) :Jacobian
                obj.pDYDW2 = obj.DYDx'*obj.Xin;
                % J * (L+1)
                obj.pDEDW2 = -obj.pDYDW2;
                % J * (L+1)
                obj.pDEssDW2= obj.pDEssDx'*obj.Xin;
                
                % Dj x Lj :Jacobian
                obj.JACWY1 = zeros(Dj, Lj);
                obj.JACWE1 = zeros(Dj, Lj);
                obj.JACWEss1 = zeros(Dj, Lj);
                % J x Lj :Jacobian
                obj.JACWY2 = zeros(obj.J, Lj);
                obj.JACWE2 = zeros(obj.J, Lj);
                obj.JACWEss2 = zeros(obj.J, Lj);
                % 1 x Lj :Jacobian
                obj.JACWY3 = zeros(1, Lj);
                obj.JACWE3 = zeros(1, Lj);
                obj.JACWEss3 = zeros(1, Lj);
                
                sx = 1; ex = obj.L+1;
                for j = 1:obj.J
                    fp = (j-1)*obj.D + 1;
                    lp = j*obj.D;
                    obj.JACWEss1(fp:lp,sx:ex) = obj.pDEssDW1(:,:,j);
                    obj.JACWEss2(j,sx:ex) = obj.pDEssDW2(j,:);
                    %
                    obj.JACWE1(fp:lp,sx:ex) = obj.pDEDW1(:,:,j);
                    obj.JACWE2(j,sx:ex) = obj.pDEDW2(j,:);
                    %
                    obj.JACWY1(fp:lp,sx:ex) = obj.pDYDW1(:,:,j);
                    obj.JACWY2(j,sx:ex) = obj.pDYDW2(j,:);
                    %
                    sx = sx + obj.L+1;
                    ex = ex + obj.L+1;
                end
                obj.JACWY3 = sum(obj.JACWY1);
                obj.JACWE3 = sum(obj.JACWE1);
                obj.JACWEss3 = sum(obj.JACWEss1);
                
                % Lj x Lj : Hessian
                obj.HESWEss1 = (obj.JACWEss1)'*obj.JACWEss1;
                obj.HESWE1 = (obj.JACWE1)'*obj.JACWE1;
                obj.HESWY1 = (obj.JACWY1)'*obj.JACWY1;
                % Lj x Lj : Hessian
                obj.HESWEss2 = (obj.JACWEss2)'*obj.JACWEss2;
                obj.HESWE2 = (obj.JACWE2)'*obj.JACWE2;
                obj.HESWY2 = (obj.JACWY2)'*obj.JACWY2;
                % (L+1) x (L+1) : Hessian
                obj.HESWY3 = obj.JACWY3'*obj.JACWY3;
                obj.HESWE3 = obj.JACWE3'*obj.JACWE3;
                obj.HESWEss3 = obj.JACWEss3'*obj.JACWEss3;
                % (L+1) x (L+1) : Hessian
                obj.HESWEss = (obj.pDEssDW2)'*obj.pDEssDW2;
                obj.HESWE = (obj.pDEDW2)'*obj.pDEDW2;
                obj.HESWY = (obj.pDYDW2)'*obj.pDYDW2;
            end
            
            %disp(''); % debug
            
        end
        
        function obj = errmdl(obj,solp)
            %ERRMDL computes error fit of lnn to data
            % involves estimating parameters that
            % ensures we have a correct output
            
            if nargin > 1
                obj = setopts(obj,solp);
            end
            obj = mimo(obj,false);
            
        end
        
        function [lbsolpvec, ubsolpvec] = ...
                sol_unroll(obj,lbsolp,ubsolp)
            %SOL_UNROLL
            % unrolls solution structure to vector form
            % for optimization
            
            obj.N = zeros(obj.J,1);
            for idx = 1:obj.J
                obj.N(idx) = obj.solp.n{idx};
            end
            
            obj.solpvec = transf2vec(obj.solp,obj.urollvs,obj.eq,...
                obj.J,obj.N,obj.p);
            
            % lb
            if nargin > 1
                lbsolpvec = transf2vec(lbsolp,obj.urollvs,obj.eq,...
                    obj.J,obj.N,obj.p);
            end
            % ub
            if nargin > 2
                ubsolpvec = transf2vec(ubsolp,obj.urollvs,obj.eq,...
                    obj.J,obj.N,obj.p);
            end
            
            function solpvec = transf2vec(solp,urollvs,eq,J,N,p)
                if eq == 0
                    pnj = sum(N.*p);
                elseif eq == 1
                    pnj = 0;
                    for j = 1:J
                        if p(j) == 7
                            pnj = pnj + (p(j)-2) + (2*N(j));
                        elseif p(j) == 6
                            pnj = pnj + (p(j)-1) + (1*N(j));
                        elseif p(j) == 5
                            pnj = pnj + p(j);
                        end
                    % pnj = (p-2) + (2*sum(N));
                    end
                end
                solpvec = zeros(pnj,1);
                % eq 0 order: base,lambda,xmax,xmin,xpks,ymax,ymin
                % eq 1 order: base,lambda,xmax,xmin,ymax,ymin

                % first vector format
                % for each j: each pj :1..nj
                endx = 0;
                if eq == 0
                    for idxx = 1:J
                        
                        if p(idxx) == 8
                            % shape
                            tempr = solp.shape{idxx};
                            if numel(tempr) == 1 && N(idxx) > 1
                                tempr = tempr*ones(N(idxx),1);
                            end
                            for ndx = endx+1:endx+N(idxx)
                                solpvec(ndx) = tempr(ndx-endx);
                            end
                            endx = endx+N(idxx);
                        end
                              
                        if p(idxx) >= 7
                            % base
                            tempr = solp.base{idxx};
                            if ~isnumeric(tempr)
                                if tempr=="nat"
                                    tempr = exp(1);
                                end
                            end
                            if numel(tempr) == 1 && N(idxx) > 1
                                tempr = tempr*ones(N(idxx),1);
                            end
                            for ndx = endx+1:endx+N(idxx)
                                solpvec(ndx) = tempr(ndx-endx);
                            end
                            endx = endx+N(idxx);
                        end
                        
                        % lambda
                        tempr = solp.lambda{idxx};
                        for ndx = endx+1:endx+N(idxx)
                            solpvec(ndx) = tempr(ndx-endx);
                        end
                        endx = endx+N(idxx);
                        
                        % xmax
                        tempr = solp.xmax{idxx};
                        for ndx = endx+1:endx+N(idxx)
                            solpvec(ndx) = tempr(ndx-endx);
                        end
                        endx = endx+N(idxx);
                        
                        % xmin
                        tempr = solp.xmin{idxx};
                        for ndx = endx+1:endx+N(idxx)
                            solpvec(ndx) = tempr(ndx-endx);
                        end
                        endx = endx+N(idxx);
                        
                        % xpks
                        tempr = solp.xpks{idxx};
                        for ndx = endx+1:endx+N(idxx)
                            solpvec(ndx) = tempr(ndx-endx);
                        end
                        endx = endx+N(idxx);
                        
                        % ymax
                        tempr = solp.ymax{idxx};
                        for ndx = endx+1:endx+N(idxx)
                            solpvec(ndx) = tempr(ndx-endx);
                        end
                        endx = endx+N(idxx);
                        
                        % ymin
                        tempr = solp.ymin{idxx};
                        for ndx = endx+1:endx+N(idxx)
                            solpvec(ndx) = tempr(ndx-endx);
                        end
                        if idxx ~=J
                            endx = endx+N(idxx);
                        end
                    end
                elseif eq == 1
                    for idxx = 1:J
                        
                        if p(idxx) == 7
                        % shape
                        tempr = solp.shape{idxx};
                        if numel(tempr) == 1 && N(idxx) > 1
                            tempr = tempr*ones(N(idxx),1);
                        end
                        for ndx = endx+1:endx+N(idxx)
                            solpvec(ndx) = tempr(ndx-endx);
                        end
                        endx = endx+N(idxx);
                        end
                        
                        if p(idxx) >= 6
                            % base
                            tempr = solp.base{idxx};
                            if ~isnumeric(tempr)
                                if tempr=="nat"
                                    tempr = exp(1);
                                end
                            end
                            ndx = endx+1;
                            solpvec(ndx) = tempr(ndx-endx);
                            endx = endx+1;
                        end
                        
                        % lambda
                        tempr = solp.lambda{idxx};
                        if numel(tempr) == 1 && N(idxx) > 1
                            tempr = tempr*ones(N(idxx),1);
                        end
                        for ndx = endx+1:endx+N(idxx)
                            solpvec(ndx) = tempr(ndx-endx);
                        end
                        endx = endx+N(idxx);
                        
                        % xmax
                        tempr = solp.xmax{idxx};
                        ndx = endx+1;
                        solpvec(ndx) = tempr(ndx-endx);
                        endx = endx+1;
                        
                        % xmin
                        tempr = solp.xmin{idxx};
                        ndx = endx+1;
                        solpvec(ndx) = tempr(ndx-endx);
                        endx = endx+1;
                        
                        % ymax
                        tempr = solp.ymax{idxx};
                        ndx = endx+1;
                        solpvec(ndx) = tempr(ndx-endx);
                        endx = endx+1;
                        
                        % ymin
                        tempr = solp.ymin{idxx};
                        ndx = endx+1;
                        solpvec(ndx) = tempr(ndx-endx);
                        if idxx ~=J
                            endx = endx+1;
                        end
                        
                    end
                    
                end
                
                % second vector format:
                % for each j: each i in nj: 1..pj
                if urollvs == 2
                    % convert first-form to second-form
                    % for the unrolled vector;
                    newsolpvec = zeros(pnj,1);
                    pn0 = 0;
                    for idxx = 1:J
                        Ni = N(idxx);
                    if eq == 0
                        pn = p(idxx)*Ni;
                    elseif eq == 1
                        if p(idxx) == 7
                            pn = (p(idxx)-2) + Ni;
                        elseif p(idxx) == 6
                            pn = (p(idxx)-1) + Ni;
                        elseif p(idxx) == 5
                            pn = p(idxx);
                        end           
                    end
                        C = zeros(p(idxx),Ni);
                        for id = 1:Ni
                            C(:,id) = pn0+id:Ni:pn0+pn;
                        end
                        newsolpvec(pn0+1:pn0+pn,1) = solpvec(C(:),1);
                        if idxx ~= J
                            pn0 = pn0+pn;
                        end
                    end
                    solpvec = newsolpvec;
                end
                
            end
            
        end
        
        function obj = sol_roll(obj,solpvec)
            % SOL_ROLL
            % rolls back solution structure from vector form
            % to a required structure of cell array forms.
            
            % n, shape,
            % required order is:
            % base,lambda,xpks,xmin,xmax,ymin,ymax
            
            if nargin > 1
                obj.solpvec = solpvec;
            end
            
            % convert second-form to first-form
            % before rolling back to structure form;
            if obj.urollvs == 2
                if obj.eq == 0
                    pnj = sum(obj.N.*obj.p);
                elseif obj.eq == 1
                    pnj = 0;
                    for j = 1:obj.J
                        if obj.p(j) == 7
                            pnj = pnj + (obj.p(j)-2) +  (2*obj.N(j));
                        elseif obj.p(j) == 6
                            pnj = pnj + (obj.p(j)-1) +  (1*obj.N(j));
                        elseif obj.p(j) == 5
                            pnj = pnj + obj.p(j);
                        end
                        % pnj = (obj.p-2) + (2*sum(obj.N));
                    end
                end
                newsolpvec = zeros(pnj,1);
                pn0 = 0;
                for idxx = 1:obj.J
                    Ni = obj.N(idxx);
                    if obj.eq == 0
                        pn = obj.p(idxx)*Ni;
                    elseif obj.eq == 1
                        if obj.p(idxx) == 7
                            pn = (obj.p(idxx)-2) + Ni;
                        elseif obj.p(idxx) == 6
                            pn = (obj.p(idxx)-1) + Ni;
                        elseif obj.p(idxx) == 5
                            pn = obj.p(idxx);
                        end           
                    end
                    C = zeros(Ni,obj.p(idxx));
                    for id = 1:obj.p(idxx)
                        C(:,id) = pn0+id:obj.p(idxx):pn0+pn;
                    end
                    newsolpvec(pn0+1:pn0+pn,1) = obj.solpvec(C(:),1);
                    if idxx ~= obj.J
                        pn0 = pn0+pn;
                    end
                end
                obj.solpvec = newsolpvec;
            end
            
            
            endx = 0;
            % keeps adding N(j) to endx
            % Roll back vector to structure
            for idx = 1:obj.J
                
                % n, shape
                obj.solp.n{idx} = obj.N(idx);
                % todo: indicator if first use to set shape to
                % a default
                % obj.solp.shape{idx} = obj.Sp{idx}; DONE..
                
                if obj.eq == 0
                    if obj.p(idx) == 8
                    % shape
                    obj.solp.shape{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                    endx = endx+obj.N(idx);
                    end
                    
                    if obj.p(idx) >= 7
                        % base
                        obj.solp.base{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                        % enforce base constraint of being >= 2
                        for ib = 1:obj.N(idx)
                            if ( obj.solp.base{idx}(ib) < 2 )
                                obj.solp.base{idx}(ib) = exp(1);
                                obj.solpvec(endx+ib) = exp(1);
                            end
                        end
                        % flatten to a single base if all i=1:nj base values
                        % are the same.
                        if sum(obj.solp.base{idx}) == obj.solp.base{idx}(1)*obj.N(idx)
                            obj.solp.base{idx} = obj.solpvec(endx+1);
                        end
                        % reduce to natural base e if equal to exp(1)
                        if abs(obj.solp.base{idx} - exp(1) ) < 1e-2
                            obj.solp.base{idx} = "nat";
                        end
                        endx = endx+obj.N(idx);
                    end
                    
                    % lambda
                    obj.solp.lambda{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                    endx = endx+obj.N(idx);
                    
                    % xmax
                    obj.solp.xmax{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                    endx = endx+obj.N(idx);
                    
                    % xmin
                    obj.solp.xmin{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                    endx = endx+obj.N(idx);
                    
                    % xpks
                    obj.solp.xpks{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                    endx = endx+obj.N(idx);
                    
                    % ymax
                    obj.solp.ymax{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                    endx = endx+obj.N(idx);
                    
                    % ymin
                    obj.solp.ymin{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                    endx = endx+obj.N(idx);
                    
                elseif obj.eq == 1
                    
                    if obj.p(idx) == 7
                        % shape
                        obj.solp.shape{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                        endx = endx+obj.N(idx);
                    end
                    
                    if obj.p(idx) >= 6
                        % base
                        obj.solp.base{idx} = obj.solpvec(endx+1);
                        endx = endx+1;
                        
                        if abs(obj.solp.base{idx} - exp(1)) < 1e-6
                            obj.solp.base{idx} = "nat";
                        end
                    end
                    
                    % lambda
                    obj.solp.lambda{idx} = obj.solpvec(endx+1:endx+obj.N(idx));
                    endx = endx+obj.N(idx);
                    
                    % xmax
                    obj.solp.xmax{idx} = obj.solpvec(endx+1);
                    endx = endx+1;
                    
                    % xmin
                    obj.solp.xmin{idx} = obj.solpvec(endx+1);
                    endx = endx+1;
                    
                    % ymax
                    obj.solp.ymax{idx} = obj.solpvec(endx+1);
                    endx = endx+1;
                    
                    % ymin
                    obj.solp.ymin{idx} = obj.solpvec(endx+1);
                    endx = endx+1;
                    
                end
                
            end
            
            % Reset options structure
            for j = 1:obj.J
                
                if obj.eq == 0
                    obj.nlsigopts(j) = ...
                        struct('n', obj.solp.n{j},'shape', obj.solp.shape{j},...
                        'base', obj.solp.base{j},'lambda', obj.solp.lambda{j},...
                        'xmax', obj.solp.xmax{j}, 'xmin', obj.solp.xmin{j},...
                        'xpks', obj.solp.xpks{j}, ...
                        'ymax', obj.solp.ymax{j},'ymin', obj.solp.ymin{j}, ...
                        'p', obj.solp.p{j},'check_constraints', 0 ...
                        );
                else
                    obj.nlsigopts(j) = ...
                        struct('n', obj.solp.n{j}, 'shape', obj.solp.shape{j},...
                        'base', obj.solp.base{j}, 'lambda', obj.solp.lambda{j},...
                        'xmax', obj.solp.xmax{j}, 'xmin', obj.solp.xmin{j},...
                        'ymax', obj.solp.ymax{j},'ymin', obj.solp.ymin{j}, ...
                        'p', obj.solp.p{j},'check_constraints', 0 ...
                        );
                end
            end
            
        end
        
        function [Eout,Jout,Hout] = objfun_unroll(obj,solpvec,type)
            %OBJFUN_UNROLL
            
            obj.solpvec = solpvec;
            obj = sol_roll(obj,obj.solpvec);
            obj = mimo(obj,false);
            
            if type == 0
                % lsqnonlin
                % error function
                Eout = obj.E(:);
            elseif type == 1
                % fmincon
                % sum of squared error function
                Eout = obj.Ess;
            end
            
            % unrolled jacobian and hessian to
            % nicer/easier form for matlab lsqnonlin/fmincon forms
            if nargout > 1
                if type == 0
                    Jout = obj.JACLE1;
                elseif type == 1
                    Jout = obj.JACLEss3;
                end
                
                if nargout > 2
                    if type == 0
                        Hout = obj.HESLE1;
                    elseif type == 1
                        Hout = obj.HESLEss3;
                    end
                end
                
                if obj.tune_win==true || obj.tune_win == 1
                    if type == 0
                        Jout = [Jout obj.JACWE1];
                        if nargout > 2
                            Hout = Jout'*Jout;
                        end
                    elseif type == 1
                        Jout = [Jout obj.JACWEss3];
                        if nargout > 2
                            Hout = Jout'*Jout;
                        end
                    end
                end
                
            end
            
        end
        
        function F = objfeval1(obj,solpvec,type)
            % OBJFEVAL1
            % easy interface for evaluating unrolled objfun
            % with MATLAB's optimization functions.
            F = obj.objfun_unroll(solpvec,type);
        end
        
        function [F,J] = objfeval2(obj,solpvec,type)
            % OBJFEVAL2
            % easy interface for evaluating unrolled objfun
            % with MATLAB's optimization functions.
            [F,J] = obj.objfun_unroll(solpvec,type);
        end
        
        function [F,J,H] = objfeval3(obj,solpvec,type)
            % OBJFEVAL3
            % easy interface for evaluating unrolled objfun
            % with MATLAB's optimization functions.
            [F,J,H] = obj.objfun_unroll(solpvec,type);
            obj.Hout = H;
        end
        
        function obj = predict(obj,solp)
            %PREDICT make inference using solution parameters.
            
            if nargin > 1
                obj = setopts(obj,solp);
            end
            obj = mimo(obj,true);
        end
        
        function obj = stats(obj)
            %STATS compute stats on solution.
            
            % regression parameters
            % or optimised parameters
            % todo: add weights w later
            
            P = zeros(obj.J,1);
            if obj.eq == 0
                P = (obj.N).*obj.p;
            elseif obj.eq == 1
                for j = 1:obj.J
                    pnj = 0;
                    if obj.p(j) == 7
                        pnj = pnj + (obj.p(j)-2) +  (2*obj.N(j));
                    elseif obj.p(j) == 6
                        pnj = pnj + (obj.p(j)-1) +  (1*obj.N(j));
                    elseif obj.p(j) == 5
                        pnj = pnj + obj.p(j);
                    end
                    P(j) = pnj;
                end
            end
            
            % average value: sum(y_data)/numel(y_data)
            % along each row, that is each j outputs.
            Ymean = mean(obj.RYout);
            % total variance in data samples
            Ytv = obj.RYout - Ymean;
            % sum of squares of the
            % total variance from the mean the data samples
            SST = sum(Ytv.^2);
            
            % regression variance
            Yreg = obj.Yout - Ymean;
            % sum of squares of the regression
            % variance from the mean
            SSM = sum(Yreg.^2);
            
            % sum of squares of the residuals (errors)
            SSE = sum((obj.E).^2);
            
            % normalized ( to values: 0 - 1) residuals
            E_normcdf = zeros(obj.D,obj.J);
            for j = 1:obj.J
                E_normcdf(:,j) = normalize(obj.RYout(:,j),'range') - ...
                    normalize(obj.Yout(:,j),'range');
            end
            
            % R2: coefficient of determination or goodness of fit
            % coefficient of determination / goodness of fit
            % compute R-squared, but avoid divide by zero warning
            if ~isequal(SST,0)
                R2 = 1 - (SSE./SST); % or SSM/SST
            elseif isequal(sst,0) && isequal( sse, 0 )
                R2 = NaN;
            else % SST==0 && SSE ~== 0
                % This is unusual, so try to determine if sse is just round-off error
                if ( sqrt(abs(SSE)) < sqrt(eps)*mean(abs(y_data)) )
                    R2 = NaN;
                else
                    R2 = -Inf;
                end
            end
            
            % Degrees of Freedom for Model Variance
            dfm = P - 1; % p > 1
            % Degrees of Freedom for Error Variance or residuals
            dfe = obj.D - P;
            % Degrees of Freedom for Total Variance
            dft = obj.D - 1; % or  dfm + dfe
            
            % mean of squares
            % for (explained) variance of the regression model
            MSM = SSM./dfm';
            % for (unexplained) variance of the error residuals
            MSE = SSE./dfe';
            % for variance of the total data samples
            MST = SST./dft';
            
            % adjusted R2
            R2a = 1 - (MSE./MST);
            
            % root mean square error: standard error of estimate
            RMSE = sqrt(MSE);
            
            % calculate F-statistics
            Fval = MSM./MSE;
            
            % 99%(default) CI on (dfm, dfe)
            % good fit has < 0.05 confidence level p-value
            % Significance probability for regression
            pval = zeros(obj.J,1);
            for id = 1:obj.J
                pval(id) = fcdf(1./max(0,Fval(id)),dfe(id),dfm(id));
            end
            
            % Adapted Kolgomorov-Smirnov and DKW stats
            
            % calculate D statistic(s)
            % number of samples
            num_samples = dft;
            % euclidean distance or 2-norm
            De = vecnorm(obj.E,2);
            % chebyschev distance or max-norm or sup-norm
            Dc = vecnorm(obj.E,Inf);
            % average 2-norm or RMS distance
            % Dr = rms(obj.E); % vecnorm(obj.E,2)/sqrt(num_samples)
            
            % normalized max-Error
            % KS Distance statistic for the cummulative distribution
            normDc = vecnorm(E_normcdf,Inf);
            
            % CI
            
            % alpha-level of significance
            alphalvl = 0.01;
            
            % DKW Inequality Conf Intervals (CI) Constant
            C = exp(1);
            % C = 2;
            
            % Critical value at alpha-level of the
            % one-sample Kolmogorov-Smirnov test for samples of size n
            % valE1 = sqrt((1/(2*num_samples))*log(C/alphalvl));
            % two-sample Kolmogorov-Smirnov test for samples of size n
            valE2 = sqrt((1/(num_samples))*log(C/alphalvl));
            % debug:
            % disp(valE2);
            
            KSgof  = zeros(obj.J,1);
            for id = 1:obj.J
                if valE2*normDc(id) > valE2
                    % normDc  > 1
                    KSgof(id) = alphalvl;
                elseif valE2*normDc(id) <= valE2
                    % normDc  <= 1
                    KSgof(id) = 1-alphalvl;
                end
            end
            
            % Modified CI Constants
            % euclidean, 2-norm
            % change to 2;
            valEe = sqrt((1/(C))*log(C/alphalvl)).*De;
            % chebyschev, max-norm
            % change to 1;
            c =  1/32;
            valEi = sqrt((1/c)*log(C/alphalvl));
            valEi = valEi.*valE2.*Dc;
            % CI value for Y
            ciE = valEi;
            
            % DY sum of squares for the residuals (errors)
            dE = gradient(obj.E,1);
            %dSSE = sum((dE.^2));
            
            % max-norm
            dDc = vecnorm(dE,Inf);
            dvalEi = sqrt((1/(1))*log(C/alphalvl))*dDc;
            
            % CI value for DY
            dciE = dvalEi;
            
            % Set up GOF structure
            gfstats = struct('residuals', obj.E,'dresiduals', dE,...
                'SSE', SSE, 'RMSE', RMSE, 'MST', MST,...
                'R2', R2,'R2a', R2a, ...
                'dfe', dfe, ...
                'Fval', Fval, 'pval', pval, ...
                'ciE', ciE, 'valEi', valEi, 'valEe', valEe, ...
                'dciE', dciE, 'KSgof', KSgof, 'normDc', normDc ...
                );
            obj.fitstats = gfstats;
            
        end
        
        function obj = setR(obj,R)
            %SETR set actual Y data
            obj.RYout = R;
        end
        
        function [XIR] = getXIR(obj,solp)
            %XIR
            % Logistic Sigmoid Curve Indices
            % XIR: X to Inflection Ratio
            
            % Given the x peak inflection-points and
            % max-min intervals in a nlsig curve
            % At any x value, find the x to inflection ratio.
            
            % For many cases, x can be interpreted as time
            % so, XIR, means input time (X) to Inflection Ratio ((X)IR)
            
            % at x < xpks_i, XIR < 1;
            % at x > xpks_i, XIR > 1;
            % at x = xpks_i, XIR = 1;
            
            % useful for indicating the distance between an input x
            % and the inflection points in the cummulative curve's interval.
            
            % disp(xpks_i); % debug
            
            % D x J
            % obj.x;
            
            % shape_i = sol.shape;
            XIR = zeros(size(obj.x));
            for j = 1:obj.J
                base_i = solp.base{j};
                lambda_i = solp.lambda{j};
                xpks_i = solp.xpks{j};
                xmax_i = solp.xmax{j};
                xmin_i = solp.xmin{j};
                
                
                % logical indexing to
                % find which x falls within a min-xmax interval
                ips_id = (obj.x(:,j) >= xmin_i');
                % sum the index to get an equivalent index 0:nj
                pidx = sum(ips_id,2);
                % fix index==0 to 1
                pidx(pidx==0) = 1; % pidx is now 1:nj
                
                % vectorize solp values for
                % the whole range of x. belonging to 1:nj
                % D x 1
                xmin = xmin_i(pidx);
                xpks = xpks_i(pidx);
                xmax = xmax_i(pidx);
                lambd = lambda_i(pidx);
                
                XIR(:,j) = (lambd./(xmax-xmin)).*(obj.x(:,j) - xpks);
                
                if ~any(isnumeric(base_i))
                    XIR(:,j) = exp(1.*XIR(:,j));
                else
                    if numel(base_i) > 1
                        bases = base_i(pidx);
                    else
                        bases = base_i;
                    end
                    XIR(:,j) = bases.^(1.*XIR(:,j));
                end
                
            end
            obj.XIR = XIR;
        end
        
        function [YIR] = getYIR(obj,solp)
            %YIR
            % Logistic Sigmoid Curve Indices
            % YIR: Y to Inflection Ratio
            
            % Given the max and min intervals of a nlsig curve.
            % At the cummulative value y,
            % find the cummulative value to inflection ratio
            % for all peak inflection-points in that curve.
            
            % YIR < 0.5; then at y, the rate of the cummulative curve is increasing.
            % YIR > 0.5; then at y, the rate of the cummulative curve is reducing.
            % YIR = 0.5; then at y, the rate of the cummulative curve is at a peak point.
            
            % useful for indicating the state of the rate of incident increase or decrease
            % over the curve's interval at a particular cummulative value.
            
            % The theoretical idea is that at y corresponding to inflection points, the value of
            % YIR is always 0.5 for the logistic curve.
            
            % D x J
            % obj.Yout;
            
            YIR = zeros(size(obj.Yout));
            for j = 1:obj.J
                
                % logical indexing to
                % find which y falls within a min-xmax interval
                ips_id = (obj.Yout(:,j) >= solp.ymin{j}');
                % sum the index to get an equivalent index 0:nj
                pidx = sum(ips_id,2);
                % fix index==0 to 1
                pidx(pidx==0) = 1; % pidx is now 1:nj
                
                % D x 1 vectorized solp
                min = solp.ymin{j}(pidx);
                max = solp.ymax{j}(pidx);
                
                YIR(:,j) = (obj.Yout(:,j) - min)./(max - min);
            end
            
            obj.YIR = YIR;
        end
        
    end
    
end

