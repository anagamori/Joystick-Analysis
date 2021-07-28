function stats_out = get_stats_with_laserpower(stats,lp_val)

stats_out = stats;
stats = get_stats_with_trajid(stats,1);
tstruct = stats.traj_struct;

output = arrayfun(@(x) (x.laser_power == lp_val),tstruct);

tstruct_out = tstruct(output);
stats_out.traj_struct = tstruct_out;