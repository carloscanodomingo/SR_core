function add_component(SR_peak_object_array_year,component)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
   mustBeMember(component,SR_config.component);
   
    for i = 1:length(SR_peak_object_array_year)
        current_month = SR_peak_object_array_year{i};
        for k = 1:length(current_month)
        current_month(k).component = component;
    end
end
