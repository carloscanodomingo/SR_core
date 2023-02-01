classdef SR_hour_array
    %UNTITLED Summary of this class goes here
    %Detailed explanation goes here
    
    properties
       hours_array;
       component;
       noisy_percent
    end
    properties (Constant)
        start_year = SR_config.start_year;
        end_year = SR_config.end_year;
        current_version = 3;
        plot_type = {'f','val'};
        SR_max_mode = 8;
        
    end

    methods
        function obj = SR_hour_array(margin,option,component,noisy_method)
            
            % Check attributes
            validateattributes(margin,{'numeric'},{'>',0,'<=',SR_hour.schumann_fc(1)})
            validateattributes(noisy_method,{'numeric'},{'>=',1,'<=',3})
            validateattributes(mod(noisy_method,1),{'numeric'},{'=',0})
            
            mustBeMember(component,SR_hour.component);
            %'maximum', 'peak','lorentz'
            mustBeMember(option,SR_peak_process.types_get_peak);
            
            obj.component = component;
            % predefine array
            obj.hours_array = cell(1, SR_hour_array.end_year - SR_hour_array.start_year + 1);
            obj.noisy_percent = cell(1,SR_hour_array.end_year - SR_hour_array.start_year + 1);
            % Loop for going over the years/ files
            for i = SR_hour_array.start_year:SR_hour_array.end_year
                
                current_year_index = i - SR_hour_array.start_year + 1;
                % load the current SR year
                %{
                mat_file = strcat("SR_" + i + "_" + component + ".mat");
                var_name = strcat("SR_" + i + "_" + component);
                if exist(var_name) ~= 1
                    load(mat_file, var_name);
                end
                %}
                SR_year_pre = SR_data.load_year(i, component, SR_config.current_version);
                % Change the name of the variable
                %SR_year_pre = eval(var_name);
                
                % Compute the mean for every hours in chunck of a month
                [current_year, obj.noisy_percent{current_year_index}] = SR_hour_aux.get_hours_year(SR_year_pre, margin, option,component, noisy_method);
                
                % Add to the object array
                obj.hours_array{current_year_index} = current_year;
            end
        end
        
        
        % Main plot function
        function print_month(obj, month, SR_mode, type)
            
            % Check attributes
            validateattributes(month,{'numeric'},{'positive','<=',12,'integer'})
            validateattributes(SR_mode,{'numeric'},{'positive','<=',SR_hour_array.SR_max_mode,'integer'})
            mustBeMember(type,SR_hour_array.plot_type);
            
            % Init complete functions
            mean_total = 0;
            std_total = 0;
            count_total = 0;
                
            % Set y label on type
            if strcmp(type,'f')
                y_label_type = "(F)";
            elseif strcmp(type,'val')
                y_label_type = "(pT/Hz)";
            end
            
            % Loop for going over the years
            for i = 1:length(obj.hours_array)
                
                % Get the current SR_hour array year
                current_year = obj.hours_array{i};
                
                % Set and Get the handler for the subplot (Just for delete it)
                h1 = subplot(length(obj.hours_array) + 1, 1, i);
                
                
                sgtitle(obj.component + " " + "Month: " + datestr(datetime(0,month + 1,0),'mmmm') + " Mode: " +  SR_mode + " Type: " + type);
                
                % If the month is in the current year (start in January)
                if(length(current_year) >= month)
                    % Get frequency of the peak or maximum value of the
                    % peak
                    if strcmp(type,'f')
                        mean_total = mean_total + obj.hours_array{i}(month).f_mean_per_hour;
                        std_total = std_total + obj.hours_array{i}(month).f_std_per_hour;
                        % Call specified SR plot function
                        obj.hours_array{i}(month).plot_f(SR_mode);
                    elseif strcmp(type,'val')
                        mean_total = mean_total + obj.hours_array{i}(month).val_mean_per_hour;
                        std_total = std_total + obj.hours_array{i}(month).val_std_per_hour;
                        % Call specified SR plot function
                        obj.hours_array{i}(month).plot_val(SR_mode); 
                    end
                    
                    % Increment internal counter for compute the mean
                    count_total = count_total + 1;
                else
                    delete(h1);
                end
                ylabel(num2str( i + SR_hour_array.start_year - 1 ) + y_label_type);
                
            end
            mean_total = mean_total / count_total;
            std_total = std_total / count_total;
            subplot(length(obj.hours_array) + 1, 1, length(obj.hours_array) + 1);
            
            if strcmp(type,'f')
                SR_hour(mean_total, std_total, 0 , 0).plot_f(SR_mode);
            elseif strcmp(type,'val')
                SR_hour(0, 0, mean_total, std_total).plot_val(SR_mode);
            end
            
            ylabel( "All years" + y_label_type);
        end
        
         function print_month_all(obj, month, type)
             close all
           for SR_mode = 1:8
               figure('NumberTitle', 'off', 'Name', "Month: " + datestr(datetime(0,month + 1,0),'mmmm') + " Mode: " +  SR_mode + " Type: " + type);
               obj.print_month(month, SR_mode, type);            
           end
         end
         
         
         function plot_year_monthly(obj, SR_mode, type)
             close all
             for month = 1:12
                 figure('NumberTitle', 'off', 'Name', "Month: " + datestr(datetime(0,month + 1,0),'mmmm') + " Mode: " +  SR_mode + " Type: " + type);
                 obj.print_month(month, SR_mode, type);
             end
         end
         
         function plot_year_all_mode(obj, type)
             close all
             for index_mode = 1:SR_hour_array.SR_max_mode
                 figure(index_mode)
                 obj.plot_year(index_mode, type);
             end
             
         end
         function mean_line = plot_month(obj, SR_mode, type, interval)
             
             % Check attributes
            validateattributes(interval,{'numeric'},{ 'row', '>=',1,'<=',12, 'nondecreasing'});
            validateattributes(SR_mode,{'numeric'},{'positive','<=',SR_hour_array.SR_max_mode,'integer'})
            mustBeMember(type,SR_hour_array.plot_type);
            index_mean_line = 1;
            if(length(interval) > 1)
                start_month = interval(1);
                last_month = interval(2);
            else
                start_month = interval;
                last_month = interval;
            end

            
                        % Init complete functions
            mean_total = 0;
            std_total = 0;
            mean_year = 0;
            std_year = 0;
            count_total = 0;
                
            % Set y label on type
            if strcmp(type,'f')
                y_label_type = "(F)";
            elseif strcmp(type,'val')
                y_label_type = "(pT/Hz)";
            end
             % Loop for going over the years
            for i = 1:length(obj.hours_array)
                mean_year = 0;
                std_year = 0;
                
                % Get the current SR_hour array year
                current_year = obj.hours_array{i};
                
                % Set and Get the handler for the subplot (Just for delete it)
                subplot(length(obj.hours_array) + 1, 1, i);
                
                
                sgtitle(obj.component + " " + " Mode: " +  SR_mode + " Type: " + type +" - " + strjoin(string(datestr(datetime(0,interval + 1,0),'mmmm'))));
                
               
                for k = start_month:last_month 
                % If the month is in the current year (start in January)
                    
                        % Get frequency of the peak or maximum value of the
                        % peak
                        if strcmp(type,'f')
                            mean_year = mean_year + obj.hours_array{i}(k).f_mean_per_hour;
                            std_year = std_year + obj.hours_array{i}(k).f_std_per_hour;
                            % Call specified SR plot function
                            
                        elseif strcmp(type,'val')
                            mean_year = mean_year + obj.hours_array{i}(k).val_mean_per_hour;
                            std_year = std_year + obj.hours_array{i}(k).val_std_per_hour;
                            % Call specified SR plot function
                        end
                        
                        
                end
                mean_year = mean_year ./ (last_month - start_month + 1);
                std_year = std_year ./ (last_month - start_month + 1);
                
               if strcmp(type,'f')
                   mean_line{index_mean_line} = SR_hour(mean_year, std_year, 0, 0).plot_f(SR_mode);
                   
               elseif strcmp(type,'val')
                   mean_line{index_mean_line} = SR_hour(0, 0, mean_year, std_year).plot_val(SR_mode);
               end
               index_mean_line = index_mean_line  + 1;
               obj.plot_suncycles([obj.start_year + i - 1, round((last_month + start_month)/2), 15]);
                
                mean_total = mean_total + mean_year ;
                std_total = std_total + std_year ;
                count_total = count_total + 1;
                ylabel(num2str( i + SR_hour_array.start_year - 1 ) + y_label_type);
            end
                
            mean_total = mean_total / count_total;
            std_total = std_total / count_total;
            subplot(length(obj.hours_array) + 1, 1, length(obj.hours_array) + 1);
            
            if strcmp(type,'f')
                mean_line{index_mean_line} = SR_hour(mean_total, std_total, 0 , 0).plot_f(SR_mode);
            elseif strcmp(type,'val')
                mean_line{index_mean_line} = SR_hour(0, 0, mean_total, std_total).plot_val(SR_mode);
            end
            index_mean_line = index_mean_line + 1;
            ylabel( "All years" + y_label_type);
            obj.plot_suncycles([round((obj.start_year + obj.start_year)/ 2), round((last_month + start_month)/2), 15]);
             
         end

         function [time, value, time_str] = get_maximums_line(obj, SR_mode, type, interval)
             obj.plot_month(SR_mode, type, interval)
             current_figure = gcf;
             current_axes = get(current_figure,'CurrentAxes');
             mean_line = current_axes.Children(5);
             TF = islocalmax(mean_line.YData);
             value = mean_line.YData(TF);
             time = mean_line.XData(TF);
             time_str = datestr( time/24, 'HH:MM' );
         end
         function DF = get_DF(obj, SR_mode, type, interval)
             obj.plot_month(SR_mode, type, interval);
             current_figure = gcf;
             current_axes = get(current_figure,'CurrentAxes');
             mean_line = current_axes.Children(5);
             DF = max(mean_line.YData) - min(mean_line.YData);
         end
         
          function mean_value = get_mean(obj, SR_mode, type, interval)
             obj.plot_month(SR_mode, type, interval);
             current_figure = gcf;
             current_axes = get(current_figure,'CurrentAxes');
             mean_line = current_axes.Children(5);
             mean_value = mean(mean_line.YData);
         end
         function [time, value, time_str] = get_minimums_line(obj, SR_mode, type, interval)
             obj.plot_month(SR_mode, type, interval)
             current_figure = gcf;
             current_axes = get(current_figure,'CurrentAxes');
             mean_line = current_axes.Children(5);
             TF = islocalmin(mean_line.YData);
             value = mean_line.YData(TF);
             time = mean_line.XData(TF); 
             time_str = datestr( time/24, 'HH:MM' );
         end
         
          function limits = get_limits(obj, SR_mode, type, interval)
             obj.plot_month(SR_mode, type, interval);
             current_figure = gcf;
             current_axes = get(current_figure,'CurrentAxes');
             mean_line = current_axes.Children(5);
             limits = [mean_line.YData(1)   , mean_line.YData(end)];
         end
         

             
             
         %Function to Create FIG
        % Main plot function
    function save_fig_season(obj, type, start_name_file, format)
        % save_fig_season(obj, type, start_name_file, format)
        % SR_mode SR mode to print
        % type = 'f', 'val'
        % start_name_file = name 
        
    % Check attributes
