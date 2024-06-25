function DataStruct = Extract_Univariate(DataStruct)
Compute_RMS = true; % Note that this is used twice - for Base RMS and Relative RMS.
Compute_Entropy = true;
Compute_SpectralEntropy = true;
Compute_SpectralKurtosis = true;
Compute_PSD = true;
compute_PSDfit = true;
Compute_Bands = true;

% This function:
%   - Operates on each patient's data stored in the structure 'DataStruct'
%   - Compute and save Base RMS for each electrode (each column)
%   - Computes several univariate parameters for each data vector, including:
%       - Relative RMS power
%           1. Normalize the data vector by subtracting its mean and dividing by the base RMS
%       - Entropy
%           1. Compute the probability distribution of the data vector
%           2. Calculate the Shannon entropy based on the probability distribution
%       - Spectral entropy - using the pentropy function
%       - Spectral kurtosis - using the pkurtosis function
%       - Autocorrelation
%           1. Compute autocorrelation using the autocorr function
%   - Power spectral density (PSD) 
%       1. Rectify the data vector by taking the absolute values
%       2. Subtract the mean from the rectified vector
%       3. Compute the power spectral density using Welch's method with the
%       following parameters:
Fs = 44000;
window_size = 1*Fs;  % 1 s Hamming window
overlap = window_size/2;  % 50% overlap
freq_range = round(linspace(3,60,585),2);
%       4. Clean 50Hz line noise and its harmonics from the PSD
%   - Computes relative power, maximum frequency, and second-highest frequency
%       1. Compute relative power by integrating the PSD within the frequency band range
%       2. Compute maximum frequency by finding the peak frequency within the band range
%       3. Compute second-highest frequency by finding the second peak frequency within the band range


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initiation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%
bands = struct('name', {'theta', 'alpha', 'beta', 'gamma'},...
    'range', {[4, 8], [8, 13], [13, 30], [30, 60]});

