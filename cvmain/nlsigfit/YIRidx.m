function YIR = YIRidx(y,ymax_i,ymin_i)
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

if isrow(y)
    y = y';
end

ips_id = y >= ymin_i';
c = sum(ips_id,2);
c(c==0) = 1;
min = ymin_i(c);
max = ymax_i(c);

YIR = (y - min)./(max - min);
%YIR = (y - ymin_i')./(ymax_i' - ymin_i');


if isrow(YIR)
    YIR = YIR';
end

% oasomefun@futa.edu.ng 2020
end