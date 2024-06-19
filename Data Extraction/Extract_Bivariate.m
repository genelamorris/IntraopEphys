function DataStruct = Extract_Bivariate(DataStruct)
%% Choose what to compute:
% Signal Amplitude:
compute_PSD = false; %% NOTE: IF this is off - all ampliture parameters are off 
Compute_covarience = true;
Compute_correlation = true;
Compute_CrossCorr = true;
Compute_CPSD = true;
Compute_Coherence = true;
Compute_Chronux = true;
Compute_Granger = true;

% Signal Phase:
compute_phase = true; %% NOTE: IF this is off - all phase parameters are off 
Save_phase = false;
save_PhaseDiff = true;
Compute_PLV = true;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function:
%   - Operates on each patient's data stored in the structure 'DataStruct'
%   - takes, in turn each pair of electrodes and computes bivariate
%     parameters from the two time series:
%       - 1. Covarience
%       - 2. Pearsons' correlation coefficient
%       - 3. Cross Correlation
%       - 4. Cross Power Spectral Density (C-PSD)
%       - Coherence - in two ways:
%         5. Using Matlab's mscohere() with the following parameters:
        Fs = 44000;
        window_size = 1*Fs;  % 1 s Hamming window
        overlap = window_size/2;  % 50% overlap
        freq_range = round(linspace(3,60,585),2);
%       - 6. Using Chronux toolbox with the following parameters:
        params.tapers = [3 5];
        params.Fs = 44000;
        params.fpass = [3 60];
%       *** Chronux toolbox computs several parameters, which are all saved
%           In a cell in the following order:
%           [Coherence, Phase, cross spectrum, Spectrum 1, Spectrum 1, Frequency axis]
%       - 7. Granger Causality

%%% in the future:
    % 1. Mutual Information
    % 2. Transfer entropy

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initiation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bands = struct('name', {'theta', 'alpha', 'beta', 'gamma'},...
               'range', {[4, 8], [8, 13], [13, 30], [30, 60]});
filter_order = 100;


