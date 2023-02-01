function [y_fft_V f] = Copia_fft_manolo(y,length_y,fs)
    nfft = 1*(2^nextpow2(length_y));   %Para un cálculo mas eficiente se hace la FFT potencia de 2
    nfft = length_y;           %Se deja el origial
    NumUniquePts = ceil((nfft+1)/2); %Son los puntos únicos 
    f = (0:NumUniquePts-1)*fs/nfft; %Vector frecuencias
    y_fft = fft(y,nfft);
    y_fft_single = y_fft(1:NumUniquePts);
    y_fft_abs_single = abs(y_fft_single);
    if rem(nfft, 2) % odd nfft excludes Nyquist point
        y_fft_abs_single(2:end) = y_fft_abs_single(2:end)*2;
    else
        y_fft_abs_single(2:end -1) = y_fft_abs_single(2:end -1)*2;
    end
    y_fft_V = y_fft_abs_single/length_y;  %Espectro de tensión
end