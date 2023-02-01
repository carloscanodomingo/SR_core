clear all
for i = 2016:2019
    mat_file = strcat("I:\Data\SR_class\SR_" + i + ".mat");
    load(mat_file);
    var_name = strcat("SR_" + i);
    SR_year_pre = eval(var_name);
    SR_year = SR_year_pre.
    clearvars var_name;
    
    filename = ("I:\Data\SR_class\SR_completed_discriminated.mat");
    if isfile(filename)
        delete(filename);
    end
    
    %GET MAXIMUM
    array_day_SR_maximum = process_year_schumann_peak.maximum_day(SR_year, 1,'maximum');
    array_day_SR_mat_maximum = [array_day_SR_maximum.mean_f];
    array_day_SR_datetime_maximum = [array_day_SR_maximum.day];
    array_day_SR_maximum_f = buffer(array_day_SR_mat_maximum,8);
    %cell_SR_maximum = {array_day_SR_datetime_maximum, array_day_SR_maximum_f};
    
    varname_f = "SR_" + i + "_maximum_f";
    varname_datetime = "SR_" + i + "_maximum_datetime";
    S.(varname_f) = array_day_SR_maximum_f';
    S.(varname_datetime) = array_day_SR_datetime_maximum';
    
    %GET PEAK
    array_day_SR_peak = process_year_schumann_peak.maximum_day(SR_year, 1,'peak');
    array_day_SR_mat_peak = [array_day_SR_peak.mean_f];
    array_day_SR_peak_f = buffer(array_day_SR_mat_peak,8);
    array_day_SR_datetime_peak = [array_day_SR_peak.day];
    cell_SR_peak = {array_day_SR_datetime_peak, array_day_SR_datetime_peak};
    
    varname_f = "SR_" + i + "_peak_f";
    varname_datetime = "SR_" + i + "_peak_datetime";
    S.(varname_f) = array_day_SR_peak_f' ;
    S.(varname_datetime) = array_day_SR_datetime_peak';

    
end

    if isfile(filename)
        save(filename, '-struct', 'S', '-append');
    else
        save(filename, '-struct', 'S');
    end