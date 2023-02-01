classdef SR_lorentz
    %SR_LORENTZ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lorentz_fit;
        lorentz_gof;
        lorentz_freq;
        lorentz_value;
        data_detrend_f;
        trend_f;
        start_freq;
        start_values;
        version;
    end
    
    methods
        function obj = SR_lorentz(SR_peak_obj , version, station )
           arguments
                SR_peak_obj
                version
                station {mustBeMember(station,["MEX","ALM"])}
           end
            % Get SR_config from the current observatory
            SR_config = SR_config_base.SR_config(station);
            %   Detailed explanation goes here    
            
            obj.version = version;
            [obj.start_freq, obj.start_values] = SR_peak_process.get_maximum_SR_smooth(SR_peak_obj, SR_config.lorentz_margin_maximum, station);
          
            %Get data values from PSD of the SR
            data = SR_peak_obj.raw_data_f;
            
            %Get x-values from the SR object = linspace...

            f = SR_config.SR_freq;
            
            
            
            %Remove trend fron the data with the order pass as an argument
            detrend_data = detrend(data, SR_config.lorentz_detrend_order);

            

            %Remove the offset of the function to fit with a sum of
            %lorentzian 
            obj.data_detrend_f = detrend_data - min(detrend_data);
            
            detrend_data_filtered = test_lpf(obj.data_detrend_f);
            %Ignores cases outside the boundry of interest
            weight = (f > SR_config.lorentz_low_f_limit & f < SR_config.lorentz_high_f_limit)/1;
            
            
            %fit and results
            [obj.lorentz_fit, obj.lorentz_gof] = fit_no_robust_6terms(f, detrend_data_filtered', weight,obj.start_freq, station);
        
             obj.trend_f = SR_peak_obj.raw_data_f - obj.data_detrend_f;
             
            [obj.lorentz_freq, obj.lorentz_value, ~] = SR_peak_process.extract_coeff_lorentz(SR_peak_obj, obj.lorentz_fit, obj.start_freq, station);
        end
        function signal = get_lorentz_signal(obj, station)
           arguments
                obj
                station {mustBeMember(station,["MEX","ALM"])}
           end
            % Get SR_config from the current observatory
            SR_config = SR_config_base.SR_config(station);
            signal = obj.lorentz_fit(SR_config.SR_freq)  + obj.trend_f;
        end
        
    end
end

