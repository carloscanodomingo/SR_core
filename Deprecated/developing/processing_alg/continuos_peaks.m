function [f,f_dist, width, value, schumann_fc, mean_error, low_f_psd, data_splitted, raw_data_f, data_f, data_f_smooth, R2_pre, R2_post] = continuos_peaks(transform_f, window_transform, overlap_transform,data,fig, funct_in, samples_per_chunk,overlap)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


N = 8;
Fs = 187;

close all

data_splitted = buffer(data, samples_per_chunk, floor(overlap * samples_per_chunk));

number_of_chunks = size(data_splitted,2);

f = zeros(N, number_of_chunks);
f_dist = zeros(N, number_of_chunks);
width = zeros(N, number_of_chunks);
value = zeros(N, number_of_chunks);
schumann_fc = zeros(N, number_of_chunks);
low_f_psd = zeros(1,number_of_chunks); 
R2_pre = zeros(1,number_of_chunks); 
R2_post = zeros(1,number_of_chunks); 
data_f = zeros(1871, number_of_chunks);
data_f_smooth = zeros(1871, number_of_chunks);
raw_data_f = zeros(1871, number_of_chunks);
display("The number of chunks is " + number_of_chunks);
hpf_value = 3;


for k=1:number_of_chunks
  current_data = data_splitted(:,k);
  raw_data_f(:,k) = transform_f(current_data,Fs,window_transform, overlap_transform, 1);
  title("chunk number: " + k);
  current_data_filter = highpass(current_data,hpf_value,187,'Steepness',0.85,'StopbandAttenuation',60);
  [data_f(:,k), freq] = transform_f(current_data_filter,Fs,window_transform, overlap_transform, 1);  
  
  [f(:,k),f_dist(:,k), width(:,k), value(:,k),~,  data_f_smooth(:,k)]  = funct_in(data_f(:,k),N,fig * 2);
  select_freq = (freq > hpf_value & freq < 40); %HPF 2Hz
  
  mdl_pre = fitlm(freq(select_freq), raw_data_f(select_freq, k));
  mdl_post = fitlm(freq(select_freq), data_f_smooth(select_freq, k));
  R2_pre(k) = mdl_pre.Rsquared.Ordinary;
  R2_post(k) = mdl_post.Rsquared.Ordinary;
  
  low_f_psd(k) = sum(log10(abs(data_f(freq < 5,k))));
  
end
mean_error = mean(f_dist(1,:));
