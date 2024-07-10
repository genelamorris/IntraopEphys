%% initialize struct
DataStruct = struct();
DataStruct.params.hemispheres = {'left', 'right'};
DataStruct.params.suffix = {'Central'; 'Lateral'; 'Anterior'; 'Medial'; 'Posterior'; 'Neuroprobe1'; 'Neuroprobe2'};

%% INPUTS
% 1. where is the Datastruct file located? or where do you want it to be?
DataStruct.params.struct_path = fullfile('C:', 'SurgeriesData', 'IntraopEphys');

% 2. where are the matlab files of ALL the patients located? 
DataStruct.params.patients_files_path = fullfile('C:', 'SurgeriesData', 'patient files');
% NOTE - this is not a specific patient's folder. all the patients' folders
% should be inside this 'patients_files_path' directory, and saved as
% 'XXX_matlab' (XXX = patient's name).

% 3. Where are the matlab functions that are needed for extraction saved?
DataStruct.params.Extraction_files_path = fullfile('C:', 'SurgeriesData', 'IntraopEphys', 'Data Extraction');

% 4. Optional, location of the CSV files
DataStruct.params.CSV_files_path = fullfile('C:', 'SurgeriesData', 'CSV');
