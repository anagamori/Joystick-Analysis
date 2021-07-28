function [thresh_out] = get_holdupdate_dist(stats,holdtime,rw_rate,skip_short)

if skip_short
    stats = get_stats_with_len(stats,50);
end
stats = get_recentered_stats(stats);
total_num = numel(stats.traj_struct);
stats = get_stats_without_lick(stats);

stats_400 = get_stats_with_len(stats,holdtime-1);
t_struct = stats_400.traj_struct;

dist_list = (1:80);
dist_success = zeros(1,numel(dist_list));

for j = 1:numel(dist_list)
    for i = 1:numel(t_struct)        
        thresh_ind = t_struct(i).magtraj>(dist_list(j)*6.35/100);
        if sum(thresh_ind) == 0
            dist_success(j) = dist_success(j)+1;
        end
    end
end

dist_success = dist_success/total_num;

[~,locs] = find(dist_success>rw_rate);
if numel(locs)<1
    locs = 80;
end
thresh_out = locs(1);

% edges = 0:1:400;
% dist_time = histc(t_index,edges);
% 
% figure;
% plot(edges,cumsum(dist_time)/numel(t_index));



end

