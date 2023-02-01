% Bilinear transformation
% from analog filter to digital filter
%Analog filter (wc= 63rad/s = 10Hz.):
num=[63]; % transfer function numerator;
den=[1 63]; %transfer function denominator
%Digital filter
fs=120; %sampling frequency in Hz.
%bilinear transformation:
[numd,dend]= bilinear(num,den,fs);
%logaritmic set of frequency values in Hz:
f=logspace(-1,2);
G=freqz(numd,dend,f,fs); %computes frequency response
AG=20*log10(abs(G)); %take decibels
FI=angle(G); %take phases (rad)
subplot(2,1,1); semilogx(f,AG,'k'); %plots decibels
grid;axis([1 100 -25 5]);
ylabel('dB');
title('frequency response forthe bilinear transformation')
subplot(2,1,2); semilogx(f,FI,'k'); %plots phases
grid;axis([1 100 -1.5 0]);
ylabel('rad.'); xlabel('Hz.')