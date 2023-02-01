classdef SR_hour
    %SR_HOUR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hour;
        f_mean_per_hour;
        f_std_per_hour;
        val_mean_per_hour;
        val_std_per_hour;
    end
   properties (Constant)
       schumann_fc = [7.83, 14.3, 20.8, 27.3, 33.8, 39, 45, 60];
       component = {'NS', 'EW'};
       total_hours_per_day = 24;
       step_fit = 0.1;
       color_area = [0, 0.5, 0.5];
       alpha_area = 0.2;
       color_line = [0, 0, 0];
   end
    
    methods
        function obj = SR_hour(f_mean_per_hour,f_std_per_hour, val_mean_per_hour,val_std_per_hour)
            %SR_HOUR Construct an instance of this class
            %   Detailed explanation goes here
            obj.f_mean_per_hour = f_mean_per_hour;
            obj.f_std_per_hour = f_std_per_hour;
            obj.val_mean_per_hour = val_mean_per_hour;
            obj.val_std_per_hour = val_std_per_hour;
        end
        

        function y_mean_values = plot_f(obj,component)
            
            mean_values = obj.f_mean_per_hour(component,:);
            std_values = obj.f_std_per_hour(component,:);
            
            y_mean_values = SR_hour.plot(mean_values, std_values);
             %ylim([SR_hour.schumann_fc(component) - 1, SR_hour.schumann_fc(component) + 1]);
           
            %title("Mode: " + component + " " + "Freq Desviation");
            
        end
        function y_mean_values = plot_val(obj,component)
            
            mean_values = obj.val_mean_per_hour(component,:);
            std_values = obj.val_std_per_hour(component,:);
            
            y_mean_values = SR_hour.plot(mean_values, std_values);
           % title("Mode: " + component + " " + "Value Desviation");
            
        end
         
    end
    methods (Static)
        function y_mean_values =  plot(mean_values, std_values)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            % get x for fitting the model 
            x_to_fit = 0:SR_hour.total_hours_per_day - 1;
            
            % Get x for ploting the area
            x_values = (0:SR_hour.step_fit:SR_hour.total_hours_per_day);
            
            % create fit model for y mean
            f_fit_mean = fit(x_to_fit', mean_values', 'smoothingspline');
            % Set up fittype and options.
            %{
            ft = fittype( 'a1*x^2+b1*x+c1+a2*sin(b2*x+c2)+a3*sin(b3*x+c3)', 'independent', 'x', 'dependent', 'y' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            opts.Algorithm = 'Levenberg-Marquardt';
            opts.Display = 'Off';
            opts.Robust = 'LAR';
            opts.StartPoint = [0.913375856139019 0.278498218867048 0.957166948242946 0.63235924622541 0.157613081677548 0.485375648722841 0.0975404049994095 0.970592781760616 0.8002804688888];
            %[fitresult, gof] = fit( xData, yData, ft, opts );

            f_fit_mean = fit( x_to_fit',mean_values',ft,opts);
            %}
            
            % calculated y and fit of lowwe std points
            lower_function = mean_values - std_values;
            f_fit_lower = fit(x_to_fit', lower_function', 'smoothingspline');
            % calculated y and fit of upper std points
            upper_function = 2 .* std_values;
            f_fit_upper = fit(x_to_fit', upper_function', 'smoothingspline');

            
            % get y values from the model
            y_mean_values = feval(f_fit_mean, x_values);
            
            % Get the lower values from lower_function_model
            lower_function_values = feval(f_fit_lower, x_values);
            
            % Get the lower values from lower_function_model
            upper_function_values = feval(f_fit_upper, x_values);
            
            % Join lower function and area to print
            X1 = [lower_function_values'; upper_function_values'];
            
            % Print Area
            h1 = area(x_values, X1');
            
            % Make Area from 0 to lower function invisible
            h1(1).FaceColor = [1, 1, 1];
            h1(1).LineStyle = ':';
            
            % Make grey and semi-transparent the area to print
            h1(2).FaceColor = SR_hour.color_area;
            h1(2).FaceAlpha = SR_hour.alpha_area;
            h1(2).LineStyle = ':';
            
            % Set x lim and show hours
            xlim([0,23]);
            xticks([0:3:23]);
            
            % Compute and Set the upper and lower limit of the plot
            max_limit = max(lower_function_values + upper_function_values) + 0.3;
            min_limit = min(lower_function_values ) - 0.3;
            
            
            % Plot the fit curve
            hold on
            l1 = plot(x_values, y_mean_values, 'k', 'LineWidth', 1);
            l1.Color = SR_hour.color_line;
            hold off;
            ylim([min_limit, max_limit]);
            
        end
          function errorbar(mean_values, std_values)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            errorbar(mean_values,std_values);
        end
    end
end

