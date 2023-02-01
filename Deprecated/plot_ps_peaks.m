function plot_ps_peaks(data_f,fs, N, prominence_factor)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
pspectrum(data_f, fs);
[ps , ~] = pspectrum(data_f, fs);
samples_hz = ceil(length(ps)/(fs/2));
findpeaks(log10(ps),'WidthReference','halfprom', ...
    'NPeaks', N,'MinPeakProminence', ...
    (max(log10(ps)) - min(log10(ps)))/(1000 * prominence_factor), 'MinPeakDistance',samples_hz);
end

