function relative_power_vector = Plot_Uni_values(DataStruct,Patient,Hemisphere,Electrode, mode, Band, show_xline, show_electrodes)

table_name = sprintf('table_%s_%s',Patient,lower(Hemisphere));
titleText = sprintf('%s - %s - %s', Patient, Hemisphere, Electrode);
% extract data from table, based on electrode:
[col_name, temp_table, Distances, x_location] = Helper_Extract_from_electrode(DataStruct, Patient,Hemisphere, Electrode);
set(groot, 'defaultTextInterpreter', 'none');


%% %%%%%%%%%%%%%%%%%%%%%%% relative RMS %%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(mode, 'relative_RMS')
    relative_RMS = [];
    for i = 1:size(temp_table,1)
        relative_RMS = [relative_RMS temp_table{i}.(mode)];
    end
   
    % plot
    plot(x_location, relative_RMS, 'LineWidth', 2)
    % Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)
    ylabel('Relative RMS [\muV]')
    xlabel('X Depth (Corrected) [mm]')
    title({titleText, 'Relative RMS along the surgery direction'})

    % adjust ylim
    [~, locs] = findpeaks(relative_RMS, 'MinPeakHeight', 10);
    relative_RMS_without_peaks = relative_RMS;
    relative_RMS_without_peaks(locs) = [];
    ylim([0 max(relative_RMS_without_peaks)+0.5]);

    set(gca, 'FontSize', 12)
    set(gca, 'Xdir', 'reverse') 
    set(gcf,'color', 'w')
    box off


end

%% %%%%%%%%%%%%%%%%%%%%%%% Aperiodic Fit Parameters %%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(mode, 'Aperiodic A')
    aperiodic_A = [];
    for i = 1:size(temp_table,1)
        aperiodic_A = [aperiodic_A temp_table{i}.PSD_fit.aperiodic_A];
    end
    % plot
    plot(x_location, aperiodic_A, 'LineWidth', 2)
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)    
    ylabel('Aperiodic Exponent [AU]')
    xlabel('X Depth (Corrected) [mm]')
    title({titleText, 'A_Aperiodic Fit along the surgery direction'})
    set(gca, 'FontSize', 12)
    set(gca, 'Xdir', 'reverse') 
    set(gcf,'color', 'w')
    box off

end

if strcmpi(mode, 'Aperiodic C')
    aperiodic_C = [];
    for i = 1:size(temp_table,1)
        aperiodic_C = [aperiodic_C temp_table{i}.PSD_fit.aperiodic_C];
    end
    % plot
    plot(x_location, aperiodic_C, 'LineWidth', 2)
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)    
    ylabel('Aperiodic Offset [AU]')
    xlabel('X Depth (Corrected) [mm]')
    title({titleText, 'C_Aperiodic Fit along the surgery direction'})
    ylim([0 1])
    % % adjust ylim
    % [~, locs] = findpeaks(aperiodic_C, 'MinPeakHeight', 10);
    % aperiodic_C_without_peaks = aperiodic_C;
    % aperiodic_C_without_peaks(locs) = [];
    % ylim([0 max(aperiodic_C_without_peaks)+0.2]);
    
    set(gca, 'FontSize', 12)
    set(gca, 'Xdir', 'reverse') 
    set(gcf,'color', 'w')
    box off
end

if strcmpi(mode, 'Fit Error')
    fit_error = [];
    for i = 1:size(temp_table,1)
        fit_error = [fit_error temp_table{i}.PSD_fit.fit_error];
    end
    % plot
    plot(x_location, fit_error, 'LineWidth', 2)
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)    
    ylabel('Fit Error (RMS)')
    xlabel('X Depth (Corrected) [mm]')
    title({titleText, 'Fit Error (RMS) along the surgery direction'})
    ylim([0 1])
    % % adjust ylim
    % [~, locs] = findpeaks(aperiodic_C, 'MinPeakHeight', 10);
    % aperiodic_C_without_peaks = aperiodic_C;
    % aperiodic_C_without_peaks(locs) = [];
    % ylim([0 max(aperiodic_C_without_peaks)+0.2]);
    
    set(gca, 'FontSize', 12)
    set(gca, 'Xdir', 'reverse') 
    set(gcf,'color', 'w')
    box off
end

