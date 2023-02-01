load('good_samples_f.mat')

for i=30:length(SR_good_samples)
    current_SR = SR_good_samples(i);
    process_schumann_peak.plot(current_SR,'pT','completed');
    pause
    close all
end
