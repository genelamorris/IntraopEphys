%% Laod the existing datastruct or create a new one
% OPTION 1: load existing
[filename, pathname] = uigetfile('*.mat', 'Select a MAT-file');
tempStruct = load(fullfile(pathname, filename));
variableName = fieldnames(tempStruct);
DataStruct = tempStruct.(variableName{1});

% OPTION 2: create a new one
% NOTE: BEFORE RUNNING, OPEN THE FILE AND SET IT UP
% run('create_data_struct.m')

%% Load New pateints
cd(DataStruct.params.Extraction_files_path)
% Patient_name = String. 
% must be the name of the folder in which the .mat files are saved. 
% EG - Patient_name = 'EC' means that .mat files are in 'EC_matlab' folder.
%patients = {'EC', 'AAM', 'AD', 'GE', 'KS'};
patients = {'EC'};
for patient = patients
    Patient_name = cell2mat(patient);
    DataStruct = Add_Patient(DataStruct, Patient_name);
end
%% extract Univariate Parameters
% First, mark as true/false each area. those are the parameters that will
% be computed.
params.Compute_RMS = true; % Note that this is used twice - for Base RMS and Relative RMS.
params.Compute_Entropy = true;
params.Compute_SpectralEntropy = true;
params.Compute_SpectralKurtosis = true;
params.Compute_PSD = true;
% Only if Compute_PSD = true:
    params.compute_PSDfit = true;
    params.Compute_Bands = true;

% 2. Now choose the patient to whom you want to compute the chosen params.
%    - parameters can be computed again if they already exist in the struct,
%      but dont have to.
patients = {'EC', 'AAM', 'AD', 'GE', 'KS'};
for patient = patients
    Patient_name = cell2mat(patient);
    DataStruct_A = Extract_Univariate(DataStruct, patient, params);
    save(fullfile(struct_path, 'DataStruct_A.mat'), 'DataStruct_A', '-v7.3')
end

%% extract Bivariate Parameters
% Signal Amplitude:
params.compute_PSD = false; %% NOTE: IF this is off - all amplitude parameters are off 
params.Compute_covarience = true;
params.Compute_correlation = true;
params.Compute_CrossCorr = true;
params.Compute_CPSD = true;
params.Compute_Coherence = true;
params.Compute_Chronux = true;
params.Compute_Granger = true;

% Signal Phase:
params.compute_phase = false; %% NOTE: IF this is off - all phase parameters are off 
params.Save_phase = false;
params.save_PhaseDiff = true;
params.Compute_PLV = true;


patients = {'EC', 'AAM', 'AD', 'GE', 'KS'};
for patient = patients
    Patient_name = cell2mat(patient);
    DataStruct_B = Extract_Bivariate(DataStruct_B, patient, params);
    save(fullfile(struct_path, 'DataStruct_B.mat'), 'DataStruct_B', '-v7.3')
end