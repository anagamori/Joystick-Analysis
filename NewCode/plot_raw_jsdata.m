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
mouse_ID = 'Box_4_AN08'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040722_47_79_010_10000_100_016_030_150_030_150_000';
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

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',200,'PassbandRipple',0.01, ...
    'SampleRate',Fs);

lpFilt2 = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.01, ...
    'SampleRate',Fs);

index_reward = [];
time_reward = [];
n_reward = 0;
index_validTrial = [];


for i = 1 %:nTrial
    js_r_contact = zeros(1,length(jstruct(i).traj_x));
    js_l_contact = zeros(1,length(jstruct(i).traj_x));
    reward = zeros(1,length(jstruct(i).traj_x));
    for j = 1:length(jstruct(i).js_pairs_r)
        js_r_contact(jstruct(i).js_pairs_r(j,1):jstruct(i).js_pairs_r(j,2)) = 1;
    end
    for k = 1:length(jstruct(i).js_pairs_l)
        js_l_contact(jstruct(i).js_pairs_l(k,1):jstruct(i).js_pairs_l(k,2)) = 1;
    end
    reward(jstruct(i).reward_onset) = 1;
    x_filt =  filtfilt(lpFilt,jstruct(i).traj_x/100*6.35);
    y_filt = filtfilt(lpFilt,jstruct(i).traj_y/100*6.35);
    radial_pos = sqrt(x_filt.^2+y_filt.^2);
    angle_js = atan2d(y_filt,x_filt);
    angle_js = angle_js + (angle_js < 0)*360;
    
    hold_binary = zeros(1,length(jstruct(i).traj_x));
    hold_binary(radial_pos<hold_threshold) = 1;
    hold_diff = [0 diff(hold_binary)]; 
    hold_onset = find(hold_diff ==1);
    hold_offset = find(hold_diff ==-1);
    index_hold = zeros(1,length(hold_offset));
     
    for m = 1:length(hold_offset)
        if max(radial_pos(hold_offset(m)-hold_duration-1:hold_offset(m)-1)) < hold_threshold ...
                && angle_js(hold_offset(m)) > angle_min && angle_js(hold_offset(m)) < angle_max
            index_hold(m) = 1;
        end           
    end
    
    figure(1)
    ax1 = subplot(4,1,1);
    plot(radial_pos,'LineWidth',2,'color',[45 49 66]/255)
    yline(hold_threshold,'--','color','k','LineWidth',2)
    yline(outer_threshold,'color','g','LineWidth',2)
    yline(max_distance,'color','g','LineWidth',2)
    ax2 = subplot(4,1,2);
    plot(js_r_contact,'LineWidth',2,'color',[45 49 66]/255)
    ylim([-0.05 1.05])
    ax3 = subplot(4,1,3);
    plot(js_l_contact,'LineWidth',2,'color',[45 49 66]/255)
    ylim([-0.05 1.05])
    ax4 = subplot(4,1,4);
    plot(reward,'LineWidth',2,'color',[45 49 66]/255)
    ylim([-0.05 1.05])
    linkaxes([ax1 ax2 ax3 ax4],'x')
end