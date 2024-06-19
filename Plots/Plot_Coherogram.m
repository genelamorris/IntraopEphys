function MSC_matrix_rep = Plot_Coherogram(DataStruct,Patient,Hemisphere,Electrode_1, Electrode_2, mode)

%% Initial params
Fs = 44000;
table_name = sprintf('table_%s_%s',Patient,Hemisphere);
[col_name_1, temp_table_1, Distances, x_location] = Helper_Extract_from_electrode(DataStruct, Patient,Hemisphere, Electrode_1);
[col_name_2, temp_table_2,~,~] = Helper_Extract_from_electrode(DataStruct, Patient,Hemisphere, Electrode_2);
stored_name_CPSD = ['CPSD_' col_name_1 '_' col_name_2];
titleText = sprintf('%s - %s - %s Vs. %s', Patient, Hemisphere, Electrode_1, Electrode_2);

%% electrode indexes
electrode_order = {'Central', 'Lateral', 'Anterior', 'Medial', 'Posterior', 'Neuroprobe_1', 'Neuroprobe_2'};
% Find the index for Electrode_1
idx_1 = find(strcmp(electrode_order, Electrode_1));
if isempty(idx_1)
    error(['Unknown electrode: ' Electrode_1]);
end
% Find the index for Electrode_2
idx_2 = find(strcmp(electrode_order, Electrode_2));
if isempty(idx_2)
    error(['Unknown electrode: ' Electrode_2]);
end
    
%% Coherence Matrix
MSC_matrix = [];
for row = 1:size(temp_table_1,1)
    if strcmp(mode, 'mscohere')
        Coherence = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Coherence{idx_1,idx_2};
        if isempty(Coherence)
                Coherence = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Coherence{idx_2,idx_1};
        end
        f_vec = Coherence(2,:);

        MSC_matrix = [MSC_matrix; normalize(Coherence(1,:))];
    end
    
    if strcmp(mode, 'CPSD')
        CPSD = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Cross_PSD{idx_1,idx_2};
        if isempty(CPSD)
            CPSD = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Cross_PSD{idx_2,idx_1};
        end
        f_vec = round(logspace(log10(3),log10(198),585),2);
        CPSD_log = 10*log10(CPSD);
        norm_log_CPSD = normalize(real(CPSD));   %%%% assume normal destribution of power

        MSC_matrix = [MSC_matrix; norm_log_CPSD];
    end
    
    if strcmp(mode, 'coherence manual') %%%%%%% NOT FINISHED
        PSD1 = DataStruct.EC.(['table_EC_' Hemisphere]).(col_name_1){row}.PSD_vec;
        PSD2 = DataStruct.EC.(['table_EC_' Hemisphere]).(col_name_2){row}.PSD_vec;
        CPSD = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Cross_PSD{idx_1,idx_2};
        if isempty(CPSD)
            CPSD = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).CPSD{idx_2,idx_1};
        end
        f_vec = round(logspace(log10(3),log10(198),585),2);
        %
        MSC = (abs(CPSD).^2)./(PSD1.*PSD2);
        MSC_log = 10*log10(MSC);
        norm_log_CPSD = normalize(real(MSC_log));   %%%% assume normal destribution of power
        MSC_matrix = [MSC_matrix; norm_log_CPSD];
    end

    if strcmp(mode, 'chronux Coherence')
        Chronux = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Chronux{idx_1,idx_2};
        if isempty(Chronux)
                Chronux = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Chronux{idx_2,idx_1};
        end
        if length(Chronux{6}) > length(MSC_matrix) && row > 1
            [~, indx_to_choose] = ismember(Chronux{6}, f_vec);
            shorter_vec = Chronux{1};
            shorter_vec = shorter_vec(indx_to_choose>0);
            f_vec = Chronux{6}(indx_to_choose>0);
            MSC_matrix = [MSC_matrix; shorter_vec'];
        elseif length(Chronux{6}) < length(MSC_matrix) && row > 1
            Distances = [Distances(1:row-1); Distances(row+1:end)];
            continue
        else
            f_vec = Chronux{6};
            MSC_matrix = [MSC_matrix; Chronux{1}'];
        end
    end
    
    if strcmp(mode, 'chronux Phase')
        Chronux = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Chronux{idx_1,idx_2};
        if isempty(Chronux)
                Chronux = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Chronux{idx_2,idx_1};
        end
        f_vec = Chronux{6};
        MSC_matrix = [MSC_matrix; Chronux{2}'];
    end

        if strcmp(mode, 'chronux CPSD')
        Chronux = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Chronux{idx_1,idx_2};
        if isempty(Chronux)
                Chronux = DataStruct.(Patient).(table_name).Bivariate_Parameters(row).Chronux{idx_2,idx_1};
        end
        f_vec = Chronux{6};
        MSC_matrix = [MSC_matrix; Chronux{3}'];
        end
    
end
MSC_matrix = MSC_matrix';


%% adjust for repeating locations
x_location_rep = x_location(1);
MSC_matrix_rep = MSC_matrix(:,1)';
for i = 2:length(Distances)
    x_location_rep = [x_location_rep repelem(x_location(i), Distances(i))];
    MSC_matrix_rep = [MSC_matrix_rep; repmat(MSC_matrix(:,i)', [Distances(i) 1])];
end
MSC_matrix_rep = MSC_matrix_rep';


%% OPTIONAL: limit of frequency:
try
    max_frq = 60;
    [~,max_indx] = min(abs(f_vec - max_frq));
    f_vec_lim = f_vec(1:max_indx+1);
    MSC_matrix_rep_lim = MSC_matrix_rep(1:max_indx+1,:);
catch
    f_vec_lim = f_vec;
    MSC_matrix_rep_lim = MSC_matrix_rep;
end
%% Plot
h = pcolor(x_location_rep, f_vec_lim,real(MSC_matrix_rep_lim));
Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode_1, Electrode_2)
shading flat; % to remove grid lines
set(h, 'FaceColor', 'interp'); % converts discrete plot into continuous with interpolation
set(gca, 'XDir', 'reverse')
set(gca, 'YScale', 'log')
set(gcf,'color', 'w')
box off

title([mode ' of '  titleText])
xlabel(['Distance of ' Electrode_1 ' from estimated location [mm]'])
ylabel('Spectral Coherence')
% y log scale labels:
selected_y_ticks = round(logspace(log10(f_vec(1)),log10(f_vec(end)), 15),2);
set(gca, 'FontSize', 12)
yticks(selected_y_ticks);
yticklabels(cellstr(num2str(selected_y_ticks')));
colormap('jet')
colorbar

% cmap limits:
caxis([-3 3])
if strcmp(mode, 'chronux Coherence')
    caxis([0 1])
elseif strcmp(mode, 'mscohere') || strcmp(mode, 'CPSD')
    caxis([-3 3])
end


end