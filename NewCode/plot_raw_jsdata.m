%% plot_raw_jsdata.m
%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 5/3/22
% Descriptions: 
%--------------------------------------------------------------------------
%%

close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN08'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '042922_63_79_030_10000_200_016_030_150_030_150_000';
condition_array = strsplit(data_ID,'_');
hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});
angle_min = str2double(condition_array{8});
angle_max = str2double(condition_array{9});

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

%%
plotOpt = 1;

nTrial = length(jstruct);
max_radial_position = []; %zeros(1,length(js_reward));
peak_vel = [];

Fs = 1000;

[b,a] = butter(10,100/(Fs/2),'low');

index_reward = [];
time_reward = [];
n_reward = 0;
index_validTrial = [];

buffer_length = 0.5*Fs;
recording_length = 0.5*Fs;
reward_count = 0;
trial_count = 1;
for i = 1:nTrial
    js_r_contact = zeros(1,length(jstruct(i).traj_x));
    js_l_contact = zeros(1,length(jstruct(i).traj_x));
    reward = zeros(1,length(jstruct(i).traj_x));
    for j = 1:size(jstruct(i).js_pairs_r,1)
        js_r_contact(jstruct(i).js_pairs_r(j,1):jstruct(i).js_pairs_r(j,2)) = 1;
    end
    for k = 1:size(jstruct(i).js_pairs_l,1)
        js_l_contact(jstruct(i).js_pairs_l(k,1):jstruct(i).js_pairs_l(k,2)) = 1;
    end
    reward(jstruct(i).reward_onset) = 1;
    time = [1:length(jstruct(i).traj_x)]./Fs;
    x_filt =  jstruct(i).traj_x/100*6.35; %filtfilt(b,a,jstruct(i).traj_x/100*6.35);
    y_filt = jstruct(i).traj_y/100*6.35; %filtfilt(b,a,jstruct(i).traj_y/100*6.35);
    radial_pos = sqrt(x_filt.^2+y_filt.^2);
    angle_js = atan2d(y_filt,x_filt);
    angle_js = angle_js + (angle_js < 0)*360;
    
    % define hold periods 
    hold_binary = zeros(1,length(jstruct(i).traj_x));
    hold_binary(radial_pos<hold_threshold) = 1;
    hold_diff = [0 diff(hold_binary)]; 
    hold_onset = find(hold_diff ==1);
    if hold_binary(1) == 1
        hold_onset = [1 hold_onset];
    end
    
    hold_offset = find(hold_diff ==-1);
