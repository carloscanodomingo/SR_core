%close all
%clear all
%load('study_MLRG');
data_problem_1 = data_f(:, 80 );
data_problem_2 = data_f(:, 91 );
data_smooth_1 = smoothdata(data_problem_1,'sgolay',30,'Degree',2);
data_smooth_2 = smoothdata(data_problem_2,'sgolay',30,'Degree',2);
figure(1);
plot(f_x,data_smooth_1, 'r');
plot(f_x, data_smooth_1, 'g');
title('schumman resonance sample 80 10min HPF 3Hz ');
xlabel('Frequency (Hz)');
ylabel('Power (dB)');

figure(2)
plot(f_x,data_smooth_1, 'r');
plot(f_x, data_smooth_1, 'g');
title('schumman resonance sample 91 10min HPF 3Hz ');
xlabel('Frequency (Hz)');
ylabel('Power (dB)');




X1 = ([f(1,:);R2_pre])';

X2 = ([f(1,:);R2_post])';

X3 = ([R2_pre;R2_post])';


figure(3)
scatter(X1(:,1), X1(:,2), '+', 'MarkerFaceColor', 'k');
title('First Schuman frequency detected vs R2 coef pre-processed');
figure(4)
scatter(X2(:,1), X2(:,2), '+', 'MarkerFaceColor', 'k');
title('First Schuman frequency detected vs R2 coef post-processed');
figure(5)
scatter(X3(:,1), X3(:,2), '+', 'MarkerFaceColor', 'k');
title('R2 coef pre-processed vs R2 coef post-processed');