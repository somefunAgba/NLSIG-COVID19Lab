function [lnnf_passes,infl_passes] = lnn_infl_opts(x_data,y_data,...
    p,eq,base,...
    tpassno,optsolver,...
    sbounds,lubnds)
%LNN_INFL_OPTS Recursive inflxpt finder and optimizer for a lnn

% total number of passes
% tpassno

% p = 6;
% eq = 0 or 1;
% base = "nat";

% Solver Options
%
% est.params bounds options
% sbounds = true or false;
% lubnds = true or false;

% optimization-solver type
% optsolver = "lsqnonlin-tr";
% optsolver = "lsqnonlin-lm";
% optsolver = "fmincon-tr";
% optsolver = "fmincon-ipt";

% 1 to tpassno
assert(tpassno >=1, "total passes must be 1 or greater integer!")

iscdf = [1;1];
shape = [1;-1];

% lnnfit holder.
lnnf_passes = cell(tpassno,1);
infl_passes = cell(tpassno,1);

% inflextion finder class
infl = inflxpt;

% loop
for idpass = 1:tpassno
    
   
    % debug
    if idpass < tpassno
        fprintf("Passing: %d of %d...\n",idpass,tpassno);
    elseif idpass == tpassno
        fprintf("Passing: %d of %d\n.",idpass,tpassno);
    end
    
    % inflections finder
    % set
    if idpass == 1
        infl.setprops(tpassno,iscdf,shape,y_data,x_data);
    elseif idpass > 1
        infl.setprops(tpassno,iscdf,shape,lnnf.Yout,infl.x_data);
    end
    %find
    infl.find();
    %group
    [infl, phase]=infl.group(); %#ok<ASGLU>
    %sort
    if idpass == 1
        [infl, solpi]=infl.sort(false,p,eq,base);
    elseif idpass > 1
        [infl, solpi]=infl.sort(true,p,eq,base);
    end
    % optimization solver
    lnnf = solvopts(infl.x_data,infl.y_data,...
        optsolver,solpi,sbounds,lubnds);
    
    lnnf_passes{idpass} = lnnf;
    infl_passes{idpass} = infl;
end

end