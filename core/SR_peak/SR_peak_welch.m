function [data_f,f ] = SR_peak_welch(data,fs, window,over_lap)
% welch_v_schumman  perform welch algorithm
%   data = data to be transformed
%   fs = sample frequency 
%   window = length of the window in samples
%   over_lap = length of the overlap in samples


    [y_mss_welch, f] = calc_mss_welch(data,fs,window,over_lap);
    
    data_f = 10*log10(y_mss_welch);  
    plot(f, data_f)

    function [y_mss_welch,f] = calc_mss_welch(y,fs,window,over_lap)
        nfft = window  * 2;
        [h,f] = pwelch(y,window,over_lap,nfft,fs);
        y_mss_welch = h;
    end

end
