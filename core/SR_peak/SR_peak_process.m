classdef SR_peak_process
    %PROCESS_SCHUMAN_PEAK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        types_get_peak = {'maximum', 'peak','lorentz'}
        max_modes_number = 8;
        default_margin = 1;
        ratio_margin = 1.5;
    end
    methods(Static)
        
        function R2_pre = get_R2_pre(SR_peak_obj, low_limit, up_limit)
            % Get R2 of a lineal regresion from the raw sample from
            % hpf_vale and the up limit
            selected_freq = (SR_peak_obj.freq > low_limit & SR_peak_obj.freq < up_limit);
            
            mdl_pre = fitlm(SR_peak_obj.freq(selected_freq), SR_peak_obj.raw_data_f(selected_freq));
            
            R2_pre = mdl_pre.Rsquared.Ordinary;
        end
        
        function R2_post = get_R2_post(SR_peak_obj, up_limit)
            % Get R2 of a lineal regresion from the Smooth sample from
            % hpf_vale and the up limit
            
            select_freq = (SR_peak_obj.freq > SR_peak_obj.hpf_value & SR_peak_obj.freq < up_limit);
            
            mdl_post = fitlm(SR_peak_obj.freq(select_freq), SR_peak_obj.smooth_data_f(select_freq));
            
            R2_post = mdl_post.Rsquared.Ordinary;
        end
        function [std_test] = estadistical_classification(SR_peak_obj)
            data_detrend = detrend(SR_peak_obj.raw_data_f);
            
            std_test = std(abs(SR_peak_obj.raw_data_f(SR_config.SR_freq > 3 & SR_config.SR_freq < 5)));
            
        end
        
        function sum_max = ratio_max_min(SR_peak_obj)
            selected_frequencies =  (SR_config.SR_freq < 6 & SR_config.SR_freq > 5);
            TF = islocalmax(SR_peak_obj.smooth_data_f,'MinProminence',0.6);
            sum_max = sum(TF(selected_frequencies));% .* SR_peak_obj.smooth_data_f(selected_frequencies));
        end
        function low_f_psd = get_low_f_psd(SR_peak_obj, up_limit)
            
            low_f_psd = sum(abs(SR_peak_obj.raw_data_f(SR_peak_obj.freq < up_limit)));
        end
        
        function low_f_psd = get_low_f_psd_detrend(SR_peak_obj, up_limit)
            detrented_data = detrend(SR_peak_obj.raw_data_f(SR_peak_obj.freq < up_limit));
            low_f_psd = sum(abs(detrented_data(SR_peak_obj.freq < up_limit)));
        end
        
        
        
        function [location, sse] = R2_lorentz_first_SR(SR_peak_obj)
            detrented_data = detrend(SR_peak_obj.raw_data_f);
            detrented_data_offset = detrented_data + abs(min(detrented_data(SR_config.SR_freq > 6.5 & SR_config.SR_freq < 8.5)));
            [fit, gof] = fit_1_lorentz(SR_peak_obj.freq, detrented_data_offset');
            location = fit.B1;
            sse = gof.sse;
        end
        
        
        function ratio_max = ratio_max(SR_peak_obj)
            max_50 = max(SR_peak_obj.raw_data_f(SR_peak_obj.freq > 45 & SR_peak_obj.freq < 55));
            max_7 = max(SR_peak_obj.raw_data_f(SR_peak_obj.freq > 1& SR_peak_obj.freq < 5));
            ratio_max = log10(max_50 / max_7);
            ratio_max = max_7;
        end
        
        function power_band_ratio = power_band_ratio_first_SR(SR_peak_obj, low_limit_lowest_band)
            %Get the ratio between the lowest band and the first SR.
            
            low_limit_band_SR = SR_peak_obj.SR_f(1) - SR_peak_process.ratio_margin;
            high_limit_band_SR = SR_peak_obj.SR_f(1) + SR_peak_process.ratio_margin;
            BW_SR = high_limit_band_SR - low_limit_band_SR;
            
            selected_freq_up_limit = (SR_peak_obj.freq < high_limit_band_SR);
            min_smooth_value = min(SR_peak_obj.raw_data_f(selected_freq_up_limit));
            raw_data_no_offset = SR_peak_obj.raw_data_f - min_smooth_value;
            
            selected_freq_lowest = (SR_peak_obj.freq < low_limit_lowest_band);
            
            psd_band_lowest = (sum((abs(raw_data_no_offset(selected_freq_lowest, :))))) / low_limit_lowest_band;
            
            selected_freq_band_SR = (SR_peak_obj.freq > low_limit_band_SR & SR_peak_obj.freq < high_limit_band_SR);
            
            psd_band_SR = sum((abs(raw_data_no_offset(selected_freq_band_SR, :)))) / BW_SR;
            
            power_band_ratio = psd_band_lowest ./  psd_band_SR;
            
        end
     
        function power_band_detrend = power_band_detrend(SR_peak_obj)
            %Get the ratio between the lowest band and the first SR.
            start_frequency = 4;
            end_frequency = 40;
            
            BW = end_frequency - start_frequency;
            
            selected_freq = (SR_peak_obj.freq > start_frequency & SR_peak_obj.freq < end_frequency);
            
            detrend_data = detrend(SR_peak_obj.raw_data_f(selected_freq), SR_config.detrend_order);
            
            power_band_detrend = sum((abs(detrend_data))) / BW;
            
        end
        
        function ratio_low_f_psd = ratio_low_f_psd(SR_peak_obj, high_frequency)
            threshold_min = 0.5;
            threshold_max = high_frequency;
            
            selected_freq = (SR_peak_obj.freq > threshold_min & SR_peak_obj.freq < threshold_max);
            
            raw_low_f_psd = sum((abs(SR_peak_obj.raw_data_f(selected_freq, :))));
            
            ratio_low_f_psd = raw_low_f_psd ./  (sum((abs(SR_peak_obj.raw_data_f(SR_peak_obj.freq < 93.5, :)))));
            
        end
        
        function [freq, values] = get_maximum_SR_smooth(SR_peak_obj, margin, station)
           arguments
                SR_peak_obj
                margin
                station {mustBeMember(station,["MEX","ALM"])}
           end
            % Get SR_config from the current observatory
            SR_config = SR_config_base.SR_config(station);
            first_SR = SR_config.schumann_fc(1);
            
            if (margin > first_SR || margin < 0)
                ME = MException('FunctArg:NotValid','margin value incorrect');
                throw(ME);
            end
            
            freq = zeros(1,length(SR_config.schumann_fc));
            values = zeros(1,length(SR_config.schumann_fc));
            try
                for i = 1:length(SR_config.schumann_fc)
                    low_edge  = SR_config.schumann_fc(i) - (0.1*margin*(i-1) + margin);
                    high_edge = SR_config.schumann_fc(i) + (0.1*margin*(i-1) + margin);
                    [freq(i), values(i)] = SR_peak_process.maximum_value(SR_peak_obj.smooth_data_f,SR_peak_obj.freq,  low_edge, high_edge);
                end
            catch
            end
        end
        
        function [freq, value] = get_peak_SR_smooth(schumann_peak_obj, prominence_factor)
            [freq,~, ~, value, ~] = find_peak_schumann(real(schumann_peak_obj.smooth_data_f),schumann_peak_obj.fs, prominence_factor);
        end
        
        
        
        function [freq, value] = get_peak_lorentz_raw(SR_peak_obj, margin)
            
            % GET START POINT WITH MAXIMUM FUNCION
            freq = SR_peak_obj.lorentz.lorentz_freq;
            value = SR_peak_obj.lorentz.lorentz_value;
        end
        
        
        
        
        function [freq, value] = maximum_value(data_f, freq,  low_edge, high_edge)
            range_freq = freq(freq > low_edge & freq < high_edge);
            data_f_first_SR = data_f(freq > low_edge & freq < high_edge);
            TF = islocalmax(data_f_first_SR);
            if sum(TF) == 0
                value = mean(data_f_first_SR);
                dist    = abs(data_f_first_SR - value);
                minDist = min(dist);
                idx     = find(dist == minDist);
                freq = range_freq(idx);
                return
            end
            value = max(data_f_first_SR(TF));
            freq_idx = find(data_f_first_SR == value,1);
            freq = range_freq(freq_idx);
            
        end
        
        function  [fitresult, gof, detrend_data_with_offset] = get_frequency_lorentz(SR_peak_obj, detrend_order, start_freq ,low_edge, high_edge)
            
            
            %Get data values from PSD of the SR
            data = SR_peak_obj.raw_data_f;
            
            %Get x-values from the SR object = linspace...
            f = SR_peak_obj.freq;
            
            
            %Remove trend fron the data with the order pass as an argument
            detrend_data = detrend(data, detrend_order);
            
            %Remove the offset of the function to fit with a sum of
            %lorentzian
            detrend_data_with_offset = detrend_data - min(detrend_data);
            
            
            %Ignores cases outside the boundry of interest
            weight = (f > low_edge & f < high_edge)/1;
            
            %fit and results
            [fitresult, gof] = fit_no_robust_6terms(f, detrend_data_with_offset', weight,start_freq);
            
            
        end
        
        
        
        function [freq, value, q_factor] = extract_coeff_lorentz(SR_peak_obj, fitresult, start_freq, station)
           arguments
                SR_peak_obj
                fitresult,
                start_freq,
                station {mustBeMember(station,["MEX","ALM"])}
           end
            % Get SR_config from the current observatory
            SR_config = SR_config_base.SR_config(station);
            %Get number of modes needed to return to the output
            num_modes = length(start_freq);
            
            %Generate array with the correct dimension
            freq = zeros(1,num_modes);
            value = zeros(1,num_modes);
            q_factor = zeros(1,num_modes);
            internal_freq = zeros(1,num_modes);
            
            %Extract coefficients
            
            lorentz_number_of_coeff = 3;
            coeff = coeffvalues(fitresult);
            number_of_coefficients = length(coeff) / lorentz_number_of_coeff;
            fit_qfactor(1:number_of_coefficients) = coeff(1:number_of_coefficients);
            fit_freq(1:number_of_coefficients) = coeff(number_of_coefficients + 1:2 * number_of_coefficients);
            fit_value(1:number_of_coefficients) = coeff(2 * number_of_coefficients + 1:3 * number_of_coefficients);
            
            for i = 1:num_modes
                current_freq = SR_config.schumann_fc(i);
                dist = abs(fit_freq - current_freq);
                min_dist = min(dist);
                idx_dist = find(dist == min_dist);
                
                if (dist > SR_config.margin)
                    freq(i) = start_freq(i);
                    %version 2
                    value(i) = fitresult(freq(i));
                    %value(i) = start_values(i);
                    q_factor(i) = NaN;
                else
                    internal_freq(i) = fit_freq(idx_dist);
                    [~,min_idx] = min(abs(SR_peak_obj.freq' - internal_freq(i)));
                    freq(i) = SR_peak_obj.freq(min_idx);
                    value(i) = fitresult(freq(i));
                    %value_int(i) = schumann_peak_obj.smooth_data_f(min_idx);
                    q_factor(i) = fit_qfactor(idx_dist);
                end
            end
        end
        
        
        function plot_smooth(SR_peak_obj)
            plot(SR_peak_obj.freq,SR_peak_obj.smooth_data_f);
        end
        function plot_raw(SR_peak_obj)
            plot(SR_peak_obj.freq,SR_peak_obj.raw_data_f);
        end
        
        
        
        function plot(SR_peak_obj, y_unit, type, filter_freq, lines)
            arguments
                SR_peak_obj
                y_unit {mustBeMember(y_unit, ["pT", "psd"])}
                type {mustBeMember(type, ["raw", "filter", "normal", "smooth", "completed", "lorentz"])}
                filter_freq {mustBeMember(filter_freq, ["none", "DL", "Normal"])}
                lines 
            end
            % Get SR_config from the current observatory
            SR_config = SR_config_base.SR_config(SR_peak_obj.station);
            switch(filter_freq)
                case "DL"
                    lim_freq = [SR_config.select_DL_low_limit, SR_config.select_DL_up_limit];
                    selected_frequencies = (SR_config.SR_freq > SR_config.select_DL_low_limit) & (SR_config.SR_freq < SR_config.select_DL_up_limit);
                case "Normal"

                    lim_freq = [SR_config.select_plot_normal_low, SR_config.select_plot_normal_up];
                    selected_frequencies = (SR_config.SR_freq > SR_config.select_plot_normal_low) & (SR_config.SR_freq < SR_config.select_plot_normal_up);
                otherwise
                    lim_freq = [min(SR_config.SR_freq), max(SR_config.SR_freq),];
                    selected_frequencies = ones(1, length(SR_config.SR_freq ));
            end

            if strcmp(type, 'raw')
                data_f = SR_peak_obj.raw_data_f;
                
            elseif strcmp(type, 'filter')
                data_f = SR_peak_obj.filter_data_f;
                
            elseif strcmp (type, 'smooth')
                data_f = SR_peak_obj.smooth_data_f;
            elseif strcmp (type, 'completed')
                data_f = SR_peak_obj.raw_data_f;
            elseif strcmp (type, 'lorentz')
                data_f = SR_peak_obj.raw_data_f;
            end
            if strcmp(y_unit, 'pT')
                data_f_power = 10.^ (data_f / 10);
                plot_y = sqrt(data_f_power);
                
                
                if strcmp ( type, 'lorentz') == 1
                    lorentz_data_f = SR_peak_obj.lorentz.get_lorentz_signal(SR_peak_obj.station);
                    semilogy(SR_config.SR_freq, plot_y,'LineWidth',2,'Color', [0, 0, 0] + 0.6);
                   data_f_power_2 = 10.^ (lorentz_data_f / 10);
                    plot_y2 = sqrt(data_f_power_2);
                    hold on;
                    semilogy(SR_config.SR_freq(selected_frequencies), plot_y2(selected_frequencies),'Color','b','LineWidth',2)
                elseif(strcmp ( type,'completed')) == 1
                    semilogy(SR_peak_obj.freq, plot_y,'LineWidth',2,'Color', [0, 0, 0] + 0.6);
                    data_f_power_2 = 10.^ (SR_peak_obj.smooth_data_f / 10);
                    plot_y2 = sqrt(data_f_power_2);
                    hold on;
                    semilogy(SR_peak_obj.freq, plot_y2,'Color','k','LineWidth',2)
                else
                    semilogy(SR_peak_obj.freq, plot_y, 'color', 'r','LineWidth',2);
                end
                
                ylabel('Magnetic field Module/frequency ($pT/\sqrt{Hz}$)', 'Interpreter', 'latex')
            elseif strcmp(y_unit, 'psd')
                plot_y = data_f;
                semilogy(SR_peak_obj.freq, plot_y);
                ylabel("Power/frequency (dB/Hz)");
            else
                return ;
            end
            date_init = SR_peak_obj.time_start;
            date_end = SR_peak_obj.time_start + SR_peak_obj.duration;
            str_title = datestr(date_init) + " to ";
            if day(date_init) == day(date_end)
                str_title = str_title + datestr(date_end,'HH:MM:SS');
            else
                str_title = str_title + datestr(date_end);
            end
            str_title = str_title; %+ "     Type: " + type + " Station: " + SR_peak_obj.station + " " + SR_peak_obj.component;
            title(str_title);
            xlim(lim_freq);
            xlabel("Frequency (Hz)");
            if lines == 1
                xline(SR_peak_obj.lorentz.lorentz_freq,'--', 'LineWidth',2,'Color','b'  )
            end
            hold off
            grid on
        end
    end
end