for patient = DataStruct.params.patients
    for hemi = DataStruct.params.hemispheres
        TableName = sprintf('table_%s_%s', cell2mat(patient), cell2mat(hemi));
        % this is the table - DataStruct.(string(patient)).(TableName);
        for col = 1:7
            disp([cell2mat(hemi) ' hemisphere: Updating column ' num2str(col) '/7'])
            col_name = string(DataStruct.(string(patient)).(TableName).Properties.VariableNames(col));
            %% %%%%%%%% Find Base RMS %%%%%%%%%%%%%%
            if Compute_RMS
                % 1. find the first and last row index in which the movement distance is 0.1:
                start_index = find(DataStruct.(string(patient)).(TableName).Movement_Distance == 0.1, 1, 'first');
                end_index = start_index+1;
                while DataStruct.(string(patient)).(TableName).Movement_Distance(end_index + 1) == 0.1
                    end_index = end_index+1;
                end
                % 2. Find RMS of the rows between start_index and end_index
                col_RMS_Vec = [];
                for row = start_index:end_index
                    % 2.1 find correct vector to work with
                    if ~isfield(DataStruct.(string(patient)).(TableName).(col_name){row}, 'data_vector_01_spk')
                        % no point in extracting the data if there is no vector.
                        disp(['No data found in row ' num2str(row)])
                        continue
                    end
                    
                    % 2.2 choose correct vector by length
                    data_vec = DataStruct.(string(patient)).(TableName).(col_name){row}.data_vector_01_spk;
                    i_vec = 2;
                    while length(data_vec) < Fs && i_vec < 5
                        vector_name = ['data_vector_0' num2str(i_vec) '_spk'];
                        try
                            data_vec = DataStruct.(string(patient)).(TableName).(col_name){row}.(vector_name);
                        catch
                            data_vec = DataStruct.(string(patient)).(TableName).(col_name){row}.data_vector_01_spk;
                        end
                        i_vec = i_vec+1;
                    end
                    data_vec = single(data_vec);
                    
                    % 2.3 take RMS of chosen vector
                    col_RMS_Vec(end+1) = rms(data_vec);
                end
                
                % 3. Calculate and Save Base RMS
                Base_rms = mean(col_RMS_Vec);
                rms_hemi = sprintf('BASE_RMS_%s', string(hemi));
                DataStruct.(string(patient)).(rms_hemi).(col_name) = Base_rms;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for row = 1:size(DataStruct.(string(patient)).(TableName),1)
                % loop is working coulmn-wise - updating all rows of a
                % column before moving to the next.
                
                %% %%%%%%%% find correct vector to work with %%%%%%%%%%%%%%
                % 1. check for data vector
                if ~isfield(DataStruct.(string(patient)).(TableName).(col_name){row}, 'data_vector_01_spk')
                    % no point in extracting the data if there is no vector.
                    disp(['No data found in row ' num2str(row)])
                    continue
                end
                
                %2. choose correct vector by length
                % some vectors are too short, because sometimes there are
                % multiple files in the same location, and only the
                % last one contains the real, long recording.
                data_vec = DataStruct.(string(patient)).(TableName).(col_name){row}.data_vector_01_spk;
                i_vec = 2;
                while length(data_vec) < Fs
                    vector_name = ['data_vector_0' num2str(i_vec) '_spk'];
                    try
                        data_vec = DataStruct.(string(patient)).(TableName).(col_name){row}.(vector_name);
                    catch
                        data_vec = DataStruct.(string(patient)).(TableName).(col_name){row}.data_vector_01_spk;
                    end
                    i_vec = i_vec+1;
                end
                data_vec = single(data_vec);
                
                
                %% %%%%%%%%%%%% Save Univariate Parameters %%%%%%%%%%%%%%%%
                % 1. Relative RMS Power
                if Compute_RMS
                    DataStruct.(string(patient)).(TableName).(col_name){row}.relative_RMS = ...
                        rms(data_vec - mean(data_vec))/Base_rms;
                end
                
                % 2. Entropy
                if Compute_Entropy
                    count = histcounts(data_vec, unique(data_vec));
                    probabilities = count / sum(count);
                    probabilities(probabilities == 0) = [];
                    Shannon_Entropy = -sum(probabilities .* log2(probabilities));
                    DataStruct.(string(patient)).(TableName).(col_name){row}.Shannon_Entropy = Shannon_Entropy;
                end
                
                % 3. Spectral Entropy
                if Compute_SpectralEntropy
                    DataStruct.(string(patient)).(TableName).(col_name){row}.Spectral_entropy = ...
                        pentropy(data_vec, Fs,Instantaneous=true);
                end
                
                % 4. Spectral Kurtosis
                if Compute_SpectralKurtosis
                    [SK, f_SK] = pkurtosis(single(abs(downsample(data_vec,88))),Fs/88);
                    DataStruct.(string(patient)).(TableName).(col_name){row}.Spectral_Kurtosis = ...
                        [SK' ; f_SK'];
                end
                
                %% %%%%%%%%%%%%%%%%%%%%% Save PSD %%%%%%%%%%%%%%%%%%%%%%%%%
                if Compute_PSD
                    %  1. rectification (abs)
                    rectified_vector = abs(data_vec);
                    %  2. mean substruction
                    rectified_vector = rectified_vector - mean(rectified_vector);
                    % 3. Calculate the power spectral density using Welch's method
                    [pxx, f_PSD] = pwelch(single(rectified_vector), window_size, overlap, freq_range, Fs);
                    % 4. Cleaning 50Hz line noise and its harmonics
                    indices_to_remove = [];
                    for harmonic = 1:4
                        indices_to_remove = [indices_to_remove, find(f_PSD >= (50*harmonic)-2 & f_PSD <= (50*harmonic)+2)];
                    end
                    indices_to_remove = unique(indices_to_remove);
                    % Interpolation for cleaning
                    pxx_cleaned = interp1(f_PSD(~ismember(1:length(f_PSD), indices_to_remove)), ...
                        pxx(~ismember(1:length(f_PSD), indices_to_remove)), ...
                        f_PSD);
                    %5. Save PSD vector and frequency axis vector
                    DataStruct.(string(patient)).(TableName).(col_name){row}.PSD_vec = pxx_cleaned;
                    DataStruct.(string(patient)).(TableName).(col_name){row}.f_PSD = f_PSD;
                

                    if compute_PSDfit
                        [final_fit, aperiodic_A, aperiodic_C, Peak_freq, Peak_bw, peak_height, rms_error] = PSD_Fit(pxx_cleaned, f_PSD, 2.5, 1, false);
                        DataStruct.(string(patient)).(TableName).(col_name){row}.PSD_fit.Final_fit = final_fit;
                        DataStruct.(string(patient)).(TableName).(col_name){row}.PSD_fit.aperiodic_A = aperiodic_A;
                        DataStruct.(string(patient)).(TableName).(col_name){row}.PSD_fit.aperiodic_C = aperiodic_C;
                        DataStruct.(string(patient)).(TableName).(col_name){row}.PSD_fit.gauss_Peak_freq = Peak_freq;
                        DataStruct.(string(patient)).(TableName).(col_name){row}.PSD_fit.gauss_Peak_bw = Peak_bw;
                        DataStruct.(string(patient)).(TableName).(col_name){row}.PSD_fit.gauss_peak_height = peak_height;
                        DataStruct.(string(patient)).(TableName).(col_name){row}.PSD_fit.fit_error = rms_error;
                    end
                            
                end
                
                
                %% %%%%%%%%%%%% Extract Band Information %%%%%%%%%%%%%%%%%%
                if Compute_Bands
                    for band = bands
                        % 1. Compute relative power
                        f_range = band.range;
                        pxx_band = pxx_cleaned(f_PSD > f_range(1) & f_PSD < f_range(2));
                        relative_power = trapz(pxx_band)/trapz(pxx_cleaned);
                        DataStruct.(string(patient)).(TableName).(col_name){row}.(band.name).relative_Power = relative_power;
                        
                        % 2. Compute maximum band frequency
                        [~, max_indx] = max(pxx_band);
                        freq_band = f_PSD(f_PSD > f_range(1) & f_PSD < f_range(2));
                        max_freq_band = freq_band(max_indx);
                        DataStruct.(string(patient)).(TableName).(col_name){row}.(band.name).max_freq = max_freq_band;
                        DataStruct.(string(patient)).(TableName).(col_name){row}.(band.name).max_freq_amp = pxx_cleaned(max_indx);

                        % 3. Compute second highest band frequency
                        f_without_max = freq_band([1:max_indx-1, max_indx+1:end]);
                        pxx_without_max = pxx_band([1:max_indx-1, max_indx+1:end]);
                        [~, second_highest_indx] = max(pxx_without_max);
                        second_highest_band_freq = f_without_max(second_highest_indx);
                        DataStruct.(string(patient)).(TableName).(col_name){row}.(band.name).second_highest_freq = second_highest_band_freq;
                    end
                end
            end
        end
    end
    disp(['Finished Loading Patient ' cell2mat(patient)])
end
end

