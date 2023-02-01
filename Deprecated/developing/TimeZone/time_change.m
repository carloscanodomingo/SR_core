sunrise(37.1, -2.7, 700, 0, datenum(2016,6,15));
values = zeros(1,3);
x_values =  zeros(1,3);
SR_hour_max.plot_month(1,'f',6);
[values(1),values(2),values(3)]=sunrise(37.1, -2.7, 700, 0, datenum(2016,6,15));
x_values = sort(x_values);
for i=1:length(values)
    date = datetime(values(i),'ConvertFrom','datenum','Timezone','UTC');
    date.TimeZone = 'Europe/Madrid';
    x_values(i) = hour(date) + minute(date)/60;
    line([x_values(i) x_values(i)], [0 100],'LineStyle','--', 'Color', [0, 0, 0] + 0.3,'LineWidth', 0.8);
end