if strcmpi(mode, 'Fit Histogram')
    Peak_freq = {};
    Peak_bw = {};
    peak_height = {};
    for i = 1:size(temp_table,1)
        Peak_freq{i} = temp_table{i}.PSD_fit.gauss_Peak_freq;
        Peak_bw{i} = temp_table{i}.PSD_fit.gauss_Peak_bw;
        peak_height{i} = temp_table{i}.PSD_fit.gauss_peak_height;
    end

    % Prepare data for the bubble chart
    x_data = [];
    y_data = [];
    bubble_colors = [];
    bubble_sizes = [];

    for i = 1:length(x_location)
        num_peaks = length(Peak_freq{i});
        x_data = [x_data; repmat(x_location(i), num_peaks, 1)];
        y_data = [y_data; Peak_freq{i}'];
        bubble_colors = [bubble_colors; peak_height{i}'];
        bubble_sizes = [bubble_sizes; Peak_bw{i}'];
    end

    % Normalize the bandwidths for coloring  
    [~, outlier_mask] = filloutliers(bubble_colors, 'linear', 'mean', 'ThresholdFactor', 1.5);
    non_outlier_values = bubble_colors(~outlier_mask);
    max_non_outlier_value = max(non_outlier_values);
    bubble_colors(find(outlier_mask)) = max_non_outlier_value;
    bubble_colors = normalize(bubble_colors);
    % Scale the bubble sizes for better visualization
    min_bw = min(bubble_sizes);
    max_bw = max(bubble_sizes);
    scaled_bubble_sizes = 250 * (bubble_sizes - min_bw) / (max_bw - min_bw) + 1; % Adjust scaling factors as needed

    % Plot the bubble chart with sizes and colors
    scatter(x_data, y_data, scaled_bubble_sizes, bubble_colors, 'filled');
    set(gca, 'Xdir', 'reverse')
    cmap = colormap(jet); % Choose a colormap, 'jet' is used here
    c = colorbar; % Show the colorbar to indicate bandwidth values
    clim([0 0.9])
    ylim([0 30])
    ylabel(c ,'Peak Amplitude', 'FontSize', 12)
    xlabel('X Depth (Corrected) [mm]');
    ylabel('Frequency [Hz]');
    title({titleText, 'Peak along Frequeny & Depth'})    
    set(gca, 'FontSize', 12)
    set(gcf,'color', 'w')
    grid minor
    set(gca, 'XMinorGrid', 'on')
    box off


end
%% %%%%%%%%%%%%%%%%%%%%%%% Entropy %%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(mode, 'Entropy')
    Entropy = [];
    for i = 1:size(temp_table,1)
        Entropy = [Entropy temp_table{i}.Shannon_Entropy];
    end
    % plot
    plot(x_location, Entropy, 'LineWidth', 2)
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)    
    ylabel('Entropy [AU]')
    xlabel('X Depth (Corrected) [mm]')
    set(gca, 'FontSize', 12)
    title({titleText, 'Shannon Entropy along the surgery direction'})
    set(gca, 'Xdir', 'reverse') 
    set(gcf,'color', 'w')
    box off


%% %%%%%%%%%%%%%%%%%%%%%%% relative Band Power %%%%%%%%%%%%%%%%%%%%%%%
Band = lower(Band);
elseif strcmpi(mode, 'relative_Power') 
    % Plot for regular Band requests - Theta, Alpha, Beta, Gamma:
    if strcmpi(Band, 'all')
        bands = {'theta', 'alpha', 'beta', 'gamma'};
        for band = bands
            band_vecs.(cell2mat(band)) = Plot_Uni_values(DataStruct,Patient,Hemisphere,Electrode, mode, cell2mat(band));
        end
        relative_power_vector =  band_vecs;
        
        % Plot
        for i = 1:length(bands)
            plot(x_location, normalize(band_vecs.(bands{i})), 'LineWidth', 2)
            hold on
        end
        Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)
        ylabel('Relative Power [\muV]')
        xlabel('X Depth (Corrected) [mm]')
        title({titleText, 'Relative Power of all bands along the surgery direction'})
        legend(bands)
        set(gca, 'FontSize', 12)
        set(gca, 'Xdir', 'reverse')
        set(gcf,'color', 'w')
        box off

    else
        relative_power_vector = [];
        for i = 1:size(temp_table,1)
            relative_power_vector = [relative_power_vector temp_table{i}.(Band).(mode)];
        end

        % plot
        plot(x_location, normalize(relative_power_vector), 'LineWidth', 2)
        Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)
        ylabel('Relative Power [\muV]')
        xlabel('X Depth (Corrected) [mm]')
        title({titleText, ['Relative ' Band ' power along the surgery direction']})
        set(gca, 'FontSize', 12)
        set(gca, 'Xdir', 'reverse')
        set(gcf,'color', 'w')
        box off

    end

