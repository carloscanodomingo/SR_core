classdef SR_config_alm < SR_config_base
    %SR_CONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        start_year = 2016;
        end_year = 2020;

        max_sr_mode = 6;

        fs = 187;
        window = 1870;

        freq_length = 1871;

        overlap = 0;
        margin = 20;

        total_elem = 79281;
      
        schumann_fc = [7.83, 14.3, 20.8, 27.3, 33.8, 39];
        fn_fit_lorentz = 'A1/(1 + ((x - B1)/(C1/2))^2) + A2/(1 + ((x - B2)/(C2/2))^2) + A3/(1 + ((x - B3)/(C3/2))^2) + A4/(1 + ((x - B4)/(C4/2))^2) + A5/(1 + ((x - B5)/(C5/2))^2)  + A6/(1 + ((x - B6)/(C6/2))^2) ';
        fn_fit_lorentz_lower = [-Inf -Inf -Inf -Inf -Inf -Inf ...
                7.0 12 18 25 30 36 ...
                0.5 0.5 0.5 0.5 0.5 0.5];
       fn_fit_lorentz_upper = [Inf Inf Inf Inf Inf Inf ...
                 9 16 23 29 36 45 ...
                 Inf Inf Inf Inf Inf Inf];
       fn_fit_lorentz_exclude_lower = 7.3;
       fn_fit_lorentz_exclude_upper = 43;
        SR_freq = linspace(0,93.5,1871);
        
        lat_observatory = 37.1;
        long_observatory = -2.6;
        alt_observatory = 700;

        % FIND SCHUMANN PEAK 
        number_of_modes = 6;
        number_of_peaks = 25;

        %LORENTZ
        lorentz_low_f_limit = 7;
        lorentz_high_f_limit = 42;
        lorentz_margin = 1.5;
        lorentz_margin_maximum = 2;
        
        
        lorentz_detrend_order = 5;
        

        remove_noise_frequency_lower_limit = 7.2;
        remove_noise_frequency_upper_limit = 8.3;
    	remove_noise_power_band_lower_limit = 18;
        remove_noise_power_band_upper_limit = 35;

       

       RMSE_low_limit = 6.5;
       RMSE_up_limit = 41;
       
       select_DL_low_limit = 3.5;
       select_DL_up_limit = 43.5;

       select_plot_normal_low = 0;
       select_plot_normal_up = 45;

    end
    
end

