function DataStruct = helper_check_rows(DataStruct)
% Processes each cell in the table, 
% renames the longest data vector,
% removes rows if none are longer then 1sec.
% 
% This function iterates through the given DataStruct and its tables, 
% identifying and renaming the longest  'data_vector_XX_spk' in each cell.
% It also removes rows where no vector exceeds the specified length threshold Fs.
%
%   Input:
%   - DataStruct: The structure containing all the data and parameters.
%
%   Output:
%   - DataStruct: Updated structure with renamed vectors and possibly removed rows.


% Get the list of patients
Fs = 44000;
patients = DataStruct.params.patients;

% Iterate through each patient
for p = 1:length(patients)
    patient = patients{p};
    % Iterate through each hemisphere
    for hemi = DataStruct.params.hemispheres
        hemi = hemi{1};  % Convert from cell to string
        TableName = sprintf('table_%s_%s', patient, hemi);
        
        % Check if the table exists
        if isfield(DataStruct.(patient), TableName)
            table_data = DataStruct.(patient).(TableName);
            
            % Initialize an array to track rows to be removed
            rows_to_remove = [];
            
            % Iterate through each row of the table
            for row_num = 1:height(table_data)
                row = table_data(row_num, :);
                max_length = 0;
                longest_vector_name = '';
                
                % Iterate through each column of the row
                for col = 1:7
                    if ~isempty(row{1, col}{1})
                        cell_data = row{1, col}{1};
                        
                        % Identify fields matching 'data_vector_XX_spk'
                        vector_fields = fieldnames(cell_data);
                        spk_fields = vector_fields(contains(vector_fields, 'data_vector') & contains(vector_fields, '_spk'));
                        
                        % Find the longest vector
                        for i = 1:length(spk_fields)
                            vec_name = spk_fields{i};
                            vec_length = length(cell_data.(vec_name));
                            if vec_length > max_length
                                max_length = vec_length;
                                longest_vector_name = vec_name;
                            end
                        end
                    
              
                    
                        % Rename the longest vector if found
                        if ~isempty(longest_vector_name)
                            main_vector_name = [longest_vector_name, '_main'];
                            cell_data.(main_vector_name) = cell_data.(longest_vector_name);
                            cell_data = rmfield(cell_data, longest_vector_name);
                            
                            % Update the row data
                            table_data{row_num, col}{1} = cell_data;
                        end

                        % Mark the row for removal if no vector exceeds the length threshold
                        if max_length <= Fs
                            rows_to_remove = [rows_to_remove; row_num];
                        end
                    end
                end
                

            end
            
            % Remove the marked rows
            table_data(rows_to_remove, :) = [];
            DataStruct.(patient).(TableName) = table_data;
        end
    end
end

fprintf('Row check and updates complete. %d rows removed.\n', length(rows_to_remove))
end