%% %%%%%%%%%%%%%%%%%%%%%%% Power Arround Beta Peak %%%%%%%%%%%%%%%%%%%%%%%
elseif strcmpi(mode, 'beta peak')
    % instead of all the beta range - plot only around a small area
    % around the peak of the graph received from Plot_Uni_values(.,.,.,.,Beta)
    % range is [f_peak - f_bound f_peak+f_bound]
    f_bound = 2.5;
    % step 1 - take the peak in beta
    relative_power_vector = Plot_Uni_values(DataStruct,Patient,Hemisphere,Electrode, 'relative_Power', 'beta');
    [~, peak_indx] = max(relative_power_vector);
    % step 2 - take the location of the peak
    peak_location = x_location(peak_indx);
    % step 3 - take the PSD of this location
    [~,index_in_table] = min(abs(str2double(DataStruct.(Patient).(table_name).Properties.RowNames) - peak_location));
    PSD_vec_of_peak_loc = temp_table{index_in_table}.PSD_vec;
    % step 4 - find the peak frequency
    f_PSD = round(3:0.3333:198,2);
    PSD_of_beta_band = PSD_vec_of_peak_loc(f_PSD>13 & f_PSD<30);
    [~, max_beta_index] = max(PSD_of_beta_band);
    f_peak = f_PSD(f_PSD > 13 & f_PSD < 30);
    f_peak = f_peak(max_beta_index);
    % step 5 - compute relative power in the band arround f_peak
    relative_Power_arround_beta_peak =[];
    for i = 1:size(temp_table,1)
        PSD_arround_beta_max = temp_table{i}.PSD_vec(f_PSD > f_peak-f_bound & f_PSD < f_peak+f_bound);
        relative_Power_arround_beta_peak = [relative_Power_arround_beta_peak trapz(PSD_arround_beta_max)];

    end
    relative_power_vector = relative_Power_arround_beta_peak;
    % step 6 - Plot
    plot(x_location, normalize(relative_Power_arround_beta_peak), 'LineWidth', 2)
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)    
    ylabel('Relative Power [\muV]')
    xlabel('X Depth (Corrected) [mm]')
    title({titleText, 'relative Power arround beta peak along the surgery direction'})
    set(gca, 'FontSize', 12)    
    set(gca, 'Xdir', 'reverse')
    set(gcf,'color', 'w')
    box off



%% %%%%%%%%%%%%%%%%%%%%%%% Peak Frequency %%%%%%%%%%%%%%%%%%%%%%%
elseif strcmpi(mode, 'Peak Frequency')
    Peak_Freq_vector = [];
    Second_Peak_vector = [];
    for i = 1:size(temp_table,1)
        Peak_Freq_vector = [Peak_Freq_vector temp_table{i}.(Band).max_freq];
        Second_Peak_vector = [Second_Peak_vector temp_table{i}.(Band).second_highest_freq];
    end
    
    % plot
    plot(x_location, Peak_Freq_vector, 'LineWidth', 2)
    hold on
    plot(x_location, Second_Peak_vector, 'LineWidth', 2)
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)
    ylabel('Peak Frequency [Hz]')
    xlabel('X Depth (Corrected) [mm]')
    legend('Peak Frequency', 'Second Highest Frequency')
    title({titleText, 'Peak Frequency along the surgery direction'})
    set(gca, 'FontSize', 12)
    set(gca, 'Xdir', 'reverse')
    set(gcf,'color', 'w')
    box off

%% %%%%%%%%%%%%%%%%%%%%%%% Spectral Entropy %%%%%%%%%%%%%%%%%%%%%%%
elseif strcmpi(mode, 'Spectral Entropy')
    SE = [];
    for i = 1:size(temp_table,1)
        SE = [SE temp_table{i}.Spectral_entropy];
    end
    
    % plot
    shadedErrorBar(x_location, SE, 'LineWidth', 2)
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)
    ylabel('Peak Frequency [Hz]')
    xlabel('X Depth (Corrected) [mm]')
    title({titleText ' ' mode ' along the surgery direction'})
    set(gca, 'FontSize', 12)
    set(gca, 'Xdir', 'reverse')
    set(gcf,'color', 'w')
    box off
  
%% %%%%%%%%%%%%%%%%%%%%%%% Spectral Kurtosis %%%%%%%%%%%%%%%%%%%%%%%
elseif strcmpi(mode, 'Spectral Kurtosis')
    SK = [];
    for i = 1:size(temp_table,1)
        SK = [SK mean(temp_table{i}.Spectral_Kurtosis)];
    end
    
    % plot
    plot(x_location, SK, 'LineWidth', 2)
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)
    ylabel('Peak Frequency [Hz]')
    xlabel('X Depth (Corrected) [mm]')
    title({titleText ' ' mode ' along the surgery direction'})
    set(gca, 'FontSize', 12)
    set(gca, 'Xdir', 'reverse')
    set(gcf,'color', 'w')
    box off
end


if show_electrodes 
    Y_lim = ylim();
    Helper_Plot_Electrode_Area(x_location, Y_lim)
end

if show_xline
    Helper_Plot_Xlines(DataStruct, Patient, Hemisphere, Electrode)   
end

end