function files_data = arrange_file_table(folder_path)
% ARRANGE_FILE_TABLE Arranges and organizes file data from a given folder.
%   This function lists all the files in the specified folder, extracts
%   relevant metadata from the filenames, and organizes the data into
%   structured tables.
%
%   Input:
%   - folder_path: A string specifying the path to the folder containing the files.
%
%   Output:
%   - files_data: A structure containing organized file data. The structure has the following fields:
%     - all_data: A table with all files and their metadata.
%     - left: A table with files from the left side, filtered and sorted.
%     - right: A table with files from the right side, filtered and sorted.

% List the files in the folder
files = dir(fullfile(folder_path, '*.*')); 
fileNames = {files(~[files.isdir]).name}'; % Extract file names

% Extract file metadata from the file names
file_side = cellfun(@(str) str(1:2), fileNames, 'UniformOutput', false); % side
file_trajectory = cellfun(@(str) str(3), fileNames, 'UniformOutput', false); % trajectory
file_distance = cellfun(@(str) strsplit(str, {'d','+','f', '_'}), fileNames, 'UniformOutput', false);
file_distance = cellfun(@(cell) cell(2), file_distance, 'UniformOutput', false);
file_distance = cellfun(@(str) str2double(str), file_distance, 'UniformOutput', false); % distance
movement_type = cellfun(@(str) regexprep(str(9:13), '\d', ''), fileNames, 'UniformOutput', false); % movement
file_num = cellfun(@(str) str(end-4), fileNames, 'UniformOutput', false); % file number

% Create a table with file names and metadata
fileTable = table(file_side, file_trajectory, file_distance, movement_type, file_num, fileNames, ...
    'VariableNames', {'Side', 'trajectory', 'distance', 'movement_type', 'file_number', 'full_filename'});
fileTable = sortrows(fileTable, 'distance', 'descend'); % Sort by distance

% Calculate previous step size
fileTable.previous_step_size = [0; abs(diff(cell2mat(file_distance)))];

% Store all data in the structure
files_data.all_data = fileTable;

% Filter and sort data for the left side
files_data.left = fileTable(strcmpi(fileTable.Side, 'lt') & strcmpi(fileTable.movement_type, 'f'), :);
files_data.left = sortrows(files_data.left, 'distance', 'descend');
files_data.left.previous_step_size = [0; round(abs(diff(cell2mat(files_data.left.distance))), 2)];

% Filter and sort data for the right side
files_data.right = fileTable(strcmpi(fileTable.Side, 'rt') & strcmpi(fileTable.movement_type, 'f'), :);
files_data.right = sortrows(files_data.right, 'distance', 'descend');
files_data.right.previous_step_size = [0; round(abs(diff(cell2mat(files_data.right.distance))), 2)];

end
