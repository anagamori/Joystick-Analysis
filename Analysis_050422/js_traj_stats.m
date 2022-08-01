% Last update: 6/24/22
% Descriptions:
%--------------------------------------------------------------------------

close all
clear all
clc

data_folder = 'F:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN639';
data_ID = '072922_63_79_010_0070_200_031_000_180_000_180_000';
condition_array = strsplit(data_ID,'_');

pltOpt = 1;

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422')

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
target_duration = str2double(condition_array{4});
trial_duration = str2double(condition_array{5});
angle_min = str2double(condition_array{8});
angle_max = str2double(condition_array{9});
reach_threshold = 31/100*6.35;

theta = 0:0.01:2*pi;

hold_duration_trial_success = [];
target_duration_trial_success = [];
path_length_success = [];
straightness_success = [];
reach_duration_trial_success = [];
peak_speed_success = [];

target_duration_trial_fail = [];
path_length_fail = [];
straightness_fail = [];
reach_duration_trial_fail = [];
peak_speed_fail = [];

for i = 1:length(js_reach)
    if js_reach(i).reward_flag == 1
        hold_duration_trial_success = [hold_duration_trial_success js_reach(i).hold_duration_trial];
       target_duration_trial_success = [target_duration_trial_success js_reach(i).target_duration_trial];
       path_length_success = [path_length_success js_reach(i).path_length];
       straightness_success = [straightness_success js_reach(i).straightness];
       reach_duration_trial_success = [reach_duration_trial_success js_reach(i).reach_duration_trial];
       peak_speed_success = [peak_speed_success js_reach(i).peak_speed];
    else
       target_duration_trial_fail = [target_duration_trial_fail js_reach(i).target_duration_trial];
       path_length_fail = [path_length_fail js_reach(i).path_length];
       straightness_fail = [straightness_fail js_reach(i).straightness];
       reach_duration_trial_fail = [reach_duration_trial_fail js_reach(i).reach_duration_trial];
       peak_speed_fail = [peak_speed_fail js_reach(i).peak_speed];
    end
end

figure(1)
histogram(target_duration_trial_success,0:10:150)
hold on 
title('Target Duration')
%histogram(target_duration_trial_fail,0:10:150)

figure(2)
histogram(path_length_success,3:0.05:4)
hold on 
%histogram(path_length_fail)

figure(3)
histogram(straightness_success,.7:0.05:1)
hold on 
%histogram(straightness_fail)

figure(4)
histogram(reach_duration_trial_success,0:10:160)
hold on 
title('Reach Duration')
%histogram(reach_duration_trial_fail,0:10:160)


figure(5)
histogram(peak_speed_success,50:10:250)
hold on 
title('Peak Speed')
%histogram(peak_speed_fail)

figure(6)
histogram(hold_duration_trial_success,0:10:500)
hold on 
title('Hold Duration')
