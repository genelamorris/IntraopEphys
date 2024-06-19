function Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode_1, Electrode_2)
% This is a helper function, it has no purpose when used alone. It is used
% to plot xlines on entries and exit from STN as assumed during the surgery
% (based on provided csv file)
% and is used in all plot_XXX functions.

% Extract Surgery data csv
Surg_data = DataStruct.(string(Patient)).Surg_data;

%% Electrode 1
try
    E1_row = DataStruct.(string(Patient)).trajectories.(lower(Hemisphere)).(['Alpha_' Electrode_1 '_RowIndx']);
    
catch
    E1_row = DataStruct.(string(Patient)).trajectories.(lower(Hemisphere)).([Electrode_1 '_RowIndx']);
end

if strcmpi(Electrode_1, 'Central') || contains(Electrode_1, 'Neuro')
    x1 = xline(Surg_data.STNDLOREntry(E1_row), '-', {[Electrode_1 ' In']}, 'Color', 'k', 'LineWidth', 2, 'FontWeight', 'bold');
    x2 = xline(Surg_data.STNExit(E1_row), '-', {[Electrode_1 ' Out']}, 'Color', 'k', 'LineWidth', 2, 'FontWeight', 'bold');

elseif any(strcmp(Electrode_1, {'Anterior', 'Posterior', 'Medial', 'Lateral'}))
    x1 = xline(Surg_data.STNDLOREntry(E1_row)+2.75, '-', {[Electrode_1 ' In']}, 'Color', 'k', 'LineWidth', 2, 'FontWeight', 'bold');
    x2 = xline(Surg_data.STNExit(E1_row)+2.75, '-', {[Electrode_1 ' Out']}, 'Color', 'k', 'LineWidth', 2, 'FontWeight', 'bold');
end

%% Electrode 2

if nargin == 5
    try
        E2_row = DataStruct.(string(Patient)).trajectories.(lower(Hemisphere)).(['Alpha_' Electrode_2 '_RowIndx']);

    catch
        E2_row = DataStruct.(string(Patient)).trajectories.(lower(Hemisphere)).([Electrode_2 '_RowIndx']);
    end

    if strcmpi(Electrode_2, 'Central')  || contains(Electrode_2, 'Neuro')
        x3 = xline(Surg_data.STNDLOREntry(E2_row), '-', {[Electrode_2 ' In']}, 'Color', '#7E2F8E', 'LineWidth', 2, 'FontWeight', 'bold');
        x4 = xline(Surg_data.STNExit(E2_row), '-', {[Electrode_2 ' Out']}, 'Color', '#7E2F8E', 'LineWidth', 2, 'FontWeight', 'bold');
    
    elseif any(strcmp(Electrode_2, {'Anterior', 'Posterior', 'Medial', 'Lateral'}))
        x3 = xline(Surg_data.STNDLOREntry(E2_row)+2.75, '-', {[Electrode_2 ' In']}, 'Color', '#7E2F8E', 'LineWidth', 2, 'FontWeight', 'bold');
        x4 = xline(Surg_data.STNExit(E2_row)+2.75, '-', {[Electrode_2 ' Out']}, 'Color', '#7E2F8E', 'LineWidth', 2, 'FontWeight', 'bold');
    end
end

