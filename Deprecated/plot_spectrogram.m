function plot_spectrogram(y,y_lenght,window,over_lap)
    fs=187;
    nftt = y_lenght;
    calc_spectrogram(y,window,over_lap,nftt,fs );
    function calc_spectrogram(y,window,over_lap,nftt,fs)
        spectrogram(y,window,over_lap,nftt,fs, 'yaxis');
    end
end
