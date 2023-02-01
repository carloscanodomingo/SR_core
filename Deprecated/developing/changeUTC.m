SR_hour_data = SR_hour_max;
for index_year=1:length(SR_hour_data.hours_array)
    hours_array = SR_hour_data.hours_array{index_year};
    for index_month=1:length(hours_array)
        SR_hour_current = hours_array(index_month);
        for index_hour = 1:24
               
               date = datetime(values(index_year),'ConvertFrom','datenum','Timezone','UTC');
               date.TimeZone = 'Europe/Madrid';
               x_values(index_year) = hour(date) + minute(date)/60;
               line([x_values(index_year) x_values(index_year)], [0 100],'LineStyle','--', 'Color', [0, 0, 0] + 0.3,'LineWidth', 0.8);
end
            utc_hour = 
        SR_hour_current.f_mean_per_hour
        
    end
end
