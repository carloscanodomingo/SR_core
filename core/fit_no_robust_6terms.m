function [fitresult, gof] = fit_no_robust(freq, detrend_data_with_offset, weight, start_points, station)
arguments
    freq,
    detrend_data_with_offset,
    weight,
    start_points
    station {mustBeMember(station,["MEX","ALM"])}
end



%% Fit: 'Sum_six_lorentz'.
% Get SR_config from the current observatory
SR_config = SR_config_base.SR_config(station);
[xData, yData, weights] = prepareCurveData( freq, detrend_data_with_offset, weight );

start_point_cut = start_points(1:SR_config.max_sr_mode);
% Set up fittype and options.

ft = fittype( SR_config.fn_fit_lorentz, 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
excludedPoints = (xData < SR_config.fn_fit_lorentz_exclude_lower) | (xData > SR_config.fn_fit_lorentz_exclude_upper);
opts.Algorithm = 'Trust-Region';
opts.DiffMinChange = 1e-9;
opts.Display = 'Off'; 
opts.MaxFunEvals = 5000;
 opts.Lower = SR_config.fn_fit_lorentz_lower;
 %schumann_fc = [7.83, 14.3, 20.8, 27.3, 33.8, 39, 45, 60];
 opts.Upper = SR_config.fn_fit_lorentz_upper;
opts.MaxIter = 1000;
opts.Robust = 'Bisquare';
pre_start_point = [0.399961864586141 0.0451092487106278 0.201045341699827 0.0428628361556463 0.639163201462111 0.2518];
post_start_point =  [0.0244699833220734 0.0397795442038889 0.529818635947425 0.933367035373425 0.602214607998047 0.601176727619887 ];
opts.StartPoint =  [pre_start_point(1:SR_config.max_sr_mode) start_point_cut post_start_point(1:SR_config.max_sr_mode)];
opts.Weights = weights;
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );


