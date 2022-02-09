%% create_js_reach.m
%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 1/9/21
% Descriptions:
%--------------------------------------------------------------------------
%%

close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_2_AN04'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '020722_63_100_005_10000_010_020_000_180_000_180_000';
condition_array = strsplit(data_ID,'_');

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

Fs = 1000;

nTrial = length(js_reach);
%%
for n =  1:nTrial
    
    %%
    
    trial_start_time =  1*Fs-0.25*Fs+1; 
    trial_end_time = 1*Fs + 0.3*Fs;
    if trial_end_time>length(js_reach(n).radial_pos)
        trial_end_time = length(js_reach(n).radial_pos);
    end
    time = -0.25+1/Fs:1/Fs:(trial_end_time-1*Fs)/Fs;
    radial_pos_trial = js_reach(n).radial_pos(trial_start_time:trial_end_time);
    mag_vel_trial = js_reach(n).mag_vel(trial_start_time:trial_end_time);
    RoC_trial = js_reach(n).RoC(trial_start_time:trial_end_time);
    
    [min_vel,loc_vel] = findpeaks(-mag_vel_trial);
    [min_RoC,loc_RoC] = findpeaks(-RoC_trial);
    A = repmat(loc_RoC',[1 length(loc_vel)]);
    [minValue,closestIndex] = min(abs(A-loc_vel),[],1);
    loc_vel(minValue>6) = [];
    closestIndex(minValue>6) = [];
    
    radial_pos_2_trial = js_reach(n).radial_pos_2(trial_start_time:trial_end_time);
    mag_vel_2_trial = js_reach(n).mag_vel_2(trial_start_time:trial_end_time);
    RoC_2_trial = js_reach(n).RoC_2(trial_start_time:trial_end_time);
    
    [min_vel_2,loc_vel_2] = findpeaks(-mag_vel_2_trial);
    [min_RoC_2,loc_RoC_2] = findpeaks(-RoC_2_trial);
    A_2 = repmat(loc_RoC_2',[1 length(loc_vel_2)]);
    [minValue_2,closestIndex_2] = min(abs(A_2-loc_vel_2),[],1);
    loc_vel_2(minValue_2>6) = [];
    closestIndex_2(minValue_2>6) = [];
    
%     figure()
%     plot(time,radial_pos_trial,'color','b','LineWidth',2)
%     hold on 
%     plot(time(loc_vel),radial_pos_trial(loc_vel),'o','color','b','LineWidth',1)
%     plot(time,radial_pos_2_trial,'color','r','LineWidth',2)
%     hold on 
%     plot(time(loc_vel_2),radial_pos_2_trial(loc_vel_2),'o','color','r','LineWidth',1)
%     
    %%
    % Find time point of conincident local minima in low-pvelocity and RoC in which
    % radial position (raw data) was in the target region
    loc_min_vel_taregt = loc_vel(radial_pos_2_trial(loc_vel)>outer_threshold&radial_pos_2_trial(loc_vel)<max_distance);
    loc_min_vel_hold = loc_vel_2(radial_pos_2_trial(loc_vel_2)<hold_threshold);
    if ~isempty(loc_min_vel_taregt) && ~isempty(loc_min_vel_hold)
        loc_min_vel_hold(loc_min_vel_hold>loc_min_vel_taregt(end)) = [];
    elseif isempty(loc_min_vel_taregt)
        [~,idx_temp] = max(radial_pos_2_trial(loc_vel));
        loc_min_vel_taregt = loc_vel(idx_temp);
        loc_min_vel_hold(loc_min_vel_hold>loc_min_vel_taregt) = [];
    end
    if isempty(loc_min_vel_hold)
        [~,idx_temp] = min(radial_pos_2_trial(1:loc_min_vel_taregt(end)));
        loc_min_vel_hold = idx_temp;
    end
    reach_start_idx = loc_min_vel_hold(end);
    reach_end_idx = loc_min_vel_taregt(1);
    if reach_start_idx < reach_end_idx && reach_start_idx-0.01*Fs>0
        time_reach = [-0.01*Fs:reach_end_idx+0.02*Fs-reach_start_idx]./Fs;

        [~,locs] = findpeaks(radial_pos_trial(reach_start_idx:reach_end_idx));
        js_reach(n).reach_start_time = reach_start_idx;
        js_reach(n).reach_end_time = reach_end_idx;
        js_reach(n).n_vel_peak_1 = length(locs);

        max_vel(n) = max(mag_vel_2_trial(reach_start_idx:reach_end_idx));
        max_pos(n) = max(radial_pos_2_trial(reach_start_idx:reach_end_idx));
        reach_duration(n) = reach_end_idx - reach_start_idx;

        figure(1+n)
        plot(time_reach,radial_pos_trial(reach_start_idx-0.01*Fs:reach_end_idx+0.02*Fs),'b','LineWidth',1)
        hold on
        plot(time_reach,radial_pos_2_trial(reach_start_idx-0.01*Fs:reach_end_idx+0.02*Fs),'r','LineWidth',1)
        yline(hold_threshold,'--','color','k','LineWidth',2)
        yline(outer_threshold,'color','g','LineWidth',2)
        yline(max_distance,'color','g','LineWidth',2)
        
        figure(1)
        plot(time_reach,radial_pos_2_trial(reach_start_idx-0.01*Fs:reach_end_idx+0.02*Fs),'k','LineWidth',1)
        hold on
        yline(hold_threshold,'--','color','k','LineWidth',2)
        yline(outer_threshold,'color','g','LineWidth',2)
        yline(max_distance,'color','g','LineWidth',2)
        
        js_reach(n).reach_flag = [];
    else
        js_reach(n).reach_flag = 1;
    end
    
end

figure()
histogram(max_vel,20:20:300)

figure()
histogram(max_pos,0:0.5:max_distance)
hold on 
xline(outer_threshold,'color','k')
xline(max_distance,'color','k')
% cd([data_folder mouse_ID '\' data_ID])
% save('js_reach','js_reach')
% cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
