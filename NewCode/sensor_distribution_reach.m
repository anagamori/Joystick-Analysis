close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_3_F_102320_CT';
data_ID = '101121_60_80_100_0500_010_010_000_360_000_360_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

nTrial = length(jstruct);
max_radial_position = []; %zeros(1,length(js_reward));

Fs = 1000;
d = fdesign.lowpass('N,F3db',8, 50, 1000);
hd = design(d, 'butter');
[b,a] = butter(4,50/(Fs*2),'low');
index_touch = [];

for i = 1:nTrial
    if ~isempty(jstruct(i).js_pairs_r)
        
        index_touch = [index_touch i];
        
    end
end

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});

theta = 0:0.01:2*pi;
js_r_diff = [];
js_l_diff = [];
%%
for j = 6:20 %length(index_touch) %1:50 %3:32
    n = index_touch(j);
    %traj_x = filtfilt(b,a,jstruct(n).traj_x/100*6.35);
    traj_x = filter(hd,jstruct(n).traj_x/100*6.35);
    vel_x = [0 diff(traj_x)*Fs];
    acc_x = [0 diff(vel_x)*Fs];
    %traj_y = filtfilt(b,a,jstruct(n).traj_y/100*6.35);
    traj_y = filter(hd,jstruct(n).traj_y/100*6.35);
    vel_y = [0 diff(traj_y)*Fs];
    acc_y = [0 diff(vel_y)*Fs];
    RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x);
    
    A = [traj_x;traj_y];
    B = [vel_x;vel_y];
    angle_pos_vel = max(min(dot(A,B)./(vecnorm(A,2,1).*vecnorm(B,2,1)),1),-1);
    angle_in_deg = real(acosd(angle_pos_vel));
    %tangential_velocity_2 = mag_vel.*sin(ThetaInDegrees*pi/180);
    radial_position = sqrt(traj_x.^2+traj_y.^2);
    radial_vel = (traj_x.*vel_x + traj_y.*vel_y)./radial_position;
    mag_vel = sqrt(vel_x.^2+vel_y.^2);
    radial_acc = [0 diff(radial_position)*Fs];
    angular_vel = (traj_x.*vel_y - traj_y.*vel_x)./(traj_x.^2+traj_y.^2);
    tangential_vel = radial_position.*angular_vel;
    
    time = [1:length(traj_x)]; %/Fs;
    
    np_vec = zeros(1,length(time));
    for i = 1:size(jstruct(n).np_pairs)
        np_vec(jstruct(n).np_pairs(i,1):jstruct(n).np_pairs(i,2)) = 1.5;
    end
    js_r_vec = zeros(1,length(time));
    js_l_vec = zeros(1,length(time));
    if ~isempty(jstruct(n).js_pairs_r)     
        for i = 1:size(jstruct(n).js_pairs_r)
            js_r_vec(jstruct(n).js_pairs_r(i,1):jstruct(n).js_pairs_r(i,2)) = 1;
        end
        js_r_diff = [js_r_diff;jstruct(n).js_pairs_r(:,2)-jstruct(n).js_pairs_r(:,1)];
    end
    if ~isempty(jstruct(n).js_pairs_l)
        for i = 1:size(jstruct(n).js_pairs_l)
            js_l_vec(jstruct(n).js_pairs_l(i,1):jstruct(n).js_pairs_l(i,2)) = 0.5;
        end
        js_l_diff = [js_l_diff;jstruct(n).js_pairs_l(:,2)-jstruct(n).js_pairs_l(:,1)];
    end
    
    np_vec(np_vec==0) = nan;
    js_r_vec(js_r_vec==0) = nan;
    js_l_vec(js_l_vec==0) = nan;
    
    figure(j)
    ax1 = subplot(4,1,1);
    plot(time,traj_x,'LineWidth',1)
    xlim([time(1),time(end)])
    ylabel('x-position (mm)')
    set(gca,'TickDir','out');
    set(gca,'box','off')
    hold on
    ax2 = subplot(4,1,2);
    plot(time,traj_y,'LineWidth',1)
    xlim([time(1),time(end)])
    xlabel('Time (s)')
    ylabel('y-position (mm)')
    set(gca,'TickDir','out');
    set(gca,'box','off')
    hold on
    ax3 =  subplot(4,1,3);
    plot(time,radial_position,'LineWidth',1)
    hold on
    plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
    plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
    plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
    xlim([time(1),time(end)])
    ylabel('radial distance (mm)')
    set(gca,'TickDir','out');
    set(gca,'box','off')
    ax4 = subplot(4,1,4);
    plot(time,np_vec,'LineWidth',1)
    hold on 
    plot(time,js_r_vec,'LineWidth',1)
    plot(time,js_l_vec,'LineWidth',1)
    ylim([0 2])
    set(gca,'TickDir','out');
    set(gca,'box','off')
    legend('Nose Poke','Joystick','Post')
    linkaxes([ax1 ax2 ax3 ax4],'x')
  
    min(js_r_diff)
    min(js_l_diff)
end

