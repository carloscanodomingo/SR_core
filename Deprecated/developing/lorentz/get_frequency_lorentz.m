function [freq, value] = get_frequency_lorentz(schumann_peak_obj, detrend_order, start_freq, start_values,low_edge, high_edge, margin)
            
            
            margin = 2;
            
            %Get data values from PSD of the SR
            data = schumann_peak_obj.raw_data_f;
            
            %Get x-values from the SR object = linspace...
            f = schumann_peak_obj.freq;
            
            %Get number of modes needed to return to the output
            num_modes = length(start_freq);
            
            %Generate array with the correct dimension
            freq = zeros(1,num_modes);
            value = zeros(1,num_modes);
            internal_freq = zeros(1,num_modes);
            %Remove trend fron the data with the order pass as an argument
            detrend_data = detrend(data, detrend_order);

            %Remove the offset of the function to fit with a sum of
            %lorentzian 
            detrend_data_with_offset = detrend_data - min(detrend_data);
            
            %Ignores cases outside the boundry of interest
            weight = (f > low_edge & f < high_edge)/1;
            
            %fit and results
            [fitresult, gof, number_of_coefficients] = fit_no_robust(f, detrend_data_with_offset', weight,start_freq);
            
            %Extract coefficients
            coeff = coeffvalues(fitresult);
            
            Qfactor = coeff(1:number_of_coefficients);
            fit_freq(1:number_of_coefficients) = coeff(number_of_coefficients + 1:2 * number_of_coefficients);
            fit_value(1:number_of_coefficients) = coeff(2 * number_of_coefficients + 1:3 * number_of_coefficients);
            for i = 1:num_modes
                current_freq = schumann_peak.schumann_fc(i);
                dist = abs(fit_freq - current_freq);
                min_dist = min(dist);
                idx_dist = find(dist == min_dist);
                
                if (dist > margin)
                    freq(i) = start_freq(i);
                    value(i) = start_values(i);
                else
                    internal_freq(i) = fit_freq(idx_dist);
                    [~,min_idx] = min(abs(schumann_peak_obj.freq' - internal_freq(i)));
                    freq(i) = schumann_peak_obj.freq(min_idx);
                    value(i) = schumann_peak_obj.smooth_data_f(min_idx);
                end
            end
end
