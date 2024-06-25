%% INPUTS
% 1. where is the Datastruct file located? or where do you want it to be?
struct_path = fullfile('C:', 'SurgeriesData', 'IntraopEphys');

% 2. where are the matlab files of ALL the patients located? 
patients_files_path = fullfile('C:', 'SurgeriesData', 'patient files');
% NOTE - this is not a specific patient's folder. all the patients' folders
% should be inside this 'patients_files_path' directory, and saved as
% 'XXX_matlab' (XXX = patient's name).

% 3. Where are the matlab functions that are needed for extraction saved?
Extraction_files_path = pwd; % it's probably this folder
Extraction_files_path = fullfile('C:', 'SurgeriesData', 'IntraopEphys', 'Data Extraction');
cd(Extraction_files_path)

% 4. Optional, location of the CSV files
CSV_files_path = fullfile('C:', 'SurgeriesData', 'CSV');

%% initialize struct
DataStruct = struct();
DataStruct.params.hemispheres = {'left', 'right'};
DataStruct.params.suffix = {'Central'; 'Lateral'; 'Anterior'; 'Medial'; 'Posterior'; 'Neuroprobe1'; 'Neuroprobe2'};

% Only important thing here is params.patients - write here the
% patients' names that you want to extract (have to have the same name as
% their matlab folder - 'RN' means there is a folder 'RN_matlab')
DataStruct.params.patients = {'Samuelov_Ido'}; %{'AAM', 'AD', 'EC', 'GE', 'MB', 'SV'};

%% STEP 1: create a table to organize all the surgery files
% create a table 
for patient = DataStruct.params.patients
    matfiles_path = fullfile(patients_files_path, [cell2mat(patient) '_matlab']);
    files_data = arrange_file_table(matfiles_path);
    for field = fieldnames(files_data)'
        temp_table = files_data.(string(field));
        DataStruct.(string(patient)).files_data.(string(field)) = temp_table(cell2mat(temp_table.distance)<10,:);
    end
end

%% STEP 2: load xml file
for patient = DataStruct.params.patients
    folder_path = fullfile(patients_files_path, [cell2mat(patient) '_matlab']);
    xml_files = dir(fullfile(folder_path, '*.xml'));
    % Check if there is exactly one XML file
    if length(xml_files) == 1
        xml_file_name = xml_files.name;
    else
        error('Expected exactly one XML file in the folder, but found %d', length(xml_files));
    end 
    DataStruct.(string(patient)).patient_params = Extract_xml(fullfile(folder_path, xml_file_name), DataStruct.params);
end


%% STEP 3: open CSV file with electrode locations and trajectories and save it as a table
% List all CSV files in the folder
if ~isempty(CSV_files_path)
    for patient = DataStruct.params.patients
        Surge_date = DataStruct.(string(patient)).patient_params.Opperation_Date;  
        matched_file = helper_find_csv(Surge_date, CSV_files_path, patient);
        
        if ~isempty(matched_file)
            % save csv as a table
            DataStruct.(string(patient)).Surg_data = readtable(fullfile(CSV_files_path, matched_file));
        
            % Extract electrode trajectories from table
            DataStruct.(string(patient)).trajectories = Extract_csv_trajectories(DataStruct.(string(patient)).Surg_data, DataStruct.params.suffix);
            disp('Saved Trajectories from CSV');
        
        else
            % Extract electrode trajectories from xml (This info is already
            % extracted inside 'Extract_xml.m', here we will re-orgenise it
            % so it will fit the expected structure of 
            % the next function (Extract_Patient_data)
            xml_traj = DataStruct.(string(patient)).patient_params.xml_trajectories;
            DataStruct.(string(patient)).trajectories = Extract_xml_trajectories(xml_traj, DataStruct.params.suffix);
            disp('Saved Trajectories from XML');
        end
    end
end

%% STEP 4: Extract Patient data
for patient = DataStruct.params.patients
    DataStruct = Extract_Patient_data(DataStruct, patients_files_path, patient);
end

%%% Check file for corrupt rows
DataStruct = helper_check_rows(DataStruct);
% some vectors are too short, because sometimes there are multiple files 
% in the same location, and only the last one contains the real, long recording.
% In other, rare instences, the recording is too short and the whole row is
% removed.
%% extract Univariate Parameters
DataStruct_A = Extract_Univariate(DataStruct);
save(fullfile(struct_path, 'DataStruct_A.mat'), 'DataStruct_A', '-v7.3')

% DataStruct_B = Extract_Bivariate(DataStruct_B);
% save(fullfile(struct_path, 'DataStruct_B.mat'), 'DataStruct_B', '-v7.3')
