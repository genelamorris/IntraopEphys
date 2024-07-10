% All function need one for each input:
Patients = {'EC'};
Hemispheres = {'left', 'right'};
electrode_order = {'Central', 'Lateral', 'Anterior', 'Medial', 'Posterior', 'Neuroprobe_1', 'Neuroprobe_2'};
DataStruct_B.EC.Surg_data = readtable('EC_matlab\STN_DBS_20230910_AP.csv');
set(groot, 'defaultTextInterpreter', 'none');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Univariate plots: 
%   1. Plot_Relative_Power(DataStruct,Patient,Hemisphere,Electrode, mode, Band)
modes = {'relative_RMS', 'Entropy', 'relative_Power', 'beta peak', 'Peak Frequency'};
%   ** 'Band' is needed in 'relative_Power' and 'Peak Frequency' mode
Bands = {'theta', 'alpha', 'beta', 'gamma', 'all'};
%   2. Plot_Spectrogram(DataStruct,Patient,Hemisphere,Electrode)

% 1. Relative RMS
electrodes = {'Central', 'Lateral', 'Anterior', 'Medial', 'Posterior', 'Neuroprobe_1'};
electrodes = {'Neuroprobe_1'};
side = 'right';
patient = 'Mahajna_Mahmoud';
show_xlines = false;
show_electrodes = false;

figure(1)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_values(DataStruct_A,patient,side,electrodes{i}, 'relative_RMS',[],show_xlines, show_electrodes);
end

% 2. Entropy
figure(2)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_values(DataStruct,'SV',side,electrodes{i}, 'Entropy',[],show_xlines, show_electrodes);
end

% 3. Relative Power
figure(3)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_values(DataStruct_A,patient,side,electrodes{i}, 'relative_Power','all',show_xlines, show_electrodes);
end
% ADD amplitude of peak frequency

% 4. Aperiodic Fit
figure(4)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_values(DataStruct_A,patient,side,electrodes{i}, 'Aperiodic A', [],show_xlines, show_electrodes);
end
figure(5)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_values(DataStruct_A,patient,side,electrodes{i}, 'Aperiodic C', [],show_xlines, show_electrodes);
end
figure(6)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_values(DataStruct_A,patient,side,electrodes{i}, 'Fit Error', [],show_xlines, show_electrodes);
end

figure(7)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_values(DataStruct_A,patient,'right',electrodes{i}, 'Fit Histogram', [],show_xlines, show_electrodes);
end

% 6. Spectrogram
% electrodes = {'Central', 'Lateral', 'Anterior', 'Medial', 'Posterior', 'Neuroprobe_1'};
figure(8)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_vectors(DataStruct_A,patient,side,electrodes{i}, 'Spectrogram');
end

figure(9)
show_xlines = false;
show_electrodes = false;
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_vectors(DataStruct_A,patient,side,electrodes{i}, 'PSD-fit Spectrogram',show_xlines, show_electrodes);
end

% 8. Spectral Entropy
figure(10);
for i = 1:length(electrodes)
    subplot(2, 3, i);
    Plot_Uni_vectors(DataStruct,patient,'right',electrodes{i}, 'Spectral Entropy',show_xlines, show_electrodes);
    % hold on
    % yyaxis right
    % Plot_Uni_values(DataStruct,patient,'left',electrodes{i}, 'relative_RMS',[]);
end

% 9. Spectral Kurtosis
figure(11)
show_xlines = false;
show_electrodes = false;
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Uni_vectors(DataStruct,patient,'left',electrodes{i}, 'Spectral Kurtosis',show_xlines, show_electrodes);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bivariate plots:
%   ** Here we choose two electrodes. X axis (distance) is based on the 1st electrode.
%   1. Plot_CrossCorr(DataStruct,Patient,Hemisphere,Electrode_1, Electrode_2, mode)
%      ** CrossCorr can plot several parameters, which are chosen with 'mode':
modes = {'Covariance', 'Corr_coeff'};
%   2. Plot_Coherogram(DataStruct,Patient,Hemisphere,Electrode_1, Electrode_2, mode)
%      ** coherogram can plot several parameters, which are chosen with 'mode':
modes = {'mscohere', 'CPSD', 'coherence manual', 'chronux Coherence', 'chronux Phase', 'chronux CPSD'};

main_electrode = 'Central';
electrodes = {'Lateral', 'Anterior', 'Medial', 'Posterior', 'Neuroprobe_1'};
% 1. Covariance
figure(9)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Bi_values(DataStruct_B,patient,'left',main_electrode,electrodes{i}, 'Covariance');
end

% 2. Cross Correlation
figure(10)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Bi_values(DataStruct_B,patient,'left',main_electrode,electrodes{i}, 'Correlation Coeffitient');
end

% 3. CPSD
figure(11)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Coherogram(DataStruct_B,patient,'right',main_electrode,electrodes{i},  'CPSD');
end

% 4. coherence (mscohere)
figure(12)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Coherogram(DataStruct_B,patient,'left',main_electrode,electrodes{i}, 'coherence manual');
end

% 5. coherence (chronux)
figure(13)
for i = 1:length(electrodes)
    subplot(2,3,i)
    Plot_Coherogram(DataStruct_B,patient,'left',main_electrode,electrodes{i}, 'chronux Coherence');
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Electrodes correlations

figure(1)
modes = {'time_vec','relative_RMS','Spectral_entropy','PSD_fit', 'beta', 'gamma'};
for i = 1:length(modes)
    subplot(2,3,i)
    Plot_Electrode_Correlation(DataStruct_A, patient, 'right', modes{i})
end
