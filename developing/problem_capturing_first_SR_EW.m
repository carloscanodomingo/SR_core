% 
load("SR_2017_EW");
SR_test = SR_2017_EW{5};
SR_good = SR_peak_process_array.remove_noisy_schumann_peak(SR_test);
[f_mean_hours, f_std_hours, val_mean_hours, val_std_hours] = SR_peak_process_array.maximum_hours(SR_good, 1, 'lorentz');



