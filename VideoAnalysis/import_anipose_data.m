close all
clear all
clc

%%C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\AN06
data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\';
mouse_ID = 'AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_v4';

cd([data_folder mouse_ID '\' data_ID '\angles'])
files_angles = dir('*.csv');

Fs = 1000;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.01, ...
    'SampleRate',Fs);

for i = 1:length(files_angles)
    file_name = strsplit(files_angles(i).name,'_');    
    trialN = str2num(file_name{3});
    temp = readtable(files_angles(i).name);
    data(trialN).elbow_angle = filtfilt(lpFilt,interp(temp.elbow_flex,5));
    data(trialN).wrist_angle = filtfilt(lpFilt,interp(temp.Wrist_flex,5));
    
end

cd([data_folder mouse_ID '\' data_ID '\pose-3d'])
files_pose_3d = dir('*.csv');

for i = 1:length(files_pose_3d)
    file_name = strsplit(files_pose_3d(i).name,'_');    
    trialN = str2num(file_name{3});
    temp = readtable(files_pose_3d(i).name);
    data(trialN).shoulder_x = filtfilt(lpFilt,interp(temp.Shoulder_x,5));
    data(trialN).shoulder_y = filtfilt(lpFilt,interp(temp.Shoulder_y,5));
    data(trialN).shoulder_z = filtfilt(lpFilt,interp(temp.Shoulder_z,5));
    data(trialN).shoulder_score = temp.Shoulder_score;
    data(trialN).elbow_x = filtfilt(lpFilt,interp(temp.Elbow_x,5));
    data(trialN).elbow_y = filtfilt(lpFilt,interp(temp.Elbow_y,5));
    data(trialN).elbow_z = filtfilt(lpFilt,interp(temp.Elbow_z,5));
    data(trialN).elbow_score = temp.Elbow_score;
    data(trialN).wrist_x = filtfilt(lpFilt,interp(temp.Wrist_x,5));
    data(trialN).wrist_y = filtfilt(lpFilt,interp(temp.Wrist_y,5));
    data(trialN).wrist_z = filtfilt(lpFilt,interp(temp.Wrist_z,5));
    data(trialN).wrist_score = temp.Wrist_score;
    data(trialN).hand_x = filtfilt(lpFilt,interp(temp.Hand_x,5));
    data(trialN).hand_y = filtfilt(lpFilt,interp(temp.Hand_y,5));
    data(trialN).hand_z = filtfilt(lpFilt,interp(temp.Hand_z,5));
    data(trialN).hand_score = temp.Hand_score;
    data(trialN).joystick_x = interp(temp.Joystick_x,5);
    data(trialN).joystick_y = interp(temp.Joystick_y,5);
    data(trialN).joystick_z = interp(temp.Joystick_z,5);
    data(trialN).joystick_score = temp.Joystick_score;
    
end

cd([data_folder  mouse_ID '\' data_ID])
save('data','data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis')