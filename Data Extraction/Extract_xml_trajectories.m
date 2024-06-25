function trajectories = Extract_csv_trajectories(xml_traj, elect_order)

hemispheres = {'left', 'right'};
for hemi = hemispheres
    hemi_traj = xml_traj.(string(hemi)).Traj0;
    hemi_traj_fields = fieldnames(hemi_traj);
    
    if numel(hemi_traj_fields) == 2    % NP Posetions
        % this means there is only 1 Neuroprobe
        NP1_name = strsplit(hemi_traj_fields{2},'_');
        trajectories.(cell2mat(hemi)).('Neuroprobe_1_position') = NP1_name{1};
        trajectories.(cell2mat(hemi)).('Neuroprobe_1_Orientation') = hemi_traj.([NP1_name{1} '_' NP1_name{2}]); 

    elseif numel(hemi_traj_fields) == 3    % NP Posetions
        % this means there are only 2 electrodes = two neuroprobes
        NP1_name = strsplit(hemi_traj_fields{2},'_');
        trajectories.(cell2mat(hemi)).('Neuroprobe_1_position') = NP1_name{1};
        trajectories.(cell2mat(hemi)).('Neuroprobe_1_Orientation') = hemi_traj.([NP1_name{1} '_' NP1_name{2}]); 

        NP2_name = strsplit(hemi_traj_fields{3},'_');
        trajectories.(cell2mat(hemi)).('Neuroprobe_2_position') = NP2_name{1};
        trajectories.(cell2mat(hemi)).('Neuroprobe_2_Orientation') = hemi_traj.([NP2_name{1} '_' NP2_name{2}]); 
    
    elseif  numel(hemi_traj_fields) > 5      % AP Posetions
        % This means there are 5 Alphaprobe electrodes and maybe 2 neuroprobes
        for i = 2:6
            AP_name = strsplit(hemi_traj_fields{i},'_');
            trajectories.(cell2mat(hemi)).(['Alpha_' AP_name{1} '_Orientation']) = hemi_traj.([AP_name{1} '_' AP_name{2}]); 
        end

        if numel(hemi_traj_fields) > 6 % look for first NP 
            NP1_name = strsplit(hemi_traj_fields{7},'_');
            trajectories.(cell2mat(hemi)).('Neuroprobe_1_position') = NP1_name{1};
            trajectories.(cell2mat(hemi)).('Neuroprobe_1_Orientation') = hemi_traj.([NP1_name{1} '_' NP1_name{2}]); 
        end

        if numel(hemi_traj_fields) > 7  % look for second NP
            NP2_name = strsplit(hemi_traj_fields{8},'_');
            trajectories.(cell2mat(hemi)).('Neuroprobe_2_position') = NP2_name{1};
            trajectories.(cell2mat(hemi)).('Neuroprobe_2_Orientation') = hemi_traj.([NP2_name{1} '_' NP2_name{2}]); 
        end


    end
end
end