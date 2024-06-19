function SE_matrix_rep = Plot_Spec_entropy(DataStruct,Patient,Hemisphere,Electrode, mode, ax)

%% Initial params
table_name = sprintf('table_%s_%s',Patient,lower(Hemisphere));
titleText = sprintf('%s - %s - %s', Patient, Hemisphere, Electrode);
% extract data from table, based on electrode:
[col_name, temp_table, Distances, x_location] = Helper_Extract_from_electrode(DataStruct, Patient,Hemisphere, Electrode);
f_PSD = round(linspace(3,60,585),2);


%% Coherence Matrix
SE_matrix = [];
for i = 1:size(temp_table,1) 

    if strcmp(mode, 'Spectral Entropy')
        SE = temp_table{i}.Spectral_entropy;
        % pxx_norm =  pxx_cleaned/trapz(pxx_cleaned);
        SE_matrix = [SE_matrix; SE'];
    end

    if strcmp(mode, 'Spectral Kurtosis')
        SK = temp_table{i}.Spectral_Kurtosis;
        % pxx_norm =  pxx_cleaned/trapz(pxx_cleaned);
        SE_matrix = [SE_matrix; SK'];
    end
    
end
SE_matrix = SE_matrix';


%% adjust for repeating locations (Jumps longer then 0.1mm):
x_location_rep = x_location(1);
SE_matrix_rep = SE_matrix(:,1)';
for i = 2:length(Distances)
    x_location_rep = [x_location_rep repelem(x_location(i), Distances(i))];
    SE_matrix_rep = [SE_matrix_rep; repmat(SE_matrix(:,i)', [Distances(i) 1])];
end
SE_matrix_rep = SE_matrix_rep';


%% plot
% cmap = colormap(jet(size(SE_matrix_rep, 2)));
% for i = 1:size(SE_matrix_rep, 2)
%     vector_data = SE_matrix_rep(:, i);
%     plot(vector_data, 'Color', cmap(i, :));
%     hold on;
% end
% %Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)
% 
% set(gcf,'color', 'w')
% set(gca, 'FontSize', 12)
% 
% title([mode ' of ' titleText])
% xlabel('Time bins in same position')
% ylabel(mode)
% 
% box off
% cb = colorbar;  
% colormap('jet');
% cb.Label.String = 'Vector Order';
% 

%% Live plot
num_vectors = size(SE_matrix_rep, 2);
cmap = colormap(jet(size(SE_matrix_rep, 2)));

for vec_idx = 1:num_vectors
    % Plot the current vector
    plot(ax, SE_matrix_rep(:, vec_idx), 'Color', cmap(vec_idx,:));  % Gray color

    % Customize plot appearance
    set(ax, 'FontSize', 12);
    xlim(ax, [1 size(SE_matrix_rep, 1)]);
    ylim(ax, [min(SE_matrix_rep(:)) max(SE_matrix_rep(:))]);  % Adjust ylim as needed

    % Update subplot title to show current vector index
    title(ax, [mode ' of ' titleText]);
    xlabel(ax, 'Time bins');
    ylabel(ax, 'Spectral Entropy');
    box(ax, 'off');
    colorbar;  

    % Refresh the plot display
    drawnow;

    % Pause to control animation speed
    pause(0.1);  % Adjust as needed
end

% Clear the current subplot for the next iteration
cla(ax);

end