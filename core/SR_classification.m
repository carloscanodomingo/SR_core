classdef SR_classification
    %SR_CLASSIFICATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MLR_R2_pre;
        MLR_R2_post;
        ST_std;
        ST_mean;
        POINT_num_max;
        POINT_num_min; 
        PB_low_f;
        PB_low_f_detrend;
        PB_ratio;
        PIB_detrend;
        LORENTZ_fit;
        LORENTZ_gof;
        LORENTZ_location;
        LORENTZ_sse;
        LORENTZ_rmse;
        PS_ratio_max; % Power signal
        FITLORENTZ_first_lorentz;
    end
    properties (Constant)
        MLR_lower_limit = 3;
        MLR_upper_limit = 10;
        ST_lower_limit  = 3;
        ST_upper_limit  = 5;
        POINT_lower_limit = 5;
        POINT_upper_limit = 6;
        PB_limit = 3;
        PIB_lower_limit = 5;
        PIB_upper_limit = 40;
        LORENTZ_lower_limit = 3;
        LORENTZ_upper_limit = 10;
        PS_low_band = [1 7];
        PS_power_signal_band = [45 55];
        RATIO_lorentz_lower_limit = 6;
        RATIO_lorentz_uppeer_limit = 9;
        
    end
    
    methods 
        function obj = SR_classification(SR_peak_obj)
            
            obj.MLR_R2_pre = obj.get_R2_pre(SR_peak_obj);
            
            obj.MLR_R2_post = obj.get_R2_post(SR_peak_obj);
            
            [obj.ST_std,obj.ST_mean] = obj.estadistical_classification_low_frequency(SR_peak_obj);
            
            obj.PB_low_f = obj.get_low_f_psd(SR_peak_obj);
            
            [obj.POINT_num_max, obj.POINT_num_min] = obj.num_max_smooth(SR_peak_obj);
            
            obj.PB_low_f_detrend = obj.get_low_f_psd_detrend(SR_peak_obj);
            
            [obj.LORENTZ_fit, obj.LORENTZ_gof, obj.LORENTZ_location, obj.LORENTZ_sse, obj.LORENTZ_rmse] = obj.R2_lorentz_first_SR(SR_peak_obj);
            
            obj.PB_ratio =  obj.power_band_ratio_first_SR(SR_peak_obj);
            
            obj.PIB_detrend = obj.power_band_detrend(SR_peak_obj);
        
            obj.PS_ratio_max = obj.ratio_max(SR_peak_obj);
            
            obj.FITLORENTZ_first_lorentz = obj.get_first_lorentz(SR_peak_obj);
        end
    end
    methods (Static)
    function MLR_R2_pre = get_R2_pre(SR_peak_obj)
            % Get R2 of a lineal regresion from the raw sample from
            % hpf_vale and the up limit
            selected_freq = (SR_config.SR_freq > SR_classification.MLR_lower_limit & SR_config.SR_freq < SR_classification.MLR_upper_limit ); 
            
            mdl_pre = fitlm(SR_config.SR_freq(selected_freq), SR_peak_obj.raw_data_f(selected_freq));
            
            MLR_R2_pre = mdl_pre.Rsquared.Ordinary;
        end
        
        function MLR_R2_post = get_R2_post(SR_peak_obj)
            % Get R2 of a lineal regresion from the Smooth sample from
            % hpf_vale and the up limit
            
            select_freq = (SR_config.SR_freq > SR_peak_obj.hpf_value & SR_config.SR_freq < SR_classification.MLR_upper_limit); 
            
            mdl_post = fitlm(SR_config.SR_freq(select_freq), SR_peak_obj.smooth_data_f(select_freq));
            
            MLR_R2_post = mdl_post.Rsquared.Ordinary;
        end
        
        
        function [ST_std,ST_mean] =  estadistical_classification_low_frequency(SR_peak_obj)
            
            data_detrend = detrend(SR_peak_obj.raw_data_f);
            
            selected_frequency = (SR_config.SR_freq > SR_classification.ST_lower_limit & SR_config.SR_freq < SR_classification.ST_upper_limit);
            
            ST_std = std(abs(SR_peak_obj.raw_data_f(selected_frequency)));
            
            ST_mean = mean(abs(SR_peak_obj.raw_data_f(selected_frequency)));
        end
        
        function [POINT_num_max, POINT_num_min] = num_max_smooth(SR_peak_obj)
            
            selected_frequencies =  (SR_config.SR_freq < SR_classification.POINT_lower_limit & SR_config.SR_freq > SR_classification.POINT_upper_limit); 
            
            TF_max = islocalmax(SR_peak_obj.smooth_data_f,'MinProminence',0.6);
            
            TF_min = islocalmin(SR_peak_obj.smooth_data_f,'MinProminence',0.6);
            
            POINT_num_max = sum(TF_max(selected_frequencies));% .* SR_peak_obj.smooth_data_f(selected_frequencies));
            
            POINT_num_min = sum(TF_min(selected_frequencies));
        end
        function PB_low_f = get_low_f_psd(SR_peak_obj)
        
            PB_low_f = sum(abs(SR_peak_obj.raw_data_f(SR_peak_obj.freq < SR_classification.PB_limit)));
        end
        
        function PB_low_f_detrend = get_low_f_psd_detrend(SR_peak_obj)
            
            selected_frequency = (SR_config.SR_freq <  SR_classification.PB_limit);
            
            detrented_data = detrend(SR_peak_obj.raw_data_f(selected_frequency));
            
            PB_low_f_detrend = sum(abs(detrented_data(selected_frequency)));
        end

        
        
        function [LORENTZ_fit, LORENTZ_gof, LORENTZ_location, LORENTZ_sse, LORENTZ_rmse] = R2_lorentz_first_SR(SR_peak_obj)
            
            selected_frequency = (SR_config.SR_freq > SR_classification.LORENTZ_lower_limit & SR_config.SR_freq < SR_classification.LORENTZ_upper_limit);
            
            detrented_data = detrend(SR_peak_obj.raw_data_f);
            
            detrented_data_offset = detrented_data + abs(min(detrented_data(selected_frequency)));
            
            [LORENTZ_fit, LORENTZ_gof] = fit_1_lorentz(SR_config.SR_freq, detrented_data_offset');
            
            LORENTZ_location = LORENTZ_fit.B1;
            
            LORENTZ_sse = LORENTZ_gof.sse;
            
            LORENTZ_rmse = LORENTZ_gof.rmse;
        end
        
        
        function ratio_max = ratio_max(SR_peak_obj)
            
            selected_frequency_power_signal_band = (SR_config.SR_freq > SR_classification.PS_low_band(1) & SR_config.SR_freq < SR_classification.PS_low_band(2));
            
            selected_frequency_low_band = (SR_config.SR_freq > SR_classification.PS_power_signal_band(1) & SR_config.SR_freq < SR_classification.PS_power_signal_band(2));
            
            max_signal_power_band = max(SR_peak_obj.raw_data_f(selected_frequency_power_signal_band));
            
            max_low_band = max(SR_peak_obj.raw_data_f(selected_frequency_low_band));
            
            ratio_max = (max_signal_power_band / max_low_band);
            
        end
        
        function PB_ratio =  power_band_ratio_first_SR(SR_peak_obj)
            %Get the ratio between the lowest band and the first SR.
            
            low_limit_band_SR = SR_peak_obj.SR_f(1) - SR_peak_process.ratio_margin;
            high_limit_band_SR = SR_peak_obj.SR_f(1) + SR_peak_process.ratio_margin;
            BW_SR = high_limit_band_SR - low_limit_band_SR;
            
            selected_freq_up_limit = (SR_peak_obj.freq < high_limit_band_SR);
            min_smooth_value = min(SR_peak_obj.raw_data_f(selected_freq_up_limit));
            raw_data_no_offset = SR_peak_obj.raw_data_f - min_smooth_value;
            
            selected_freq_lowest = (SR_peak_obj.freq < SR_classification.PB_limit);
            
            psd_band_lowest = (sum((abs(raw_data_no_offset(selected_freq_lowest, :))))) / SR_classification.PB_limit;
            
            selected_freq_band_SR = (SR_peak_obj.freq > low_limit_band_SR & SR_peak_obj.freq < high_limit_band_SR);
            
            psd_band_SR = sum((abs(raw_data_no_offset(selected_freq_band_SR, :)))) / BW_SR;
            
            PB_ratio = psd_band_lowest ./  psd_band_SR;
     
        end
        
        
        
        function PIB_detrend = power_band_detrend(SR_peak_obj)
            %Get the ratio between the lowest band and the first SR.
 
            BW = SR_classification.PIB_upper_limit - SR_classification.PIB_lower_limit;
            
            selected_freq = (SR_peak_obj.freq > SR_classification.PIB_lower_limit & SR_peak_obj.freq < SR_classification.PIB_upper_limit);
            
            detrend_data = detrend(SR_peak_obj.raw_data_f(selected_freq), SR_config.lorentz_detrend_order);

            PIB_detrend = sum((abs(detrend_data))) / BW;

        end
        
        function ratio_low_f_psd = DEPRECATED_ratio_low_f_psd(SR_peak_obj, high_frequency)
            threshold_min = 0.5;
            threshold_max = high_frequency;
            
            selected_freq = (SR_peak_obj.freq > threshold_min & SR_peak_obj.freq < threshold_max);
            
            raw_low_f_psd = sum((abs(SR_peak_obj.raw_data_f(selected_freq, :))));
            
            ratio_low_f_psd = raw_low_f_psd ./  (sum((abs(SR_peak_obj.raw_data_f(SR_peak_obj.freq < 93.5, :)))));
     
        end
        
        function first_lorentz = get_first_lorentz(SR_peak_obj)
    
            first_lorentz = SR_peak_obj.lorentz.lorentz_freq(1);
        end
        
        function ratio_lorentz_raw = get_ratio_lorentz_raw(SR_peak_obj)
            
            complete_signal = SR_peak_obj.lorentz.lorentz_fit(SR_config.SR_freq) + SR_peak_obj.lorentz.trend_f;
            
            selected_frequency = (SR_config.SR_freq > SR_classification.ST_lower_limit & SR_config.SR_freq < SR_classification.ST_upper_limit);
            
            pwd_lorentz = sqrt(sum((complete_signal(selected_frequency) .^2)));
            
            pwd_raw  = sqrt(sum((SR_peak_obj.raw_data_f(selected_frequency) .^2 )));
            
            ratio_lorentz_raw = pwd_raw / pwd_lorentz;
        end
        
        function ratio_sse_mean = sse_mean(SR_peak_obj)
            
            complete_signal = SR_peak_obj.SR_
            
            selected_frequency = (SR_config.SR_freq > SR_classification.ST_lower_limit & SR_config.SR_freq < SR_classification.ST_upper_limit);
            
            pwd_lorentz = sqrt(sum((complete_signal(selected_frequency) .^2)));
            
            pwd_raw  = sqrt(sum((SR_peak_obj.raw_data_f(selected_frequency) .^2 )));
            
            ratio_lorentz_raw = pwd_raw / pwd_lorentz;
        end
    end
end

