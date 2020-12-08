% boot ci computation
function [sol_lb, sol_ub] = sol_bootci(boot_sol,nboot,n,p)

assert( p==2||p==3 || p==6||p==7,'Oops, nlsig expects 2, 3, 6 or 7 variables for optimization!');

boot_var = zeros(nboot,n,p);
for id = 1:nboot
    bootTable = struct2table(boot_sol{id});
    for kd = 1:p
        boot_var(id,:,kd) = bootTable{:,kd}'; %boot_sol{id}.lambda ...;
    end
end
ci_lb95 = prctile(boot_var, 2.5);
ci_lb95 = (reshape(ci_lb95,n,p))';
ci_ub95 = prctile(boot_var, 97.5);
ci_ub95 = (reshape(ci_ub95,n,p))';


if p == 6
% the ' transforms from row to column vector form
sol_lb.lambda = ci_lb95(1,:)';
sol_lb.xmax = ci_lb95(2,:)';
sol_lb.xmin = ci_lb95(3,:)';
sol_lb.xpks = ci_lb95(4,:)';
sol_lb.ymax = ci_lb95(5,:)';
sol_lb.ymin = ci_lb95(6,:)';
% the ' transforms from row to column vector form
sol_ub.lambda = ci_ub95(1,:)';
sol_ub.xmax = ci_ub95(2,:)';
sol_ub.xmin = ci_ub95(3,:)';
sol_ub.xpks = ci_ub95(4,:)';
sol_ub.ymax = ci_ub95(5,:)';
sol_ub.ymin = ci_ub95(6,:)';

elseif p == 7
% the ' transforms from row to column vector form
sol_lb.base = ci_lb95(1,:)';
sol_lb.lambda = ci_lb95(2,:)';
sol_lb.xmax = ci_lb95(3,:)';
sol_lb.xmin = ci_lb95(4,:)';
sol_lb.xpks = ci_lb95(5,:)';
sol_lb.ymax = ci_lb95(6,:)';
sol_lb.ymin = ci_lb95(7,:)';

% the ' transforms from row to column vector form
sol_ub.base = ci_ub95(1,:)';
sol_ub.lambda = ci_ub95(2,:)';
sol_ub.xmax = ci_ub95(3,:)';
sol_ub.xmin = ci_ub95(4,:)';
sol_ub.xpks = ci_ub95(5,:)';
sol_ub.ymax = ci_ub95(6,:)';
sol_ub.ymin = ci_ub95(7,:)';

elseif p == 2
 % the ' transforms from row to column vector form
sol_lb.lambda = ci_lb95(1,:)';
sol_lb.xpks = ci_lb95(2,:)';

% the ' transforms from row to column vector form
sol_ub.lambda = ci_ub95(1,:)';
sol_ub.xpks = ci_ub95(2,:)';
elseif p == 3
% the ' transforms from row to column vector form
sol_lb.base = ci_lb95(1,:)';
sol_lb.lambda = ci_lb95(2,:)';
sol_lb.xpks = ci_lb95(3,:)';
% the ' transforms from row to column vector form
sol_ub.base = ci_ub95(1,:)';
sol_ub.lambda = ci_ub95(2,:)';
sol_ub.xpks = ci_ub95(3,:)';

else
    error('Oops, nlsig expects 2,3, 6 or 7 variables for optimization!');
end


end