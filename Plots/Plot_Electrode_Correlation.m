function Plot_Electrode_Correlation(DataStruct, patient, hemisphere, mode)
    % Inputs:
    % DataStruct - Data structure containing the data tables
    % patient - patient identifier (e.g., 'EC')
    % hemisphere - hemisphere identifier (e.g., 'left')
    % mode - processing mode (e.g., 'relative_power')

    % find positions:
    trajectories = DataStruct.(patient).trajectories.(hemisphere);  
    AP_pos = trajectories.AP_position;
    NP_pos = trajectories.Neuroprobe_1_position;

    % Extract the data table based on patient and hemisphere
    data_table = DataStruct.(patient).(['table_' patient '_' hemisphere]);

    % Extract and adjust the locations
    locations_NP = cellfun(@(x) str2num(x), data_table.Properties.RowNames, 'UniformOutput', false);
    locations_NP = cell2mat(locations_NP);
    locations_AP = locations_NP + 2.75;

    first_AP_indx = find(locations_AP < 10, 1);
    locations_AP_adj = locations_AP(first_AP_indx:end);
    locations_NP_adj = locations_NP(1:end-first_AP_indx+1);

    % Extract the data vectors for each placement
    Lateral_col = data_table.Alpha_Lateral(first_AP_indx:end);
    Anterior_col = data_table.Alpha_Anterior(first_AP_indx:end);
    Medial_col = data_table.Alpha_Medial(first_AP_indx:end);
    Posterior_col = data_table.Alpha_Posterior(first_AP_indx:end);
    NP_col = data_table.Neuroprobe_1(1:end-first_AP_indx+1);
    Central_col = data_table.Alpha_Central(1:end-first_AP_indx+1);


    % Extract chosen parameter
    if contains(mode, 'time_vec')
        data_Lateral = cellfun(@(x) findMainField(x), Lateral_col, 'UniformOutput', false);
        data_Anterior = cellfun(@(x) findMainField(x), Anterior_col, 'UniformOutput', false);
        data_Medial = cellfun(@(x) findMainField(x), Medial_col, 'UniformOutput', false);
        data_Posterior = cellfun(@(x) findMainField(x), Posterior_col, 'UniformOutput', false);
        data_NP = cellfun(@(x) findMainField(x), NP_col, 'UniformOutput', false);
        data_Central = cellfun(@(x) findMainField(x), Central_col, 'UniformOutput', false);
    elseif contains(mode, {'theta', 'beta', 'gamma'})
        data_Lateral = cellfun(@(x) x.(mode).relative_Power, Lateral_col, 'UniformOutput', false);
        data_Anterior = cellfun(@(x) x.(mode).relative_Power, Anterior_col, 'UniformOutput', false);
        data_Medial = cellfun(@(x) x.(mode).relative_Power, Medial_col, 'UniformOutput', false);
        data_Posterior = cellfun(@(x) x.(mode).relative_Power, Posterior_col, 'UniformOutput', false);
        data_NP = cellfun(@(x) x.(mode).relative_Power, NP_col, 'UniformOutput', false);
        data_Central = cellfun(@(x) x.(mode).relative_Power, Central_col, 'UniformOutput', false);
    elseif contains(mode, 'Spectral_entropy')
        data_Lateral = cellfun(@(x) x.(mode)', Lateral_col, 'UniformOutput', false);
        data_Anterior = cellfun(@(x) x.(mode)', Anterior_col, 'UniformOutput', false);
        data_Medial = cellfun(@(x) x.(mode)', Medial_col, 'UniformOutput', false);
        data_Posterior = cellfun(@(x) x.(mode)', Posterior_col, 'UniformOutput', false);
        data_NP = cellfun(@(x) x.(mode)', NP_col, 'UniformOutput', false);
        data_Central = cellfun(@(x) x.(mode)', Central_col, 'UniformOutput', false);
    elseif contains(mode, 'PSD_fit')
        data_Lateral = cellfun(@(x) x.(mode).Final_fit, Lateral_col, 'UniformOutput', false);
        data_Anterior = cellfun(@(x) x.(mode).Final_fit, Anterior_col, 'UniformOutput', false);
        data_Medial = cellfun(@(x) x.(mode).Final_fit, Medial_col, 'UniformOutput', false);
        data_Posterior = cellfun(@(x) x.(mode).Final_fit, Posterior_col, 'UniformOutput', false);
        data_NP = cellfun(@(x) x.(mode).Final_fit, NP_col, 'UniformOutput', false);
        data_Central = cellfun(@(x) x.(mode).Final_fit, Central_col, 'UniformOutput', false);
    else
        data_Lateral = cellfun(@(x) x.(mode), Lateral_col, 'UniformOutput', false);
        data_Anterior = cellfun(@(x) x.(mode), Anterior_col, 'UniformOutput', false);
        data_Medial = cellfun(@(x) x.(mode), Medial_col, 'UniformOutput', false);
        data_Posterior = cellfun(@(x) x.(mode), Posterior_col, 'UniformOutput', false);
        data_NP = cellfun(@(x) x.(mode), NP_col, 'UniformOutput', false);
        data_Central = cellfun(@(x) x.(mode), Central_col, 'UniformOutput', false);
    end

    % Define placements and corresponding vectors and locations
    placements = {'Lateral', 'Anterior', 'Medial', 'Posterior', 'Central', 'NP'};
    data_vectors = {data_Lateral, data_Anterior, data_Medial, data_Posterior, data_Central, data_NP};
    locations = {locations_AP_adj, locations_AP_adj, locations_AP_adj, locations_AP_adj, locations_NP_adj, locations_NP_adj};

    % Initialize correlation matrix
    num_placements = length(placements);
    correlation_matrix = zeros(num_placements, num_placements);

    % Compute mean correlations
    for i = 1:num_placements
        for j = i:num_placements
            correlations = [];
            for k = 1:length(data_vectors{i})
                % Find the closest location
                [~, idx] = min(abs(locations{i}(k) - locations{j}));
                % Get the vectors
                vec1 = double(data_vectors{i}{k});
                vec2 = double(data_vectors{j}{idx});
                if length(vec1) > 1
                    % Interpolate to the common length
                    common_length = min(length(vec1), length(vec2));
                    vec1_final = vec1(1:common_length);
                    vec2_final = vec2(1:common_length);
                    % Compute correlation between the interpolated vectors
                    corr_val = corr(vec1_final', vec2_final');
                    correlations = [correlations; corr_val];
                else
                    if vec1 > 3
                        vec1 = 3;
                    end
                    if vec2 > 3
                        vec2 = 3;
                    end
                    correlations = [correlations ; vec1 vec2]; % vec1 and vec2 are values here
                end
            end
            % Store mean correlation
            try
                correlation_matrix(i, j) = mean(correlations, 'omitnan');
                correlation_matrix(j, i) = mean(correlations, 'omitnan');
            catch
                correlation_matrix(i, j) = mean(corr(correlations(:,1), correlations(:,2)));
                correlation_matrix(j, i) = mean(corr(correlations(:,1), correlations(:,2)));
            end
        end
    end

    % Plot heatmap
    heatmap(placements, placements, correlation_matrix, 'Colormap', jet, 'ColorbarVisible', 'on',Interpreter='none');
    title(sprintf('Mean %s Correlation', mode));
    xlabel('Placements');
    ylabel('Placements');
    sgtitle({['AP Position - ' AP_pos], ['NP Position - ' NP_pos]})
    set(gcf, 'Color', 'w');
end


function mainField = findMainField(structure)
    fieldNames = fieldnames(structure);
    mainFieldName = fieldNames{find(contains(fieldNames, 'main'), 1)};
    mainField = structure.(mainFieldName);
end