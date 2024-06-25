function patient_params = Extract_xml(full_filename, params)
% open file
xml_struct = readstruct(full_filename,FileType="xml");

%% extract patient data
tmp_data = xml_struct.workspace(2).Patients.Patient0.WorkspaceInfo;

% 1. opperation date
patient_params.Opperation_Date = [num2str(tmp_data.OperationDateTime.year) '_' ...
                                  num2str(tmp_data.OperationDateTime.month) '_' ...
                                  num2str(tmp_data.OperationDateTime.day)];

% 2. gender
if tmp_data.Gender == 0
    patient_params.gender = 'M';
else
    patient_params.gender = 'F';
end

% 3. opp description
patient_params.Description = tmp_data.PhysicianDescription;

% 4. Patient Name
patient_params.PatientName = tmp_data.PatientName;

% 5. Hospital
patient_params.Hospital = tmp_data.Institute;


%% Extract electrode data
xml_traj_order = {'Anterior'; 'Lateral'; 'Central'; 'Medial'; 'Posterior'};
xml_traj_num = 0:4;
tmp_traject = xml_struct.workspace(2).Tracks.Trajectories;

for hemi = {'Left', 'Right'}
    hemi_traject = tmp_traject.(cell2mat(hemi));
    hemi_traject_fields = fieldnames(hemi_traject);

    for i = 1:numel(hemi_traject_fields)
        traj_i = hemi_traject.(hemi_traject_fields{i});
        
        patient_params.xml_trajectories.(lower(cell2mat(hemi))).(hemi_traject_fields{i}).BenGunType = ...
            traj_i.BenGunType;
        
        % BenGunToChannelMap using the above mapping (xml_traj_order and num),
        % map every used channel to the correct electrodes. used channels
        % are those that contain a number between 0 and 4. unused once
        % contain -1.
        for j = 1:5
            truj_num =xml_traj_num(j);
            BenGunToChannelMap_num_j = traj_i.(['BenGunToChannelMap' num2str(truj_num)]); 
            % the value in channel j - it's eather -1 or a valide number (0-4) indicating the electorde number in it.
            
            if BenGunToChannelMap_num_j ~= -1
                patient_params.xml_trajectories.(lower(cell2mat(hemi))).(hemi_traject_fields{i}).([xml_traj_order{j} '_Orientation']) = ...
                    BenGunToChannelMap_num_j+1;
            end
        end
    end
end