function matched_file = helper_find_csv(Surge_date, CSV_files_path, patient)
% FIND_MATCHING_CSV Finds the CSV file in the given path that matches the Surge_date.
%   Input:
%   - Surge_date: A string representing the date in 'yyyy_m_d' format.
%   - CSV_files_path: A string representing the path to the folder containing the CSV files.
%
%   Output:
%   - matched_file: The name of the matching CSV file. If no match is found, returns an empty string.

% Parse the Surge_date
date_parts = strsplit(Surge_date, '_');
year = date_parts{1};
month = sprintf('%02d', str2double(date_parts{2})); % Ensure two-digit month
day = sprintf('%02d', str2double(date_parts{3}));   % Ensure two-digit day

% Convert to the target format: 'yyyymmdd'
target_date_str = [year, month, day];

% List all CSV files in the folder
csv_files = dir(fullfile(CSV_files_path, '*.xls'));

% Initialize matched_file as empty
matched_file = '';

% Loop through the CSV files to find a match
for i = 1:length(csv_files)
    file_name = csv_files(i).name;
    % Extract the date part from the filename
    date_str = regexp(file_name, 'STN_DBS_(\d+)\.xls', 'tokens', 'once');
    if ~isempty(date_str)
        date_str = date_str{1};
        % Compare the date part with the target date
        if strcmp(date_str, target_date_str)
            matched_file = file_name;
            fprintf('CSV file found for patient %s\n', string(patient));
            break;
        end
    end
end

% Display a message if match is found
if isempty(matched_file)
    fprintf('CSV file NOT found found for patient %s\n', string(patient));
end

end