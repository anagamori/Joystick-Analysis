close all
clear all
clc

%%C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\AN06
data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\';
mouse_ID = 'AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_v3';

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
    data(trialN).shoulder_x = temp.Shoulder_x;
    data(trialN).shoulder_y = temp.Shoulder_y;
    data(trialN).shoulder_z = temp.Shoulder_z;
    data(trialN).shoulder_score = temp.Shoulder_score;
    data(trialN).elbow_x = temp.Elbow_x;
    data(trialN).elbow_y = temp.Elbow_y;
    data(trialN).elbow_z = temp.Elbow_z;
    data(trialN).elbow_score = temp.Elbow_score;
    data(trialN).wrist_x = temp.Wrist_x;
    data(trialN).wrist_y = temp.Wrist_y;
    data(trialN).wrist_z = temp.Wrist_z;
    data(trialN).wrist_score = temp.Wrist_score;
    data(trialN).hand_x = temp.Hand_x;
    data(trialN).hand_y = temp.Hand_y;
    data(trialN).hand_z = temp.Hand_z;
    data(trialN).hand_score = temp.Hand_score;
    data(trialN).joystick_x = temp.Joystick_x;
    data(trialN).joystick_y = temp.Joystick_y;
    data(trialN).joystick_z = temp.Joystick_z;
    data(trialN).joystick_score = temp.Joystick_score;
    
end

cd([data_folder  mouse_ID '\' data_ID])
save('data','data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis')