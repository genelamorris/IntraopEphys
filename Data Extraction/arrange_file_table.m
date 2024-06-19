function files_data = arrange_file_table(folder_path)

files = dir(fullfile(folder_path, '*.*')); % List the files in the folder
fileNames = {files(~[files.isdir]).name}'; % Extract file names
% side
file_side = cellfun(@(str) str(1:2), fileNames, 'UniformOutput', false);
% trajectory
file_trajectory = cellfun(@(str) str(3), fileNames, 'UniformOutput', false);
% distance
file_distance = cellfun(@(str) strsplit(str, {'d','+','f', '_'}), fileNames, 'UniformOutput', false);
file_distance = cellfun(@(cell) cell(2), file_distance, 'UniformOutput', false);
file_distance = cellfun(@(str) str2double(str), file_distance, 'UniformOutput', false);
% movement
movement_type = cellfun(@(str) regexprep(str(9:13), '\d', ''), fileNames, 'UniformOutput', false);
% file number
file_num = cellfun(@(str) str(end-4), fileNames, 'UniformOutput', false);


fileTable = table(file_side,file_trajectory, file_distance,movement_type,file_num, fileNames, 'VariableNames', {'Side','trajectory', 'distance','movement_type','file_number', 'full_filename'}); % Create a table with file names
fileTable = sortrows(fileTable, 'distance', 'descend');
% step size
fileTable.previous_step_size = [0;abs(diff(cell2mat(file_distance)))];

files_data.all_data = fileTable;
files_data.left = fileTable(strcmpi(fileTable.Side,'lt') & strcmpi(fileTable.movement_type,'f'),:);
files_data.left = sortrows(files_data.left, 'distance', 'descend');
files_data.left.previous_step_size = [0; round(abs(diff(cell2mat(files_data.left.distance))), 2)];
%
files_data.right = fileTable(strcmpi(fileTable.Side,'rt') & strcmpi(fileTable.movement_type,'f'),:);
files_data.right = sortrows(files_data.right, 'distance', 'descend');
files_data.right.previous_step_size = [0; round(abs(diff(cell2mat(files_data.right.distance))), 2)];

end