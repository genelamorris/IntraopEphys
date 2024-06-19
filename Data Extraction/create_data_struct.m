%% Important locations
struct_path = 'C:\SurgeriesData\Alpha-Probe-STN';
patients_files_path = 'C:\SurgeriesData\patient files';
Extraction_files_path = 'C:\SurgeriesData\Alpha-Probe-STN\Data Extraction';
cd(Extraction_files_path)

%% initialize struct

if isfile([struct_path '\DataStruct.mat'])
    DataStruct = load([struct_path ,'\ DataStruct.mat']);
else
    DataStruct = struct();
    DataStruct.params.patients = {'EC'}; %{'AAM', 'AD', 'EC', 'GE', 'MB', 'SV'};
    DataStruct.params.hemispheres = {'left', 'right'};
    DataStruct.params.suffix = {'Central'; 'Lateral'; 'Anterior'; 'Medial'; 'Posterior'; 'Neuroprobe1'; 'Neuroprobe2'};
end



%% load file data
% create a table 
for patient = DataStruct.params.patients

    % STEP 1: create a table to orgenize all the surgery files
    files_data = arrange_file_table([patients_files_path '\' cell2mat(patient) '_matlab']);
    for field = fieldnames(files_data)'
        temp_table = files_data.(string(field));
        DataStruct.(string(patient)).files_data.(string(field)) = temp_table(cell2mat(temp_table.distance)<10,:);
    end

    % STEP 2: open CSV file with electrode locations and trajectories and
    % save it as a table
        % List all CSV files in the folder
    folder_path = char([patients_files_path  '\' cell2mat(patient) '_matlab']);
    csv_files = dir(fullfile(folder_path, '*.csv'));
        % Check if there is exactly one CSV file
    if length(csv_files) == 1
        csv_file_name = csv_files.name;
        disp('Found CSV file');
    else
        error('Expected exactly one CSV file in the folder, but found %d', length(csv_files));
    end 
        % save csv as a table
    file_name = fullfile(folder_path, csv_file_name);
    DataStruct.(string(patient)).Surg_data = readtable(file_name);

    % STEP 3: extract electrode trajectories from table
    DataStruct.(string(patient)).trajectories = Extract_trajectories(DataStruct.(string(patient)).Surg_data, DataStruct.params.suffix);
    disp('Saved Trajectories');
    
end

%% Extract Patient data
DataStruct = Extract_Patient_data(DataStruct, patients_files_path);

%% extract Univariate Parameters
DataStruct_A = Extract_Univariate(DataStruct);
save(fullfile(struct_path, 'DataStruct_A.mat'), 'DataStruct_A', '-v7.3')


% DataStruct_B = Extract_Bivariate(DataStruct_B);
% save(fullfile(struct_path, 'DataStruct_B.mat'), 'DataStruct_B', '-v7.3')

