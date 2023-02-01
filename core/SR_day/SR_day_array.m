classdef SR_day_array < handle
    %SR_DAY_ARRAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        component;
        relevant_parameter;
        days_array;
        days_array_intervals
        num_intervals;
        start_year = SR_config_base.start_year;
        end_year = SR_config_base.end_year;
        days_year = 1:366;
        selected_interval;
        selected_mode;
        fit_frequency; 
        values_val;
        values_frequency;
        fit_val;
    end
    properties (Constant)
        line_style = repmat(["-","-.", "--",":"],1,24);
        marker_style = repmat(['^','o','s','h','p','x','v'],1,100)
        total_hours = SR_config_base.total_hours;
    end
    
    methods
        function obj = SR_day_array(margin,component,option, num_intervals, method)
  
            % Check attributes
            validateattributes(margin,{'numeric'},{'>',0,'<=',SR_hour.schumann_fc(1)})
            validateattributes(num_intervals,{'numeric'},{'>',1,'<=',24})
            
            
            
            mustBeMember(component,SR_hour.component);
            mustBeMember(option,SR_peak_process.types_get_peak);
            
            obj.component = component;
            
            obj.num_intervals = num_intervals;
            days_array_intervals = cell(1, obj.num_intervals);
            obj.selected_interval = ones(1,obj.num_intervals);
            
            % predefine array
            obj.days_array = cell(1, SR_hour_array.end_year - SR_hour_array.start_year + 1);
            
            for index_interval = 1:obj.num_intervals
                obj.days_array_intervals{index_interval} = cell(1, SR_hour_array.end_year - SR_hour_array.start_year + 1);
            end
            
            % Loop for going over the years/ files
            for index_year = SR_config.start_year:SR_config.end_year
                
                
                SR_year_pre = SR_data.load_year(index_year, component, SR_config.current_version);
                % Compute the mean for every hours in chunck of a month
                %current_year = process_year_schumann_peak.get_days_year(SR_year_pre,margin, option, [0,23]);
                
                % Add to the object array
                %obj.days_array{index_year - SR_hour_array.start_year + 1} = current_year;
                
                for index_interval = 1:obj.num_intervals
                    interval_width = obj.total_hours / obj.num_intervals;
                    interval = [(index_interval - 1) * interval_width, (index_interval * interval_width) - 1];
                    obj.days_array_intervals{index_interval}{index_year - SR_hour_array.start_year + 1} = SR_hour_aux.get_days_year(SR_year_pre,margin, option, interval,component,method);
                end
            end

                obj.get_fit_function('f', obj.start_year, obj.end_year)
                obj.get_fit_function('val', obj.start_year, obj.end_year)
                obj.array_relevant_parameters();
            
            
        end
        function get_fit_function(obj, type, start_year, end_year)
            % Check attributes
            validateattributes(start_year,{'numeric'},{'positive','>=',obj.start_year,'<=',obj.end_year,'integer'})
            validateattributes(end_year,{'numeric'},{'positive','>=',obj.start_year,'<=',obj.end_year,'integer'})
            validateattributes(end_year,{'numeric'},{'positive','>=',start_year,'integer'})
            mustBeMember(type,SR_hour_array.plot_type);
            
            num_years = end_year - start_year + 1;
            % Loop for going over the years
            first_year = start_year - obj.start_year + 1;
            last_year = first_year + num_years - 1;
            
            for index_sr_mode=1:SR_config.number_of_modes
                for index_year = first_year:last_year
                % Loop for going over all intervals
                
                    for index_interval = 1: obj.num_intervals
                
                        current_days_array_interval = obj.days_array_intervals{index_interval};
                        
                            % Get the current SR_hour array year
                        current_year = current_days_array_interval{index_year};

                        if strcmp(type,'f')
                            mean_data = buffer([current_year.mean_f],8);
                        elseif strcmp(type,'val')
                            mean_data = buffer([current_year.mean_val], 8);
                        end


                        mean_component = mean_data(index_sr_mode,:);
                        days = [current_year.day];

                        % Change to numeric values
                        days_enum = day(days,'dayofyear');

                        % filter
                        [fitresult,~] = SR_day_smooth_filter(days_enum, mean_component);
                        %Get result for every day in the year
                        fit_function{index_year,index_interval} = fitresult;
                        if index_interval == 24
                            index_interval = 24;
                        end
                        result_values{index_year,index_interval} = {mean_component;days};
                            %Get total mean
                    end
                end
                fit_result_array{index_sr_mode} = fit_function;    
                result_values_array{index_sr_mode} = result_values;
            end
            if strcmp(type,'f')
                obj.fit_frequency = fit_result_array;
                obj.values_frequency = result_values_array;
            elseif strcmp(type,'val')
                obj.fit_val= fit_result_array;
                obj.values_val = result_values_array;
            end;

        end
        function array_relevant_parameters(obj)
             
            for idx_sr_mode = 1:length(obj.values_frequency)
                current_mode_frequency = obj.values_frequency{idx_sr_mode};
                current_mode_intensity = obj.values_val{idx_sr_mode};
                for idx_interval = 1:(size(current_mode_frequency,2))
                    current_interval_frequency = current_mode_frequency(:,idx_interval);
                    current_interval_intensity = current_mode_intensity(:,idx_interval);
                    relevant_parameters_frequency = [];
                    relevant_parameters_intensity = [];
                    for idx_year = 1:size(current_interval_frequency)
                        
                        current_year_frequency  = current_interval_frequency{idx_year};
                        current_year_intensity = current_interval_intensity{idx_year};
                        
                        values_year_frequency = current_year_frequency{1};
                        values_year_intensity = current_year_intensity{1};
                        time_year = current_year_frequency{2};
                        
                        
                            
                        year_for_checking = mode(year(time_year));
                        min_month = min(month(time_year));
                        max_month = max(month(time_year));
                        
                        for index_month = min_month:max_month
                            select_index_month = (year(time_year) == year_for_checking) & month(time_year) == index_month;
                            
                            values_month_frequency = values_year_frequency(select_index_month);
                            values_month_intensity = values_year_intensity(select_index_month);
                            time_month = time_year(select_index_month);
                            relevant_parameters_frequency = [relevant_parameters_frequency, RelevantParameters(time_month, values_month_frequency)];
                            relevant_parameters_intensity = [relevant_parameters_intensity, RelevantParameters(time_month, values_month_intensity)];
                            
                        end
                             
                    end
                    relevant_parameters_matrix_freq{idx_sr_mode, idx_interval} = relevant_parameters_frequency;
                    relevant_parameters_matrix_int{idx_sr_mode, idx_interval} = relevant_parameters_intensity;

                end
            end
            obj.relevant_parameter = [];
            obj.relevant_parameter.frequency = relevant_parameters_matrix_freq;
            obj.relevant_parameter.intensity = relevant_parameters_matrix_int;
        end
        
        function plot_interval(obj, sr_mode, type, start_year, end_year)
            
            close 
            % Check attributes
            validateattributes(sr_mode,{'numeric'},{'positive','<=',SR_hour_array.SR_max_mode,'integer'})
            validateattributes(start_year,{'numeric'},{'positive','>=',obj.start_year,'<=',obj.end_year,'integer'})
            validateattributes(end_year,{'numeric'},{'positive','>=',obj.start_year,'<=',obj.end_year,'integer'})
            validateattributes(end_year,{'numeric'},{'positive','>=',start_year,'integer'})
            mustBeMember(type,SR_hour_array.plot_type);
            
 
            
            % Set y label on type
            if strcmp(type,'f')
                y_label_type = "(F)";
            elseif strcmp(type,'val')
                y_label_type = "(P/Hz)";
            end
            
            num_years = end_year - start_year + 1;
            % Loop for going over the years
            first_year = start_year - obj.start_year + 1;
            last_year = first_year + num_years - 1;
            offset_year = first_year - 1;
            num_of_subplot = num_years;
            
            for index_year = first_year:last_year
                
                index_plot = index_year - offset_year;
                subplot_array(index_plot) = subplot(1, num_of_subplot, index_plot );
                hold off;

                for index_interval = 1: obj.num_intervals
                        
                    tittle_beggining = "Hour Annual ";
                    if strcmp(type,'f')
                        tittle_type = "Frequency ";
                        y_label_type = "(Hz)";
                    elseif strcmp(type,'val')
                        tittle_type = "Intensity ";
                        y_label_type = "(dBpT)";
                    end
                    sgtitle(tittle_beggining + tittle_type + '${SR}_{mode}$ ' + sr_mode + " " + '$\mathcal{B}_{' + obj.component + '}$','Interpreter', 'latex', 'FontSize', 12);

                    
                    if (obj.selected_interval(index_interval) == 1)
                        %Type of filter
                        if strcmp(type,'f')
                            fit_frequency_sr_mode = obj.fit_frequency{sr_mode};
                            y_values = fit_frequency_sr_mode{index_year, index_interval}(obj.days_year);
                        elseif strcmp(type,'val')
                            fit_val_sr_mode = obj.fit_val{sr_mode};
                            y_values = fit_val_sr_mode{index_year, index_interval}(obj.days_year);
                        end
                       % plot(obj.days_year, y_values);
                       plot(obj.days_year, y_values);
                        
                        hold on;
                    end
                end
                
            legend_labels_num = string([0:obj.total_hours/obj.num_intervals:24]);
              legend_labels_str = [];
            for index = 1:obj.num_intervals
                if (obj.selected_interval(index) == 1)
                legend_labels_str = [legend_labels_str, legend_labels_num(index) + ":00-"+ legend_labels_num(index + 1)+":00"];
                end
            end

            
            end

            
            for index_subplot = 1:length(subplot_array)
                ylim(subplot_array(index_subplot), obj.get_lim_year(sr_mode, type));
                if index_subplot == 1
                    ylabel(subplot_array(index_subplot), "Mean " + y_label_type);
                    ylim(subplot_array(index_subplot), obj.get_lim_year(sr_mode, type));
                elseif (index_subplot == floor(length(subplot_array) / 2) + 1)
                    xlabel(subplot_array(index_subplot), "Month of the Year" + newline +  string(start_year + index_subplot - 1)+ " " );
                    yticklabels(subplot_array(index_subplot),[]);
                elseif (index_subplot == length(subplot_array))
                    yticklabels(subplot_array(index_subplot),[]);
                    yyaxis right
                    ylabel(subplot_array(index_subplot), "Mean " + y_label_type);
                    ylim(subplot_array(index_subplot), obj.get_lim_year(sr_mode, type))
                else
                    yticklabels(subplot_array(index_subplot),[]);
                end
                
                
                
                xticks(subplot_array(index_subplot),[1:length(obj.days_year)/4 +  1:length(obj.days_year)]);
                datetick(subplot_array(index_subplot),'x','m','keepticks');
                xlim(subplot_array(index_subplot),[1,length(obj.days_year)]);
                lines =  findobj(subplot_array(index_subplot),'Type', 'line');
                for index_lines=1:length(lines)
                    internal_index = length(lines) - index_lines + 1;
                    lines(internal_index).LineStyle = SR_day_array.line_style(internal_index);
                    lines(internal_index).LineWidth = 2;
                    lines(internal_index).Marker = SR_day_array.marker_style(internal_index);
                    lines(internal_index).MarkerIndices = [1:round(length(lines(internal_index).XData)/12):round(length(lines(internal_index).XData))];
                    
                    lines(internal_index).Color = [0, 0.2, 0.2] + ([0.5 0.8 0.8] * (internal_index - 1) * (0.65/(length(lines))));
                end
            end
            for i=1:length(subplot_array)
                lg(i) = legend(subplot_array(i), legend_labels_str, 'Orientation','horizontal','Location','NorthOutside');
                lg(i).Visible = 0;
            end
            lg(length(subplot_array)).Visible = 1;
            
        end
        function save_fig_annual(obj, start_year, end_year, path, format)
           for sr_mode = 1:SR_config.max_sr_mode 
                obj.plot_interval( sr_mode, 'f', start_year, end_year);
                file_name = path + "Annual_mode_"+ sr_mode + "_type_" + "f"  + "_"+ obj.component;
                save_fig('wide', file_name, format);
                obj.plot_interval( sr_mode, 'val', start_year, end_year);
                file_name = path + "Annual_mode_"+ sr_mode + "_type_" + "val"  + "_"+ obj.component;
                save_fig('wide', file_name, format);
           end 
        end
        
       function output = get_variable(obj, type, func) 
           if strcmp(type,'f')
               fit_current = obj.fit_frequency;
           elseif strcmp(type,'val')
                fit_current = obj.fit_val;
           end
           for index_year = 1:size(fit_current,1)
               intercal_select_index = 1;
               total = zeros(366,size(fit_current,2));
               for index_interval = 1:size(fit_current,2)
                   y_values = fit_current{index_year, index_interval}(obj.days_year);
                   total(:,index_interval) = y_values;
                   if (obj.selected_interval(index_interval) == 1)
                         if strcmp(func, "DF")
                            output(index_year, intercal_select_index) = max(y_values) - min(y_values); 
                         elseif strcmp(func, "mean")
                             output(index_year, intercal_select_index) = mean(y_values); 
                         elseif strcmp(func, "max")
                             output(index_year, intercal_select_index) = max(y_values); 
                          elseif strcmp(func, "std")
                             output(index_year, intercal_select_index) = std(y_values); 
                        elseif strcmp(func, "norm")
                            output(index_year, intercal_select_index) = mean(y_values); 
                        end
                         intercal_select_index = intercal_select_index + 1;
                   end
               end
               total_mean = mean(total,2);
               total_std = std(total, 0, 2);
               if strcmp(func, "DF")
                    output(index_year, intercal_select_index) = max(total_mean) - min(total_mean); 
               elseif strcmp(func, "mean")
                    output(index_year, intercal_select_index) = mean(total_mean); 
               elseif strcmp(func, "max")
                    output(index_year, intercal_select_index) = max(total_mean); 
               elseif strcmp(func, "std")
                    output(index_year, intercal_select_index) = mean(total_std); 
               elseif strcmp(func, "norm")
                    output(index_year, :) = (output(index_year, :) - mean(total_mean)) / mean(total_std);
                    output(index_year, intercal_select_index) = mean(total_std); 
               end
           end
           output(index_year + 1,:) = mean(output);
       end
       
        function set_intervals (obj, index_interval_array)
        
            validateattributes(index_interval_array,{'numeric'},{'row', '>=',0,'<=',obj.num_intervals - 1, 'nondecreasing'});
            obj.selected_interval = zeros(1,obj.num_intervals);
            internal_index_interval_array = index_interval_array + 1;
            obj.selected_interval(internal_index_interval_array) = 1;
        end
        
        function extract_series(obj)
        end
            
        
        % Main plot function
        function plot_year(obj, SR_mode, type)
            
            % Check attributes
            validateattributes(SR_mode,{'numeric'},{'positive','<=',SR_hour_array.SR_max_mode,'integer'})
            mustBeMember(type,SR_hour_array.plot_type);
            
            % Init complete variable
            mean_total = 0;
            std_total = 0;
            count_total = 0;
                
            % Set y label on type
            if strcmp(type,'f')
                y_label_type = "(F)";
            elseif strcmp(type,'val')
                y_label_type = "(P/Hz)";
            end
            
            % Loop for going over the years
            
            for i = 1:length(obj.days_array)
                
                % Get the current SR_hour array year
                current_year = obj.days_array{i};
                
                % Set and Get the handler for the subplot (Just for delete it)
                h1 = subplot(length(obj.days_array), 1, i);
                
                
                sgtitle(obj.component + " dayly" + " Mode: " +  SR_mode + " Type: " + type);
                
                if strcmp(type,'f')
                    mean_data = buffer([current_year.mean_f],8);
                elseif strcmp(type,'val')
                    mean_data = buffer([current_year.mean_val], 8);
                end
                
                mean_component = mean_data(SR_mode,:);
                days = [current_year.day];
                
                plot(days, mean_component, 'LineWidth',2);%,2,'Color', [0, 0, 0] + 0.7);
                
                hold on;
                data_filter = smoothdata(mean_component,'sgolay',30);
                plot(days, data_filter,'Color','k','LineWidth',1);
                hold off;
            end
        end
        function interval =  get_lim_year(obj, sr_mode, type)
            if strcmp(obj.component, 'EW')
                if strcmp(type, 'val')
                    interval = [-20 20];
                    if sr_mode == 1
                        interval = [5 15];
                    elseif sr_mode == 2
                        interval = [-20 20];
                    elseif sr_mode == 3
                    elseif sr_mode == 4
                    elseif sr_mode == 5
                    elseif sr_mode == 6
                    end
                elseif strcmp(type, 'f')
                    if sr_mode == 1
                        interval = [7.55 8.05];
                    elseif sr_mode == 2
                        interval = [13.8 14.8];
                    elseif sr_mode == 3
                        interval = [19.6 20.8];
                    elseif sr_mode == 4
                        interval = [25.6 27];
                    elseif sr_mode == 5
                        interval = [31 33];
                    elseif sr_mode == 6
                        interval = [38 40];
                    end
                end
            elseif strcmp(obj.component, 'NS')
                if strcmp(type, 'val')
                    interval = [0 15];
                    if sr_mode == 1
                        interval = [5 15];
                    elseif sr_mode == 2
                        interval = [5 15];
                    elseif sr_mode == 3
                    elseif sr_mode == 4
                    elseif sr_mode == 5
                    elseif sr_mode == 6
                    end
                elseif strcmp(type, 'f')
                    if sr_mode == 1
                        interval = [7.55 8.05];
                    elseif sr_mode == 2
                        interval = [13.8 14.8];
                    elseif sr_mode == 3
                        interval = [19.6 20.8];
                    elseif sr_mode == 4
                        interval = [25.8 27.2];
                    elseif sr_mode == 5
                        interval = [31 34];
                    elseif sr_mode == 6
                        interval = [38.5 40.5];
                    end
                end
            end
        end
    end
end

