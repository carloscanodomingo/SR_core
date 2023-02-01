directory = 'I:\Data\capturas_elf_cal_test'; 

FileList = dir(fullfile(directory, '**', '*NS_cal.mat'));
fs = 187;
data_length = fs*60*30;
k = 1;
data_advance = data_length; % NO OVERLAP
data_advance_duration = seconds(data_advance / fs);
duration = seconds(data_length / fs);
data_buffer_index = 336600;
data_buffer = [];
complete_SR = [];
current_datetime = datetime(0,'ConvertFrom','datenum');
filename = 'extract_fr_data';

while 1
    if length(data_buffer) - (data_buffer_index - 1) < data_length
        if k <= length(FileList)
            load(FileList(k).name);
            str_time = extractBetween(FileList(k).name,'c_',strcat('_','NS', '_cal.mat'));
            next_datetime = datetime(str_time,'InputFormat','yyyy_MM_dd_HHmmss');
            if ((next_datetime - current_datetime) < minutes(31))
                if month(current_datetime) ~= month(next_datetime)
                    if ~isempty(complete_SR)
                        varname = strcat('SR',datestr(current_datetime, 'mm_yyyy'),'_NS');
                        S.(varname) = complete_SR;
                        if isfile(filename)
                            save(filename, '-struct', 'S', '-append');
                        else
                            save(filename, '-struct', 'S');
                        end
                        
                        clearvars('complete_SR');
                        complete_SR = [];
                    end
                end
                    
 
                current_datetime = next_datetime - seconds((length(data_buffer) - data_buffer_index)/fs);
                data_buffer = [data_buffer(data_buffer_index : end); y_cal];
            else
                current_datetime = next_datetime;
                data_buffer = y_cal;
            end
            data_buffer_index = 1;
            k = k + 1;
        else
            break;
        end
    end
    data = data_buffer(data_buffer_index : (data_buffer_index + data_length - 1));
    SR = schumann_peak();
    SR = SR.get_schumann_peak(current_datetime,duration,data);
    complete_SR = [ complete_SR, SR];
    data_buffer_index = data_buffer_index + data_advance;
    current_datetime = current_datetime + data_advance_duration;
        
end
varname = strcat('SR_', datestr(current_datetime, 'mm_yyyy'),'_NS');
S.(varname) = complete_SR;
if isfile(filename)
    save(filename, '-struct', 'S', '-append');
else
    save(filename, '-struct', 'S');
end
