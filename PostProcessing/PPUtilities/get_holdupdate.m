function [thresh_out] = get_holdupdate(stats,targ_holdtime,skip_short)

if skip_short
    stats = get_stats_with_len(stats,50);
end

stats = get_recentered_stats(stats);

t_struct = stats.traj_struct;  
t_index = zeros(1,numel(t_struct));

for i = 1:numel(t_struct)    
   thresh_ind = t_struct(i).magtraj>(dist1*6.35/100);
   
   if sum(thresh_ind)
       [~,temp] = find(thresh_ind);
       t_index(i) = temp(1);
   else
       t_index(i) = numel(t_struct(i).magtraj);
   end
end

edges = 0:1:400;
dist_time = histc(t_index,edges);

figure;
plot(edges,cumsum(dist_time)/numel(t_index));
