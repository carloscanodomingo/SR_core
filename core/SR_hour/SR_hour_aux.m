classdef SR_hour_aux
 %SR_peak_process_array Summary of this class goes here
    %   Detailed explanation goes here
    
        methods(Static)
            function [year_hours_SR_array, noisy_percent] = get_hours_year(year_schumann_peak, margin, option,component, noisy_method)
            
                % clear year array
                year_hours_SR_array = []; 
                noisy_percent = zeros(1,length(year_schumann_peak));
                % Loop for going over the year
                for i = 1: length(year_schumann_peak)

                    
                    % Get the current month
                    month_schumann_peak = year_schumann_peak{i};

                    %remove noisy samples.
                    selected = SR_peak_process_array.select_not_noisy( month_schumann_peak,component, noisy_method);
                    noisy_percent(i) = sum(selected)/ length(month_schumann_peak);
                    
                    month_selected = month_schumann_peak(selected);
                    % Compute the values for the month
                    [f_mean_month, f_std_month, val_mean_month, val_std_month ] =  SR_peak_process_array.maximum_hours(month_selected, margin, option);
                    
                   
                    
                    % add month though the year
                    year_hours_SR_array = [year_hours_SR_array , SR_hour(f_mean_month,f_std_month, val_mean_month, val_std_month)];
                end
            end
        
            function year_hours_SR_array_discriminated = get_hours_year_discriminated(year_schumann_peak, margin, option)
            year_hours_SR_array = [];
            for i = 1: length(year_schumann_peak)
                month_schumann_peak = year_schumann_peak{i};
                month_schumann_peak_discriminated = month_schumann_peak;
                [mean_month, std_month] =  SR_peak_process_array.maximum_hours(month_schumann_peak, margin, option);
                year_hours_SR_array = [year_hours_SR_array , SR_hour(mean_month,std_month)];
            end
        end
        
        function array_day_SR = get_days_year(year_schumann_peak, margin, option, interval, component, method)
            
            array_day_SR = [];
            
            validateattributes(interval,{'numeric'},{'row', 'numel', 2, '>=',0,'<=',23, 'nondecreasing'})
            get_function = SR_peak_process_array.get_function_get_freq(option);
            
            % Loop for going over the year
            for i = 1: length(year_schumann_peak)
                
                % Get the current month
                month_schumann_peak = year_schumann_peak{i};
               
                % Compute index
                start_day = min(day([month_schumann_peak.time_start]));
                end_day = max(day([month_schumann_peak.time_start]));
                
                % Loop for going over the whole month
                for k = start_day : end_day
                    
                    % Get the current day
                    current_day_SR_array =  month_schumann_peak((day([month_schumann_peak.time_start]) == k));
                                        % Check if there are no data in the current day
                    if isempty(current_day_SR_array)
                        display("problem in month " + i + " day: " + k + " idx: " + length(array_day_SR));
                        continue
                    end                                        
                                 %current_day_SR_array_selected = current_day_SR_array;       


                   selected =  SR_peak_process_array.select_not_noisy(current_day_SR_array, component, method);
                   current_day_SR_array_selected = current_day_SR_array(selected);
                    if isempty(current_day_SR_array_selected)
                        display("SELECTED: problem in month " + i + " day: " + k + " idx: " + length(array_day_SR));
                        continue
                    end
                    if (interval(1) == 23)
                        interval(2) = 23;
                    end
                    current_day_SR_array_select_hour = current_day_SR_array_selected((hour([current_day_SR_array_selected.time_start]) >= interval(1)) & hour([current_day_SR_array_selected.time_start]) <= interval(2));
                    if isempty(current_day_SR_array_select_hour)
                        continue
                    end
    
                    [f_mean_hours, f_std_hours, val_mean_hours, val_std_hours] = SR_peak_process_array.maximum_day(current_day_SR_array_select_hour, margin, option);
                    date_day = datetime(year(current_day_SR_array_select_hour(1).time_start), month(current_day_SR_array_select_hour(1).time_start), day(current_day_SR_array_select_hour(1).time_start));
                    day_select_f = SR_day(date_day, f_mean_hours, f_std_hours, val_mean_hours, val_std_hours); 
                    array_day_SR = [array_day_SR, day_select_f];
                end
            end
        end
            function plot_day_max_first_SR(data)
             %y_axis_limit = [7 8];   
               for i=1:8
                figure(i)
                subplot(3,1,1)
                plot(data{1}(:,i));
                title("Average max fisrt during a day");
                %ylim(y_axis_limit);
                subplot(3,1,2)
                plot(data{2}(:,i));
                title("Average max fisrt during a daylight 12:00 to 18:00");
               % ylim(y_axis_limit);
                subplot(3,1,3)
                plot(data{3}(:,i));
                title("Average max fisrt during a night 00:00 to 6:00");
               % ylim(y_axis_limit);
               end
            end
            function funct = get_function_get_freq(option)
                if strcmp(option, 'maximum')
                    funct = @process_schumann_peak.get_maximum_SR_smooth;
                elseif strcmp(option, 'peak')
                    funct = @process_schumann_peak.get_peak_SR_smooth;
                end

            end
                
    end
end

