function [pks,locs,w] = extract_all_peaks(ps, fs, N, prominence_factor)
% Performs a component extraction of the signal using find peaks.

samples_hz = ceil(length(ps)/(fs/ 2));

[pks,locs_temp,w,~] = findpeaks(ps,'WidthReference','halfprom', ...
    'NPeaks', N,'MinPeakProminence', ...
    (max(ps) - min(ps))/(1000 * prominence_factor) , 'MinPeakDistance', samples_hz);

locs = locs_temp * (fs/2) / length(ps);
w = w * (fs/2) / length(ps);

end

