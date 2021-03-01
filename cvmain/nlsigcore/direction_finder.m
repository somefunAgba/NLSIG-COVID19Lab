function dirvec = direction_finder(Y)
%DIRECTION_FINDER find direction of increase, decrease or stationary

sz = size(Y);
J = sz(2);
D = sz(1);

dirvec = zeros(D,J);
dirvec(1,:) = 0;
for d=2:D
    for j=1:J
        c = Y(d,j) - Y(d-1,j);
        if abs(c-0) <= 1e-5
            dirvec(d,j) = 0;
        elseif c > 0
            dirvec(d,j) = 1;
        elseif c < 0
            dirvec(d,j) = -1;
        end
    end
end

end