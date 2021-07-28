function [stats] = meanpos_athold(stats,secnum,div)

blksize = 360/div;

stats = get_stats_with_len(stats,50);
tstruct = stats.traj_struct;

for i=1:numel(tstruct)   
    mean_x(i) = mean(tstruct(i).traj_x);
    mean_y(i) = mean(tstruct(i).traj_y);
end

[theta,rho] = cart2pol(mean_x,mean_y);

theta=theta*180/pi;
theta = wrapTo360(theta);

secnum_list = (theta>=(secnum-1)*blksize & theta<secnum*blksize & rho>0.05);

stats.traj_struct = tstruct(secnum_list);

%tpdf = hist2d([mean_x',mean_y'],-0.635:0.03175:0.635,-0.635:0.03175:0.635);
% 
% tpdf = tpdf/(sum(sum(tpdf)));
% figure;
% ax = gca;
% draw_heat_map(tpdf, ax, ['Hold Centers'], 1, [1 99], []);
