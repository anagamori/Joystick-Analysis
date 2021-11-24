close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_F_081921_CT_EMG_2'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '110621_60_80_050_0300_010_010_000_360_000_360_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
nTrial = length(js_reach);

for i = 1:nTrial
   if  js_reach(i).n_vel_peak_1 == 1
       figure(1)
       plot(js_reach(i).radial_pos(js_reach(i).reach_start_time:js_reach(i).reach_end_time))
       hold on 
   end
end

