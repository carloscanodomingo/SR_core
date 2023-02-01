classdef SR_peak_process_array
    %SR_peak_process_array Summary of this class goes here
    %   Detailed explanation goes here
    
    
    methods(Static)
        function [f_mean_hours, f_std_hours, val_mean_hours, val_std_hours] = maximum_hours(array_schumann_peak, margin, option)
           
            % Get funciton reference for compute the peak through option
            % value
            get_function = SR_peak_process_array.get_function_get_freq(option);
            
            % Get the first and last day in the month
            start_day = min(day([array_schumann_peak.time_start]));
            end_day = max(day([array_schumann_peak.time_start]));

            %Predefine cells
            cell_hours_f = cell(1,24);
            cell_hours_val = cell(1,24);
            
            % Loop for going over the month
            for index_day = start_day : end_day
                
                % Select only SR_array object with the selected day
                current_day_SR_array =  array_schumann_peak((day([array_schumann_peak.time_start]) == index_day));
                
                % Do nothing if the day has no data
                if isempty(current_day_SR_array)
                    continue
                end
                
                % Loop for going over the day
                for index_hour = 1:24
                    % Correct diferences between index and real hours
                    current_hour = index_hour - 1; 
                    
                    % Select only SR object for the specified hour in the current day 
                    current_hour_SR_array = current_day_SR_array((hour([current_day_SR_array.time_start]) == current_hour));
                    
                    % Calculated the SR frequencies and the value of their
                    % frequencies
                    [current_maximum_hour_f_cell, current_maximum_hour_value_cell] = arrayfun(@(x) get_function(x,margin),current_hour_SR_array, 'UniformOutput', false);


                    % If not empty fill the cell with the correct form of
                    % the matrix
                    if isempty(current_maximum_hour_f_cell) == 0  
                        current_maximum_hour_f = buffer(cell2mat(current_maximum_hour_f_cell),8);
                        cell_hours_f{index_hour} = [cell_hours_f{index_hour}, current_maximum_hour_f];
                    end
                    
                    if isempty(current_maximum_hour_value_cell) == 0  
                        current_maximum_hour_val = buffer(cell2mat(current_maximum_hour_value_cell),8);
                        cell_hours_val{index_hour} = [cell_hours_val{index_hour}, current_maximum_hour_val];
                    end
                    
                end
            end
            
            % Init mean and std for the day
            f_mean_hours = zeros(8,24);
            f_std_hours = zeros(8,24);
            val_mean_hours = zeros(8,24);
            val_std_hours = zeros(8,24);
            
            % Loop fot going over the hours of the whole month
            for index_hour = 1:24                 
                %Change local time for UTC
                %next_datetime = datetime(current_year, current_month, index_day, index_hour - 1, 0, 0, 'Timezone', 'Europe/Madrid');
                %next_datetime.TimeZone = 'UTC';
                %index_hour_utc = (hour(next_datetime) + 1) ;
                if (size(cell_hours_f{index_hour },2) == 1)
                    f_mean_hours(:,index_hour) = (cell_hours_f{index_hour}');
                    f_std_hours(:,index_hour) = 0.1;
                else
                    f_mean_hours(:,index_hour) = mean(cell_hours_f{index_hour}');
                    f_std_hours(:,index_hour) = std(cell_hours_f{index_hour}');
                end
                
                if (size(cell_hours_val{index_hour },2) == 1)
                    val_mean_hours(:,index_hour) = (cell_hours_val{index_hour}');
                    val_std_hours(:,index_hour) = (cell_hours_val{index_hour}');
                else
                    val_mean_hours(:,index_hour) = mean(cell_hours_val{index_hour}');
                    val_std_hours(:,index_hour) = std(cell_hours_val{index_hour}');
                end
                
                
            end
        end
        
        function [f_mean_hours, f_std_hours, val_mean_hours, val_std_hours] = maximum_day(day_array_schumann_peak, margin, option)
            
            get_function = SR_peak_process_array.get_function_get_freq(option);
            
           
           [maximum_day_f, maximum_day_val] = arrayfun(@(x) get_function(x,margin),day_array_schumann_peak, 'UniformOutput', false);
           day_f = buffer(cell2mat(maximum_day_f),8);
           day_val = buffer(cell2mat(maximum_day_val),8);
            
           if(length(maximum_day_f) ~= 1)
                f_mean_hours = mean(day_f');
                f_std_hours = std(day_f');
           else
               f_mean_hours = day_f';
               f_std_hours = zeros(1,8);
           end
           if(length(maximum_day_f) ~= 1)
             val_mean_hours = mean(day_val');
             val_std_hours = std(day_val');
           else
               val_mean_hours = day_val';
               val_std_hours = zeros(1,8);
           end


           
        end
        function  SR_peak_object_array = calculate_fit_lorentz_classification(SR_peak_object_array,version)
            tic
            parfor i=1:length(SR_peak_object_array)
                SR_peak_object_array(i).lorentz = SR_lorentz(SR_peak_object_array(i),version);
                SR_peak_object_array(i).classification = SR_classification(SR_peak_object_array(i));
            end
            toc
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
            if strcmp(option, SR_config.types_get_peak(1))
                funct = @SR_peak_process.get_maximum_SR_smooth;
            elseif strcmp(option, SR_config.types_get_peak(2))
                funct = @SR_peak_process.get_peak_SR_smooth;
            elseif strcmp(option, SR_config.types_get_peak(3))
                funct = @SR_peak_process.get_peak_lorentz_raw;
            end

        end
                function plot_array(SR_array, option)
                        for i = 1:length(SR_array)
                            figure(i)
                            if strcmp(option, 'raw')
                                SR_y = SR_array(i).raw_data_f;

                            elseif strcmp(option, 'filter')
                                SR_y = SR_array(i).filter_data_f;

                            elseif strcmp (option, 'smooth')
                                SR_y = SR_array(i).smooth_data_f;
                            end
                            plot(SR_array(i).freq, SR_y);
                        end
                end
                
            function selected = select_not_noisy(array_schumann_peak, component, method)
                SR_classification_current = [array_schumann_peak.classification];
                    
                if method == 1 
                    scale = 1;
                    %selected_schumann_peak = ones(1,length(array_schumann_peak);
                    % 5 METHODS
                    % POWER BAND LOW F
                    PB_low_f = [SR_classification_current.PB_low_f];
                    limit = median(PB_low_f) + scale * std(PB_low_f);
                    selected_first_method = (PB_low_f < limit);  

                    % ST MEAN
                    ST_mean = [SR_classification_current.ST_mean];
                    limit = median(ST_mean) + scale * std(ST_mean);
                    selected_second_method =  (ST_mean < limit);

                    % ST STD
                    ST_std = [SR_classification_current.ST_std];
                    limit = median(ST_std) + scale * std(ST_std);
                    selected_third_method =  (ST_std < limit);

                    % Ratio BW max
                    PS_ratio_max = [SR_classification_current.PS_ratio_max];
                    limit = median(PS_ratio_max) + scale * std(PS_ratio_max);
                    selected_fourth_method =  (PS_ratio_max < limit & PS_ratio_max > 0);

                    % Location
                    LORENTZ_location = [SR_classification_current.LORENTZ_location];
                    selected_fifth_method =  (LORENTZ_location < 8 & LORENTZ_location > 7.5);

                    % LORENTZ FIT
                    FITLORENTZ_first_lorentz = [SR_classification_current.FITLORENTZ_first_lorentz];
                    selected_LAST_method =  (FITLORENTZ_first_lorentz < 8.2 & FITLORENTZ_first_lorentz > 7.5);


                    selected = (selected_first_method & selected_second_method & selected_third_method & selected_fourth_method & selected_fifth_method & selected_LAST_method);
                elseif    method == 2
                    num_filter = 4;
                    filter_array = ones(num_filter, length(SR_classification_current));
                    filter_index = 1;
                    % ST MEAN / STD
                    ST_mean_std = [SR_classification_current.ST_mean] ./ [SR_classification_current.ST_std];
                    limit = 4;
                    filter_array(filter_index,:) =  (ST_mean_std < limit);

                    filter_index = filter_index + 1;
                    % Ratio BW max
                    PS_ratio_max = [SR_classification_current.PS_ratio_max];
                    limit = 10;
                    filter_array(filter_index,:) =  (PS_ratio_max < limit & PS_ratio_max > 0);

                    % Location
                    filter_index = filter_index + 1;
                    LORENTZ_location = [SR_classification_current.LORENTZ_location];
                    filter_array(filter_index,:) =  (LORENTZ_location < 8.2 & LORENTZ_location > 7.5);

                    % LORENTZ FIT
                    filter_index = filter_index + 1;
                    FITLORENTZ_first_lorentz = [SR_classification_current.FITLORENTZ_first_lorentz];
                    filter_array(filter_index,:) =  (FITLORENTZ_first_lorentz < 8.2 & FITLORENTZ_first_lorentz > 7.5);
                    
                    selected = ones(1, length(SR_classification_current));
                    for i = 1:num_filter
                        selected = (selected & filter_array(i,:));
                    end
               
                elseif  method == 3
                    num_filter = 6;

                    filter_array = ones(num_filter, length(SR_classification_current));
                    filter_index = 1;
                    
                    ST_std = [SR_classification_current.ST_std];
                    
                    if strcmp(component,"NS")
                    limit = 3.2;
                    elseif strcmp(component, "EW")
                    limit = 4;
                    end
                    filter_array(filter_index,:) =  (ST_std < limit);
                    
                    
                    % ST MEAN
                    filter_index = filter_index + 1;
                    ST_mean = [SR_classification_current.ST_mean];

                    if strcmp(component,"NS")
                        limit = 15;
                    elseif strcmp(component, "EW")
                        limit = 20;
                    end
                    filter_array(filter_index,:) =  (ST_mean < limit);
                    
                    % Ratio BW max
                    filter_index = filter_index + 1;
                    PS_ratio_max = [SR_classification_current.PS_ratio_max];
                    if strcmp(component,"NS")
                        limit = 5;
                    elseif strcmp(component, "EW")
                        limit = 6;
                    end
                    filter_array(filter_index,:) =  (PS_ratio_max < limit & PS_ratio_max > 0);
                    
                    % RMSE
                    filter_index = filter_index + 1;
                    LORENTZ_rmse = [SR_classification_current.LORENTZ_rmse];
                    if strcmp(component,"NS")
                        limit = 1.7;
                    elseif strcmp(component, "EW")
                        limit = 2.5;
                    end
                    filter_array(filter_index,:) =  (LORENTZ_rmse < limit);

                    % Location
                    filter_index = filter_index + 1;
                    LORENTZ_location = [SR_classification_current.LORENTZ_location];
                    filter_array(filter_index,:) =  (LORENTZ_location < 8.2 & LORENTZ_location > 7.5);

                    % LORENTZ FIT
                    filter_index = filter_index + 1;
                    FITLORENTZ_first_lorentz = [SR_classification_current.FITLORENTZ_first_lorentz];
                    filter_array(filter_index,:) =  (FITLORENTZ_first_lorentz < 8.2 & FITLORENTZ_first_lorentz > 7.4);
                    
                    selected = ones(1, length(SR_classification_current));
                    for i = 1:num_filter
                        selected = (selected & filter_array(num_filter - i + 1,:));
                        sum(selected);
                    end
                   
                end
            end
            function array_schumann_peak = add_station(array_schumann_peak_in, station)
            arguments
                array_schumann_peak_in, 
                station {mustBeMember(station,["MEX","ALM"])}
            end
            array_schumann_peak = array_schumann_peak_in;
                for index_array = 1:length(array_schumann_peak_in)
                    array_schumann_peak(index_array).station = station;
                end
            end
     function scatter_correlation(array_schumann_peak)
         SR_classification_current = [array_schumann_peak.SR_classification];
         figure();
         subplot(3,1,1)
         
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.LORENTZ_location]);
         title("SR vs FIRST SR location")
         subplot(3,1,2)
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.LORENTZ_rmse]);
         title("SR vs FIRST SR rmse")
         subplot(3,1,3)
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.LORENTZ_sse]);
         title("FIRST SR vs sse")

                  figure();
         subplot(2,1,1)
         
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.ST_mean]);
         title("SR vs ST mean")
         subplot(2,1,2)
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.ST_std]);
         title("SR vs ST std")
         
         %Power band 
         figure();
         subplot(3,1,1)
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.PB_low_f]);
         title("SR vs PB low f")
         subplot(3,1,2)
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.PB_low_f_detrend]);
         title("SR vs PB low f detrend")
         subplot(3,1,3)
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.PB_ratio]);
         title("FIRST SR vs PB ratio")
         
          %Power band 
         figure();
         subplot(2,1,1)
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.PS_ratio_max]);
         title("SR vs ratio between maximums")
         subplot(2,1,2)
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],[SR_classification_current.PIB_detrend]);
         title("SR vs PIB detrend")

         
          %Power band 
         subplot(2,1,2)
         ratio_lorentz = SR_peak_process_array.extract_classificator(array_schumann_peak,"RATIO_LORENTZ");
         scatter([SR_classification_current.FITLORENTZ_first_lorentz],ratio_lorentz);
         title("SR vs ratio_lorentz")
         
     end
                    
    function value_array = extract_classificator(array_schumann_peak, classifier)
        if strcmp(classifier,"RATIO_LORENTZ")
            value_array = arrayfun(@(x) x.SR_classification.get_ratio_lorentz_raw(x),array_schumann_peak, 'UniformOutput', true);
        end
    end
    end
end