%    validateattributes(start_name_file,{'string'})
    mustBeMember(type,SR_hour_array.plot_type);
    mustBeMember(format,SR_config.save_fig_format_valid);
    
    months_per_trimester = 3;
    number_of_years = 2;
    
    for index_modes = 1:SR_config.max_sr_mode
        close all
        for index_season=1:SR_config.number_of_season
            figures(index_season) = figure();
            obj.plot_month(index_modes,type,[(index_season - 1) * months_per_trimester + 1,  index_season * months_per_trimester]);
        end
        if type == 'val'
            y_labels = ["All years (dBpT)","2017 (dBpT)", "2016 (dBpT)"];
            start_title = "Diurnal Intensity Variation ";
            if index_modes == 1
                y_edge_values = [0, 30];
            elseif index_modes == 2
                y_edge_values = [0, 30];
            elseif index_modes == 3
                y_edge_values = [0, 30];
            elseif index_modes == 4
                y_edge_values = [0, 30];
            elseif index_modes == 5
                y_edge_values = [0, 30];
            elseif index_modes == 6
                y_edge_values = [0, 30];
            else
            end

        elseif type == 'f'
            y_labels = ["All years (Hz)","2017 (Hz)", "2016 (Hz)"];
                start_title = "Diurnal Frequency Variation ";
                if index_modes == 1
                    y_edge_values =  [7.2, 8.2];
                elseif index_modes == 2
                    y_edge_values = [13.5 15.5];
                elseif index_modes == 3
                    y_edge_values = [19 21.5];
                elseif index_modes == 4
                    y_edge_values = [24.5 28];
                elseif index_modes == 5
                    y_edge_values = [30.5 35];
                elseif index_modes == 6
                    y_edge_values = [37 41];
                end
        end
            margin = (max(y_edge_values) - min(y_edge_values)) / 30;
            y_values = [min(y_edge_values), (min(y_edge_values) +   max(y_edge_values)) /2, max(y_edge_values)];
            y_ticks_values = [min(y_values) + margin,y_values(2), max(y_values) - margin];
            y_ticks_names = string(y_values);

            
            subtitle_season = ["Winter","Spring","Summer","Autumn"];
            f1 = figure('MenuBar', 'none','ToolBar', 'none');
            
            % Specific option to save pic
            first_space_width = 0.05;
            first_space_height = 0.12;
            width_subfig = 0.22;
            width_subtotal = 0.23;
            height_subfig = 0.26;
            height_subtotal = 0.265;

            total_subplot_horizontal = number_of_years + 1;
            for i=1:SR_config.number_of_season
                for k = 1:total_subplot_horizontal
                    h(i,k)=subplot('Position',[first_space_width + ((i - 1) * width_subtotal), first_space_height + ((k - 1) * height_subtotal), width_subfig, height_subfig]);
                    
                    if k == 1
                        set(h(i,k),'XTick',[0.3,12,23.7],'XTickLabels', ["0", "12", "24"]);
                    else
                        set(h(i,k),'XTick',[]);
                    end
                    if k == total_subplot_horizontal
                        title(subtitle_season(i))
                    end
                    if i == 1
                        set(h(i,k),'YTick',y_ticks_values, 'YTickLabels', y_ticks_names);
                        ylabel( y_labels(k));
                    else
                        set(h(i,k),'YTick',[]);
                    end
                    xlim([0 24])
                    ylim([min(y_values) max(y_values)])
                end
            end
            for i=1:SR_config.number_of_season
                allaxes = findall(figures(i), 'type', 'axes');
                for k = 1:length(allaxes)
                    copyobj(allchild(allaxes(k)),h(i,k));
                    box(h(i,k),'on');
                end
                close(figure(i))
            end
            lines_legend = [h(i,k).Children(1), h(i,k).Children(4),h(i,k).Children(3), h(i,k).Children(2), h(i,k).Children(5), h(i,k).Children(6)];
            lines_legend_names = ["Night","Sunrise","Noon","Sunset", "Mean", "SD"];
            legend(lines_legend, lines_legend_names,'FontSize', 8);
            legend('Position',[0.25 0 0.5 0.05]);
            legend('Orientation','horizontal')
            legend('boxoff')
            %ylabel('Magnetic field Module/frequency ($pT/\sqrt{Hz}$)', 'Interpreter', 'latex')
            sgtitle(start_title + '${SR}_{mode}$ ' + index_modes + " " + '$\mathcal{B}_{' + obj.component + '}$','Interpreter', 'latex', 'FontSize', 12);
            
            h(1,1).XLabel.String = 'UTC Time of day (Hour)';
            h(1,1).XLabel.Position(1) = h(1,1).XLabel.Position(1) * 4.2;
            
            save_fig('wide',start_name_file + "_mode_" + index_modes + "_type_" + type + "_" + obj.component , format)
    end
        
    end
    function DF =  report_df_season(obj,type)
            num_of_lines = (SR_config.end_year - SR_config.start_year + 2);
            DF = cell(num_of_lines,1);
            for index_year = 1:num_of_lines
                DF{index_year} = zeros(SR_config.max_sr_mode,4);
            end
            for index_mode = 1:SR_config.max_sr_mode
                for index_season = 1:4
                    df = obj.get_DF(index_mode, type, [(index_season - 1) * 3 + 1,  (index_season ) * 3]);
                    for index_year = 1:num_of_lines
                        DF{index_year}(index_mode, index_season) = df(index_year);
                    end
                end
            end
           
    end
    
        function plot_suncycles(obj, date)

            values = zeros(1,3);
            x_values = zeros(1,4);
            linestyle_array = {'-.','-',':', '--'};
            % Compute SUNRISE, SUNSET AND NOON HOURS FOR a specific day
            [values(1),values(2),values(3)] = sunrise(SR_config.lat_observatory, SR_config.long_observatory, SR_config.alt_observatory, 1, date);
            values = sort(values);

            % Loop for the three suncycle hours
            for i=1:length(values)
                % Convert to datetime using UTC
                date = datetime(values(i),'ConvertFrom','datenum','Timezone','UTC');
                % Calculate hour in the local timezone
                %date.TimeZone = 'Europe/Madrid';
                % Calculate point in the axis
                x_values(i) = hour(date) + minute(date)/60;
                % Plot line
                line_obj(i) = line([x_values(i) x_values(i)], [-1000 1000],'LineStyle',linestyle_array{i}, 'Color', [0.6 * 0.8^(i), 0.9* 0.8^(i), 0.5* 1.1^(i)] * 0.8^(i),'LineWidth', 1);
            end
            x_values(4) = ((x_values(1) + 24 + x_values(3)) / 2) - 24;
            line_obj(4) = line([x_values(4) x_values(4)], [-1000 1000],'LineStyle',linestyle_array{4}, 'Color', [1, 0, 0] ,'LineWidth', 1);
            %legend((line_obj), {"Sunrise","Noon","Sunset", "Night"});
        end
        end
end