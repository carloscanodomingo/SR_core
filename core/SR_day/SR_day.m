classdef SR_day
    %SR_SELECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        day;
        mean_f;
        std_f;
        mean_val;
        std_val;

    end
    
    methods
        function obj = SR_day(day, mean_f, std_f, mean_val, std_val)
            %SR_SELECT Construct an instance of this class
            %   Detailed explanation goes here
            obj.day = day;
            obj.mean_f = mean_f;
            obj.std_f = std_f;
            obj.mean_val = mean_val;
            obj.std_val = std_val;
        end
        
    end
end

