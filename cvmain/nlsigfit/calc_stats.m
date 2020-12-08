function goodfit_stats = calc_stats(y_data,y_est,p,n_ips)
%CALC_STATS Compute goodness of fit (coefficient of determination) stats.
%
% Inputs:
%   y_data, actual values
%   y_est, estimated values
%   p, number of regression model parameters
%
% Output:
%   goodfit_stats structure
%

p = p*n_ips;

% See http://facweb.cs.depaul.edu/sjost/csc423/documents/f-test-reg.htm

% errors/variances sum of squares

y_mean  = mean(y_data); % average value: sum(y_data)/numel(y_data)
% sum of squares for the total variance in the data samples
tots = y_data - y_mean;
SST = sum((tots.^2));    
% sum of squares for the regression model
regs = y_est - y_mean;
SSM =  sum((regs.^2));
% sum of squares for the residuals
res = y_data - y_est;
SSE = sum((res.^2));

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

% p, number of regression parameters          

% adjusted R2
R2a = (numel(y_data) - 1)/(numel(y_data) - p);
R2a = 1 - ((1 - R2)*R2a);
% Degrees of Freedom for Model Variance
dfm = p - 1; % p > 1
% Degrees of Freedom for Error Variance or residuals
dfe = numel(y_data) - p;
% Degrees of Freedom for Total Variance
dft = numel(y_data) - 1; % or  dfm + dfe
% mean of squares
% for (explained) variance of the regression model
MSM = SSM/dfm;
% for (unexplained) variance of the error residuals
MSE = SSE/dfe;
% for variance of the total data samples
MST = SST/dft;

% root mean square error: standard error of estimate
RMSE = sqrt(MSE);

% calculate F-statistics
Fval = MSM/MSE;

% 95% CI on (dfm, dfe)
% good fit has < 0.05 confidence level p-value 
pval = fcdf(1./max(0,Fval),dfe,dfm);
% Significance probability for regression

% Set up GOF structure
goodfit_stats = struct('residuals', res,...
    'SSE', SSE, 'RMSE', RMSE, 'MST', MST,...
    'R2', R2,'R2a', R2a, ...
    'dfe', dfe, ...
    'Fval', Fval, 'pval', pval ...
    );

% %... set logaritmic scale
% set(gca, 'YScale', 'log')
% 
% tx1 = sprintf('%s: Covid-19 epidemic %s',...
%     country,datestr(time0+length(length(C))-1));


end