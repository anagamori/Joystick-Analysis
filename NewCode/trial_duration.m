%%-------------------------------------------------------------------------
% Compute duration of
%   1. Trial (trial_offset - trial_onset)
%   2. Reach (time at which the joystick crosses the nimimum target threshold for the first time
%       - time at which the joystick leaves the inner threshold)
%   3. Hold within the inner circle
%%-------------------------------------------------------------------------
close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_2_F_081920_CT';
data_ID = '081721_60_80_100_0225_010_010_000_360_000_360_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

nTrial = length(jstruct);

trial_dur = [];
hold_duration = [];
hold_target_duration = [];
js_reward_count = [];
Fs = 1000;
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
theta = 0:0.01:2*pi;

zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0);  

%%
for j = 1:length(index_reward) %1:50 %3:32
    
    n = index_reward(j);
    traj_x = filtfilt(b,a,jstruct(n).traj_x/100*6.35);
    traj_y = filtfilt(b,a,jstruct(n).traj_y/100*6.35);
    
    onset_reward = jstruct(n).reward_onset;
    js_reward = find(jstruct(n).js_reward==1); %joystick contact for which reward was given
    onset_js = jstruct(n).js_pairs_r(js_reward,1);
    offset_js = jstruct(n).js_pairs_r(js_reward,2);
    
    js_reward_count = [js_reward_count length(js_reward)];
    for k = 1:length(js_reward)
        a_diff = find(jstruct(n).np_pairs(:,1)-onset_js(k)<0);
        
        onset_np = jstruct(n).np_pairs(a_diff(end),1);
        offset_np = jstruct(n).np_pairs(a_diff(end),2);
        
        b_diff = find(jstruct(n).js_pairs_l(:,1)-onset_js(k)<0);
        
        onset_js_l = jstruct(n).js_pairs_l(b_diff(end),1);
        offset_js_l = jstruct(n).js_pairs_l(b_diff(end),2);
        
        trial_live_idx = find(jstruct(n).trial_live(:,1)==onset_js(k));
        onset_trial = jstruct(n).trial_live(trial_live_idx,1);
        offset_trial = jstruct(n).trial_live(trial_live_idx,2);
        
        trial_dur = [trial_dur offset_trial - onset_trial];
        
        start_time = onset_js(k);
        end_time = offset_trial+1*Fs; %offset_js(k);
        time = [1:end_time-start_time+1]./Fs;
        
        radial_position = sqrt(traj_x.^2+traj_y.^2);
        
        [~,t_min_thres] = min(abs(radial_position(start_time:end_time) - hold_threshold));
        [~,t_target_thres] = min(abs(radial_position(start_time:end_time) - outer_threshold));
        
        zx_hold_threshold = zci(radial_position(start_time:end_time) - hold_threshold);
        zx_target_threshold = zci(radial_position(start_time:end_time) - outer_threshold);
        
        if ~isempty(zx_hold_threshold) 
            if zx_hold_threshold(1) < zx_target_threshold(1)
                hold_duration = [hold_duration zx_hold_threshold(1)];
                hold_target_duration = [hold_target_duration zx_target_threshold(1) - zx_hold_threshold(1)];
            end
        end
 
    end
end

%%
figure(101)
ax1 = subplot(2,1,1);
histogram(hold_duration,0:5:max(hold_duration))
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(2,1,2);
boxplot(hold_duration, 'Orientation','Horizontal')
xlabel('Duration within hold')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2],'x')
%%
figure(102)
ax1 = subplot(2,1,1);
histogram(hold_target_duration,20:5:max(hold_target_duration))
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(2,1,2);
boxplot(hold_target_duration, 'Orientation','Horizontal')
xlabel('Duration from hold to target')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2],'x')

%%
figure(103)
ax1 = subplot(2,1,1);
histogram(trial_dur,50:5:max(trial_dur))
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(2,1,2);
boxplot(trial_dur, 'Orientation','Horizontal')
xlabel('Trial Duration')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2],'x')
