clear all
close all
clc

data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data';
code_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis';

Fs = 200;

filename_cam1 = 'M_012121_CT_102121_v2_1_16-47-57_cam1DLC_resnet_50_JoystickOct23shuffle1_50000';
filename_cam2 = 'M_012121_CT_102121_v2_1_16-47-57_cam2DLC_resnet_50_JoystickOct23shuffle1_50000';

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
hand_x = data_cam1(:,11);
hand_y = data_cam1(:,12);

x1 =  elbow_x-shoulder_x;
y1 =  elbow_y-shoulder_y;
upper_length = sqrt(x1.^2+y1.^2);
x2 =  wrist_x-elbow_x;
y2 =  wrist_y-elbow_y;
fore_length = sqrt(x2.^2+y2.^2);
elbow_angle_cam1 = 180+atan2d(x1.*y2-y1.*x2,x1.*x2+y1.*y2);
x3 =  hand_x-wrist_x;
y3 =  hand_y-wrist_y;
wrist_angle_cam1 = 180+atan2d(x2.*y3-y2.*x3,x2.*x3+y2.*y3);

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

elbow_angle_cam2 = 180+atan2d(x1.*y2-y1.*x2,x1.*x2+y1.*y2);

figure(1)
subplot(2,1,1)
plot(time,elbow_angle_cam1,'LineWidth',1)
hold on 
plot(time,elbow_angle_cam2,'LineWidth',1)
xline(0.5,'--','LineWidth',1,'color','k')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,1,2)
plot(time,wrist_angle_cam1,'LineWidth',1)
xline(0.5,'--','LineWidth',1,'color','k')
set(gca,'TickDir','out')
set(gca,'box','off')


figure(2)
h1 = axes;
plot(shoulder_x,shoulder_y,'o','LineWidth',1)
hold on 
plot(elbow_x,elbow_y,'o','LineWidth',1)
plot(wrist_x,wrist_y,'o','LineWidth',1)
set(h1, 'Ydir', 'reverse')
set(gca,'TickDir','out')
set(gca,'box','off')

figure(3)
h2 = axes;
for i = 1 %:10:length(time)

plot([shoulder_x(i) elbow_x(i) wrist_x(i)],[shoulder_y(i) elbow_y(i) wrist_y(i)],'color','k','LineWidth',1)
hold on 
plot(shoulder_x(i),shoulder_y(i),'o','color','b','LineWidth',1)
plot(elbow_x(i),elbow_y(i),'o','color','r','LineWidth',1)
plot(wrist_x(i),wrist_y(i),'o','color','m','LineWidth',1)
end
set(h2, 'Ydir', 'reverse')
set(gca,'TickDir','out')
set(gca,'box','off')
axis equal