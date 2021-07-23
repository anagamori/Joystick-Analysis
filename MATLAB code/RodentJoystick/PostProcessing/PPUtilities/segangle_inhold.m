function [] = segangle_inhold(stats)

stats = get_stats_with_len(stats,50);
stats = get_stats_without_lick(stats);
stats = get_recentered_stats(stats);

for i=1:12
    seg_list = get_seg_start_at(stats,2*6.35/100,15*6.35/100,[],(i-1)*30,i*30,1);    
    seg_dir{i} = get_seg_dir_teja(seg_list);    
end

for i=1:12
    if numel(seg_dir{i})
        dir_vect = seg_dir{i};
        dir_vect = dir_vect(~isnan(dir_vect));
        dir_region(i) = circ_mean(dir_vect'*pi/180);
    else
        dir_region(i) = nan;
    end
end

figure;
for i=1:12
    amp_vect = 0.25;
    ang1 = (i-1)*30+15;    
    dir_index = [1*cosd(ang1) sind(ang1)];
    quiver(dir_index(1),dir_index(2),amp_vect*cos(dir_region(i)),amp_vect*sin(dir_region(i)),'linewidth',2,'MaxHeadSize',4);
    hold on;
end
axis square
axis equal
axis([-2 2 -2 2])

% for i=1:12
%     figure
%     dir_vect = seg_dir{i};
%     hist(dir_vect,100);
% end