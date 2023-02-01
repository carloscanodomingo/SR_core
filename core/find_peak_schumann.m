function [f,f_dist, width, value, schumann_fc] = find_peak_schumann(data_f, station)
    arguments
        data_f
        station {mustBeMember(station,["MEX","ALM"])}
    end

    % Get SR_config from the current observatory
    SR_config = SR_config_base.SR_config(station);

    % Function to find the N first modes of the schumann Resonance.
    
    % Prominence_factor factor to sleect wheter is a new peak or not.

    number_of_modes = SR_config.number_of_modes;
    number_of_peaks = SR_config.number_of_peaks;

    % Find all peaks with extract component
    [pks,locs,w] = extract_all_peaks(data_f, SR_config.fs, number_of_peaks, SR_config.prominence_factor);

    f = zeros(1,number_of_modes);
    f_dist = zeros(1,number_of_modes);
    width = zeros(1,number_of_modes);
    value = zeros(1,number_of_modes);

    % Loop for the 8 resonances
    for k=1:length(SR_config.schumann_fc)
        
        % Compute distant from all the peaks and selected SR frequency
        % expectate
        dist = abs(locs - SR_config.schumann_fc(k));
        
        %Select closest peak
        minDist = min(dist);
        idx = find(dist == minDist,1);
        
        % Save values.
        if isempty(idx) == 0
        f(k) = locs(idx);
        width(k) = w(idx);
        value(k) = pks(idx);
        f_dist(k) = minDist;
        else
                  f(k) = 0;
        width(k) = 0;
        value(k) = 0;
        f_dist(k) = 0;  
        end
    end
    
    %DELETE ASAP
    schumann_fc = SR_config.schumann_fc;
    
    function [pks,locs,w] = extract_all_peaks(ps, fs, N, prominence_factor)
        % Performs a component extraction of the signal using find peaks.

        samples_hz = ceil(length(ps)/(fs/ 2));

        [pks,locs_temp,w,~] = findpeaks(ps,'WidthReference','halfprom', ...
            'NPeaks', N,'MinPeakProminence', ...
            (max(ps) - min(ps))/(1000 * prominence_factor) , 'MinPeakDistance', samples_hz);

        locs = locs_temp * (fs/2) / length(ps);
        w = w * (fs/2) / length(ps);

    end



end