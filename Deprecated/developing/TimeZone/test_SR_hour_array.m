
for i = 1:6
    close all
total_subplot_vertial = 1;

mode = 2;
type = 'val';
component = 'NS';
start_name = "test_value_method_2"

for i=1:total_subplot_vertial
    figures(i) = figure();
    SR_hour_max.plot_month(mode,type,[(i - 1) * 3 + 1,  i * 3]);
end
if type == 'val'
    if mode == 1
        y_edge_values = [0, 30];
    elseif mode == 2
        y_edge_values = [0, 30];
    else
        y_edge_values = [-30, 10];
    end
elseif type == 'f'
    if mode == 1
        y_edge_values = [6, 9];
    elseif mode == 2
        y_edge_values = [13 16];
    elseif mode == 3
        y_edge_values = [19 23];
    elseif mode == 4
        y_edge_values = [25.5 29.5];
    elseif mode == 5
        y_edge_values = [31.5 36.5];
    elseif mode == 6
        y_edge_values = [36.5 41.5];
    end
end
margin = (max(y_edge_values) - min(y_edge_values)) / 30;
y_values = [min(y_edge_values), (min(y_edge_values) +   max(y_edge_values)) /2, max(y_edge_values)];
y_ticks_values = [min(y_values) + margin,y_values(2), max(y_values) - margin];
y_ticks_names = string(y_values);
    

y_labels = ["All years (Hz)","2017 (Hz)", "2016 (Hz)"];
subtitle_season = ["Winter","Spring","Summer","Autum"];
f1 = figure('MenuBar', 'none','ToolBar', 'none');
first_space_width = 0.05;
first_space_height = 0.07;
width_subfig = 0.22;
width_subtotal = 0.23;
height_subfig = 0.28;
height_subtotal = 0.29;

total_subplot_horizontal = 3;
for i=1:total_subplot_vertial
    for k = 1:total_subplot_horizontal
            h(i,k)=subplot('Position',[first_space_width + ((i - 1) * width_subtotal), first_space_height + ((k - 1) * height_subtotal), width_subfig, height_subfig]);
            if k == 1
                set(h(i,k),'XTick',[0.3,12,23.7],'XTickLabels', ["0", "12", "24"]);
            else
                set(h(i,k),'XTick',[]);
            end
            if k == total_subplot_horizontal
                title(subtitle_season(i))
            end
            if i == 1
                set(h(i,k),'YTick',y_ticks_values, 'YTickLabels', y_ticks_names);
                ylabel( y_labels(k));
            else
                set(h(i,k),'YTick',[]);
            end
            xlim([0 24])
            ylim([min(y_values) max(y_values)])

    end
end

for i=1:total_subplot_vertial
    allaxes = findall(figures(i), 'type', 'axes');
    for k = 1:length(allaxes)
        copyobj(allchild(allaxes(k)),h(i,k));
    end
    %close(figure(i))
end
lines_legend = [h(i,k).Children(1), h(i,k).Children(4),h(i,k).Children(3), h(i,k).Children(2)];
lines_legend_names = ["Night","Sunrise","Noon","Sunset"];


legend(lines_legend, lines_legend_names);


legend('Position',[0.25 0 0.5 0.05]);
legend('Orientation','horizontal')
legend('boxoff')
save_fig('wide', start_name + "_test_mode_" + mode + "_type_" + type + "_" + component , 'png')
return
end