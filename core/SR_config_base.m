classdef SR_config_base
    %SR_CONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)

        total_hours = 24;

        number_of_season = 4;
        save_fig_format_valid = ["pdf","png", "tiff"]

        MAX_SIZE_KERAS = 256;
 
        
        format_date_table = 'yyyy/dd/mm-HH:MM:SS';

        
        prominence_factor = 0.2;
        


        types_get_peak = {'maximum', 'peak','lorentz'}
        
        component = ["NS","EW"];
        
        current_version = 5;
        
       base_path_linux = getenv('HOME') + "/img";
       base_path_windows = getenv('HOMEPATH') + "\img";
       
       threshold_p_value = 0.0001;
       
       
       sr_ionos_var_name = ["IO_hF","IO_hF2","IO_hE","IO_hEs","IO_tec",         "IO_sunspot_total","IO_sunspot_north","IO_sunspot_south",           "IO_Kp","IO_Ap",   "IO_lightning","IO_global_temperature", "IO_D_local"];

       DL_len = 256;

       SR_paper_3_show_title = false;
    end
    methods(Static)
        function ref_class = SR_config(station )
           arguments
                station {mustBeMember(station,["MEX","ALM"])}
            end
             if station == "MEX"
                 ref_class = SR_config_mex;
             elseif station == "ALM"
                 ref_class = SR_config_alm;
             end
         end
    end
    
end

