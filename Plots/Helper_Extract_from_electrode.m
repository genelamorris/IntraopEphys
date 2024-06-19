function [col_name, temp_table, Distances, x_location] = Helper_Extract_from_electrode(DataStruct, Patient,Hemisphere,Electrode)
% This is a helper function, it has no purpose when used alone. It is used
% to extract data about the electrodes before plotting and is used in all
% plot_XXX functions.
%% Inputs:
% DataStruct
% Patient - As the patient's struct name in the DataStruct
% Hemisphere - 'left' or 'right'
% Electrode - one on the following:
% electrodes = {'Central', 'Lateral', 'Anterior', 'Medial', 'Posterior', 'Neuroprobe_1', 'Neuroprobe_2'};

%% Outputs:
% col_name = name of the column corresponding to the electrode in the patients data table.
% temp_table = a table consisting of only the relevant column for the specified electrode.
% Distances = vector of distances indicating the length of the jump from
%             location i to location i+1 in [mm].
% x_location = the location of the electrode at any given row along the
% surgery axis, 0 indicating predicted implant location.

%% extract data from table, based on electrode:
    table_name = sprintf('table_%s_%s',Patient,Hemisphere);
    if strcmp(Electrode, 'Central') 
        col_name = sprintf('Alpha_%s',Electrode);
        temp_table = DataStruct.(Patient).(table_name).(col_name);
        Distances =  round(DataStruct.(Patient).(table_name).Movement_Distance / 0.1);
        x_location = str2double(DataStruct.(Patient).(table_name).Properties.RowNames);
    elseif any(strcmp(Electrode, {'Anterior', 'Posterior', 'Medial', 'Lateral'}))
        col_name = sprintf('Alpha_%s',Electrode);
        temp_table = DataStruct.(Patient).(table_name).(col_name);
        Distances =  round(DataStruct.(Patient).(table_name).Movement_Distance / 0.1);
        x_location = str2double(DataStruct.(Patient).(table_name).Properties.RowNames);    
        x_location = x_location + 2.75;
    elseif any(strcmp(Electrode, {'Neuroprobe_1', 'Neuroprobe_2'}))
        col_name = Electrode;
        temp_table = DataStruct.(Patient).(table_name).(col_name);
        Distances =  round(DataStruct.(Patient).(table_name).Movement_Distance / 0.1);
        x_location = str2double(DataStruct.(Patient).(table_name).Properties.RowNames);
        x_location = x_location;
    end
end


