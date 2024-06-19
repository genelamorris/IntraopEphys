function PSD_matrix_rep = Plot_Uni_vectors(DataStruct,Patient,Hemisphere,Electrode, mode)

%% Initial params
table_name = sprintf('table_%s_%s',Patient,lower(Hemisphere));
titleText = sprintf('%s - %s - %s', Patient, Hemisphere, Electrode);
% extract data from table, based on electrode:
[col_name, temp_table, Distances, x_location] = Helper_Extract_from_electrode(DataStruct, Patient,Hemisphere, Electrode);


%% Create the Matrix
PSD_matrix = [];
for i = 1:size(temp_table,1) 
    if strcmpi(mode, 'Spectrogram')
        PSD = temp_table{i}.PSD_vec;
        if exist('f_PSD', 'var') == 0
            f_PSD = temp_table{i}.f_PSD;
        end
        PSD_log = 10*log10(PSD);
        norm_log_PSD = normalize(real(PSD_log));   %%%% assume normal destribution of power
        PSD_matrix = [PSD_matrix; norm_log_PSD];

    elseif strcmpi(mode, 'PSD-fit Spectrogram')
        PSD_fit = temp_table{i}.PSD_fit.Final_fit;
        if exist('f_PSD', 'var') == 0
            f_PSD = temp_table{i}.f_PSD;
        end
        PSD_log = 10*log10(PSD_fit);
        norm_log_PSD = normalize(real(PSD_log));   %%%% assume normal destribution of power
        PSD_matrix = [PSD_matrix; norm_log_PSD];

    elseif strcmpi(mode, 'Spectral Entropy')
        SE = temp_table{i}.Spectral_entropy;
        if i == 1
            PSD_matrix = [PSD_matrix ; SE'];
        else
            L = min([length(PSD_matrix) length(SE)]);
            PSD_matrix = [PSD_matrix(:,1:L); SE(1:L)'];
        end
    

    elseif strcmpi(mode, 'Spectral Kurtosis')
        SK = temp_table{i}.Spectral_entropy;
        SK_log = 10*log10(SK);
        norm_log_SK = normalize(SK_log);   %%%% assume normal destribution of power
        if exist('f_PSD', 'var') == 0
            f_PSD = temp_table{i}.Spectral_Kurtosis(2,:);
        end
        if i == 1
            PSD_matrix = [PSD_matrix ; norm_log_SK'];
        else
            L = min([length(PSD_matrix) length(norm_log_SK)]);
            PSD_matrix = [PSD_matrix(:,1:L); norm_log_SK(1:L)'];
            f_PSD = f_PSD(1:L);
        end
    end
end
PSD_matrix = PSD_matrix';


%% adjust for repeating locations (Jumps longer then 0.1mm):
x_location_rep = x_location(1);
PSD_matrix_rep = PSD_matrix(:,1)';
for i = 2:length(Distances)
    x_location_rep = [x_location_rep repelem(x_location(i), Distances(i))];
    PSD_matrix_rep = [PSD_matrix_rep; repmat(PSD_matrix(:,i)', [Distances(i) 1])];
end
PSD_matrix_rep = PSD_matrix_rep';

%% plot
if strcmpi(mode, 'Spectral Entropy')
    shadedErrorBar(x_location', PSD_matrix,{@mean,@std},'lineprops',{'-ko','MarkerFaceColor','g'});
    hold on
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)
    box off
    title([mode ' of ' titleText])
    set(gcf, 'Color','w')
    set(gca, 'XDir', 'reverse')
    set(groot, 'defaultTextInterpreter', 'none');
    set(gca, 'FontSize', 12)

    return
end

% if mode = 'Spectrogram' or 'Spectral Kurtosis':
n_points_x = 30;
n_points_y = 15;

% OPTIONAL: limit of frequency:
if strcmpi(mode, 'Spectral Kurtosis')
    max_frq = 60;
    [~,max_indx] = min(abs(f_PSD - max_frq));
    f_PSD_lim = f_PSD(2:max_indx+1);
    PSD_matrix_rep_lim = PSD_matrix_rep(2:max_indx+1,:);
else
    f_PSD_lim = f_PSD;
    PSD_matrix_rep_lim = PSD_matrix_rep;
end

h = pcolor(x_location_rep, f_PSD_lim,PSD_matrix_rep_lim);
Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)

shading flat; % to remove grid lines
set(h, 'FaceColor', 'interp'); % converts discrete plot into continuous with interpolation
set(gca, 'XDir', 'reverse')
set(gca, 'YScale', 'log')
set(gcf,'color', 'w')
set(gca, 'FontSize', 12)

title([mode ' of ' titleText])
xlabel('Distance [cm]')
ylabel('Frequency [Hz]')


% y log scale labels:
selected_y_ticks = round(logspace(log10(f_PSD_lim(1)),log10(f_PSD_lim(end)), n_points_y),2);
yticks(selected_y_ticks);
yticklabels(cellstr(num2str(selected_y_ticks')));

box off
colormap('jet')
colorbar

caxis([-3 3])

end