%SR_peak_noisy = SR_peak_process_array.remove_noisy_schumann_peak(SR_2018_EW_start);
SR_peak_noisy = SR_good;
output = arrayfun(@(x) SR_peak_process.get_peak_lorentz_raw(x,5),SR_peak_noisy, 'UniformOutput', false);
frequency_lorentz_6 = buffer(cell2mat(output),8);
first_SR = frequency_lorentz_6(1,:);
selected_first_SR_anomalous = (first_SR >= 6.00 & first_SR <= 6.5);

SR_2016_jan_anomalous = SR_peak_noisy(selected_first_SR_anomalous);

first_SR_anomalous = first_SR(selected_first_SR_anomalous);

%{
[output_max_smooth,gof] = arrayfun(@(x) SR_peak_process.R2_lorentz_first_SR(x),SR_peak_noisy, 'UniformOutput', false);
%scatter(first_SR,std_raw);

for i=1:length(output_max_smooth)
    select_cell = output_max_smooth{i};
    fit = select_cell;
    gof_current = gof{i};
    array_amplitude(i) = fit.A1;
    array_location(i) = fit.B1;
    array_width(i) = fit.C1;
    array_sse(i) = gof_current.sse;
end
figure(1)
scatter(first_SR,array_amplitude);
figure(2)
scatter(first_SR,array_location);
figure(3)
scatter(first_SR,array_width);
figure(4)
scatter(first_SR,array_sse);
%}