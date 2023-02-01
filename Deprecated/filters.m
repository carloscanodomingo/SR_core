Fs = 187;
Fn = Fs/2;             % Nyquist Frequency
Fc = 3;
N = 120;
N = 2*fix(N/2);
wndw = blackman(N+1);
clf
b = fir1(N, Fc/Fn, 'high', wndw);

%y = y_buffer(:,66);

plot_signal(1,y);
y_cal_filter = filter(b,1,y);
plot_signal(2,y_cal_filter);


wo = 50/(187/2);  
bw = wo/35;
[b,a] = iirnotch(wo,bw);
y_cal_notch = filter(b,a,y);
plot_signal(3,y_cal_notch);


wo = 50/(187/2);  
bw = wo/35;
[b,a] = iirnotch(wo,bw);
y_cal_both = filter(b,a,y_cal_filter);
plot_signal(4,y_cal_both);


