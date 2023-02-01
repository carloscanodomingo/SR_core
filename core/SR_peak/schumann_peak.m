classdef schumann_peak
    %SCHUMMAN_PEAK Summary of this class goes here
    %   Detailed explanation goes here
    %   time_start start of the capture
    %   duration length in time of the capture
    %   SR_f frecuency extracted of the each schumann resonance 8 component
    %   SR_width length in Hz of the shumanc resonance peak 8 component
    %   SR_values value of the schumann resonance in dB 8 component
    %   raw_data_f frecuency transfor of the data without any treatment 
    %   filter_data_f frequency transform of data filtered
    %   smooth_data_f frequency transform of data smoth
    
    properties(Access = public)
        time_start;
        duration;
        max_value;
        min_value;
        max_count;
        min_count;
        SR_f;
        SR_width;
        SR_values;
        raw_data_f;
        filter_data_f;
        smooth_data_f;
        lorentz_data_f;
        lorentz;
        classification;
        freq;
        hpf_value = 3;
        fs;
        component;
        window;
        n_modes;
        station;
    end
    properties(Access = private)
        transform_func = @SR_peak_welch;
        filter_func = @hpf;
        find_peak_func = @find_peak_schumann; 
        overlap = 0;
        SR_max_peak = 8;
    end
    properties(Constant)
    end
    
    methods
        function obj = schumann_peak()
        end
        function obj = get_schumann_peak(obj, time_start,duration, data, component, station )
                arguments
                    obj,
                    time_start,
                    duration,
                    data,
                    component  {mustBeMember(component,["NS","EW"])},
                    station {mustBeMember(station,["MEX","ALM"])}
                end
            %SCHUMMAN_PEAK Construct an instance of this class
            % Get SR_config from the current observatory
            SR_config = SR_config_base.SR_config(station);

            %   Detailed explanation goes here
            obj.time_start = time_start;
            obj.duration = duration;
            obj.station = station;

             % Start processing
            obj.SR_f = zeros(1, SR_config.max_sr_mode);
            obj.SR_width = zeros(1, SR_config.max_sr_mode);
            obj.SR_values = zeros(1, SR_config.max_sr_mode);
            obj.raw_data_f = zeros(1, SR_config.freq_length);
            obj.filter_data_f = zeros(1, SR_config.freq_length);
            obj.smooth_data_f = zeros(1, SR_config.freq_length);
            
            obj.component = component;
            
            %  Get raw data f
            [obj.raw_data_f, obj.freq] = obj.transform_func(data, SR_config.fs, SR_config.window, SR_config.overlap);
            
            % Filter data in t
            data_filtered_t = obj.filter_func(data,obj.hpf_value, SR_config.fs);
            
            % Get filtered data f
            obj.filter_data_f = obj.transform_func(data_filtered_t, SR_config.fs, SR_config.window, SR_config.overlap);
            
            % smooth frecuency spectrum
            obj.smooth_data_f = smoothdata(obj.filter_data_f,'sgolay',30,'Degree',2); % Create ‘sgolayfilt’ Filtered FFT

            % get schumman peaks
            [obj.SR_f,~, obj.SR_width, obj.SR_values, ~] = obj.find_peak_func(real(obj.smooth_data_f), station); 
            
            obj.lorentz = SR_lorentz(obj, SR_config.current_version, station);
            obj.lorentz_data_f = obj.lorentz.get_lorentz_signal(obj.station);
            %obj.classification = SR_classification(obj);
         end
    end
end


function [data_filtered] = hpf(data,hpf_value, fs)
%HPF Summary of this function goes here
%   Detailed explanation goes here
data_filtered = highpass(data,hpf_value,fs,'Steepness',0.85,'StopbandAttenuation',60);
end


