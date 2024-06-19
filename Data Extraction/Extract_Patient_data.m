function DataStruct = Extract_Patient_data(DataStruct, patients_files_path)
for patient = DataStruct.params.patients
    patient_num = find(ismember(DataStruct.params.patients,patient));
    patient_path = char(sprintf("%s\\%s_matlab",patients_files_path, string(patient)));
    for hemi = DataStruct.params.hemispheres
        files_table = DataStruct.(cell2mat(patient)).files_data.(cell2mat(hemi));
        unq_distances = unique(cell2mat(files_table.distance),'stable');
        unq_movement = round([0;abs(diff(unq_distances))],1);
        % create empty table for every patient and every hemi
        TableName = sprintf('table_%s_%s', cell2mat(patient), cell2mat(hemi));
        DataStruct.(string(patient)).(TableName) = table('Size',[length(unq_distances) 9],...
        'VariableTypes',{'cell','cell','cell','cell','cell','cell','cell','double','struct'},...
        'VariableNames',{'Alpha_Central','Alpha_Lateral','Alpha_Anterior','Alpha_Medial','Alpha_Posterior',...
                         'Neuroprobe_1', 'Neuroprobe_2', 'Movement_Distance', 'Bivariate_Parameters'},...
        'RowNames', string(unq_distances));
    
        % fill the table, row by row
        for file_num = 1:size(files_table,1)
            % open file
            filename = files_table.full_filename{file_num};
            distance = files_table.distance{file_num};
            vetor_num = files_table.file_number{file_num};
            field_name_with_suffix_spk = ['data_vector_0' num2str(vetor_num) '_spk']; % for vectors with multiple files
            field_name_with_suffix_lfp = ['data_vector_0' num2str(vetor_num) '_lfp']; % for vectors with multiple files
            data = load([patient_path '\' filename]);
            row_names = cellstr(DataStruct.(string(patient)).(TableName).Properties.RowNames);
            row_num = find(ismember(row_names, num2str(distance)));
            
            %%%%%%%%%%% fill in vectors %%%%%%%%%%%
            %%%% 1-5. Alpha probe columns
            %%%% 6. neuro probe 1 column
            %%%% 7. neuro probe 2 column
            for col = 1:7
                %%%% find the data vector:
                % some files are called 'CSPK_0X' and some 'CSPK_0X__location' 
                % - we will find the correct vector with 'contains'
                
                % probe indexes based on orientation during surgery (preditermained):
                col_name = string(DataStruct.(string(patient)).(TableName).Properties.VariableNames(col));
                if isfield(DataStruct.(string(patient)).trajectories.(cell2mat(hemi)), [char(col_name) '_Orientation'])
                    probe_indx = DataStruct.(string(patient)).trajectories.(cell2mat(hemi)).([char(col_name) '_Orientation']);  
                    
                    % names of vectors to extract:
                    vec_name_spk = sprintf('CSPK_0%d', probe_indx);
                    vec_name_lfp = sprintf('CLFP_0%d', probe_indx);
                    
                    % vector extraction
                    data_fields = fieldnames(data);
                    data_vec_indx_spk = find(cellfun(@(x) contains(x, vec_name_spk) && isa(data.(x), 'int16'), data_fields));
                    data_vec_indx_lfp = find(cellfun(@(x) contains(x, vec_name_lfp) && isa(data.(x), 'int16'), data_fields));
                    %%%% if found, add the data vectors:
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
    disp(['data extraction from patient ' + string(patient)  + ' complete'])
end
end

