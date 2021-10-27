clear all
close all
clc

data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data';
code_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis';

Fs = 200;

filename_cam1 = 'F_102320_CT_102221_1_14-05-59_cam1DLC_resnet_50_JoystickOct23shuffle1_50000';
filename_cam2 = 'F_102320_CT_102221_1_14-05-59_cam2DLC_resnet_50_JoystickOct23shuffle1_50000';

cd(data_folder)
data_cam1 = readmatrix(filename_cam1);
data_cam2 = readmatrix(filename_cam2);
cd(code_folder)

sample = data_cam1(:,1);
time = [1:length(sample)]./Fs;


shoulder_x = data_cam1(:,2);
shoulder_y = data_cam1(:,3);
elbow_x = data_cam1(:,5);
elbow_y = data_cam1(:,6);
wrist_x = data_cam1(:,8);
wrist_y = data_cam1(:,9);

x1 =  elbow_x-shoulder_x;
y1 =  elbow_y-shoulder_y;
x2 =  wrist_x-elbow_x;
y2 =  wrist_y-elbow_y;

elbow_angle_cam1 = atan2d(x1.*y2-y1.*x2,x1.*x2+y1.*y2);

shoulder_x = data_cam2(:,2);
shoulder_y = data_cam2(:,3);
elbow_x = data_cam2(:,5);
elbow_y = data_cam2(:,6);
wrist_x = data_cam2(:,8);
wrist_y = data_cam2(:,9);

x1 =  elbow_x-shoulder_x;
y1 =  elbow_y-shoulder_y;
x2 =  wrist_x-elbow_x;
y2 =  wrist_y-elbow_y;

elbow_angle_cam2 = atan2d(x1.*y2-y1.*x2,x1.*x2+y1.*y2);

figure(1)
plot(time,elbow_angle_cam1,'LineWidth',1)
hold on 
plot(time,elbow_angle_cam2,'LineWidth',1)
xline(1,'--','LineWidth',1,'color','k')
set(gca,'TickDir','out')
set(gca,'box','off')