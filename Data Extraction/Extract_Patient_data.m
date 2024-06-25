function DataStruct = Extract_Patient_data(DataStruct, patients_files_path, patient)
% EXTRACT_PATIENT_DATA Extracts patient data and organizes it in the DataStruct.
%   This function extracts data for a specified patient, organizes it into tables, 
%   and updates the DataStruct with the extracted data.
%
%   Input:
%   - DataStruct: The structure containing all the data and parameters.
%   - patients_files_path: Path to the folder containing patient files.
%   - patient: The name of the patient whose data needs to be extracted.
%
%   Output:
%   - DataStruct: Updated structure with the extracted patient data.

patient_num = find(ismember(DataStruct.params.patients, patient));
patient_path = fullfile(patients_files_path, sprintf('%s_matlab', string(patient)));

for hemi = DataStruct.params.hemispheres
    files_table = DataStruct.(cell2mat(patient)).files_data.(cell2mat(hemi));
    unq_distances = unique(cell2mat(files_table.distance), 'stable');
    unq_movement = round([0; abs(diff(unq_distances))], 1);
    
    % Create empty table for every patient and every hemisphere
    TableName = sprintf('table_%s_%s', cell2mat(patient), cell2mat(hemi));
    DataStruct.(string(patient)).(TableName) = table('Size', [length(unq_distances) 9], ...
        'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'cell', 'cell', 'cell', 'double', 'struct'}, ...
        'VariableNames', {'Alpha_Central', 'Alpha_Lateral', 'Alpha_Anterior', 'Alpha_Medial', 'Alpha_Posterior', ...
        'Neuroprobe_1', 'Neuroprobe_2', 'Movement_Distance', 'Bivariate_Parameters'}, ...
        'RowNames', string(unq_distances));

    % Fill the table, row by row
    for file_num = 1:size(files_table, 1)
        % Open file
        filename = files_table.full_filename{file_num};
        distance = files_table.distance{file_num};
        vetor_num = files_table.file_number{file_num};
        field_name_with_suffix_spk = sprintf('data_vector_0%s_spk', vetor_num); % for vectors with multiple files
        field_name_with_suffix_lfp = sprintf('data_vector_0%s_lfp', vetor_num); % for vectors with multiple files
        data = load(fullfile(patient_path, filename));
        row_names = cellstr(DataStruct.(string(patient)).(TableName).Properties.RowNames);
        row_num = find(ismember(row_names, num2str(distance)));

        %%%%%%%%%%% Fill in vectors %%%%%%%%%%%
        %%%% 1-5. Alpha probe columns
        %%%% 6. neuro probe 1 column
        %%%% 7. neuro probe 2 column
        for col = 1:7
            %%%% Find the data vector:
            % Some files are called 'CSPK_0X' and some 'CSPK_0X__location'
            % - we will find the correct vector with 'contains'

            % Probe indexes based on orientation during surgery (predetermined):
            col_name = string(DataStruct.(string(patient)).(TableName).Properties.VariableNames(col));
            if isfield(DataStruct.(string(patient)).trajectories.(cell2mat(hemi)), [char(col_name) '_Orientation'])
                probe_indx = DataStruct.(string(patient)).trajectories.(cell2mat(hemi)).([char(col_name) '_Orientation']);

                % Names of vectors to extract:
                vec_name_spk = sprintf('CSPK_0%d', probe_indx);
                vec_name_lfp = sprintf('CLFP_0%d', probe_indx);

                % Vector extraction
                data_fields = fieldnames(data);
                data_vec_indx_spk = find(cellfun(@(x) contains(x, vec_name_spk) && isa(data.(x), 'int16'), data_fields));
                data_vec_indx_lfp = find(cellfun(@(x) contains(x, vec_name_lfp) && isa(data.(x), 'int16'), data_fields));
                %%%% If found, add the data vectors:
                if ~isempty(data_vec_indx_spk)
                    data_vec_spk = data.(data_fields{data_vec_indx_spk(1)});
                    DataStruct.(string(patient)).(TableName).(col_name){row_num}.(string(field_name_with_suffix_spk)) = data_vec_spk;
                end
                if ~isempty(data_vec_indx_lfp)
                    data_vec_lfp = data.(data_fields{data_vec_indx_lfp(1)});
                    DataStruct.(string(patient)).(TableName).(col_name){row_num}.(string(field_name_with_suffix_lfp)) = data_vec_lfp;
                end
            end
        end
        DataStruct.(string(patient)).(TableName).Movement_Distance(row_num) = unq_movement(row_num);
    end
end
disp(['Data extraction from patient ' + string(patient) + ' complete'])
end
