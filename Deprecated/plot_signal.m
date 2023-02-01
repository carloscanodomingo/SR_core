function [] = plot_signal(index, y)
Fs = 187;
figure(index)
subplot(3,2,1)
plot(y)
subplot(3,2,2)
fft_complet(y, length(y));
subplot(3,2,3)
[mss,f] = welch_v_schumman(y, length(y)/10, length(y)/20, index);
subplot(3,2,5)
plot_pspectrum(y, Fs);
subplot(3,2,[4, 6])
pspectrum(y, Fs, 'spectrogram');
plot_spectrogram(y_cal,length(y_cal),length(y_cal)/100,1);
end

