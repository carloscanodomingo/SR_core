classdef SR_spectrogram
    % Class to group spectrogram properties.
    properties
        year_data_f;
        component
        start_year = 2016;
        end_year = 2019;
    end
    methods 
        function obj = SR_spectrogram(component, start_year, end_year)

            obj.component = component;
            last_data_f = NaN(1871,1);
            completed_data_f = [];
            next_datetime = 0;
            obj.start_year = start_year;
            obj.end_year = end_year;
            obj.year_data_f = cell(1,obj.end_year - obj.start_year + 1);
            for i = obj.start_year:obj.end_year
                index_year = i - obj.start_year + 1;
                SR_year = SR_data.load_year(i,component,SR_config.current_version);
%                 mat_file = strcat("SR_" + i + "_" + component + ".mat");
%                 load(mat_file);
%                 var_name = strcat("SR_" + i + "_" + component);
%                 SR_year = eval(var_name);              
%                 clearvars var_name;
                
                for k = 1 : length(SR_year)
                    current_month_pre = SR_year{k};
                    selected = SR_peak_process_array.select_not_noisy(current_month_pre,component,SR_config.current_version);
                    current_month = current_month_pre(selected);
                    for l = 1 : length(current_month)
                        current_datetime = current_month(l).time_start;
                        if isempty(completed_data_f)
                            next_datetime = current_datetime;
                        end
                        
                        while current_datetime > next_datetime + minutes(1)
                            next_datetime =  next_datetime + minutes(30);
                            completed_data_f = [completed_data_f, last_data_f];                        
                        end
                        next_datetime = next_datetime + minutes(30);
                        last_data_f = current_month(l).raw_data_f;
                        completed_data_f = [completed_data_f, last_data_f];
                        
                    end
                end  
                obj.year_data_f{index_year} = completed_data_f;
            end
        end
        function plot(obj,year, option, filter)
            close 
            get_year_data_f = obj.year_data_f{(year - obj.start_year + 1)};
            time = [0:size(get_year_data_f,2)-1];
            
            frecuencies = linspace(0,93.5,1871);
            if contains(filter, 'HPF')
                get_year_data_f = get_year_data_f(frecuencies > 5,:);
                frecuencies = frecuencies(frecuencies > 5);
            end
            if contains(filter, 'LPF')
                get_year_data_f = get_year_data_f(frecuencies < 48,:);
                frecuencies = frecuencies(frecuencies < 48);
            end
            if strcmp(option,'image')
                
                imagesc(time,frecuencies,get_year_data_f,[-20 0]);
                %{
                hold on
                number_of_modes = 6;
                for i= 1 : number_of_modes
                    current_mode_f = schumann_peak.schumann_fc(i);
                    box_margin = 0.1;
                    lower_margin = (current_mode_f - box_margin);
                    up_margin = (current_mode_f + box_margin);
                    up_left_point = [1 lower_margin];
                    up_right_point = [length(time), lower_margin];
                    lower_right_point = [length(time), up_margin];
                    lower_left_point = [1, up_margin];
                    box_points = [up_left_point; up_right_point; lower_right_point; lower_left_point;up_left_point];
                    plot(box_points(:,1), box_points(:,2),'k','LineWidth', 2);
                    line([1,length(time)], [current_mode_f,current_mode_f], 'Color', 'w' ,'LineWidth', 1.2);
                end
                %}
            elseif strcmp(option,'spectrogram')
                waterfall(time,frecuencies, get_year_data_f);
            end
            colorbar();
            xlabel("Time")
            xticks(length(time)/8:length(time)/4:length(time));
            xticklabels(["Winter", "Spring", "Summer", "Autum"]);
            ylabel("Frequency   (Hz)")
            zlabel("Power/Hz")
            title(obj.component + " Spectogram of " + num2str(year));
            colormap(winter)
        end
        
        function save_fig_annual(obj,year,filter,path, format)
            obj.plot( year, "image", filter);
            file_name = path + "Spectrogram_" + year + "_" + obj.component;
            save_fig('wide', file_name, format);
        end
            
    end
end

