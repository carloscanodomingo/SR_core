% GET FIRST WEEK
first_week_SR_09_2015_NS = SR09_2015_NS((day([SR09_2015_NS.time_start]) < 7));
maximum_first_week = arrayfun(@(x) process_schumann_peak.get_maximum_first_SR_smooth(x,1),first_week_SR_09_2015_NS);
maximum_first_week = maximum_first_week(maximum_first_week ~= -1);
mean(maximum_first_week)

% GET FIRST WEEK FROM 12 to 18
first_week_day_SR_09_2015_NS = first_week_SR_09_2015_NS((hour([first_week_SR_09_2015_NS.time_start]) >= 12) & (hour([first_week_SR_09_2015_NS.time_start]) < 18) );
maximum_first_week_day = arrayfun(@(x) process_schumann_peak.get_maximum_first_SR_smooth(x,1),first_week_day_SR_09_2015_NS);
maximum_first_week_day = maximum_first_week_day(maximum_first_week_day ~= -1);
mean(maximum_first_week_day)

% GET FIRST WEEK FROM 00 to 6
first_week_night_SR_09_2015_NS = first_week_SR_09_2015_NS((hour([first_week_SR_09_2015_NS.time_start]) >= 00) & (hour([first_week_SR_09_2015_NS.time_start]) < 6));
maximum_first_week_night = arrayfun(@(x) process_schumann_peak.get_maximum_first_SR_smooth(x,1),first_week_night_SR_09_2015_NS);
maximum_first_week_night = maximum_first_week_night(maximum_first_week_night ~= -1);
mean(maximum_first_week_night)


figure(1)
subplot(3,1,1)
plot(maximum_first_week);
subplot(3,1,2)
plot(maximum_first_week_day);
subplot(3,1,3)
plot(maximum_first_week_night);

maximum_mean = zeros(1,30);
maximum_mean_day = zeros(1,30);
maximum_mean_night = zeros(1,30);
figure(2)
for i = 1:30
    % GET FOR one day
    current_SR_09_2015_NS = SR09_2015_NS((day([SR09_2015_NS.time_start]) == i));
    current_maximum_first_week = arrayfun(@(x) process_schumann_peak.get_maximum_first_SR_smooth(x,1),current_SR_09_2015_NS);
    current_maximum_first_week = current_maximum_first_week(current_maximum_first_week ~= -1);
    maximum_mean(i) = mean(current_maximum_first_week);
    % GET maximum for the day
    current_day_SR_09_2015_NS = current_SR_09_2015_NS((hour([current_SR_09_2015_NS.time_start]) >= 12) & (hour([current_SR_09_2015_NS.time_start]) < 18) );
    current_maximum_first_week_day = arrayfun(@(x) process_schumann_peak.get_maximum_first_SR_smooth(x,1),current_day_SR_09_2015_NS);
    current_maximum_first_week_day = current_maximum_first_week_day(current_maximum_first_week_day ~= -1);
    maximum_mean_day(i) = mean(current_maximum_first_week_day);
    
    % GET maximum for the night
    current_night_SR_09_2015_NS = current_SR_09_2015_NS((hour([current_SR_09_2015_NS.time_start]) >= 0) & (hour([current_SR_09_2015_NS.time_start]) < 6) );
    current_maximum_first_week_night = arrayfun(@(x) process_schumann_peak.get_maximum_first_SR_smooth(x,1),current_night_SR_09_2015_NS);
    current_maximum_first_week_night = current_maximum_first_week_night(current_maximum_first_week_night ~= -1);
    maximum_mean_night(i) = mean(current_maximum_first_week_night);
end

figure(2)
subplot(3,1,1)
plot(maximum_mean);
subplot(3,1,2)
plot(maximum_mean_day);
subplot(3,1,3)
plot(maximum_mean_night);


display("mean month " + mean(maximum_mean))
display("mean month daylight " + mean(maximum_mean_day))
display("day mean month nightlight:" + mean(maximum_mean_night))