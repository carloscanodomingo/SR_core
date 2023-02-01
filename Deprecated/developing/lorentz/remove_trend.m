close all

%% EXAMPLE
t = 0:300;
dailyFluct = gallery('normaldata',size(t),2); 
sdata = cumsum(dailyFluct) + 20 + t/100;
figure(1)
plot(t,sdata);
legend('Original Data','Location','northwest');
xlabel('Time (days)');
ylabel('Stock Price (dollars)');

detrend_sdata = detrend(sdata);
strend = sdata - detrend_sdata;
mean(detrend_sdata)


hold on
plot(t,strend,':r')
plot(t,detrend_sdata,'m')
plot(t,zeros(size(t)),':k')
legend('Original Data','Trend','Detrended Data',...
       'Mean of Detrended Data','Location','northwest')
xlabel('Time (days)'); 
ylabel('Stock Price (dollars)');
%% OUR DATA
if exist('data_1','var') == 0
    load("data_1.mat")
end
if exist('SR_2018_EW','var') == 0
    load('SR_2018_EW.mat')
end
if exist('SR_2018_NS','var') == 0
    load('SR_2018_Ns.mat')
end
month = SR_2018_NS{1};
SR_f = buffer([month.SR_f],8);
bad_SR = month(SR_f(1,:) > 8.5);

first_bad_SR = bad_SR(1);
good_SR = month(SR_f(1,:) < 8 & SR_f(1,:) > 7.4 );
first_good_SR = good_SR(1);
%data = data_1.raw_data_f;
SR = first_good_SR;
data = SR.raw_data_f;
freq = SR.freq;
%freq = data_1.freq(data_1.freq > 3 & data_1.freq < 45);
%data = data_1.filter_data_f(data_1.freq > 3 & data_1.freq < 45)';

figure(2)
plot(freq,data);
legend('Original Data','Location','northwest');
xlabel('freq (Hz)');
ylabel('PSD (dBPT)');

detrend_data = detrend(data,5);
trend = data - detrend_data;
mean(detrend_data)

hold on
plot(freq,trend,':r')
plot(freq,detrend_data,'m')
plot(freq,zeros(size(freq)),':k')
legend('Original Data','Trend','Detrended Data',...
       'Mean of Detrended Data','Location','northwest')
xlabel('freq (Hz)');
ylabel('PSD (dBPT)');

interval_freq = (data_1.freq > 5 & data_1.freq < 43);
detrend_data_with_offset = detrend_data - min(detrend_data);
weight = interval_freq/1;
figure(3)
[fitresult, gof] = Fits(freq, detrend_data_with_offset, weight)
figure(4)
start_points = [7.83 14.3 20.8 27.3 33.8 39 45];
start_points = data_1.SR_f(1:7);
%[fitresult_ref, gof] = reference(freq, detrend_data_with_offset, weight ,start_points);
[fitresult_completed_offset, gof] = fit_no_robust(freq, detrend_data_with_offset, weight ,start_points);
%[fitresult, gof] = Fits_six(freq, detrend_data_with_offset, weight ,start_points);

detrend_data_with_offset = detrend_data - min(detrend_data(interval_freq));
%[fitresult, gof] = reference(freq, detrend_data_with_offset, weight ,start_points);
[fitresult_uncompleted_offset, gof] = fit_no_robust(freq, detrend_data_with_offset, weight ,start_points);
%[fitresult, gof] = Fits_six(freq, detrend_data_with_offset, weight ,start_points);
detrend_data_with_offset = detrend_data;
%[fitresult, gof] = reference(freq, detrend_data_with_offset, weight ,start_points);
%[fitresult, gof] = fit_no_robust(freq, detrend_data_with_offset, weight ,start_points);
%[fitresult, gof] = Fits_six(freq, detrend_data_with_offset, weight ,start_points);


%coeff = coeffvalues(fitresult);
%Qfactor = coeff(1:6);
%f = coeff(7:12);
%val = coeff(12:18);
%%TEST LORENTZ




