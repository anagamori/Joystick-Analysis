function [fig_handle] = show_trajectory(stats,index)

tstruct = stats.traj_struct(index);

x = tstruct.traj_x;
y = tstruct.traj_y;

x_d = diff(x);
y_d = diff(y);
        
x_dd = diff(x_d); y_dd = diff(y_d);        
x_d = x_d(2:end); y_d = y_d(2:end);
r_c = ((x_d.^2+y_d.^2).^(1.5))./(x_d.*y_dd-y_d.*x_dd); r_c = abs(r_c);



fig_handle = figure;

figure;
plot(tstruct.traj_x);
ylim([-6.35 6.35])

figure;
plot(tstruct.traj_y);
ylim([-6.35 6.35])

figure;
plot(tstruct.magtraj);
ylim([0 6.35])

figure;
hold on
plot(10*tstruct.vel_mag);
plot(tstruct.redir_pts+1,10*tstruct.vel_mag(tstruct.redir_pts+1),'rx','MarkerSize',10,'LineWidth',2);

figure;
hold on
plot(r_c);
ylim([0 1]);
plot(tstruct.redir_pts,r_c(tstruct.redir_pts),'rx','MarkerSize',10,'LineWidth',2);

figure;
x = 1.9*cosd(0:1:360);
y = 1.9*sind(0:1:360);
plot(x,y,'Color', [0.8 0.8 0.8],'LineWidth',2);
hold on

x = 4*cosd(0:1:360);
y = 4*sind(0:1:360);
plot(x,y,'Color', [0.8 0.8 0.8],'LineWidth',2);

x = 6.35*cosd(0:1:360);
y = 6.35*sind(0:1:360);
plot(x,y,'Color', [0.8 0.8 0.8],'LineWidth',2)

plot(tstruct.traj_x,tstruct.traj_y,'LineWidth',2);

axis equal
axis square
ylim([-6.35 6.35])
xlim([-6.35 6.35])