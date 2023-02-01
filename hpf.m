function [data_filtered] = hpf(data,hpf_value, fs)
%HPF Summary of this function goes here
%   Detailed explanation goes here
data_filtered = highpass(data,hpf_value,fs,'Steepness',0.85,'StopbandAttenuation',60);
end