for patient = DataStruct.params.patients
    for hemi = {'right'} % DataStruct.params.hemispheres
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

                    
                    %% %%%%%%%%%%%%%% Spectral Parameters %%%%%%%%%%%%%%%%%
                    if compute_PSD
                        % 1. covarience
                        if Compute_covarience
                            cov_XY = cov(vec_1_final, vec_2_final); % cov(A,B) is the 2-by-2 covariance matrix
                            DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).Covariance{i,j} =...
                                cov_XY(1,2);
                        end
                        
                        % 2. pearson's correlation coefficient
                        if Compute_correlation
                            corr_XY = corrcoef(vec_1_final, vec_2_final);
                            DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).Corr_coeff{i,j} = ...
                                corr_XY(1,2);
                        end
                        
                         % 3. cross correlation
                         if Compute_CrossCorr
                             [cross_corr, lags] = xcorr(vec_1_final,vec_2_final,Fs,'unbiased');
                             DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).Cross_Corr{i,j} = ...
                                 [cross_corr ; lags];
                             DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).max_corr_lag{i,j} = ...
                                 lags(cross_corr == max(cross_corr));
                         end
                         
                         % 4. Cross-PSD
                         if Compute_CPSD
                             [CPSD, f_CPSD] = cpsd(vec_1_final,vec_2_final,window_size,overlap,freq_range,Fs);
                             %  Cleaning 50Hz line noise and its harmonics
                             indices_to_remove = [];
                             for harmonic = 1:4
                                 indices_to_remove = [indices_to_remove, find(f_CPSD >= (50*harmonic)-2 & f_CPSD <= (50*harmonic)+2)];
                             end
                             indices_to_remove = unique(indices_to_remove);
                             % Interpolation for cleaning
                             CPSD_cleaned = interp1(f_CPSD(~ismember(1:length(f_CPSD), indices_to_remove)), ...
                                 CPSD(~ismember(1:length(f_CPSD), indices_to_remove)), ...
                                 f_CPSD);
                             DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).Cross_PSD{i,j} = ...
                                 [CPSD_cleaned ; f_CPSD];
                         end
                        
                        %  5. coherence with mscohere
                        if Compute_Coherence
                            [cxy,f_msc] = mscohere(vec_1_final,vec_2_final,window_size,overlap,freq_range,Fs);
                             %  Cleaning 50Hz line noise and its harmonics
                             indices_to_remove = [];
                             for harmonic = 1:4
                                 indices_to_remove = [indices_to_remove, find(f_msc >= (50*harmonic)-2 & f_msc <= (50*harmonic)+2)];
                             end
                             indices_to_remove = unique(indices_to_remove);
                             % Interpolation for cleaning
                             cxy_cleaned = interp1(f_msc(~ismember(1:length(f_msc), indices_to_remove)), ...
                                 cxy(~ismember(1:length(f_msc), indices_to_remove)), ...
                                 f_msc);                        
                            DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).Coherence{i,j} = ...
                                [cxy_cleaned ; f_msc];
                        end
                        
                        % 6. chronux coherencyc
                        if Compute_Chronux
                            [C,phi,S12,S1,S2,f_ch] =coherencyc(vec_1,vec_2,params);
                            DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).Chronux{i,j} = ...
                                {C,phi,S12,S1,S2,f_ch};
                        end
                        
                        % 7. Granger causality
                        if Compute_Granger
                            [h_12, p_12] = gctest(double(vec_1)',double(vec_2)');
                            DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).Granger_test{i,j} = ...
                                [h_12 ; p_12];
                            [h_21, p_21] = gctest(double(vec_2)',double(vec_1)');
                            DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).Granger_test{j,i} = ...
                                [h_21 ; p_21];
                        end
                    end
                     
      
                    %% %%%%%%%%%%%%%%% Phase Parameters %%%%%%%%%%%%%%%%%%% 
                    if compute_phase
                        for band = bands
                            %%%%%%%%%%%%%%   Phase Extraction   %%%%%%%%%%%%%%
                            % 1. Apply bandpass filter
                            b = fir1(filter_order, [band.range(1) / (Fs/2), band.range(2) / (Fs/2)], 'bandpass');
                            filtered_data_1 = filter(b, 1, vec_1);
                            filtered_data_2 = filter(b, 1, vec_2);
                            
                            % 2. Extract the phase from the Hilbert transform
                            trim_range = 2*filter_order;
                            hilbert_phase_1 = angle(hilbert(filtered_data_1(trim_range:end-trim_range)));
                            hilbert_phase_2 = angle(hilbert(filtered_data_2(trim_range:end-trim_range)));
                            
                            % 3. Handle Phase Unwrapping (jumps of over +-pi)
                                % also called cyclic relative phase
                            phase_unwrapped_1 = unwrap(hilbert_phase_1);
                            phase_unwrapped_2 = unwrap(hilbert_phase_2);
                            
                            % 4. Save Phases
                            if Save_phase
                                if ~isfield(DataStruct.(string(patient)).(TableName).(electrode_1){row}.(band.name).phase)
                                    DataStruct.(string(patient)).(TableName).(electrode_1){row}.(band.name).phase = phase_unwrapped_1;
                                end
                                %
                                if ~isfield(DataStruct.(string(patient)).(TableName).(electrode_2){row}.(band.name).phase)
                                    DataStruct.(string(patient)).(TableName).(electrode_2){row}.(band.name).phase = phase_unwrapped_2;
                                end
                            end
                              
                            
                            %%%%%%%%%%%%%% Parameter Extraction %%%%%%%%%%%%%%%
                            
                            % 1. Phase Diff
                            phase_diff = hilbert_phase_1 - hilbert_phase_2;
                            if save_PhaseDiff
                                DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).(['Phase_diff_' band.name]){i,j} = phase_diff;
                            end
    
                            % 2. Phase locking value
                                % also called mean phase coherence / synchrony factor
                            if Compute_PLV
                                plv_value = abs(mean(exp(1i * phase_diff)));  % Absolute value of the mean of complex exponential
                                DataStruct.(cell2mat(patient)).(TableName).Bivariate_Parameters(row).(['PLV_' band.name]){i,j} = plv_value;
                            end
    
                            % % 3. 
                            % if Compute_synchronization
                            %     L = 8; % Number of bins
                            %     bins_x = linspace(0, 2*pi*m, L+1); % Bins for phase x
                            %     bins_y = linspace(0, 2*pi*n, L+1); % Bins for phase y
                            % 
                            %     % Calculate conditional probabilities
                            %     rl = zeros(1, L); % Initialize conditional probabilities
                            %     Ml = zeros(1, L); % Initialize number of points in each bin
                            % 
                            %     for l = 1:L
                            %         indices_x = find(phi_x_normalized >= bins_x(l) & phi_x_normalized < bins_x(l+1));
                            %         Ml(l) = length(indices_x);
                            %         % Calculate average phase of y where x falls into bin l
                            %         if ~isempty(indices_x)
                            %             rl(l) = mean(exp(1i * phi_y_normalized(indices_x)));
                            %         end
                            %     end
                            % 
                            %     % Compute λn,m
                            %     lambda_nm = 1/L * sum(abs(rl).^a);
                            % end
                            % % 4. normalized Phase Synchronization index
                            % if Compute_PhaseCoherence
                            % 
                            % end
                        end
                    end
                end
            end
        end
        disp(['Finished Loading Patient ' cell2mat(patient) ' - ' cell2mat(hemi) ' hemi'])
    end
end

