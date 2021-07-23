function stats = get_hold_component(stats,thresh_in)

tstruct = stats.traj_struct;
output = arrayfun(@(y) find(y.magtraj>thresh_in,1,'first'), tstruct,'UniformOutput',false);

vect_keep = zeros(numel(tstruct),1);

for i=1:numel(output)
    if numel(output{i})
        
        ind = output{i};
        seg_end_ind = find(ind>tstruct(i).redir_pts);
        if numel(seg_end_ind)
            seg_end = tstruct(i).redir_pts(seg_end_ind(end));
            
            tstruct(i).traj_x = tstruct(i).traj_x(1:seg_end);
            tstruct(i).traj_y = tstruct(i).traj_y(1:seg_end);
            tstruct(i).vel_x = tstruct(i).vel_x(1:seg_end);
            tstruct(i).vel_y = tstruct(i).vel_y(1:seg_end);
        else
            tstruct(i).traj_x = [];
            tstruct(i).traj_y = [];
            tstruct(i).vel_x = [];
            tstruct(i).vel_y = [];
        end
    end
end

stats.traj_struct = tstruct;