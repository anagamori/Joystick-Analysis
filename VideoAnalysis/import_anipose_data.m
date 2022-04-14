close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122';

cd([data_folder mouse_ID '\' data_ID '\angles'])
files_angles = dir('*.csv');

for i = 1:length(files_angles)
    file_name = strsplit(files_angles(i).name,'_');    
    trialN = str2num(file_name{3});
    temp = readtable(files_angles(i).name);
    data(trialN).elbow_angle = temp.elbow_flex;
    data(trialN).wrist_angle = temp.Wrist_flex;
    
end

cd([data_folder mouse_ID '\' data_ID '\pose-3d'])
files_pose_3d = dir('*.csv');

for i = 1:length(files_pose_3d)
    file_name = strsplit(files_pose_3d(i).name,'_');    
    trialN = str2num(file_name{3});
    temp = readtable(files_pose_3d(i).name);
    data(trialN).Shoulder_x = temp.Shoulder_x;
    data(trialN).Shoulder_y = temp.Shoulder_y;
    data(trialN).Shoulder_z = temp.Shoulder_z;
    data(trialN).Shoulder_score = temp.Shoulder_score;
    data(trialN).Elbow_x = temp.Elbow_x;
    data(trialN).Elbow_y = temp.Elbow_y;
    data(trialN).Elbow_z = temp.Elbow_z;
    data(trialN).Elbow_score = temp.Elbow_score;
    data(trialN).Wrist_x = temp.Wrist_x;
    data(trialN).Wrist_y = temp.Wrist_y;
    data(trialN).Wrist_z = temp.Wrist_z;
    data(trialN).Wrist_score = temp.Wrist_score;
    data(trialN).Hand_x = temp.Hand_x;
    data(trialN).Hand_y = temp.Hand_y;
    data(trialN).Hand_z = temp.Hand_z;
    data(trialN).Hand_score = temp.Hand_score;
    data(trialN).Joystick_x = temp.Joystick_x;
    data(trialN).Joystick_y = temp.Joystick_y;
    data(trialN).Joystick_z = temp.Joystick_z;
    data(trialN).Joystick_score = temp.Joystick_score;
    
end

cd([data_folder  mouse_ID '\' data_ID])
save('data','data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis')