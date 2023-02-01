
if exist('data_1','var') == 0
    load("data_1.mat")
end

freq = data_1.freq;
first_interval = [5.83,9.83];
data_1_to_fit = data_1.smooth_data_f;
data_1_to_fit_interval = data_1.smooth_data_f(freq > first_interval(1) & freq < first_interval(2));
first_interval_freq = freq(freq > first_interval(1) & freq < first_interval(2));
X = first_interval_freq';
Y = data_1_to_fit_interval;

% rough guess of initial parameters
a3 = ((max(X)-min(X))/10)^2;
a2 = (max(X)+min(X))/2;
a1 = max(Y)*a3;
a0 = [a1,a2,a3,0];
[yprime1 params1 resnorm1 residual1] = lorentzfit(X,Y,flip(a0));
figure; plot(X,Y,'b.','LineWidth',2)
hold on; plot(X,yprime1,'r-','LineWidth',2)

% define lorentz inline, instead of in a separate file
lorentz = @(param, x) param(1) ./ ((x-param(2)).^2 + param(3));

% define objective function, this captures X and Y
fit_error = @(param) sum((Y - lorentz(param, X)).^2);

% do the fit
a_fit = fminsearch(fit_error, a0);

% quick plot
x_grid = linspace(min(X), max(X), 1000); % fine grid for interpolation
plot(X, Y, '.', x_grid, lorentz(a_fit, x_grid), 'r')
legend('Measurement', 'Fit')
title(sprintf('a1_fit = %g, a2_fit = %g, a3_fit = %g', ...
    a_fit(1), a_fit(2), a_fit(3)), 'interpreter', 'none')
