close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_2_F_081920_CT';
data_ID = '083021_60_80_100_0250_010_010_000_360_000_360_000';
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
index_reward = [];

for i = 1:nTrial
    if ~isempty(jstruct(i).reward_onset)
        index_reward = [index_reward i];
    end
end

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});

theta = 0:0.01:2*pi;
%%
for j = 2 %:length(index_reward) %1:50 %3:32
    
    n = index_reward(j);
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
    onset_reward = jstruct(n).reward_onset;
    js_reward = find(jstruct(n).js_reward==1); %joystick contact for which reward was given
    onset_js = jstruct(n).js_pairs_r(js_reward,1);
    offset_js = jstruct(n).js_pairs_r(js_reward,2);
    
    radial_vel = abs(radial_vel);
    for k = 1:length(js_reward)
        
        % Extract data within a trial
        start_time = onset_js(k)-0.1*Fs;

        radial_pos_trial = radial_position(start_time:start_time + trial_duration + 0.1*Fs);
        radial_vel_trial = radial_vel(start_time:start_time + trial_duration + 0.1*Fs);
        tangential_vel_trial = tangential_vel(start_time:start_time + trial_duration + 0.1*Fs);
        RoC_trial = RoC(start_time:start_time + trial_duration + 0.1*Fs); 
        
        % Find local minima in radial velocity and RoC
        [min_vel,loc_vel] = findpeaks(-radial_vel_trial);
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
        
        end_time = start_time + trial_duration + 0.1*Fs;
        time = -0.05:1/Fs:(trial_duration+0.05*Fs)/Fs; %[-0.05*Fs:end_time]./Fs;
        time = time*1000;
        loc_vel(loc_vel>end_time) = [];
        loc_RoC(loc_RoC>end_time) = [];
        
        
        closestIndex(closestIndex>length(loc_RoC)) = [];
        if plotOpt == 1           
            figure()
            subplot(3,1,1)
            plot(time,traj_x(start_time:end_time),'LineWidth',1)
            xlim([time(1),time(end)])
            ylabel('x-position (mm)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            hold on
            subplot(3,1,2)
            plot(time,traj_y(start_time:end_time),'LineWidth',1)
            xlim([time(1),time(end)])
            xlabel('Time (s)')
            ylabel('y-position (mm)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            hold on
            subplot(3,1,3)
            plot(time,radial_position(start_time:end_time),'LineWidth',1)
            hold on
            plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
            plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
            plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
            xlim([time(1),time(end)])
            ylabel('radial distance (mm)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            
            figure()
            subplot(3,1,1)
            plot(time,radial_position(start_time:end_time),'LineWidth',1)
            hold on
            plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
            plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
            plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
            xlim([time(1),time(end)])
            ylabel('Radial Position (mm)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            subplot(3,1,2)
            plot(time,radial_vel(start_time:end_time),'LineWidth',1)
            hold on 
            plot(time(loc_vel),radial_vel(loc_vel+start_time),'o')
            xlim([time(1),time(end)])
            ylabel('Radial Velocity (mm/s)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            subplot(3,1,3)
            semilogy(time,RoC(start_time:end_time),'LineWidth',1)
            hold on 
            semilogy(time(loc_RoC(closestIndex)),RoC(loc_RoC(closestIndex)+start_time),'o')
            xlabel('Time (ms)')
            ylabel('Raidus of Curvature')
            xlim([time(1),time(end)])
            set(gca,'TickDir','out');
            set(gca,'box','off')
            
            figure()
            plot(traj_x(start_time:end_time),traj_y(start_time:end_time),'LineWidth',1)
            hold on
            plot(traj_x(loc_vel+start_time),traj_y(loc_vel+start_time),'o','LineWidth',1)
            xlim([-7 7])
            ylim([-7 7])
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
            plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'color','g')
            plot(max_distance*cos(theta),max_distance*sin(theta),'color','g')
            axis equal
            
            figure()
            subplot(3,1,1)
            plot(time,radial_position(start_time:end_time),'LineWidth',1)
            hold on
            plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
            plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
            plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
            xlim([time(1),time(end)])
            ylabel('Radial Position (mm)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            subplot(3,1,2)
            plot(time,abs(tangential_vel(start_time:end_time)),'LineWidth',1)
            xlim([time(1),time(end)])
            ylabel('Tangential Velocity (mm/s)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            subplot(3,1,3)
            semilogy(time,RoC(start_time:end_time),'LineWidth',1)
            hold on 
            semilogy(time(loc_RoC(closestIndex)),RoC(loc_RoC(closestIndex)+start_time),'o')
            xlabel('Time (ms)')
            ylabel('Raidus of Curvature')
            xlim([time(1),time(end)])
            set(gca,'TickDir','out');
            set(gca,'box','off')
            
        elseif plotOpt == 2
            figure(1)
            plot(traj_x(start_time:end_time+start_time),traj_y(start_time:end_time+start_time),'LineWidth',1)
            hold on
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
        %
        %
        %         figure(2)
        %         plot(traj_x(start_time:end_time),traj_y(start_time:end_time),'LineWidth',1)
        %         xlabel('x-position (mm)')
        %         ylabel('y-position (mm)')
        %         xlim([-6.35 6.35])
        %         ylim([-6.35 6.35])
        %         %axis equal
        %         set(gca,'TickDir','out')
        %         set(gca,'box','off')
        %         hold on
        %         plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
        %         plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'color','g')
        %         plot(max_distance*cos(theta),max_distance*sin(theta),'color','g')
        
        max_radial_position = [max_radial_position max(radial_position(start_time:onset_reward(k)))]; %[max_radial_position max(radial_position(onset_reward(k)))];
        %[max_radial_position(k),loc] = max(radial_position(start_time:end_time));
        
    end
end

%%
% figure(11)
% histogram(max_radial_position,[0:6.35/50:6.35])
% hold on
% line([outer_threshold, outer_threshold], ylim, 'LineWidth', 2, 'Color', 'r');
% line([max_distance, max_distance], ylim, 'LineWidth', 2, 'Color', 'r');
%
% %
