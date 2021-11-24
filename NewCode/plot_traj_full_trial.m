%% plot_traj_full_trial.m
%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 10/19/21
% Descriptions:
%   Plot x, y and radial trajectories of rewarded trials from the onset of
%   joystick contact to the user-specified duration of reach
%--------------------------------------------------------------------------
%%
close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_2_AN04'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '112321_25_200_010_1000_010_020_060_300_060_300_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

nTrial = length(jstruct);
max_radial_position = []; %zeros(1,length(js_reward));

Fs = 1000;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',10,'PassbandRipple',0.2, ...
    'SampleRate',Fs);

lpFilt2 = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.2, ...
    'SampleRate',Fs);

index_reward = [];

for i = 1:nTrial
    if ~isempty(jstruct(i).reward_onset)
        if length(jstruct(i).reward_onset) > size(jstruct(i).masking_light,1)
            index_reward = [index_reward i];
        end
    end
end

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});
min_angle = str2double(condition_array{8});
max_angle = str2double(condition_array{9});

theta = 0:0.01:2*pi;
%%
for j = 1:2 %length(index_reward) %1:50 %3:32
    
    n = index_reward(j);
    %traj_x = filtfilt(b,a,jstruct(n).traj_x/100*6.35);
    traj_x = filtfilt(lpFilt,jstruct(n).traj_x/100*6.35);
    vel_x = [0 diff(traj_x)*Fs];
    acc_x = [0 diff(vel_x)*Fs];
    %traj_y = filtfilt(b,a,jstruct(n).traj_y/100*6.35);
    traj_y = filtfilt(lpFilt,jstruct(n).traj_y/100*6.35);
    vel_y = [0 diff(traj_y)*Fs];
    acc_y = [0 diff(vel_y)*Fs];
    RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x);
    
    angle_pos = atan2d(traj_y,traj_x);
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
    onset_reward = jstruct(n).reward_onset;
    js_reward = find(jstruct(n).js_reward==1); %joystick contact for which reward was given
    onset_js = jstruct(n).js_pairs_r(js_reward,1);
    offset_js = jstruct(n).js_pairs_r(js_reward,2);
    
    radial_vel = abs(radial_vel);
    for k = 1:length(js_reward)
        
        % Extract data within a trial
        start_time = onset_js(k) - 0.1*Fs;
        end_time = onset_reward(k) + 0.05*Fs;
        
        radial_pos_trial = radial_position(start_time:end_time);
        mag_vel_trial = mag_vel(start_time:end_time);
        tangential_vel_trial = tangential_vel(start_time:end_time);
        RoC_trial = RoC(start_time:end_time);
        
        % Find local minima in radial velocity and RoC
        [min_vel,loc_vel] = findpeaks(-mag_vel_trial);
        [min_RoC,loc_RoC] = findpeaks(-RoC_trial);
        
        % Find local minima in RoC that coincided (within 2 ms difference) with local minima in
        % radial velocity
        A = repmat(loc_RoC',[1 length(loc_vel)]);
        [minValue,closestIndex] = min(abs(A-loc_vel),[],1);
        loc_vel(minValue>1) = [];
        closestIndex(minValue>1) = [];
        
        %
        pos_min_vel = radial_pos_trial(loc_vel);
        [max_pos,max_pos_loc] = max(pos_min_vel);
        
        %end_time = loc_vel(max_pos_loc) + 0.1*Fs; %offset_trial+0.3*Fs; %start_time + loc_RoC + 0.2; %offset_trial+1*Fs; %offset_js(k);
        
        %end_time = start_time + trial_duration + 0.1*Fs;
        time = [-0.05*Fs:end_time-start_time-0.05*Fs]./Fs;
        time = time*1000;
        loc_vel(loc_vel>end_time) = [];
        loc_RoC(loc_RoC>end_time) = [];
        
        
        closestIndex(closestIndex>length(loc_RoC)) = [];
        
        % Plot x, y and radial position
%         figure()
%         subplot(3,1,1)
%         plot(time,traj_x(start_time:end_time),'LineWidth',1)
%         xlim([time(1),time(end)])
%         ylabel('x-position (mm)')
%         set(gca,'TickDir','out');
%         set(gca,'box','off')
%         hold on
%         subplot(3,1,2)
%         plot(time,traj_y(start_time:end_time),'LineWidth',1)
%         xlim([time(1),time(end)])
%         xlabel('Time (s)')
%         ylabel('y-position (mm)')
%         set(gca,'TickDir','out');
%         set(gca,'box','off')
%         hold on
%         subplot(3,1,3)
%         plot(time,radial_position(start_time:end_time),'LineWidth',1)
%         hold on
%         plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
%         plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
%         plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
%         xlim([time(1),time(end)])
%         ylabel('radial distance (mm)')
%         set(gca,'TickDir','out');
%         set(gca,'box','off')
%         
        % Plot radial position, velocity magnitude and radius of curvature 
        figure()
        ax4 = subplot(3,1,1);
        plot(time,radial_position(start_time:end_time),'LineWidth',1)
        hold on
        plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
        plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
        plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
        xlim([time(1),time(end)])
        ylabel('Radial Position (mm)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        ax5 = subplot(3,1,2);
        plot(time,mag_vel(start_time:end_time),'LineWidth',1)
        hold on
        plot(time(loc_vel),mag_vel(loc_vel+start_time),'o')
        xlim([time(1),time(end)])
        ylabel('Radial Velocity (mm/s)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        ax6 = subplot(3,1,3);
        semilogy(time,RoC(start_time:end_time),'LineWidth',1)
        hold on
        semilogy(time(loc_RoC(closestIndex)),RoC(loc_RoC(closestIndex)+start_time),'o')
        xlabel('Time (ms)')
        ylabel('Raidus of Curvature')
        xlim([time(1),time(end)])
        set(gca,'TickDir','out');
        set(gca,'box','off')
        linkaxes([ax4 ax5 ax6],'x')
        
        

        % Plot x and y trajectories in polar coordinate
        rot = -90*pi/180;
        x = 0;
        y = 0;
        x2=x+(6.35*cos(min_angle*pi/180+rot));
        y2=y+(6.35*sin(min_angle*pi/180+rot));
        x3=x+(6.35*cos(max_angle*pi/180+rot));
        y3=y+(6.35*sin(max_angle*pi/180+rot));

        figure(101)
        plot(traj_x(start_time:end_time)*cos(rot) -traj_y(start_time:end_time)*sin(rot),traj_y(start_time:end_time)*cos(rot) + traj_x(start_time:end_time)*sin(rot) ,'LineWidth',1)
        hold on
        plot(traj_x(loc_vel+start_time)*cos(rot) -traj_y(loc_vel+start_time)*sin(rot),traj_y(loc_vel+start_time)*cos(rot) + traj_x(loc_vel+start_time)*sin(rot),'o','LineWidth',1)
        plot([x x2],[y y2],'--','color','m')
        plot([x x3],[y y3],'--','color','m')
        xlim([-7 7])
        ylim([-7 7])
        set(gca,'TickDir','out')
        set(gca,'box','off')
        hold on
        plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
        plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'color','g')
        plot(max_distance*cos(theta),max_distance*sin(theta),'color','g')
        axis equal
       
    end
end

