function [f,f_dist, width, value, schumann_fc, data_smooth] = get_schumman_peaks(data_f,N ,prominence_factor)
%UNTITLED4 Summary of this function goes here
% Detailed explanation goes here

% smooth frecuency spectrum
data_smooth = smoothdata(data_f,'sgolay',30,'Degree',2); % Create ‘sgolayfilt’ Filtered FFT

[f,f_dist, width, value, schumann_fc] = find_peak_schumman(real(data_smooth),N, prominence_factor);
