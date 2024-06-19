function DataStruct = Extract_Phase_Params(DataStruct)
Compute_PLV = true;
Compute_synchronization = true;
Compute_PhaseCoherence = true;

% Save the cleaned PSD vector and frequency axis vector
%   - For each frequency band (theta, alpha, beta, gamma):
%       - Computes phase information for different frequency bands
%           1. Apply a bandpass filter to isolate the frequency band
%           2. Extract the phase from the Hilbert transform of the filtered signal
%           3. Handle phase unwrapping to correct phase jumps
%           4. Save the phase vector

% 1. Phase Differance
% 2. PLV (Phase Locking Value)
% 3. Phase synchronization
% 4. mean phase coherence
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initiation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bands = struct('name', {'theta', 'alpha', 'beta', 'gamma'},...
               'range', {[4, 8], [8, 13], [13, 30], [30, 60]});
filter_order = 100;


for patient = DataStruct.params.patients
    for hemi = DataStruct.params.hemispheres
        TableName = sprintf('table_%s_%s', cell2mat(patient), cell2mat(hemi));
        for row = 1:size(DataStruct.(string(patient)).(TableName),1)
            Electrodes = DataStruct.(string(patient)).(TableName).Properties.VariableNames(1:7);
            for i = 1:numel(Electrodes)
                for j = (i+1):numel(Electrodes)
                    electrode_1 = Electrodes{i};
                    electrode_2 = Electrodes{j};
                    
                    %% %%%%%%% find correct vector to work with %%%%%%%%%%%
                    vec_1 = DataStruct.(string(patient)).(TableName).(electrode_1){row}.data_vector_01_spk;
                    vec_2 = DataStruct.(string(patient)).(TableName).(electrode_2){row}.data_vector_01_spk;
                    i_vec = 2;
                    while length(vec_1) < Fs 
                        % same location - vectors have the same length - one loop is enough  
                        vector_name_1 = ['data_vector_0' num2str(i_vec) '_spk'];
                        vec_1 = DataStruct.(string(patient)).(TableName).(electrode_1){row}.(vector_name_1);
                        vector_name_2 = ['data_vector_0' num2str(i_vec) '_spk'];
                        vec_2 = DataStruct.(string(patient)).(TableName).(electrode_2){row}.(vector_name_2);
                        i_vec = i_vec+1;
                    end
                    
                    %% %%%%%% Preprocessing for spectral analysis %%%%%%%%%
                    vec_1 = single(vec_1);
                    vec_2 = single(vec_2);
                    
                    %  1. rectification (abs)
                    rectified_vec_1 = abs(vec_1);
                    rectified_vec_2 = abs(vec_2);
                    
                    %  2. mean substruction (coherence requires zero-mean stationary random processes)
                    vec_1_final = rectified_vec_1 - mean(rectified_vec_1);
                    vec_2_final = rectified_vec_2 - mean(rectified_vec_2);

                    
                    %% %%%%%%%%%%%%%%% Phase Extraction %%%%%%%%%%%%%%%%%%%     
                    for band = bands
                        
                        % 1. Apply bandpass filter
                        b = fir1(filter_order, [band.range(1) / (Fs/2), band.range(2) / (Fs/2)], 'bandpass');
                        filtered_data_1 = filter(b, 1, vec_1);
                        filtered_data_2 = filter(b, 1, vec_2);
                        
                        % 2. Extract the phase from the Hilbert transform
                        trim_range = 2*filter_order;
                        hilbert_phase_1 = angle(hilbert(filtered_data_1(trim_range:end-trim_range)));
                        hilbert_phase_2 = angle(hilbert(filtered_data_2(trim_range:end-trim_range)));
                        
                        % 3. Handle Phase Unwrapping (jumps of over +-pi)
                        phase_unwrapped_1 = unwrap(hilbert_phase_1);
                        phase_unwrapped_2 = unwrap(hilbert_phase_2);
                        
                        % 4. Save Phases
                        if ~isfield(DataStruct.(string(patient)).(TableName).(electrode_1){row}.(band.name).phase)
                            DataStruct.(string(patient)).(TableName).(electrode_1){row}.(band.name).phase = phase_unwrapped_1;
                        end
                        %
                        if ~isfield(DataStruct.(string(patient)).(TableName).(electrode_2){row}.(band.name).phase)
                            DataStruct.(string(patient)).(TableName).(electrode_2){row}.(band.name).phase = phase_unwrapped_2;
                        end
                          
                        
                        %% %%%%%%%%%%%% Parameter Extraction %%%%%%%%%%%%%%
                        
                        % 1. Phase Diff
                        phase_diff = hilbert_transform_1 - hilbert_transform_2;

                        % 2. Phase locking value
                        if Compute_PLV
                            plv_value = abs(mean(exp(1i * phase_diff)));  % Absolute value of the mean of complex exponential
                            DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).(['PLV_' band.name]){i,j} = plv_value;
                        end
                        % 3. mean phase coherence / synchrony factor
                        if Compute_synchronization
                            
                        end
                        % 4. normalized Phase Synchronization index
                        if Compute_PhaseCoherence
                            
                        end
                        
                        
                    end

                    
                    
                    
                    
                end
            end
        end
        disp(['Finished Loading Patient ' cell2mat(patient) ' - ' cell2mat(hemi) ' hemi'])
    end
end

