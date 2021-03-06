%close all
clear all
clc

data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Data\Box_3_F_102320_CT\072921_30_100_030_000_360_000_360_00';
% 072321_60_100_050_000_360_000_360_00
% 072521_60_100_050_000_360_000_360_00
% 072621_60_100_050_000_360_000_360_00
cd(data_folder)
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

nTrial = length(jstruct);
max_radial_position = []; %zeros(1,length(js_reward));

Fs = 1000;
[b,a] = butter(4,20/(Fs*2),'low');
index_reward = [];
        
for i = 1:nTrial
    if ~isempty(jstruct(i).reward_onset)
        index_reward = [index_reward i];
    end
end

hold_threshold = 30/100*6.35;
outer_threshold = 30/100*6.35;
max_distance = 110/100*6.35;
theta = 0:0.01:2*pi;
%%
for j = 1:length(index_reward) %1:50 %3:32
    
    n = index_reward(j);
    traj_x = filtfilt(b,a,jstruct(n).traj_x/100*6.35);
    traj_y = filtfilt(b,a,jstruct(n).traj_y/100*6.35);
    reward_vec = zeros(1,length(traj_x)); 
    reward_vec(jstruct(n).reward_onset) = 1;
    js_reward = find(jstruct(n).js_reward==1); %joystick contact for which reward was given 
    onset_js = jstruct(n).js_pairs_r(js_reward,1);
    offset_js = jstruct(n).js_pairs_r(js_reward,2);
    
    
    
    for k = 1:length(js_reward)
        a_diff = find(jstruct(n).np_pairs(:,1)-onset_js(k)<0);
    
        onset_np = jstruct(n).np_pairs(a_diff(end),1);
        offset_np = jstruct(n).np_pairs(a_diff(end),2);
        start_time = onset_js(k);
        end_time = jstruct(n).reward_onset(k)+1*Fs; %offset_js(k);
        time = [1:end_time-start_time+1]./Fs;
        
        radial_position = sqrt(traj_x.^2+traj_y.^2);
        
        
        figure(1)
        subplot(4,1,1)
        plot(time,traj_x(start_time:end_time),'LineWidth',1)
        ylabel('x-position (mm)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        hold on 
        subplot(4,1,2)
        plot(time,traj_y(start_time:end_time),'LineWidth',1)
        xlabel('Time (s)')
        ylabel('y-position (mm)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        hold on
        subplot(4,1,3)
        plot(time,radial_position(start_time:end_time),'LineWidth',1)
        hold on 
        plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
        plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
        plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
        ylabel('radial distance (mm)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        subplot(4,1,4)
        plot(time,reward_vec(start_time:end_time),'LineWidth',1)
        ylabel('Reward')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        hold on 
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
        
        max_radial_position = [max_radial_position max(radial_position(start_time:end_time))];
        %[max_radial_position(k),loc] = max(radial_position(start_time:end_time));
        
    end
end

%%
figure(11)
histogram(max_radial_position,[0:6.35/50:6.35])
hold on 
line([outer_threshold, outer_threshold], ylim, 'LineWidth', 2, 'Color', 'r');
line([max_distance, max_distance], ylim, 'LineWidth', 2, 'Color', 'r');


