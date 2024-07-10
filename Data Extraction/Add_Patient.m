function DataStruct = Add_Patient(DataStruct, patient)

DataStruct.params.patients = [DataStruct.params.patients{:} {patient}];
struct_path = DataStruct.params.struct_path;
patients_files_path = DataStruct.params.patients_files_path;
Extraction_files_path = DataStruct.params.Extraction_files_path;
CSV_files_path = DataStruct.params.CSV_files_path;
cd(Extraction_files_path);

%% STEP 1: create a table to organize all the surgery files

% create a table 
matfiles_path = fullfile(patients_files_path, [char(patient) '_matlab']);
files_data = arrange_file_table(matfiles_path);
for field = fieldnames(files_data)'
    temp_table = files_data.(char(field));
    DataStruct.(char(patient)).files_data.(char(field)) = temp_table(cell2mat(temp_table.distance)<10,:);
end

%% STEP 2: load xml file

folder_path = fullfile(patients_files_path, [char(patient) '_matlab']);
xml_files = dir(fullfile(folder_path, '*.xml'));
% Check if there is exactly one XML file
if length(xml_files) == 1
    xml_file_name = xml_files.name;
    DataStruct.(char(patient)).patient_params = Extract_xml(fullfile(folder_path, xml_file_name), DataStruct.params);
else
    warning('Expected exactly one XML file in the folder, but found %d', length(xml_files));
end 


%% STEP 3: open CSV file with electrode locations and trajectories and save it as a table

% List all CSV files in the folder
if ~isempty(CSV_files_path)
    % 1. first check for csvs in the patient's files directory
    folder_path = fullfile(patients_files_path, [char(patient) '_matlab']);
    csv_files = dir(fullfile(folder_path, '*.csv'));
    if length(csv_files) == 1
        csv_file_name = csv_files.name;
        DataStruct.(char(patient)).Surg_data = readtable(fullfile(folder_path, csv_file_name));
        
        % Extract electrode trajectories from table
        DataStruct.(char(patient)).trajectories = Extract_csv_trajectories(DataStruct.(char(patient)).Surg_data, DataStruct.params.suffix);
        disp('Saved Trajectories from CSV');
    

    % 2. then check for csvs in the csv directory. (only if there is an
    % xml - otherwise we can't know which csv to choose)
    elseif isfield(DataStruct.(char(patient)),'patient_params')
        Surge_date = DataStruct.(char(patient)).patient_params.Opperation_Date;
        matched_file = helper_find_csv(Surge_date, CSV_files_path, patient);

        if ~isempty(matched_file)
            % save csv as a table
            DataStruct.(char(patient)).Surg_data = readtable(fullfile(CSV_files_path, matched_file));

            % Extract electrode trajectories from table
            DataStruct.(char(patient)).trajectories = Extract_csv_trajectories(DataStruct.(char(patient)).Surg_data, DataStruct.params.suffix);
            disp('Saved Trajectories from CSV');
        else
            % Extract electrode trajectories from xml (This info is already
            % extracted inside 'Extract_xml.m', here we will re-orgenise it
            % so it will fit the expected structure of
            % the next function (Extract_Patient_data)
            xml_traj = DataStruct.(char(patient)).patient_params.xml_trajectories;
            DataStruct.(char(patient)).trajectories = Extract_xml_trajectories(xml_traj, DataStruct.params.suffix);
            disp('Saved Trajectories from XML');
        end
    else 
        error(sprintf('No CSV file and no XML file for patient %s', char(patient)))        
    end
end

%% STEP 4: Extract Patient data

DataStruct = Extract_Patient_data(DataStruct, patients_files_path, patient);

%%% Check file for corrupt rows
DataStruct = helper_check_rows(DataStruct);
% some vectors are too short, because sometimes there are multiple files 
% in the same location, and only the last one contains the real, long recording.
% In other, rare instences, the recording is too short and the whole row is
% removed.

end

