function plot_f_mark(schumman_resonance_obj, fitresult)
%PLOT_F_MARK Summary of this function goes here
%   Detailed explanation goes here
num_coeff = length(coeffvalues(fitresult))/3;
coeff = coeffvalues(fitresult);
f = coeff(num_coeff + 1:2 * num_coeff)
[min_values,min_idx] = min(abs(schumman_resonance_obj.freq' - f));
figure()
plot(schumman_resonance_obj.freq,schumman_resonance_obj.smooth_data_f);
hold on
plot(schumman_resonance_obj.freq(min_idx), schumman_resonance_obj.smooth_data_f(min_idx), '+', 'MarkerSize', 10);
hold off
end

