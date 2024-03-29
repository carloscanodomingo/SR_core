function [fitresult, gof] = Fits(freq, detrend_data_with_offset, weight)
%CREATEFITS(FREQ,DETREND_DATA_WITH_OFFSET,WEIGHT)
%  Create fits.
%
%  Data for 'untitled fit 1' fit:
%      X Input : freq
%      Y Output: detrend_data_with_offset
%      Weights : weight
%  Output:
%      fitresult : a cell-array of fit objects representing the fits.
%      gof : structure array with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 21-Apr-2020 21:19:50

%% Initialization.

% Initialize arrays to store fits and goodness-of-fit.
fitresult = cell( 2, 1 );
gof = struct( 'sse', cell( 2, 1 ), ...
    'rsquare', [], 'dfe', [], 'adjrsquare', [], 'rmse', [] );

%% Fit: 'untitled fit 1'.
[xData, yData, weights] = prepareCurveData( freq, detrend_data_with_offset, weight );

% Set up fittype and options.
ft = fittype( 'A1/(1 + ((x - B1)/(C1/2))^2) + A2/(1 + ((x - B2)/(C2/2))^2) + A3/(1 + ((x - B3)/(C3/2))^2) + A4/(1 + ((x - B4)/(C4/2))^2) + A5/(1 + ((x - B5)/(C5/2))^2)  + A6/(1 + ((x - B6)/(C6/2))^2) + A7/(1 + ((x - B7)/(C8/2))^2)', 'independent', 'x', 'dependent', 'y' );
%ft = fittype( 'A1/(1 + ((x - B1)/(C1/2))^2) + A2/(1 + ((x - B2)/(C2/2))^2) + A3/(1 + ((x - B3)/(C3/2))^2) + A4/(1 + ((x - B4)/(C4/2))^2) + A5/(1 + ((x - B5)/(C5/2))^2)  + A6/(1 + ((x - B6)/(C6/2))^2) + Z', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Levenberg-Marquardt';
opts.DiffMinChange = 1e-10;
opts.Display = 'Off';
opts.MaxFunEvals = 1000;
opts.MaxIter = 10000;
opts.Robust = 'Bisquare';
opts.StartPoint = [0.428252992979386 0.482022061031856 0.120611613297162 0.589507484695059 0.226187679752676 0.384619124369411 0.582986382747674 7.83 14.3 20.8 27.3 33.8 39 50 0.343877004114983 0.584069333278452 0.107769015243743 0.906308150649733 0.879653724481905 0.817760559370642 0.260727999055465];
opts.Weights = weights;

% Fit model to data.
[fitresult{1}, gof(1)] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult{1}, xData, yData );
legend( h, 'detrend_data_with_offset vs. freq with weight', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'freq', 'Interpreter', 'none' );
ylabel( 'detrend_data_with_offset', 'Interpreter', 'none' );
grid on

%% Fit: 'untitled fit 2'.
% Cannot generate code for fit 'untitled fit 2' because the data selection is incomplete.


