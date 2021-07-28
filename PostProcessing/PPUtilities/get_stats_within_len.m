function stats_out = get_stats_within_len(stats,len)

stats_out = stats;
tstruct= stats.traj_struct;
output = arrayfun(@(x) numel(x.traj_x)<len,tstruct);
tstruct_out = tstruct(output);
stats_out.traj_struct = tstruct_out;