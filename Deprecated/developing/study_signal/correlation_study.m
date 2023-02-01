%load('correlation_study.mat');
f_x = linspace(0,93.5,1871);
threshold_min = 0.5;
threshold_max = 5;
selected_freq = (f_x > threshold_min & f_x < threshold_max);
%sat_measure = sum(data_splitted > 
low_f_psd = sum(((data_f(selected_freq, :))));
raw_low_f_psd = sum((abs(raw_data_f(selected_freq, :))));
ratio_low_f_psd = raw_low_f_psd ./  (sum((abs(raw_data_f(f_x < 93.5, :)))));

X1_1 = ([f(1,:);ratio_low_f_psd])';
X1_2 = ([f(2,:);ratio_low_f_psd])';
X1_3 = ([f(3,:);ratio_low_f_psd])';
X1_4 = ([f(4,:);ratio_low_f_psd])';

X2 = ([f(3,:);raw_low_f_psd])';


figure(1)
subplot(2,2,1)
scatter(X1_1(:,1), X1_1(:,2), '+', 'MarkerFaceColor', 'k');
title('First Resonance');
subplot(2,2,2)
scatter(X1_2(:,1), X1_2(:,2), '+', 'MarkerFaceColor', 'k');
title('Second Resonance');
subplot(2,2,3)
scatter(X1_3(:,1), X1_3(:,2), '+', 'MarkerFaceColor', 'k');
title('Third Resonance');
subplot(2,2,4)
scatter(X1_4(:,1), X1_4(:,2), '+', 'MarkerFaceColor', 'k');
title('Fouth Resonance');

figure(2)
scatter(X2(:,1), X2(:,2), '+', 'MarkerFaceColor', 'k');
title('Correlation between unfiltered low frecuency psd and FRS');

X3 = ([f(1,:);ratio_low_f_psd])';
figure(3)
scatter(X3(:,1), X3(:,2), '+', 'MarkerFaceColor', 'k');
title('Correlation between unfiltered ratio low frecuency psd and FRS');
%%% raw_low_f_psd discrimination

Threshold = 0.03 ;
selected_f_discriminated = (ratio_low_f_psd < Threshold);

f_discriminated = f(1,selected_f_discriminated);


X4 = ([f_discriminated(1,:);ratio_low_f_psd(selected_f_discriminated)])';

figure(4)
scatter(X4(:,1), X4(:,2), '+', 'MarkerEdgeColor', [1 0.2 0.3], 'MarkerFaceColor', 'r');
title('Correlation between unfiltered ratio low frecuency psd and FRS after discrimination lfPSD');
%%% correlation bw low_f_psd and MRLG R2 coefficient post processed
disp("Ratio discriminated: " + length(f_discriminated)/size(data_f,2));
anormal_frequencies = sum(f(1,:) < 7.3 | f(1,:) > 8.3);
anormal_frequencies_discriminated = sum(f(1,selected_f_discriminated) < 7.3 | f(1,selected_f_discriminated) > 8.3);
disp("anormal frequencies total: " + anormal_frequencies);
disp("anormal frequencies after discrimination: " + anormal_frequencies_discriminated);
disp("anormal frequencies ratio discrimination: " + anormal_frequencies_discriminated/anormal_frequencies);
disp("false positive lost: " + (anormal_frequencies -anormal_frequencies_discriminated) / (size(data_f,2) - length(f_discriminated)));  


X5 = ([R2_post;ratio_low_f_psd])';
figure(5)
scatter(X5(:,1), X5(:,2), '+', 'MarkerFaceColor', 'k');
title('correlation bw low_f_psd and MRLG R2 coefficient post processed');


%%% Correlation with the discrimited date and the MLRG


X6 = ([R2_post(selected_f_discriminated);ratio_low_f_psd(1,selected_f_discriminated)])';
figure(6)
scatter(X6(:,1), X6(:,2), '+', 'MarkerEdgeColor', [1 0.2 0.3], 'MarkerFaceColor', 'r');
title('correlation bw low_f_psd and MRLG R2 coefficient post processed in discriminated freq');



%%% Correlation  MLRG
X7 = ([f(1,:);R2_post])';
figure(7)
scatter(X7(:,1), X7(:,2), '+', 'MarkerFaceColor', 'k');
title('First Schuman frequency detected vs R2 coef post-processed')

%%% Correlation  width
X8 = ([f(1,:);width(1,:)])';
figure(8)
scatter(X8(:,1), X8(:,2), '+', 'MarkerFaceColor', 'k');
title('First Schuman frequency detected vs width peak')


X9 = ([f_discriminated(1,:);width(1,selected_f_discriminated)])';
figure(9)
scatter(X9(:,1), X9(:,2), '+', 'MarkerEdgeColor', [1 0.2 0.3], 'MarkerFaceColor', 'k');
title('correlation discriminated frequency peak and peak witdh');

X10_1 = ([f(1,(selected_f_discriminated));ratio_low_f_psd(selected_f_discriminated)])';
X10_2 = ([f(2,(selected_f_discriminated));ratio_low_f_psd(selected_f_discriminated)])';
X10_3 = ([f(3,(selected_f_discriminated));ratio_low_f_psd(selected_f_discriminated)])';
X10_4 = ([f(4,(selected_f_discriminated));ratio_low_f_psd(selected_f_discriminated)])';


figure(10)
subplot(2,2,1)
scatter(X10_1(:,1), X10_1(:,2), '+', 'MarkerFaceColor', 'k');
title('First Resonance');
subplot(2,2,2)
scatter(X10_2(:,1), X10_2(:,2), '+', 'MarkerFaceColor', 'k');
title('Second Resonance');
subplot(2,2,3)
scatter(X10_3(:,1), X10_3(:,2), '+', 'MarkerFaceColor', 'k');
title('Third Resonance');
subplot(2,2,4)
scatter(X10_4(:,1), X10_4(:,2), '+', 'MarkerFaceColor', 'k');
title('Fouth Resonance');
