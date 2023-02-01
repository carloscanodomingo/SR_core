function y = samples_concat(path_dir, pattern, start_datetime, total_hours, max_error);
% SAMPLES_CONCAT  Concat samples from the specifed day up to the number of hours specifed.
%   path_dir = name of the directory where the samples are located
%   pattern = 'NS' or 'EW'. desired polarization 
%   start_time = start time in datetime format
%   total_hours = total duration to be concacatenated
%   max_error = max error allowed between consecutived samples. Ideal 0 so
%   30min between samples.


    listing = dir(path_dir);
    y = [];
    
    % Find index
    k = find_index(start_datetime, listing, pattern);

    if ( k == -1)
        msg = 'day not found in the current directory';
        error(msg)
    end 
    
    previous_time = 0;
    added = 0;
    
    while (k < size(listing,1) && added < total_hours*2)
        if contains(listing(k).name,pattern)
            str_time = extractBetween(listing(k).name,'c_',strcat('_',pattern, '_cal.mat'));
            current_time = posixtime(datetime(str_time,'InputFormat','yyyy_MM_dd_HHmmss'));
            if ( previous_time ~= 0)
                total_time = total_time + (current_time - previous_time);
                if (check_continuity(current_time, previous_time, max_error) == 0)
                    error(strcat("Discontinuity detected in ", int2str(k)))
                end
             previous_time = current_time;
            end
            
            load(listing(k).name);
            y = [y;y_cal];
            clear y_cal;
            added = added + 1;
        end
        k = k + 1;

    end
end
function bool = check_continuity(time1, time2, error_range)
    if (abs(time1-time2) < error_range)
        bool = 1;
    else
        bool = 0;
    end
end

function index = find_index(start_datetime, listing, pattern)
    k = 1;
    while((contains(listing(k).name,pattern)) ==  0)
        k = k + 1;
    end
        
    display(listing(k).name)
    
    str_time = extractBetween(listing(k).name,'c_',strcat('_',pattern, '_cal.mat'));
    index_datetime = datetime(str_time,'InputFormat','yyyy_MM_dd_HHmmss');
    
    display(index_datetime)
    
    if(index_datetime > start_datetime)
        error("day not in the current database")
    end
    while(k < size(listing,1))
        str_time = extractBetween(listing(k).name,'c_',strcat('_',pattern, '_cal.mat'));
        index_datetime = datetime(str_time,'InputFormat','yyyy_MM_dd_HHmmss');
        if (index_datetime > start_datetime)
            index = k;
            display(index_datetime)
            return;
        end
        k = k + 1;
    end
    index = -1;
end
    