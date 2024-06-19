function data_vector = Plot_Bi_values(DataStruct,Patient,Hemisphere,Electrode_1, Electrode_2, mode)

%% Initial params
table_name = sprintf('table_%s_%s',Patient,Hemisphere);
[col_name_1, temp_table_1, Distances, x_location] = Helper_Extract_from_electrode(DataStruct, Patient,Hemisphere, Electrode_1);
[col_name_2, temp_table_2,~,~] = Helper_Extract_from_electrode(DataStruct, Patient,Hemisphere, Electrode_2);
titleText = sprintf('%s - %s - %s Vs. %s', Patient, Hemisphere, Electrode_1, Electrode_2);

%% electrode indexes
electrode_order = {'Central', 'Lateral', 'Anterior', 'Medial', 'Posterior', 'Neuroprobe_1', 'Neuroprobe_2'};
% Find the index for Electrode_1
idx_1 = find(strcmp(electrode_order, Electrode_1));
if isempty(idx_1)
    error(['Unknown electrode: ' Electrode_1]);
end
% Find the index for Electrode_2
idx_2 = find(strcmp(electrode_order, Electrode_2));
if isempty(idx_2)
    error(['Unknown electrode: ' Electrode_2]);
end
    

%% Extract data vector (across distances)
% Plot for regular Band requests - Theta, Alpha, Beta, Gamma:
data_vector = [];
for i = 1:size(temp_table_1,1)
    row_data = DataStruct.(Patient).(table_name).Bivariate_Parameters(i);

    if strcmp(mode, 'Covariance')
        data_vector = [data_vector row_data.Covariance{idx_1,idx_2}];
        if isempty(row_data.Covariance{idx_1,idx_2})
            data_vector = [data_vector row_data.Covariance{idx_2,idx_1}];
        end
    end
    
    if strcmp(mode, 'Correlation Coeffitient')
        data_vector = [data_vector row_data.Corr_coeff{idx_1,idx_2}];
        if isempty(row_data.Covariance{idx_1,idx_2})
            data_vector = [data_vector row_data.Corr_coeff{idx_2,idx_1}];
        end
    end
    
end

% plot
plot(x_location, data_vector, 'LineWidth', 2)
Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode_1, Electrode_2)
ylabel('Value')
xlabel('X Depth (Corrected) [mm]')
title({[mode ' of '], titleText})

% adjust ylim
if mean(data_vector) > 20*median(data_vector) % this is for extreme cases
    peak_thresh = 3.5*median(data_vector);
else
    peak_thresh = mean(data_vector) + 2*std(data_vector);
end
[~, locs] = findpeaks(abs([data_vector mean(data_vector)]), 'MinPeakHeight', peak_thresh);
data_vector_without_peaks = data_vector;
data_vector_without_peaks(locs) = [];
if strcmp(mode, 'Covariance')
    ylim([0 max(data_vector_without_peaks)+0.5]);
elseif strcmp(mode, 'Correlation Coeffitient')
    ylim([0 min([max(data_vector_without_peaks)+0.1 1])]);
end

set(gca, 'FontSize', 12)
set(gca, 'Xdir', 'reverse')
set(gcf,'color', 'w')
box off



end