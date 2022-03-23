close all
clear all
clc



data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN04';

target_hold_duration_all = [];
hold_still_duration_all = [];
reach_duration_all = [];
path_length_all = [];
peak_velocity_all = [];

for i = 1:8
    if i == 1
       data_ID = '030922_63_79_020_10000_020_016_030_150_030_150_000';
    elseif i == 2
        data_ID = '031022_63_79_020_10000_020_016_030_150_030_150_000';
    elseif i == 3
        data_ID = '031122_63_79_020_10000_020_016_030_150_030_150_000';
    elseif i == 4
        data_ID = '031422_63_79_020_10000_020_016_030_150_030_150_000';
    elseif i == 5
        data_ID = '031522_63_79_020_10000_020_016_030_150_030_150_000';
    elseif i == 6
        data_ID = '031622_63_79_020_10000_020_016_030_150_030_150_000';
    elseif i == 7
        data_ID = '031722_63_79_020_10000_020_016_030_150_030_150_000';
    elseif i == 8
        data_ID = '031822_63_79_020_10000_020_016_030_150_030_150_000';
    end

condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
load('hold_still_duration')
load('target_hold_duration')
load('reach_duration')
load('peak_velocity')
load('path_length')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
nTrial = length(js_reach);

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});
angle_1 = str2double(condition_array{8})/180*pi;
angle_2 = str2double(condition_array{9})/180*pi;

idx = find(reach_duration<100);


target_hold_duration_all = [target_hold_duration_all target_hold_duration(idx)];
hold_still_duration_all = [hold_still_duration_all hold_still_duration(idx)];
reach_duration_all = [reach_duration_all reach_duration(idx)];
path_lengt_allh = [path_length_all path_length(idx)];
peak_velocity_all = [peak_velocity_all peak_velocity(idx)];


end

figure(1)
histogram(peak_velocity_all,50:5:200)