%     if hold_binary(end) == 1
%         hold_offset = [hold_offset length(hold_binary)];
%     end
    index_hold_onset = [];
    index_hold_offset = [];
    hold_offset(hold_offset<hold_duration) = [];
    for m = 1:length(hold_offset)
        if max(radial_pos(hold_offset(m)-hold_duration-1:hold_offset(m)-1)) < hold_threshold ...
                && angle_js(hold_offset(m)) > angle_min && angle_js(hold_offset(m)) < angle_max
            index_hold_offset = [index_hold_offset hold_offset(m)];
            index_hold_onset_temp = hold_onset - hold_offset(m);
            index_hold_onset_temp(index_hold_onset_temp>0) = []; % remove hold onset that occurs after a given hold offset
            [~,loc] = max(index_hold_onset_temp);
            index_hold_onset = [index_hold_onset hold_onset(loc)];
        end           
    end
    
    figure()
    ax1 = subplot(4,1,1);
    plot(time,radial_pos,'LineWidth',2,'color',[45 49 66]/255)
    hold on 
    yline(hold_threshold,'--','color','k','LineWidth',2)
    yline(outer_threshold,'--','color','k','LineWidth',2)
    yline(max_distance,'--','color','k','LineWidth',2)
    
    for n = 1:size(jstruct(i).trial_live,1)
        plot(time(jstruct(i).trial_live(n,1):jstruct(i).trial_live(n,2)),radial_pos(jstruct(i).trial_live(n,1):jstruct(i).trial_live(n,2)),'LineWidth',2,'color',[204 45 53]/255)
    end
    for n = 1:length(index_hold_onset)
        plot(time(index_hold_onset(n):index_hold_offset(n)),radial_pos(index_hold_onset(n):index_hold_offset(n)),'LineWidth',2,'color',[225 218 174]/255)
    end
    
    ax2 = subplot(4,1,2);
    plot(time,js_r_contact,'LineWidth',2,'color',[45 49 66]/255)
    ylim([-0.05 1.05])
    ax3 = subplot(4,1,3);
    plot(time,js_l_contact,'LineWidth',2,'color',[45 49 66]/255)
    ylim([-0.05 1.05])
    ax4 = subplot(4,1,4);
    plot(time,reward,'LineWidth',2,'color',[45 49 66]/255)
    ylim([-0.05 1.05])
    linkaxes([ax1 ax2 ax3 ax4],'x')
   
    
    for n = 1:length(index_hold_offset)
        hold_duration_trial = index_hold_offset(n)-index_hold_onset(n);
        if index_hold_offset(n)-buffer_length < 0
            js_reach(trial_count).x_traj = x_filt(1:index_hold_offset(n)+recording_length-1);
            js_reach(trial_count).y_traj = y_filt(1:index_hold_offset(n)+recording_length-1);
            js_reach(trial_count).radial_pos = radial_pos(1:index_hold_offset(n)+recording_length-1);
            js_reach(trial_count).angle_js = angle_js(1:index_hold_offset(n)+recording_length-1);
            js_reach(trial_count).trigger = index_hold_offset(n);
            if any(reward(1:index_hold_offset(n)+recording_length-1))
                js_reach(trial_count).reward_flag = 1;
                js_reach(trial_count).reward_idx = find(reward(index_hold_offset(n)-buffer_length+1:index_hold_offset(n)+recording_length)==1);              
                reward_count = reward_count + 1;
            else
                js_reach(trial_count).reward_flag = 0;
            end       
        elseif length(x_filt)-index_hold_offset(n)<recording_length
            js_reach(trial_count).x_traj = x_filt(index_hold_offset(n)-buffer_length+1:end);
            js_reach(trial_count).y_traj = y_filt(index_hold_offset(n)-buffer_length+1:end);
            js_reach(trial_count).radial_pos = radial_pos(index_hold_offset(n)-buffer_length+1:end);
            js_reach(trial_count).angle_js = angle_js(index_hold_offset(n)-buffer_length+1:end);
            js_reach(trial_count).trigger = buffer_length;
            if any(reward(index_hold_offset(n)-buffer_length+1:end))
                js_reach(trial_count).reward_flag = 1;
                js_reach(trial_count).reward_idx = find(reward(index_hold_offset(n)-buffer_length+1:index_hold_offset(n)+recording_length)==1);              
                reward_count = reward_count + 1;
            else
                js_reach(trial_count).reward_flag = 0;
            end       
        else
            js_reach(trial_count).x_traj = x_filt(index_hold_offset(n)-buffer_length+1:index_hold_offset(n)+recording_length);
            js_reach(trial_count).y_traj = x_filt(index_hold_offset(n)-buffer_length+1:index_hold_offset(n)+recording_length);
            js_reach(trial_count).radial_pos = radial_pos(index_hold_offset(n)-buffer_length+1:index_hold_offset(n)+recording_length);
            js_reach(trial_count).angle_js = angle_js(index_hold_offset(n)-buffer_length+1:index_hold_offset(n)+recording_length);
            js_reach(trial_count).trigger = buffer_length;
            if any(reward(index_hold_offset(n)-buffer_length+1:index_hold_offset(n)+recording_length))
                js_reach(trial_count).reward_flag = 1;
                js_reach(trial_count).reward_idx = find(reward(index_hold_offset(n)-buffer_length+1:index_hold_offset(n)+recording_length)==1);              
                reward_count = reward_count + 1;
            else
                js_reach(trial_count).reward_flag = 0;
            end            
        end
        trial_count = trial_count+1;
    end
end

cd([data_folder mouse_ID '\' data_ID])
save('js_reach','js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
