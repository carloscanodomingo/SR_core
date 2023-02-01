classdef SR_data
    %SR_DATA Summary of this class goes here
    %   Detailed explanation goes here

    properties (Constant)
        months = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    end
    methods(Static)
        function extract_data_from_server(start_year, end_year, version)
            %directory = '/home/asepen/capturas_elf_cal';
            directory = 'Z:\SR\capturas_elf_cal';
            directory_raw = "/home/asepen/capturas_elf";
            fs = 187;

            for index_component = 1:length(SR_config.component)
                for index_year = start_year:end_year
                    for index_month = 1:12
                        suffix_path = "/" + string(index_year) + "/" + string(SR_data.months(index_month));
                        path = directory + suffix_path;
                        path_no_cal = directory_raw + suffix_path;
                        FileList = dir(fullfile(path, '**', "*" + SR_config.component(index_component) + "_cal.mat"));
                        FileList_no_cal = dir(fullfile(path_no_cal, '**', "*" + SR_config.component(index_component) + ".dat"));
                        if (size(FileList,1) == 0)
                            continue;
                        end
                        month_SR = schumann_peak.empty(0,length(FileList));
                        parfor index_file = 1:length(FileList)
                            path = fullfile(FileList(index_file).folder, FileList(index_file).name)
                            data = load(path);
                            data = data.y_cal;
                            data_no_cal = [];
                            if(length(FileList) == length(FileList_no_cal))
                                data_no_cal = load(FileList_no_cal(index_file).name);
                            end
                            % supossing two folder are identily distributed
                            str_time = extractBetween(FileList(index_file).name,'c_',strcat('_',SR_config.component(index_component), '_cal.mat'));
                            current_datetime = datetime(str_time,'InputFormat','yyyy_MM_dd_HHmmss') - minutes(30);
                            SR = schumann_peak();
                            month_SR(1,index_file) = SR.get_schumann_peak(current_datetime, length(data) * (1 / fs), data, data_no_cal,SR_config.component(index_component));
                        end
                        var_name_lorentz = "SR_" + string(index_year) + "_" + string(SR_data.months(index_month)) + "_" + SR_config.component(index_component);
                        S.(var_name_lorentz) = month_SR;
                        filename = var_name_lorentz + "_v_" + num2str(version) + ".mat";
                        save(filename, '-struct', 'S');
                        clearvars(var_name_lorentz);
                        clearvars("S");
                        clearvars("month_SR");
                    end
                end
            end
        end
        function add_lorentz_year(start_year, end_year, component, version)


            % Check attributes
            mustBeMember(component,SR_config.component);
            %'maximum', 'peak','lorentz'


            % Loop for going over the years/ files
            for i = start_year:end_year

                % load the current SR year
                mat_file = strcat("SR_" + i + "_" + component + ".mat");
                var_name = strcat("SR_" + i + "_" + component);
                load(mat_file, var_name);
                % Change the name of the variable
                SR_year_pre = eval(var_name);
                clearvars(var_name);
                for k=1:12
                    month_SR = SR_year_pre{k};
                    month_SR_lorentz = SR_peak_process_array.calculate_fit_lorentz_classification(month_SR,version);
                    var_name_lorentz = "SR_" + num2str(i) + "_" + SR_data.months(k) + "_" + component;
                    S.(var_name_lorentz) = month_SR_lorentz;
                    filename = var_name_lorentz + "_v_" + num2str(version) + ".mat";
                    save(filename, '-struct', 'S');
                    clearvars("month_SR_lorentz");
                    clearvars(var_name_lorentz);
                    clearvars("S");
                    clearvars("month_SR");
                    display("Finish Lorentz" + string(k) + "/" + string(i) );
                end
            end
        end
        function add_classification(start_year, end_year, component, version)


            % Check attributes

            mustBeMember(component,SR_config.component);
            %'maximum', 'peak','lorentz'

            % predefine array
            obj.hours_array = cell(1, start_year - end_year + 1);

            % Loop for going over the years/ files
            for i = start_year:end_year

                % load the current SR year
                mat_file = strcat("SR_" + i + "_" + component + ".mat");
                var_name = strcat("SR_" + i + "_" + component);
                load(mat_file, var_name);

                % Change the name of the variable
                SR_year_pre = eval(var_name);
                for k=1:11
                    month_SR = SR_year_pre{k};
                    month_SR_lorentz = SR_peak_process_array.calculate_fit_lorentz_classification(month_SR,version);
                    var_name_lorentz = "data";%"SR_" + i + "_" + SR_data.months(k) + "_" + component+  "_lorentz";
                    filename =  "SR_" + i + "_" + component +  "_" + SR_data.months(k) +  "_lorentz";
                    S.(var_name_lorentz) = month_SR_lorentz;

                    save(filename, '-struct', 'S', '-v7.3');

                    pause(5)
                    display("Finish Month " + k + " of year " + i);
                end


            end
        end
        function save_year(name)

            listing = dir();
            cell2save = {};
            for i = 3:length(listing)
                current_SR_array = load(listing(i).name);
                variable_names = fieldnames(current_SR_array);
                cell2save{i - 2} = current_SR_array.(variable_names{1});
            end
            S.(name) = cell2save;
            save(name, '-struct', 'S','-v7.3')
        end
        function year_SR = load_year(year, component, version)
            tic
            year_SR = {};
            for i = 1:length(SR_data.months)
                complete_name = "SR_" + num2str(year) + "_" + SR_data.months(i) + "_"  + component + "_v_" + num2str(version) + ".mat";
                current_SR_array = load(complete_name);
                variable_names = fieldnames(current_SR_array);
                year_SR{i} = current_SR_array.(variable_names{1});
            end
            toc
        end
        function number = number_of_elements(component, version)
            number = 0;
            if SR_config.total_elem == 0 
            for index_year = SR_config.start_year:SR_config.end_year
                for index_month = 1:12
                    current_month = SR_data.load_month(index_year, index_month, component, version);
                    number = number + length(current_month);
                end
            end
            else
                number = SR_config.total_elem;
            end
            
        end
        function month_SR = load_month(year, month, component, version)

                complete_name = "SR_" + num2str(year) + "_" + SR_data.months(month) + "_"  + component + "_v_" + num2str(version) + ".mat";
                current_SR_array = load(complete_name);
                variable_names = fieldnames(current_SR_array);
                month_SR = current_SR_array.(variable_names{1});
       
        end
        function  save_table_SR(component)
            arguments
                component {mustBeMember(component, ["NS", "EW"])}
            end
            LEN_FORMAT = length(SR_config.format_date_table);
            % Declare Empty arrays
            number_of_element = SR_data.number_of_elements(component,  SR_config.current_version);
            signal_lorentz_array = zeros(number_of_element, SR_config.DL_len);
            signal_raw_array = zeros(number_of_element, SR_config.DL_len);
            label_freq_array = zeros(number_of_element, 6);
            label_year_array = zeros(1, number_of_element);
            label_month_array = zeros(1, number_of_element);
            label_day_array = zeros(1, number_of_element);
            label_hour_array = zeros(1, number_of_element);
            label_min_array = zeros(1, number_of_element);
            label_selected = zeros(1, number_of_element);
            label_rmse_array = zeros(1, number_of_element);
            label_noise_array = zeros(1, number_of_element);
            previous_index_output = 0;
            index_output = 0;
            for index_year = SR_config.start_year:SR_config.end_year
                for index_month = 1:12

                    % TO allow the parallel computing it is mandatory to
                    % know the index position without the dependenceof the
                    % previous iteration
                    index_output = index_output + previous_index_output;
                    current_month = SR_data.load_month(index_year, ...
                        index_month, component, SR_config.current_version);
                    previous_index_output = length(current_month);
                    
                    parfor index_object = 1:length(current_month)
                        current_object = current_month(index_object);
                        selected_freq = (SR_config.SR_freq < SR_config.select_DL_up_limit &  SR_config.SR_freq > SR_config.select_DL_low_limit);
                        % Get Raw Signal
                        signal_raw_total = current_object.raw_data_f;
                        signal_raw = signal_raw_total(selected_freq);
                        signal_raw = resample(signal_raw, SR_config.DL_len, length(signal_raw))';
                        normalize_max_raw = max(signal_raw)
                        normalize_min_raw = min(signal_raw)
                        signal_raw_array(index_object + index_output, :) = signal_raw;

                        % Get Lorentz Signal
                        signal_lorentz_total = current_object.lorentz.get_lorentz_signal();
                        signal_lorentz = signal_lorentz_total(selected_freq);
                        signal_lorentz = resample(signal_lorentz, SR_config.DL_len, length(signal_lorentz));


                        signal_lorentz_array(index_object + index_output, :) = signal_lorentz;

                        % COMPUTE RMSE of selected interval
                        frequencies_selected = (SR_config.SR_freq < SR_config.RMSE_up_limit & SR_config.SR_freq > SR_config.RMSE_low_limit);
                        label_rmse_array(index_object + index_output) = sqrt(immse(signal_lorentz_total(frequencies_selected), signal_raw_total(frequencies_selected)));
                        

                        %
                        select = (SR_config.SR_freq > 5 & SR_config.SR_freq < 43)
                        x = current_object.raw_data_f(select);
                        label_noise_array(index_object + index_output) = std(highpass(x,0.03,'Steepness',0.85,'StopbandAttenuation',60));
                        % Get Freq Array

                        label_freq = current_object.lorentz.lorentz_freq';
                        label_freq_array(index_object + index_output, :) = label_freq;

                        % Get Labels Signal
                        % min
                        label_min_array(index_object + index_output) = minute(current_object.time_start);
                        % Hour
                        label_hour_array(index_object + index_output) = hour(current_object.time_start);
                        
                        %DAY
                        label_day_array(index_object + index_output) = day(current_object.time_start);
                        % Month
                        label_month_array(index_object + index_output) = month(current_object.time_start);
                        % Year
                        label_year_array(index_object + index_output) = year(current_object.time_start);

                        %label_msre =
                        select_array_selected = SR_peak_process_array.select_not_noisy(current_object, "NS", 3);
                        label_selected(index_object + index_output) = select_array_selected;
                    end
                    display("YEAR " + index_year + "MONTH" + index_month)
                end
            end


            s.label_min = label_min_array;
            s.label_hour = label_hour_array;
            s.label_day = label_day_array;
            s.label_month = label_month_array;
            s.label_year = label_year_array;
            s.label_selected = label_selected;
            s.label_rmse_array = label_rmse_array;
            s.signal_lorentz = signal_lorentz_array;
            s.signal_raw = signal_raw_array;
            s.label_freq = label_freq_array;
            s.label_noise = label_noise_array;
            save("SR_table" + component + "_DL", '-struct', "s", "-v7.3");
            pause(1)
        end
        function EarthQuakeData(component)
            arguments
                component {mustBeMember(component, ["NS", "EW"])}
            end
            load("SR_table_DL_"+ component +".mat");
            load("encoded.mat");
            [label_index, time_array]  = SREarthQuake.DT2TS(component);
            table_earthquake = SREarthQuake.read_table_earthquake(false);
            label_mag = [];
            label_dist = [];
            label_depth = [];
            label_arc = [];
            for index_time = 1:length(time_array)
                current_start_time = time_array(index_time);
                row_select = table_earthquake.Time >= current_start_time & ...
                    table_earthquake.Time < current_start_time + minutes(30);
                if (sum(row_select) > 0)
                    select_table = table_earthquake(row_select,:);
                    [~, idx] = max(select_table.mag);
                    row_earthquake = select_table(idx, :);
                    label_mag = [label_mag, row_earthquake.mag];
                    label_dist = [label_dist, row_earthquake.dist];
                    label_depth = [label_depth, row_earthquake.depth];
                    label_arc = [label_arc, row_earthquake.arc];
                else
                    label_mag = [label_mag, 0];
                    label_dist = [label_dist, Inf];
                    label_depth = [label_depth, Inf];
                    label_arc = [label_arc, -90];
                end
            end
            label_encoded = zeros(length(time_array), 10);
            label_raw = zeros(length(time_array), size(signal_raw,2));
            label_encoded(label_index,:) = encoded_vae_raw;
            label_raw(label_index,:) = signal_raw;
            s.signal_encoded = label_encoded;
            s.signal_raw = label_raw;
            s.label_mag = label_mag';
            s.label_dist = label_dist';
            s.label_arc = label_arc';
            s.label_depth = label_depth';
            save("SR_table_EarthQuake_" + component, '-struct', "s", "-v7.3");
        end
        function EarthQuakeDataV2()

            % Get signal data from Alm dataset
            % Expand Signal dataset to all 30min possible registers
            [label_index, time_array]  = SREarthQuake.DT2TS(SR_config_base.component(1));
            for index_component = 1:length(SR_config_base.component)
                current_component = SR_config_base.component(index_component);
                temp_struct = load("SR_table_"  + "DL_"+ current_component + ".mat",'signal_raw');
                temp_var = temp_struct.signal_raw;
                signal = zeros(length(time_array), size(temp_var,2));
                signal(label_index,:) = temp_var;
                % Save Signal in the final struct S
                s.("signal_"+current_component) = signal;
            end
            % Read Table for label mag...
            table_earthquake = SREarthQuake.read_table_earthquake(false);
            mag_list = [];
            dist_list = [];
            depth_list = [];
            arc_list = [];

            % Fit to the time slot configured -- 30min segments
            for index_time = 1:length(time_array)
                current_start_time = time_array(index_time);
                row_select = table_earthquake.Time >= current_start_time & ...
                    table_earthquake.Time < current_start_time + minutes(30);
                % Check whether there is at least one EQ for a selected
                % slot
                if (sum(row_select) > 0)
                    select_table = table_earthquake(row_select,:);
                    % Take the highest
                    [~, idx] = max(select_table.mag);
                    row_earthquake = select_table(idx, :);
                    mag_list = [mag_list, row_earthquake.mag];
                    dist_list = [dist_list, row_earthquake.dist];
                    depth_list = [depth_list, row_earthquake.depth];
                    arc_list = [arc_list, row_earthquake.arc];
                else
                    mag_list = [mag_list, 0];
                    dist_list = [dist_list, 0];
                    depth_list = [depth_list, 0];
                    arc_list = [arc_list, -90];
                end
            end

            % Select filter for Earthquake
            mag_thresshold = SREarthQuake.threshold_mag;
            dist_thresshold = SREarthQuake.threshold_dist;
            depth_thresshold = SREarthQuake.threshold_depth;
            selected = ((mag_list > mag_thresshold) & (dist_list < dist_thresshold) & (depth_list < depth_thresshold));

            mag_list(~selected) = 0;

            dist_list(~selected) = 0;

            depth_list(~selected) = 0;

            arc_list(~selected) = 0;

            % Overlap saegments
            overlap = mag_list;
            overlap(selected) = 1;
            overlap(~selected) = 0;
            b = 1 * ones(1,SREarthQuake.window);
            w = triang(SREarthQuake.window);
            a = 1;
            overlap_filtered = filter(b,a,overlap);
            overlap_filtered(overlap_filtered > 0) = 1;
            
            label_mag = zeros(1, length(mag_list));
            label_dist = zeros(1, length(dist_list));
            label_depth = zeros(1, length(depth_list));
            label_arc = zeros(1, length(arc_list));
            % Label each separate region.
            [labeledX, numRegions] = bwlabel(overlap_filtered);
            % Get lengths of each region
            props = regionprops(labeledX, 'Area', 'PixelList');
            regionLengths = [props.Area];
            for k = 1 : numRegions
                start_index = find(labeledX == k, 1);
                selected_region = (labeledX == k);
                offset = round(regionLengths(k) / 2);
                label_mag(selected_region) =  max(mag_list(selected_region));
                label_dist(selected_region) =  max(dist_list(selected_region));
                [label_depth(selected_region), index_max] =  max(depth_list(selected_region));
                temp_arc = (arc_list(selected_region));
                label_arc(selected_region) = temp_arc(index_max);
            end
            s.label_mag = label_mag;%filter( b,a,label_mag);
            s.label_dist = label_dist;%filter( b,a,label_dist);
            s.label_arc = label_arc;%filter( b,a,label_arc);
            s.label_depth = label_depth;%filter( b,a,label_depth);
            s.label_eq = (s.label_mag > 0.0);
            save("SR_table_EarthQuake_v2", '-struct', "s", "-v7.3");
        end
    function s = read_codify_data()
        % Get signal data from Alm dataset
            % Expand Signal dataset to all 30min possible registers
            s_temp = load('SR_earthquake_DL.mat', 'EW_mean');
            s.EW_mean = s_temp.EW_mean;
            s_temp = load('SR_earthquake_DL.mat', 'EW_std');
            s.EW_std = s_temp.EW_std;
            s_temp = load('SR_earthquake_DL.mat', 'NS_mean');
            s.NS_mean = s_temp.NS_mean;
            s_temp = load('SR_earthquake_DL.mat', 'NS_std');
            s.NS_std = s_temp.NS_std;
            
    end
    function EarthQuakeDataV5()

            % Get signal data from Alm dataset
            % Expand Signal dataset to all 30min possible registers
            [label_index, time_array]  = SREarthQuake.DT2TS(SR_config_base.component(1));
            s = SR_data.read_codify_data();
            % Read Table for label mag...
            table_earthquake = SREarthQuake.read_table_earthquake(false);
            mag_list = [];
            dist_list = [];
            depth_list = [];
            arc_list = [];
            lat_list = [];

            % Fit to the time slot configured -- 30min segments
            for index_time = 1:length(time_array)
                current_start_time = time_array(index_time);
                row_select = table_earthquake.Time >= current_start_time & ...
                    table_earthquake.Time < current_start_time + minutes(30);
                % Check whether there is at least one EQ for a selected
                % slot
                if (sum(row_select) > 0)
                    select_table = table_earthquake(row_select,:);
                    % Take the highest
                    [~, idx] = max(select_table.mag);
                    row_earthquake = select_table(idx, :);
                    lat_list = [lat_list, row_earthquake.latitude];
                    mag_list = [mag_list, row_earthquake.mag];
                    dist_list = [dist_list, row_earthquake.dist];
                    depth_list = [depth_list, row_earthquake.depth];
                    arc_list = [arc_list, row_earthquake.arc];
                else
                    lat_list = [lat_list, nan];
                    mag_list = [mag_list, nan];
                    dist_list = [dist_list, nan];
                    depth_list = [depth_list, nan];
                    arc_list = [arc_list, nan];
                end
            end

            s.lat = lat_list;
            s.mag = mag_list;%filter( b,a,label_mag);
            s.dist = dist_list;%filter( b,a,label_dist);
            s.arc = arc_list;%filter( b,a,label_arc);
            s.depth = depth_list;%filter( b,a,label_depth);
            save("SR_table_EarthQuake_v5", '-struct', "s", "-v7.3");
        end
    end
end

