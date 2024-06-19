% make a shifted locations vector for each electrode
% compare each electrode to the others (correlation)

data_table = DataStruct_A.EC.table_EC_left;
locations_NP = cellfun(@(x) str2num(x), data_table.Properties.RowNames, 'UniformOutput', false);
locations_NP = cell2mat(locations_NP);
locations_AP = locations_NP + 2.75;

first_AP_indx = find(locations_AP<10, 1);
%[~, last_NP_indx] = min(abs(locations_NP-locations_AP(end)));


locations_AP_adj = locations_AP(first_AP_indx:end);
locations_NP_adj = locations_NP(1:end-first_AP_indx+1);



data_Lateral = data_table.Alpha_Lateral(first_AP_indx:end);
data_Anterior = data_table.Alpha_Anterior(first_AP_indx:end);
data_Medial = data_table.Alpha_Medial(first_AP_indx:end);
data_Posterior = data_table.Alpha_Posterior(first_AP_indx:end);
%
data_NP = data_table.Neuroprobe_1(1:end-first_AP_indx+1);
data_Central = data_table.Alpha_Central(1:end-first_AP_indx+1);


% Extract vectors
data_Lateral_vectors = cellfun(@(x) double(x.gamma.relative_Power), data_Lateral, 'UniformOutput', false);
data_Anterior_vectors = cellfun(@(x) double(x.gamma.relative_Power), data_Anterior, 'UniformOutput', false);
data_Medial_vectors = cellfun(@(x) double(x.gamma.relative_Power), data_Medial, 'UniformOutput', false);
data_Posterior_vectors = cellfun(@(x) double(x.gamma.relative_Power), data_Posterior, 'UniformOutput', false);
data_Central_vectors = cellfun(@(x) double(x.gamma.relative_Power), data_Central, 'UniformOutput', false);
data_NP_vectors = cellfun(@(x) double(x.gamma.relative_Power), data_NP, 'UniformOutput', false);

% Define placements and corresponding vectors and locations
placements = {'Lateral', 'Anterior', 'Medial', 'Posterior', 'Central', 'NP'};
data_vectors = {data_Lateral_vectors, data_Anterior_vectors, data_Medial_vectors, data_Posterior_vectors, data_Central_vectors, data_NP_vectors};
locations = {locations_AP_adj, locations_AP_adj, locations_AP_adj, locations_AP_adj, locations_NP_adj, locations_NP_adj};

% Initialize correlation matrix
num_placements = length(placements);
correlation_matrix = zeros(num_placements, num_placements);

% Compute mean correlations
for i = 1:num_placements
    for j = 1:num_placements
        correlations = [];
        for k = 1:length(data_vectors{i})
            % Find the closest location
            [~, idx] = min(abs(locations{i}(k) - locations{j}));
            % Get the vectors
            vec1 = data_vectors{i}{k};
            vec2 = data_vectors{j}{idx};
            if length(vec1) > 1    
                % Interpolate to the common length
                common_length = min(length(vec1), length(vec2));
                vec1_final =  vec1(1:common_length);
                vec2_final =  vec2(1:common_length);
                % Compute correlation between the interpolated vectors
                corr_val = corr(vec1_final, vec2_final);
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
            correlation_matrix(i, j) =  mean(correlations, 'omitnan');
        catch
            correlation_matrix(i, j) =  mean(corr(correlations(:,1), correlations(:,2)));
        end
    end
end

% Plot heatmap
figure()
heatmap(placements, placements, correlation_matrix, 'Colormap', parula, 'ColorbarVisible', 'on');
title('Mean Correlation Heatmap between Placements');
xlabel('Placements');
ylabel('Placements');