close all
clear all
clc


data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\';
mouse_ID = 'AN06';
data_ID = '040122';

cd([data_folder mouse_ID '\' data_ID ,'_v5'])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis')

trial = 18;

time_vec = [491 914 1009 1044 1088];
figure()
plot3(data(trial).shoulder_mat(1,time_vec),data(trial).shoulder_mat(3,time_vec),data(trial).shoulder_mat(2,time_vec),'o')
hold on 
plot3(data(trial).elbow_mat(1,time_vec),data(trial).elbow_mat(3,time_vec),data(trial).elbow_mat(2,time_vec),'o')
plot3(data(trial).wrist_mat(1,time_vec),data(trial).wrist_mat(3,time_vec),data(trial).wrist_mat(2,time_vec),'o')
plot3(data(trial).hand_mat(1,time_vec),data(trial).hand_mat(3,time_vec),data(trial).hand_mat(2,time_vec),'o')
plot3(data(trial).joystick_mat(1,time_vec),data(trial).joystick_mat(3,time_vec),data(trial).joystick_mat(2,time_vec),'o')
plot3([data(trial).shoulder_mat(1,time_vec(1)) data(trial).elbow_mat(1,time_vec(1))],[data(trial).shoulder_mat(3,time_vec(1)) data(trial).elbow_mat(3,time_vec(1))],[data(trial).shoulder_mat(3,time_vec(1)) data(trial).elbow_mat(3,time_vec(1))])
xlabel('Anterior-posterior (mm)')
ylabel('Medial-lateral (mm)')
zlabel('Superior-inferior (mm)')
