function trajectories = Extract_trajectories(Surg_data, elect_order)

hemispheres = {'left', 'right'};
for hemi = hemispheres
    hemi_indx = find(strcmpi(Surg_data.Side, cell2mat(hemi)));
    
    % AP position
    AP_indx = find(strcmpi(Surg_data.ElectrodeType, 'AP'));
    AP_pos_indx = intersect(hemi_indx, AP_indx);
    if ~isempty(AP_pos_indx)
        APflag = true;

        trajectories.(cell2mat(hemi)).AP_position = cell2mat(Surg_data.Position(AP_pos_indx(1)));
        % AP orientations
        for i = 1:length(AP_pos_indx)
            elect_name = cell2mat(elect_order(i));
            elect_initial = elect_name(1);
            AP_or_indx = find(strcmpi(Surg_data.Orientation, elect_initial));
            elect_pos = intersect(hemi_indx,AP_or_indx);
            trajectories.(cell2mat(hemi)).(['Alpha_' elect_name '_RowIndx']) = elect_pos;
            if elect_pos > 7
                elect_pos = elect_pos - 7;
            end
            trajectories.(cell2mat(hemi)).(['Alpha_' elect_name '_Orientation']) = i;

        end
    else
        APflag = false;
    end
    
    
    % NP position
    NP_indx = find(strcmpi(Surg_data.ElectrodeType, 'NP'));
    NP_pos_indx = intersect(hemi_indx,NP_indx);
    
    if ~isempty(NP_pos_indx)
        for i = 1:length(NP_pos_indx)
            trajectories.(cell2mat(hemi)).(['Neuroprobe_' num2str(i) '_RowIndx']) = NP_pos_indx(i);
            trajectories.(cell2mat(hemi)).(['Neuroprobe_' num2str(i) '_position']) = cell2mat(Surg_data.Position(NP_pos_indx(i)));
            if APflag
                trajectories.(cell2mat(hemi)).(['Neuroprobe_' num2str(i) '_Orientation']) = 5 + i;
            elseif ~APflag
                trajectories.(cell2mat(hemi)).(['Neuroprobe_' num2str(i) '_Orientation']) = i;  
            end
        end
    end

end
end