function [stats] = get_recentered_stats(stats)

num_traj = numel(stats.traj_struct);

for i=1:num_traj   
    
    stats.traj_struct(i).traj_x = stats.traj_struct(i).traj_x - stats.traj_struct(i).traj_x(1);
    stats.traj_struct(i).traj_y = stats.traj_struct(i).traj_y - stats.traj_struct(i).traj_y(1);
    
    stats.traj_struct(i).traj_x_seg = stats.traj_struct(i).traj_x_seg - stats.traj_struct(i).traj_x_seg(1);
    stats.traj_struct(i).traj_y_seg = stats.traj_struct(i).traj_y_seg - stats.traj_struct(i).traj_y_seg(1);
    
    stats.traj_struct(i).magtraj = sqrt(stats.traj_struct(i).traj_x.^2 + stats.traj_struct(i).traj_y.^2);
    
    if numel(stats.traj_struct(i).seginfo)
        for j = 1:numel(stats.traj_struct(i).seginfo)
            stats.traj_struct(i).seginfo(j).traj_x = stats.traj_struct(i).seginfo(j).traj_x - stats.traj_struct(i).traj_x(1);
            stats.traj_struct(i).seginfo(j).traj_y = stats.traj_struct(i).seginfo(j).traj_y - stats.traj_struct(i).traj_y(1);
        end
    end
            
end    
