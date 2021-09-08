close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_2_F_081920_CT';
data_ID = '081621_60_80_100_0250_010_010_000_360_000_360_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 0;

nTrial = length(jstruct);
max_radial_position = []; %zeros(1,length(js_reward));
peak_vel = [];

Fs = 1000;
d = fdesign.lowpass('N,F3db',8, 50, 1000);
hd = design(d, 'butter');

[b,a] = butter(8,50/(Fs*2),'low');
index_reward = [];
index_validTrial = [];

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
for j = 1 %:length(index_reward) %1:50 %3:32
    
    n = index_reward(j);
    traj_x = filter(hd,jstruct(n).traj_x/100*6.35);
    vel_x = [0 diff(traj_x)*Fs];
    acc_x = [0 diff(vel_x)*Fs];
    traj_y = filter(hd,jstruct(n).traj_y/100*6.35);
    vel_y = [0 diff(traj_y)*Fs];
    acc_y = [0 diff(vel_y)*Fs];
    RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x);
    radial_position = sqrt(traj_x.^2+traj_y.^2);
    
    radial_vel = (traj_x.*vel_x + traj_y.*vel_y)./radial_position;
    radial_vel_2 = [0 diff(radial_position)*Fs];
    radial_acc = sqrt(acc_x.^2+acc_y.^2);
    radial_acc_2 = [0 diff(radial_vel_2)*Fs];
    onset_reward = jstruct(n).reward_onset;
    js_reward = find(jstruct(n).js_reward==1); %joystick contact for which reward was given
    onset_js = jstruct(n).js_pairs_r(js_reward,1);
    offset_js = jstruct(n).js_pairs_r(js_reward,2);
    
    for k = 1:length(js_reward)
        
        % Extract data within a trial
        trial_start_time = onset_js(k)-0.05*Fs;
        trial_end_time = trial_start_time + trial_duration + 0.1*Fs;

        radial_pos_trial = radial_position(trial_start_time:trial_start_time + trial_duration + 0.1*Fs);
        radial_vel_trial = radial_vel(trial_start_time:trial_start_time + trial_duration + 0.1*Fs);
        RoC_trial = RoC(trial_start_time:trial_start_time + trial_duration + 0.1*Fs); 
        
        % Find local minima in radial velocity and RoC
        [min_vel,loc_vel] = findpeaks(-abs(radial_vel_trial));
        [min_RoC,loc_RoC] = findpeaks(-RoC_trial);
        
        % Find local minima in RoC that coincided (within 2 ms difference) with local minima in
        % radial velocity
        A = repmat(loc_RoC',[1 length(loc_vel)]);
        [minValue,closestIndex] = min(abs(A-loc_vel),[],1);        
        loc_vel(minValue>5) = [];
        closestIndex(minValue>5) = [];
        
        % Find velocity peaks 
        [max_vel,loc_max_vel] = findpeaks(radial_vel_trial);
        
        %
        reach_start_time_index = find(radial_pos_trial(loc_vel)<hold_threshold);
        if ~isempty(reach_start_time_index)
            reach_start_time = loc_vel(reach_start_time_index(end));
        end
        
        %         
        reach_end_time_index = find(radial_pos_trial(loc_vel)>=outer_threshold&radial_pos_trial(loc_vel)<=max_distance);
        if ~isempty(reach_end_time_index)
            reach_end_time = loc_vel(reach_end_time_index(end));
        end
        
        if ~isempty(reach_start_time_index)&&~isempty(reach_end_time_index)
            loc_max_vel_reach_index = find(loc_max_vel>reach_start_time&loc_max_vel<reach_end_time);
            
            n_vel_peak = length(loc_max_vel_reach_index);

            time = -0.01:1/Fs:(reach_end_time-reach_start_time+0.01*Fs)/Fs; %[-0.05*Fs:end_time]./Fs;
            time = time*1000;

            if n_vel_peak == 1 
                index_validTrial = [index_validTrial [j;k]];
                peak_vel = [peak_vel max_vel(loc_max_vel_reach_index)];
                
                figure()
                subplot(3,1,1)
                plot(time,traj_x(reach_start_time-0.01*Fs+trial_start_time:reach_end_time+0.01*Fs+trial_start_time),'LineWidth',1)
                ylabel('x-position (mm)')
                set(gca,'TickDir','out');
                set(gca,'box','off')
                hold on
                subplot(3,1,2)
                plot(time,traj_y(reach_start_time-0.01*Fs+trial_start_time:reach_end_time+0.01*Fs+trial_start_time),'LineWidth',1)              
                xlabel('Time (s)')
                ylabel('y-position (mm)')
                set(gca,'TickDir','out');
                set(gca,'box','off')
                hold on
                subplot(3,1,3)
                plot(time,radial_position(reach_start_time-0.01*Fs+trial_start_time:reach_end_time+0.01*Fs+trial_start_time),'LineWidth',1)
                hold on
                plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
                plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
                plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
                ylabel('radial distance (mm)')
                set(gca,'TickDir','out');
                set(gca,'box','off')

                figure()
                subplot(3,1,1)
                plot(time,radial_position(reach_start_time-0.01*Fs+trial_start_time:reach_end_time+0.01*Fs+trial_start_time),'LineWidth',1)
                hold on
                plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
                plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
                plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
                ylabel('Radial Position (mm)')
                set(gca,'TickDir','out');
                set(gca,'box','off')
                subplot(3,1,2)
                plot(time,radial_vel(reach_start_time-0.01*Fs+trial_start_time:reach_end_time+0.01*Fs+trial_start_time),'LineWidth',1)
                ylabel('Radial Velocity (mm/s)')
                set(gca,'TickDir','out');
                set(gca,'box','off')
                subplot(3,1,3)
                semilogy(time,RoC(reach_start_time-0.01*Fs+trial_start_time:reach_end_time+0.01*Fs+trial_start_time),'LineWidth',1)
                xlabel('Time (ms)')
                ylabel('Raidus of Curvature')
                set(gca,'TickDir','out');
                set(gca,'box','off')
    %             
                figure()
                plot(traj_x(reach_start_time-0.01*Fs+trial_start_time:reach_end_time+0.01*Fs+trial_start_time),traj_y(reach_start_time-0.01*Fs+trial_start_time:reach_end_time+0.01*Fs+trial_start_time),'LineWidth',1)
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
   
    end
end

%%
figure()
histogram(peak_vel,[20:5:200])
