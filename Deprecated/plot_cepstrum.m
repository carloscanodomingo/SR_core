function plot_cepstrum(y_cal)
%PLOT_CEPSTRUM Summary of this function goes here
%   Detailed explanation goes here
cz=rceps(y_cal); %real cepstrum
plot(cz,'k'); %plots cepstrum
ylabel('cepstrum'); xlabel('seconds');
end

